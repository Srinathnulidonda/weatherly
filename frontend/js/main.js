const API_BASE_URL = 'https://weatherly-app-bp4c.onrender.com/api/v1';

const WeatherApp = {
    currentCity: 'London',
    currentData: null,
    forecastData: null,
    savedLocations: [],
    recentSearches: [],
    units: {
        temperature: localStorage.getItem('tempUnit') || 'metric',
        wind: localStorage.getItem('windUnit') || 'metric'
    },
    settings: {
        animations: localStorage.getItem('animations') !== 'false',
        uvIndex: localStorage.getItem('uvIndex') !== 'false',
        alerts: localStorage.getItem('alerts') === 'true'
    },

    async init() {
        this.loadSavedData();
        this.bindEvents();
        this.setupTouch();
        this.initSettings();
        this.updateUIUnits();
        this.setupSearch();
        this.setupSimpleAppDownload(); // Added app download setup

        const lastCity = localStorage.getItem('lastCity');
        if (lastCity) {
            this.currentCity = lastCity;
            await this.loadWeatherData();
        } else {
            this.getDeviceLocation();
        }

        this.updateDate();
        setInterval(() => this.updateDate(), 60000);
    },

    loadSavedData() {
        this.savedLocations = JSON.parse(localStorage.getItem('savedLocations') || '[]');
        this.recentSearches = JSON.parse(localStorage.getItem('recentSearches') || '[]');
        this.updateSavedLocationsUI();
        this.updateRecentSearchesUI();
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

    isDesktop() {
        return window.innerWidth >= 1024;
    },

    bindEvents() {
        document.getElementById('menu-toggle').addEventListener('click', () => {
            this.toggleMobileMenu();
        });

        document.getElementById('menu-close').addEventListener('click', () => {
            this.toggleMobileMenu();
        });

        document.getElementById('current-location-btn').addEventListener('click', () => {
            this.getDeviceLocation();
        });

        const searchToggle = document.getElementById('search-toggle');
        if (searchToggle) {
            searchToggle.addEventListener('click', () => {
                if (!this.isDesktop()) {
                    this.toggleSearch();
                }
            });
        }

        document.getElementById('search-back').addEventListener('click', () => {
            this.toggleSearch();
        });

        const desktopSearchInput = document.getElementById('desktop-search-input');
        const desktopSearchClear = document.getElementById('desktop-search-clear');
        const desktopSearch = document.getElementById('desktop-search');

        if (desktopSearchInput) {
            let desktopSearchTimeout;

            desktopSearchInput.addEventListener('input', e => {
                const value = e.target.value.trim();
                desktopSearchClear.classList.toggle('d-none', !value);

                clearTimeout(desktopSearchTimeout);

                if (value.length === 0) {
                    this.clearDesktopSearch();
                    return;
                }

                if (value.length < 2) return;

                this.showDesktopSearchLoading(true);
                desktopSearchTimeout = setTimeout(() => this.handleDesktopSearch(value), 400);
            });

            desktopSearchInput.addEventListener('keydown', e => {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    const value = e.target.value.trim();
                    if (value) {
                        this.selectDesktopSuggestion(value);
                    }
                } else if (e.key === 'Escape') {
                    this.clearDesktopSearch();
                    desktopSearchInput.blur();
                }
            });

            desktopSearchInput.addEventListener('focus', () => {
                if (desktopSearchInput.value.trim().length >= 2) {
                    this.handleDesktopSearch(desktopSearchInput.value.trim());
                }
            });

            desktopSearchClear.addEventListener('click', () => {
                desktopSearchInput.value = '';
                desktopSearchClear.classList.add('d-none');
                this.clearDesktopSearch();
                desktopSearchInput.focus();
            });

            document.addEventListener('click', e => {
                if (!desktopSearch.contains(e.target)) {
                    this.clearDesktopSearch();
                }
            });
        }

        window.addEventListener('resize', () => {
            if (this.isDesktop()) {
                const overlay = document.getElementById('search-overlay');
                if (overlay.classList.contains('active')) {
                    overlay.classList.remove('active');
                    document.body.classList.remove('search-open');
                    document.body.style.top = '';
                }
            }
        });

        document.getElementById('settings-toggle').addEventListener('click', () => {
            this.toggleSettings();
        });

        document.getElementById('settings-close').addEventListener('click', () => {
            this.toggleSettings();
        });

        document.getElementById('mobile-settings').addEventListener('click', (e) => {
            e.preventDefault();
            this.toggleMobileMenu();
            this.toggleSettings();
        });

        document.getElementById('mobile-about').addEventListener('click', (e) => {
            e.preventDefault();
            this.toggleMobileMenu();
            this.openAbout();
        });

        const desktopAbout = document.getElementById('desktop-about');
        if (desktopAbout) {
            desktopAbout.addEventListener('click', () => {
                this.openAbout();
            });
        }

        document.querySelectorAll('.toggle-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                const unit = btn.dataset.unit;
                const value = btn.dataset.value;
                this.updateUnit(unit, value);
            });
        });

        document.getElementById('animations-toggle').addEventListener('change', e => {
            this.settings.animations = e.target.checked;
            localStorage.setItem('animations', e.target.checked);
            if (!e.target.checked) {
                WeatherAnimations.clear();
            } else if (this.currentData) {
                const theme = ThemeEngine.applyTheme(
                    this.currentData.weather.main,
                    this.currentData.weather.description
                );
                WeatherAnimations.startAnimation(theme.weatherCategory);
            }
        });

        document.getElementById('uv-toggle').addEventListener('change', e => {
            this.settings.uvIndex = e.target.checked;
            localStorage.setItem('uvIndex', e.target.checked);
            document.querySelector('.uv-tile').style.display = e.target.checked ? 'flex' : 'none';
        });

        document.getElementById('alerts-toggle').addEventListener('change', e => {
            this.settings.alerts = e.target.checked;
            localStorage.setItem('alerts', e.target.checked);
            if (e.target.checked) {
                this.requestNotificationPermission();
            }
        });

        document.addEventListener('click', e => {
            if (e.target.classList.contains('menu-overlay')) {
                this.toggleMobileMenu();
            }
        });
    },

    setupSearch() {
        const searchInput = document.getElementById('location-search');
        const clearBtn = document.getElementById('clear-search');
        const searchOverlay = document.getElementById('search-overlay');
        let searchTimeout;

        searchInput.addEventListener('input', e => {
            const value = e.target.value.trim();
            clearBtn.classList.toggle('d-none', !value);

            clearTimeout(searchTimeout);

            if (value.length === 0) {
                this.showDefaultSearch();
                this.showMobileSearchLoading(false);
                return;
            }

            if (value.length < 2) return;

            this.showMobileSearchLoading(true);
            searchTimeout = setTimeout(() => {
                this.performSearch(value);
            }, 400);
        });

        searchInput.addEventListener('keydown', e => {
            if (e.key === 'Enter' && e.target.value.trim()) {
                e.preventDefault();
                this.searchLocation(e.target.value.trim());
            } else if (e.key === 'Escape') {
                this.toggleSearch();
            }
        });

        clearBtn.addEventListener('click', () => {
            searchInput.value = '';
            clearBtn.classList.add('d-none');
            searchInput.focus();
            this.showDefaultSearch();
            this.showMobileSearchLoading(false);
        });

        const observer = new MutationObserver(() => {
            if (searchOverlay.classList.contains('active')) {
                setTimeout(() => {
                    searchInput.focus();
                    if ('ontouchstart' in window) {
                        searchInput.click();
                    }
                }, 350);
            }
        });

        observer.observe(searchOverlay, {
            attributes: true,
            attributeFilter: ['class']
        });
    },

    // New Simple App Download Setup
    setupSimpleAppDownload() {
        const downloadBtn = document.getElementById('simple-download');
        const pwaBtn = document.getElementById('simple-pwa');

        if (!downloadBtn || !pwaBtn) return; // Exit if elements don't exist

        // Android Download
        downloadBtn.addEventListener('click', (e) => {
            e.preventDefault();

            // Add success animation
            downloadBtn.classList.add('download-success');

            // Show downloading state
            const originalText = downloadBtn.querySelector('span').textContent;
            const originalIcon = downloadBtn.querySelector('i').className;
            downloadBtn.querySelector('span').textContent = 'Downloading...';
            downloadBtn.querySelector('i').className = 'fas fa-spinner fa-spin';

            // Start download
            const link = document.createElement('a');
            link.href = downloadBtn.href;
            link.download = 'WeatherApp.apk';
            link.style.display = 'none';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);

            // Track download analytics
            this.trackDownload('android_apk');

            // Reset button with success state
            setTimeout(() => {
                downloadBtn.querySelector('span').textContent = 'Downloaded!';
                downloadBtn.querySelector('i').className = 'fas fa-check';

                // Show success notification
                this.showDownloadNotification('Download started! Check your Downloads folder.');

                setTimeout(() => {
                    downloadBtn.querySelector('span').textContent = originalText;
                    downloadBtn.querySelector('i').className = originalIcon;
                    downloadBtn.classList.remove('download-success');
                }, 2000);
            }, 1000);
        });

        // PWA Installation
        let deferredPrompt;

        window.addEventListener('beforeinstallprompt', (e) => {
            e.preventDefault();
            deferredPrompt = e;
            pwaBtn.style.display = 'flex';
        });

        pwaBtn.addEventListener('click', async () => {
            if (deferredPrompt) {
                deferredPrompt.prompt();
                const { outcome } = await deferredPrompt.userChoice;

                if (outcome === 'accepted') {
                    this.showDownloadNotification('App installed successfully!');
                    this.trackDownload('pwa_install');
                }

                deferredPrompt = null;
            } else {
                // Show device-specific instructions
                this.showPWAInstructions();
            }
        });

        // Hide PWA button if already installed
        window.addEventListener('appinstalled', () => {
            pwaBtn.style.display = 'none';
            this.showDownloadNotification('Weather App installed to your home screen!');
        });

        // Check if PWA is already installed
        if (window.matchMedia && window.matchMedia('(display-mode: standalone)').matches) {
            pwaBtn.style.display = 'none';
        }
    },

    trackDownload(type) {
        // Simple analytics tracking
        try {
            const analytics = {
                type: type,
                timestamp: new Date().toISOString(),
                userAgent: navigator.userAgent,
                platform: navigator.platform
            };

            // Store locally for now (you can send to your analytics service)
            localStorage.setItem('lastDownload', JSON.stringify(analytics));

            // Optional: Send to analytics service
            // fetch('/api/analytics/download', {
            //     method: 'POST',
            //     headers: { 'Content-Type': 'application/json' },
            //     body: JSON.stringify(analytics)
            // }).catch(e => console.log('Analytics failed:', e));

        } catch (error) {
            console.log('Analytics tracking failed:', error);
        }
    },

    showDownloadNotification(message) {
        // Create a simple notification
        const notification = document.createElement('div');
        notification.className = 'download-notification';
        notification.innerHTML = `
            <div class="notification-content">
                <i class="fas fa-check-circle"></i>
                <span>${message}</span>
            </div>
        `;

        // Add notification styles if not already present
        if (!document.getElementById('notification-styles')) {
            const style = document.createElement('style');
            style.id = 'notification-styles';
            style.textContent = `
                .download-notification {
                    position: fixed;
                    top: 20px;
                    right: 20px;
                    background: rgba(16, 185, 129, 0.95);
                    color: white;
                    padding: 16px 20px;
                    border-radius: 12px;
                    backdrop-filter: blur(10px);
                    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
                    z-index: 10000;
                    transform: translateX(100%);
                    transition: transform 0.3s ease;
                    max-width: 300px;
                }
                .download-notification.show {
                    transform: translateX(0);
                }
                .notification-content {
                    display: flex;
                    align-items: center;
                    gap: 12px;
                }
                .notification-content i {
                    font-size: 18px;
                }
                @media (max-width: 480px) {
                    .download-notification {
                        left: 20px;
                        right: 20px;
                        max-width: none;
                    }
                }
            `;
            document.head.appendChild(style);
        }

        document.body.appendChild(notification);

        // Show notification
        setTimeout(() => notification.classList.add('show'), 100);

        // Hide and remove notification
        setTimeout(() => {
            notification.classList.remove('show');
            setTimeout(() => notification.remove(), 300);
        }, 3000);
    },

    showPWAInstructions() {
        const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent);
        const isAndroid = /Android/.test(navigator.userAgent);

        let message = '';

        if (isIOS) {
            message = 'Tap the Share button (⎙) in Safari, then select "Add to Home Screen"';
        } else if (isAndroid) {
            message = 'Tap the menu (⋮) in your browser, then select "Add to Home Screen" or "Install App"';
        } else {
            message = 'Look for an install button in your browser\'s address bar';
        }

        this.showDownloadNotification(message);
    },

    showDesktopSearchLoading(show) {
        const searchIcon = document.querySelector('.desktop-search .search-icon');
        const loadingSpinner = document.querySelector('.desktop-search .search-loading-spinner');

        if (show) {
            searchIcon.style.opacity = '0';
            loadingSpinner.classList.remove('d-none');
        } else {
            searchIcon.style.opacity = '1';
            loadingSpinner.classList.add('d-none');
        }
    },

    showMobileSearchLoading(show) {
        const searchIcon = document.querySelector('.search-input-icon');
        const loadingSpinner = document.querySelector('.search-input-loading');

        if (show) {
            searchIcon.style.opacity = '0';
            loadingSpinner.classList.remove('d-none');
        } else {
            searchIcon.style.opacity = '1';
            loadingSpinner.classList.add('d-none');
        }
    },

    async handleDesktopSearch(query) {
        const container = document.getElementById('desktop-search-suggestions');

        if (!container || query.length < 2) {
            this.clearDesktopSearch();
            return;
        }

        try {
            const cities = [
                { name: 'New York', country: 'United States', region: 'New York' },
                { name: 'London', country: 'United Kingdom', region: 'England' },
                { name: 'Tokyo', country: 'Japan', region: 'Kanto' },
                { name: 'Paris', country: 'France', region: 'Île-de-France' },
                { name: 'Sydney', country: 'Australia', region: 'New South Wales' },
                { name: 'Mumbai', country: 'India', region: 'Maharashtra' },
                { name: 'Dubai', country: 'UAE', region: 'Dubai' },
                { name: 'Singapore', country: 'Singapore', region: 'Central' },
                { name: 'Los Angeles', country: 'United States', region: 'California' },
                { name: 'Chicago', country: 'United States', region: 'Illinois' },
                { name: 'Toronto', country: 'Canada', region: 'Ontario' },
                { name: 'Berlin', country: 'Germany', region: 'Berlin' },
                { name: 'Madrid', country: 'Spain', region: 'Madrid' },
                { name: 'Rome', country: 'Italy', region: 'Lazio' },
                { name: 'Bangkok', country: 'Thailand', region: 'Bangkok' },
                { name: 'Seoul', country: 'South Korea', region: 'Seoul' }
            ];

            const results = cities.filter(city =>
                city.name.toLowerCase().includes(query.toLowerCase()) ||
                city.country.toLowerCase().includes(query.toLowerCase())
            ).slice(0, 6);

            await new Promise(resolve => setTimeout(resolve, 200));

            this.showDesktopSearchLoading(false);

            if (results.length === 0) {
                this.clearDesktopSearch();
                return;
            }

            container.innerHTML = results.map(city => `
                <div class="desktop-suggestion-item" onclick="WeatherApp.selectDesktopSuggestion('${city.name}')">
                    <i class="fas fa-location-dot"></i>
                    <span>${city.name}, ${city.country}</span>
                </div>
            `).join('');

            container.classList.add('active');

        } catch (error) {
            console.error('Desktop search error:', error);
            this.showDesktopSearchLoading(false);
            this.clearDesktopSearch();
        }
    },

    clearDesktopSearch() {
        const container = document.getElementById('desktop-search-suggestions');
        if (container) {
            container.classList.remove('active');
            setTimeout(() => {
                container.innerHTML = '';
            }, 300);
        }
    },

    selectDesktopSuggestion(city) {
        const input = document.getElementById('desktop-search-input');
        if (input) {
            input.value = '';
            document.getElementById('desktop-search-clear').classList.add('d-none');
        }
        this.clearDesktopSearch();
        this.searchLocation(city);
    },

    async performSearch(query) {
        this.showSearchLoading();

        try {
            const cities = [
                { name: 'New York', country: 'United States', region: 'New York', lat: 40.7128, lon: -74.0060 },
                { name: 'London', country: 'United Kingdom', region: 'England', lat: 51.5074, lon: -0.1278 },
                { name: 'Tokyo', country: 'Japan', region: 'Kanto', lat: 35.6762, lon: 139.6503 },
                { name: 'Paris', country: 'France', region: 'Île-de-France', lat: 48.8566, lon: 2.3522 },
                { name: 'Sydney', country: 'Australia', region: 'New South Wales', lat: -33.8688, lon: 151.2093 },
                { name: 'Mumbai', country: 'India', region: 'Maharashtra', lat: 19.0760, lon: 72.8777 },
                { name: 'Dubai', country: 'UAE', region: 'Dubai', lat: 25.2048, lon: 55.2708 },
                { name: 'Singapore', country: 'Singapore', region: 'Central', lat: 1.3521, lon: 103.8198 },
                { name: 'Los Angeles', country: 'United States', region: 'California', lat: 34.0522, lon: -118.2437 },
                { name: 'Chicago', country: 'United States', region: 'Illinois', lat: 41.8781, lon: -87.6298 },
                { name: 'Toronto', country: 'Canada', region: 'Ontario', lat: 43.6532, lon: -79.3832 },
                { name: 'Berlin', country: 'Germany', region: 'Berlin', lat: 52.5200, lon: 13.4050 },
                { name: 'Madrid', country: 'Spain', region: 'Madrid', lat: 40.4168, lon: -3.7038 },
                { name: 'Rome', country: 'Italy', region: 'Lazio', lat: 41.9028, lon: 12.4964 },
                { name: 'Bangkok', country: 'Thailand', region: 'Bangkok', lat: 13.7563, lon: 100.5018 },
                { name: 'Seoul', country: 'South Korea', region: 'Seoul', lat: 37.5665, lon: 126.9780 }
            ];

            const results = cities.filter(city => {
                const searchLower = query.toLowerCase();
                return city.name.toLowerCase().includes(searchLower) ||
                    city.country.toLowerCase().includes(searchLower) ||
                    city.region.toLowerCase().includes(searchLower);
            }).slice(0, 8);

            await new Promise(resolve => setTimeout(resolve, 300));

            this.showMobileSearchLoading(false);

            if (results.length > 0) {
                this.displaySearchResults(results);
            } else {
                this.showNoResults(query);
            }
        } catch (error) {
            console.error('Search error:', error);
            this.showMobileSearchLoading(false);
            this.showDefaultSearch();
        }
    },

    displaySearchResults(results) {
        const container = document.getElementById('search-suggestions');
        const defaultContent = document.getElementById('default-search-content');
        const loading = document.getElementById('search-loading');

        loading.classList.add('d-none');
        defaultContent.classList.add('d-none');

        container.innerHTML = `
            <div class="search-section">
                <div class="section-header">
                    <h4><i class="fas fa-search"></i> Search Results</h4>
                </div>
                ${results.map(city => `
                    <div class="search-item" onclick="WeatherApp.searchLocation('${city.name}')">
                        <div class="search-item-icon">
                            <i class="fas fa-location-dot"></i>
                        </div>
                        <div class="search-item-content">
                            <div class="search-item-title">${city.name}</div>
                            <div class="search-item-subtitle">${city.region}, ${city.country}</div>
                        </div>
                    </div>
                `).join('')}
            </div>
        `;
    },

    showDefaultSearch() {
        document.getElementById('search-suggestions').innerHTML = '';
        document.getElementById('default-search-content').classList.remove('d-none');
        document.getElementById('search-loading').classList.add('d-none');
    },

    showSearchLoading() {
        document.getElementById('search-loading').classList.remove('d-none');
        document.getElementById('default-search-content').classList.add('d-none');
        document.getElementById('search-suggestions').innerHTML = '';
    },

    showNoResults(query) {
        const container = document.getElementById('search-suggestions');
        const defaultContent = document.getElementById('default-search-content');
        const loading = document.getElementById('search-loading');

        loading.classList.add('d-none');
        defaultContent.classList.add('d-none');

        container.innerHTML = `
            <div class="empty-state" style="padding: 60px 20px; text-align: center;">
                <i class="fas fa-search" style="font-size: 48px; color: rgba(255,255,255,0.3); margin-bottom: 16px;"></i>
                <h4 style="color: var(--text-primary); margin-bottom: 8px; font-size: 18px;">No results found</h4>
                <p style="color: rgba(255,255,255,0.5); margin: 0; font-size: 14px;">
                    Try searching for a different city or check your spelling
                </p>
            </div>
        `;
    },

    initSettings() {
        document.getElementById('animations-toggle').checked = this.settings.animations;
        document.getElementById('uv-toggle').checked = this.settings.uvIndex;
        document.getElementById('alerts-toggle').checked = this.settings.alerts;

        if (!this.settings.uvIndex) {
            document.querySelector('.uv-tile').style.display = 'none';
        }

        document.querySelectorAll('.toggle-btn').forEach(btn => {
            const unit = btn.dataset.unit;
            const value = btn.dataset.value;
            if ((unit === 'temp' && value === this.units.temperature) ||
                (unit === 'wind' && value === this.units.wind)) {
                btn.classList.add('active');
            } else {
                btn.classList.remove('active');
            }
        });
    },

    toggleMobileMenu() {
        const menu = document.getElementById('mobile-menu');
        const isActive = menu.classList.toggle('active');

        if (isActive) {
            const overlay = document.createElement('div');
            overlay.className = 'menu-overlay active';
            document.body.appendChild(overlay);
        } else {
            const overlay = document.querySelector('.menu-overlay');
            if (overlay) overlay.remove();
        }
    },

    toggleSearch() {
        if (this.isDesktop()) {
            return;
        }

        const overlay = document.getElementById('search-overlay');
        const searchInput = document.getElementById('location-search');
        const isOpening = !overlay.classList.contains('active');

        overlay.classList.toggle('active');

        if (isOpening) {
            document.body.classList.add('search-open');
            document.body.style.top = `-${window.scrollY}px`;

            setTimeout(() => {
                searchInput.focus();
                this.updateRecentSearchesUI();
            }, 300);
        } else {
            const scrollY = document.body.style.top;
            document.body.classList.remove('search-open');
            document.body.style.top = '';
            window.scrollTo(0, parseInt(scrollY || '0') * -1);

            searchInput.value = '';
            document.getElementById('search-suggestions').innerHTML = '';
            document.getElementById('clear-search').classList.add('d-none');
            this.showDefaultSearch();
            this.showMobileSearchLoading(false);
        }
    },

    toggleSettings() {
        const panel = document.getElementById('settings-panel');
        panel.classList.toggle('active');
    },

    updateUnit(unitType, value) {
        document.querySelectorAll(`.toggle-btn[data-unit="${unitType}"]`).forEach(btn => {
            btn.classList.toggle('active', btn.dataset.value === value);
        });

        if (unitType === 'temp') {
            this.units.temperature = value;
            localStorage.setItem('tempUnit', value);
        } else if (unitType === 'wind') {
            this.units.wind = value;
            localStorage.setItem('windUnit', value);
        }

        this.updateUI();
        this.updateUIUnits();
    },

    updateUIUnits() {
        const tempUnit = this.units.temperature === 'imperial' ? 'F' : 'C';
        document.querySelectorAll('.temp-unit').forEach(el => {
            el.textContent = `°${tempUnit}`;
        });
    },

    updateDate() {
        const now = new Date();
        const options = { weekday: 'long', month: 'long', day: 'numeric' };
        const dateStr = now.toLocaleDateString('en-US', options);
        const dateEl = document.getElementById('today-date');
        if (dateEl) dateEl.textContent = dateStr;
    },

    async searchLocation(city) {
        if (!city || city.trim() === '') return;

        this.addRecentSearch(city.trim());
        this.toggleSearch();
        await this.loadWeatherData(city.trim());
    },

    addRecentSearch(city) {
        this.recentSearches = this.recentSearches.filter(c => c.toLowerCase() !== city.toLowerCase());
        this.recentSearches.unshift(city);
        this.recentSearches = this.recentSearches.slice(0, 5);
        localStorage.setItem('recentSearches', JSON.stringify(this.recentSearches));
    },

    updateRecentSearchesUI() {
        const container = document.getElementById('recent-list');
        const section = document.getElementById('recent-searches');

        if (!this.recentSearches.length) {
            section.style.display = 'none';
            return;
        }

        section.style.display = 'block';
        container.innerHTML = this.recentSearches.map(city => `
            <div class="search-item" onclick="WeatherApp.searchLocation('${city}')">
                <div class="search-item-icon">
                    <i class="fas fa-history"></i>
                </div>
                <div class="search-item-content">
                    <div class="search-item-title">${city}</div>
                </div>
            </div>
        `).join('');
    },

    clearRecentSearches() {
        this.recentSearches = [];
        localStorage.setItem('recentSearches', JSON.stringify([]));
        this.updateRecentSearchesUI();
        document.getElementById('recent-searches').style.display = 'none';
    },

    updateSavedLocationsUI() {
        const desktopContainer = document.getElementById('saved-locations-desktop');
        if (!desktopContainer) return;

        if (this.savedLocations.length === 0) {
            desktopContainer.innerHTML = '<p style="color: var(--text-secondary); font-size: 14px;">No saved locations</p>';
            return;
        }

        desktopContainer.innerHTML = this.savedLocations.map(location => `
            <div class="saved-location-item" onclick="WeatherApp.loadWeatherData('${location.city}')">
                <div>
                    <div style="font-weight: 500;">${location.city}</div>
                    <div style="font-size: 12px; color: var(--text-secondary);">${location.temp}°</div>
                </div>
                <i class="fas fa-chevron-right" style="color: var(--text-secondary);"></i>
            </div>
        `).join('');
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

            if (document.getElementById('feels-like')) {
                document.getElementById('feels-like').textContent =
                    Math.round(this.convertTemperature(this.currentData.temperature.feels_like)) + '°';
            }
            if (document.getElementById('dew-point')) {
                const t = this.currentData.temperature.current;
                const rh = this.currentData.details.humidity;
                const dewPoint = t - ((100 - rh) / 5);
                document.getElementById('dew-point').textContent =
                    Math.round(this.convertTemperature(dewPoint)) + '°';
            }

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

        if (this.settings.animations) {
            WeatherAnimations.startAnimation(theme.weatherCategory);
        }

        const iconEl = document.getElementById('weather-icon');
        iconEl.src = `https://openweathermap.org/img/wn/${this.currentData.weather.icon}@4x.png`;
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

        if (this.settings.uvIndex) {
            document.getElementById('uv-index').textContent = Math.floor(Math.random() * 11);
        }

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

    requestNotificationPermission() {
        if ('Notification' in window && Notification.permission === 'default') {
            Notification.requestPermission();
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

    openAbout() {
        window.location.href = '/about.html';
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