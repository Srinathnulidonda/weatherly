const API_BASE_URL = 'https://weatherly-app-bp4c.onrender.com';

const weatherAnimations = new WeatherAnimations();
let currentCity = null;
let currentWeatherData = null;
let updateInterval = null;
let theme = localStorage.getItem('theme') || 'dark';

const elements = {
    searchInput: document.getElementById('searchInput'),
    locationBtn: document.getElementById('locationBtn'),
    refreshBtn: document.getElementById('refreshBtn'),
    themeBtn: document.getElementById('themeBtn'),
    retryBtn: document.getElementById('retryBtn'),
    loader: document.getElementById('loader'),
    errorContainer: document.getElementById('errorContainer'),
    weatherContainer: document.getElementById('weatherContainer'),
    quickCities: document.getElementById('quickCities')
};

const defaultCities = ['New York', 'London', 'Tokyo', 'Mumbai', 'Paris', 'Sydney', 'Dubai', 'Singapore'];

function init() {
    applyTheme();
    renderQuickCities();
    bindEvents();
    updateDateTime();
    setInterval(updateDateTime, 60000);

    const lastCity = localStorage.getItem('lastCity');
    if (lastCity) {
        fetchWeather(lastCity);
    } else {
        getCurrentLocation();
    }
}

function bindEvents() {
    elements.searchInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') handleSearch();
    });

    elements.locationBtn.addEventListener('click', getCurrentLocation);
    elements.refreshBtn.addEventListener('click', handleRefresh);
    elements.themeBtn.addEventListener('click', toggleTheme);
    elements.retryBtn.addEventListener('click', () => {
        if (currentCity) fetchWeather(currentCity);
    });
}

function renderQuickCities() {
    elements.quickCities.innerHTML = defaultCities
        .map(city => `<span class="city-chip" onclick="fetchWeather('${city}')">${city}</span>`)
        .join('');
}

function handleSearch() {
    const city = elements.searchInput.value.trim();
    if (city) {
        fetchWeather(city);
        elements.searchInput.value = '';
    }
}

function handleRefresh() {
    if (currentCity) {
        fetchWeather(currentCity);
        showNotification('Weather updated!', 'success');
    }
}

function toggleTheme() {
    theme = theme === 'dark' ? 'light' : 'dark';
    applyTheme();
    localStorage.setItem('theme', theme);
}

function applyTheme() {
    document.documentElement.setAttribute('data-theme', theme);
    const icon = elements.themeBtn.querySelector('i');
    icon.className = theme === 'dark' ? 'bi bi-moon-fill' : 'bi bi-sun-fill';
}

function getCurrentLocation() {
    if (!navigator.geolocation) {
        showError('Geolocation is not supported by your browser');
        return;
    }

    showLoader();
    navigator.geolocation.getCurrentPosition(
        position => {
            const { latitude, longitude } = position.coords;
            fetchWeatherByCoords(latitude, longitude);
        },
        error => {
            showError('Unable to retrieve your location. Please search manually.');
        },
        { enableHighAccuracy: true, timeout: 10000 }
    );
}

async function fetchWeather(city) {
    showLoader();
    try {
        const response = await fetch(`${API_BASE_URL}/api/v1/weather/${city}`);
        const result = await response.json();

        if (!result.success) {
            throw new Error(result.error?.message || 'Failed to fetch weather');
        }

        currentCity = city;
        currentWeatherData = result.data;
        localStorage.setItem('lastCity', city);

        displayWeather(result.data);
        await fetchForecast(city);

        startAutoUpdate();
    } catch (error) {
        showError(error.message);
    }
}

async function fetchWeatherByCoords(lat, lon) {
    showLoader();
    try {
        const response = await fetch(`${API_BASE_URL}/api/v1/weather/coordinates?lat=${lat}&lon=${lon}`);
        const result = await response.json();

        if (!result.success) {
            throw new Error(result.error?.message || 'Failed to fetch weather');
        }

        currentCity = result.data.city;
        currentWeatherData = result.data;

        displayWeather(result.data);
        await fetchForecast(result.data.city);

        startAutoUpdate();
    } catch (error) {
        showError(error.message);
    }
}

async function fetchForecast(city) {
    try {
        const response = await fetch(`${API_BASE_URL}/api/v1/forecast/${city}`);
        const result = await response.json();

        if (result.success) {
            displayForecast(result.data.forecast);
        }
    } catch (error) {
        console.error('Failed to fetch forecast:', error);
    }
}

function displayWeather(data) {
    updateTheme(data.weather.icon);
    weatherAnimations.startAnimation(data);

    document.getElementById('cityName').textContent = `${data.city}, ${data.country}`;
    document.getElementById('coordinates').textContent = `${data.coordinates.latitude.toFixed(2)}°, ${data.coordinates.longitude.toFixed(2)}°`;
    document.getElementById('temperature').textContent = data.temperature.current;
    document.getElementById('tempMin').textContent = data.temperature.min;
    document.getElementById('tempMax').textContent = data.temperature.max;
    document.getElementById('description').textContent = data.weather.description;
    document.getElementById('feelsLike').textContent = data.temperature.feels_like;
    document.getElementById('windSpeed').textContent = `${data.details.wind_speed} m/s`;
    document.getElementById('humidity').textContent = `${data.details.humidity}%`;
    document.getElementById('pressure').textContent = `${data.details.pressure} hPa`;
    document.getElementById('visibility').textContent = `${data.details.visibility} km`;
    document.getElementById('clouds').textContent = `${data.details.clouds}%`;
    document.getElementById('windDirection').textContent = `${getWindDirection(data.details.wind_direction)}`;
    document.getElementById('sunrise').textContent = data.sun.sunrise;
    document.getElementById('sunset').textContent = data.sun.sunset;

    const iconUrl = `https://openweathermap.org/img/wn/${data.weather.icon}@4x.png`;
    document.getElementById('weatherIcon').src = iconUrl;

    updateSunPosition(data.sun.sunrise, data.sun.sunset);

    hideLoader();
    elements.weatherContainer.classList.add('show');
}

function displayForecast(forecast) {
    const forecastGrid = document.getElementById('forecastGrid');
    forecastGrid.innerHTML = forecast.map(day => `
        <div class="forecast-card glass">
            <div class="forecast-date">${new Date(day.date).toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' })}</div>
            <div class="forecast-day">${day.day}</div>
            <img src="https://openweathermap.org/img/wn/${day.weather.icon}@2x.png" alt="${day.weather.description}" class="forecast-icon">
            <div class="forecast-temps">
                <span class="temp-high">${day.temperature.max}°</span>
                <span class="temp-low">${day.temperature.min}°</span>
            </div>
            <div class="forecast-details">
                <span><i class="bi bi-droplet-half"></i> ${day.details.humidity}%</span>
                <span><i class="bi bi-wind"></i> ${day.details.wind_speed} m/s</span>
            </div>
            <div class="forecast-description">${day.weather.description}</div>
        </div>
    `).join('');
}

function updateTheme(iconCode) {
    const body = document.body;
    body.className = '';

    const weatherMap = {
        '01': 'clear',
        '02': 'clear',
        '03': 'clouds',
        '04': 'clouds',
        '09': 'rain',
        '10': 'rain',
        '11': 'thunderstorm',
        '13': 'snow',
        '50': 'mist'
    };

    const weatherType = weatherMap[iconCode.substring(0, 2)] || 'clear';
    const timeOfDay = iconCode.includes('n') ? 'night' : 'day';

    body.classList.add(`weather-${weatherType}-${timeOfDay}`);
}

function updateSunPosition(sunrise, sunset) {
    const now = new Date();
    const sunriseTime = new Date();
    const sunsetTime = new Date();

    const [sunriseHour, sunriseMin] = sunrise.split(':');
    const [sunsetHour, sunsetMin] = sunset.split(':');

    sunriseTime.setHours(parseInt(sunriseHour), parseInt(sunriseMin));
    sunsetTime.setHours(parseInt(sunsetHour), parseInt(sunsetMin));

    const totalMinutes = (sunsetTime - sunriseTime) / 60000;
    const elapsedMinutes = (now - sunriseTime) / 60000;
    const percentage = Math.max(0, Math.min(100, (elapsedMinutes / totalMinutes) * 100));

    document.getElementById('sunPosition').style.width = `${percentage}%`;
}

function getWindDirection(degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    const index = Math.round(degrees / 45) % 8;
    return `${directions[index]} (${degrees}°)`;
}

function updateDateTime() {
    const now = new Date();
    const options = {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    };
    document.getElementById('dateTime').textContent = now.toLocaleDateString('en-US', options);
}

function startAutoUpdate() {
    if (updateInterval) clearInterval(updateInterval);
    updateInterval = setInterval(() => {
        if (currentCity) fetchWeather(currentCity);
    }, 300000);
}

function showLoader() {
    elements.loader.classList.add('show');
    elements.errorContainer.classList.remove('show');
    elements.weatherContainer.classList.remove('show');
}

function hideLoader() {
    elements.loader.classList.remove('show');
}

function showError(message) {
    document.getElementById('errorMessage').textContent = message;
    elements.errorContainer.classList.add('show');
    elements.loader.classList.remove('show');
    elements.weatherContainer.classList.remove('show');
}

function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;

    document.body.appendChild(notification);

    setTimeout(() => {
        notification.classList.add('show');
    }, 100);

    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}

window.fetchWeather = fetchWeather;

document.addEventListener('DOMContentLoaded', init);