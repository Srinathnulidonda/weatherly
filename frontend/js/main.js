const API_BASE_URL = 'https://weatherly-app-bp4c.onrender.com/api/v1';

const WeatherApp = {
    currentCity: 'London',
    currentData: null,
    forecastData: null,
    units: {
        temperature: localStorage.getItem('tempUnit') || 'metric',
        wind: localStorage.getItem('windUnit') || 'metric'
    },

    async init() {
        this.bindEvents();
        this.setupTouch();

        const lastCity = localStorage.getItem('lastCity');
        if (lastCity) {
            this.currentCity = lastCity;
            await this.loadWeatherData();
        } else {
            this.getDeviceLocation();
        }
    },

    setupTouch() {
        let touchStart = 0;
        let touchEnd = 0;

        document.addEventListener('touchstart', e => {
            touchStart = e.changedTouches[0].screenY;
        }, { passive: true });

        document.addEventListener('touchend', e => {
            touchEnd = e.changedTouches[0].screenY;
            if (touchStart - touchEnd < -100 && window.scrollY === 0) {
                this.refreshWeather();
            }
        }, { passive: true });
    },

    bindEvents() {
        document.getElementById('current-location-btn').addEventListener('click', () => {
            this.getDeviceLocation();
        });

        document.getElementById('search-toggle').addEventListener('click', () => {
            this.toggleSearch();
        });

        document.getElementById('search-close').addEventListener('click', () => {
            this.toggleSearch();
        });

        const searchInput = document.getElementById('location-search');
        let searchTimeout;

        searchInput.addEventListener('input', e => {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(() => this.handleSearch(e.target.value), 300);
        });

        searchInput.addEventListener('keypress', e => {
            if (e.key === 'Enter') {
                e.preventDefault();
                this.searchLocation(e.target.value);
            }
        });
    },

    async loadWeatherData(city = this.currentCity) {
        try {
            this.showLoading();

            const [weatherResponse, forecastResponse] = await Promise.all([
                fetch(`${API_BASE_URL}/weather/${encodeURIComponent(city)}`),
                fetch(`${API_BASE_URL}/forecast/${encodeURIComponent(city)}`)
            ]);

            if (!weatherResponse.ok || !forecastResponse.ok) {
                throw new Error('Unable to fetch weather data');
            }

            const weatherData = await weatherResponse.json();
            const forecastData = await forecastResponse.json();

            this.currentData = weatherData.data;
            this.forecastData = forecastData.data;
            this.currentCity = this.currentData.city;

            localStorage.setItem('lastCity', this.currentCity);
            document.getElementById('location-text').textContent =
                `${this.currentData.city}, ${this.currentData.country}`;

            this.updateUI();
            this.showContent();

            if ('vibrate' in navigator) {
                navigator.vibrate(10);
            }

        } catch (error) {
            this.showError(error.message);
        }
    },

    async getDeviceLocation() {
        const btn = document.getElementById('current-location-btn');
        const originalHTML = btn.innerHTML;
        btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Getting location...';
        btn.disabled = true;

        try {
            const position = await new Promise((resolve, reject) => {
                navigator.geolocation.getCurrentPosition(resolve, reject, {
                    enableHighAccuracy: true,
                    timeout: 10000,
                    maximumAge: 0
                });
            });

            const { latitude, longitude } = position.coords;
            const response = await fetch(
                `${API_BASE_URL}/weather/coordinates?lat=${latitude}&lon=${longitude}`
            );

            if (!response.ok) {
                throw new Error('Unable to get weather for your location');
            }

            const data = await response.json();
            await this.loadWeatherData(data.data.city);

        } catch (error) {
            this.showError('Unable to get your location');
        } finally {
            btn.innerHTML = originalHTML;
            btn.disabled = false;
        }
    },

    updateUI() {
        if (!this.currentData) return;

        const theme = ThemeEngine.applyTheme(
            this.currentData.weather.main,
            this.currentData.weather.description
        );
        WeatherAnimations.startAnimation(theme.weatherCategory);

        const iconEl = document.getElementById('weather-icon');
        iconEl.src = `https://openweathermap.org/img/wn/${this.currentData.weather.icon}@2x.png`;
        iconEl.alt = this.currentData.weather.description;

        document.getElementById('current-temp').textContent =
            Math.round(this.convertTemperature(this.currentData.temperature.current));
        document.getElementById('weather-desc').textContent =
            this.currentData.weather.description;
        document.getElementById('temp-high').textContent =
            Math.round(this.convertTemperature(this.currentData.temperature.max)) + '°';
        document.getElementById('temp-low').textContent =
            Math.round(this.convertTemperature(this.currentData.temperature.min)) + '°';

        const rainChance = this.currentData.weather.main.toLowerCase().includes('rain') ?
            Math.floor(Math.random() * 50 + 50) : Math.floor(Math.random() * 30);
        document.getElementById('rain-chance').textContent = rainChance + '%';

        this.updateDetails();
        this.updateHourlyForecast();
        this.updateDailyForecast();
    },

    updateDetails() {
        const details = this.currentData.details;
        const windSpeed = this.convertWindSpeed(details.wind_speed);

        document.getElementById('wind-speed').textContent =
            `${Math.round(windSpeed)} ${this.units.wind === 'imperial' ? 'mph' : 'km/h'}`;
        document.getElementById('humidity').textContent = details.humidity;
        document.getElementById('visibility').textContent = details.visibility;
        document.getElementById('pressure').textContent = details.pressure;
        document.getElementById('uv-index').textContent = Math.floor(Math.random() * 11);
        document.getElementById('sunrise').textContent = this.currentData.sun.sunrise;
    },

    updateHourlyForecast() {
        const container = document.getElementById('hourly-forecast');
        container.innerHTML = '';

        for (let i = 0; i < 24; i++) {
            const hour = new Date();
            hour.setHours(hour.getHours() + i);

            const temp = this.currentData.temperature.current +
                (Math.random() * 10 - 5) * Math.sin(i / 4);

            const hourItem = document.createElement('div');
            hourItem.className = 'hourly-item';
            hourItem.innerHTML = `
                <div class="hourly-time">${i === 0 ? 'Now' : this.formatHour(hour)}</div>
                <img src="https://openweathermap.org/img/wn/${this.currentData.weather.icon}@2x.png" 
                     class="hourly-icon">
                <div class="hourly-temp">${Math.round(this.convertTemperature(temp))}°</div>
            `;
            container.appendChild(hourItem);
        }
    },

    updateDailyForecast() {
        const container = document.getElementById('daily-forecast');
        container.innerHTML = '';

        if (this.forecastData && this.forecastData.forecast) {
            this.forecastData.forecast.forEach((day, index) => {
                const dayItem = document.createElement('div');
                dayItem.className = 'daily-item';
                dayItem.innerHTML = `
                    <div class="day-info">
                        <div class="day-name">${index === 0 ? 'Today' : day.day}</div>
                        <div class="day-date">${this.formatDate(day.date)}</div>
                    </div>
                    <div class="weather-summary">
                        <img src="https://openweathermap.org/img/wn/${day.weather.icon}@2x.png" 
                             class="daily-icon">
                    </div>
                    <div class="temp-range-display">
                        <span class="temp-max">
                            ${Math.round(this.convertTemperature(day.temperature.max))}°
                        </span>
                        <span class="temp-min">
                            ${Math.round(this.convertTemperature(day.temperature.min))}°
                        </span>
                    </div>
                `;
                container.appendChild(dayItem);
            });
        }
    },

    handleSearch(query) {
        const suggestions = document.getElementById('search-suggestions');

        if (query.length < 2) {
            suggestions.innerHTML = '';
            return;
        }

        const cities = [
            'New York, US', 'London, UK', 'Tokyo, JP', 'Paris, FR',
            'Sydney, AU', 'Mumbai, IN', 'Dubai, AE', 'Singapore, SG'
        ].filter(city => city.toLowerCase().includes(query.toLowerCase()));

        suggestions.innerHTML = cities.map(city => `
            <div class="search-suggestion" onclick="WeatherApp.searchLocation('${city.split(',')[0]}')">
                <i class="fas fa-location-dot me-2"></i>${city}
            </div>
        `).join('');
    },

    async searchLocation(city) {
        if (!city || city.trim() === '') return;
        this.toggleSearch();
        await this.loadWeatherData(city.trim());
    },

    toggleSearch() {
        const overlay = document.getElementById('search-overlay');
        const searchInput = document.getElementById('location-search');

        overlay.classList.toggle('active');

        if (overlay.classList.contains('active')) {
            searchInput.focus();
        } else {
            searchInput.value = '';
            document.getElementById('search-suggestions').innerHTML = '';
        }
    },

    convertTemperature(temp) {
        return this.units.temperature === 'imperial' ? (temp * 9 / 5) + 32 : temp;
    },

    convertWindSpeed(speed) {
        return this.units.wind === 'imperial' ? speed * 2.237 : speed * 3.6;
    },

    formatHour(date) {
        return date.toLocaleTimeString('en-US', { hour: 'numeric', hour12: true });
    },

    formatDate(dateString) {
        const date = new Date(dateString);
        return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    },

    async refreshWeather() {
        const content = document.querySelector('.weather-content');
        if (content) {
            content.style.opacity = '0.7';
        }

        await this.loadWeatherData();

        if (content) {
            content.style.opacity = '1';
        }
    },

    showLoading() {
        document.getElementById('loading-state').classList.remove('d-none');
        document.getElementById('error-state').classList.add('d-none');
        document.getElementById('weather-content').classList.add('d-none');
    },

    showContent() {
        document.getElementById('loading-state').classList.add('d-none');
        document.getElementById('error-state').classList.add('d-none');
        document.getElementById('weather-content').classList.remove('d-none');
    },

    showError(message) {
        document.getElementById('loading-state').classList.add('d-none');
        document.getElementById('weather-content').classList.add('d-none');
        document.getElementById('error-state').classList.remove('d-none');
        document.getElementById('error-message').textContent = message;
    }
};

document.addEventListener('DOMContentLoaded', () => {
    WeatherApp.init();
});

window.addEventListener('offline', () => {
    WeatherApp.showError('No internet connection');
});

window.addEventListener('online', () => {
    WeatherApp.refreshWeather();
});