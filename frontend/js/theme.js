const ThemeEngine = {
    timeOfDay: {
        dawn: { start: 4.5, end: 6.5 },
        sunrise: { start: 6.5, end: 7.5 },
        morning: { start: 7.5, end: 11.5 },
        midday: { start: 11.5, end: 14.5 },
        afternoon: { start: 14.5, end: 17.5 },
        dusk: { start: 17.5, end: 19.5 },
        night: { start: 19.5, end: 4.5 }
    },

    backgrounds: {
        dawn: {
            clear: {
                gradient: 'linear-gradient(to bottom, #FF6B6B 0%, #FFE66D 50%, #87CEEB 100%)',
                colors: ['#FF6B6B', '#FFE66D', '#87CEEB']
            },
            cloudy: {
                gradient: 'linear-gradient(to bottom, #D3D3D3 0%, #FFB6C1 50%, #87CEEB 100%)',
                colors: ['#D3D3D3', '#FFB6C1', '#87CEEB']
            },
            rain: {
                gradient: 'linear-gradient(to bottom, #708090 0%, #FFB6C1 50%, #4682B4 100%)',
                colors: ['#708090', '#FFB6C1', '#4682B4']
            },
            thunderstorm: {
                gradient: 'linear-gradient(to bottom, #2F4F4F 0%, #708090 50%, #696969 100%)',
                colors: ['#2F4F4F', '#708090', '#696969']
            },
            snow: {
                gradient: 'linear-gradient(to bottom, #E6E6FA 0%, #F0F8FF 50%, #FFFFFF 100%)',
                colors: ['#E6E6FA', '#F0F8FF', '#FFFFFF']
            },
            fog: {
                gradient: 'linear-gradient(to bottom, #C0C0C0 0%, #D3D3D3 50%, #DCDCDC 100%)',
                colors: ['#C0C0C0', '#D3D3D3', '#DCDCDC']
            }
        },
        sunrise: {
            clear: {
                gradient: 'linear-gradient(to bottom, #FF8C00 0%, #FFD700 30%, #87CEEB 100%)',
                colors: ['#FF8C00', '#FFD700', '#87CEEB']
            },
            cloudy: {
                gradient: 'linear-gradient(to bottom, #CD853F 0%, #F0E68C 50%, #B0C4DE 100%)',
                colors: ['#CD853F', '#F0E68C', '#B0C4DE']
            },
            rain: {
                gradient: 'linear-gradient(to bottom, #8B7355 0%, #D2B48C 50%, #778899 100%)',
                colors: ['#8B7355', '#D2B48C', '#778899']
            },
            thunderstorm: {
                gradient: 'linear-gradient(to bottom, #4B4B4D 0%, #8B7D6B 50%, #696969 100%)',
                colors: ['#4B4B4D', '#8B7D6B', '#696969']
            },
            snow: {
                gradient: 'linear-gradient(to bottom, #FFE4E1 0%, #FFF0F5 50%, #F0FFFF 100%)',
                colors: ['#FFE4E1', '#FFF0F5', '#F0FFFF']
            },
            fog: {
                gradient: 'linear-gradient(to bottom, #DEB887 0%, #F5DEB3 50%, #E0E0E0 100%)',
                colors: ['#DEB887', '#F5DEB3', '#E0E0E0']
            }
        },
        morning: {
            clear: {
                gradient: 'linear-gradient(to bottom, #00BFFF 0%, #87CEEB 50%, #87CEFA 100%)',
                colors: ['#00BFFF', '#87CEEB', '#87CEFA']
            },
            cloudy: {
                gradient: 'linear-gradient(to bottom, #4682B4 0%, #B0C4DE 50%, #D3D3D3 100%)',
                colors: ['#4682B4', '#B0C4DE', '#D3D3D3']
            },
            rain: {
                gradient: 'linear-gradient(to bottom, #2F4F4F 0%, #708090 50%, #778899 100%)',
                colors: ['#2F4F4F', '#708090', '#778899']
            },
            thunderstorm: {
                gradient: 'linear-gradient(to bottom, #191970 0%, #2F4F4F 50%, #483D8B 100%)',
                colors: ['#191970', '#2F4F4F', '#483D8B']
            },
            snow: {
                gradient: 'linear-gradient(to bottom, #B0E0E6 0%, #E0FFFF 50%, #F0FFFF 100%)',
                colors: ['#B0E0E6', '#E0FFFF', '#F0FFFF']
            },
            fog: {
                gradient: 'linear-gradient(to bottom, #A9A9A9 0%, #C0C0C0 50%, #D3D3D3 100%)',
                colors: ['#A9A9A9', '#C0C0C0', '#D3D3D3']
            }
        },
        midday: {
            clear: {
                gradient: 'linear-gradient(to bottom, #1E90FF 0%, #00BFFF 50%, #87CEEB 100%)',
                colors: ['#1E90FF', '#00BFFF', '#87CEEB']
            },
            cloudy: {
                gradient: 'linear-gradient(to bottom, #5F9EA0 0%, #87CEEB 50%, #B0C4DE 100%)',
                colors: ['#5F9EA0', '#87CEEB', '#B0C4DE']
            },
            rain: {
                gradient: 'linear-gradient(to bottom, #36454F 0%, #708090 50%, #8B9DC3 100%)',
                colors: ['#36454F', '#708090', '#8B9DC3']
            },
            thunderstorm: {
                gradient: 'linear-gradient(to bottom, #1C1C1C 0%, #36454F 50%, #4B0082 100%)',
                colors: ['#1C1C1C', '#36454F', '#4B0082']
            },
            snow: {
                gradient: 'linear-gradient(to bottom, #ADD8E6 0%, #E0FFFF 50%, #FFFFFF 100%)',
                colors: ['#ADD8E6', '#E0FFFF', '#FFFFFF']
            },
            fog: {
                gradient: 'linear-gradient(to bottom, #B0B0B0 0%, #D0D0D0 50%, #E0E0E0 100%)',
                colors: ['#B0B0B0', '#D0D0D0', '#E0E0E0']
            }
        },
        afternoon: {
            clear: {
                gradient: 'linear-gradient(to bottom, #4169E1 0%, #6495ED 50%, #87CEEB 100%)',
                colors: ['#4169E1', '#6495ED', '#87CEEB']
            },
            cloudy: {
                gradient: 'linear-gradient(to bottom, #6B8E23 0%, #9ACD32 50%, #B0C4DE 100%)',
                colors: ['#6B8E23', '#9ACD32', '#B0C4DE']
            },
            rain: {
                gradient: 'linear-gradient(to bottom, #3B3C36 0%, #696969 50%, #808080 100%)',
                colors: ['#3B3C36', '#696969', '#808080']
            },
            thunderstorm: {
                gradient: 'linear-gradient(to bottom, #1B1B1B 0%, #3B3C36 50%, #483D8B 100%)',
                colors: ['#1B1B1B', '#3B3C36', '#483D8B']
            },
            snow: {
                gradient: 'linear-gradient(to bottom, #9AC0CD 0%, #CAE1FF 50%, #F0F8FF 100%)',
                colors: ['#9AC0CD', '#CAE1FF', '#F0F8FF']
            },
            fog: {
                gradient: 'linear-gradient(to bottom, #A8A8A8 0%, #C8C8C8 50%, #D8D8D8 100%)',
                colors: ['#A8A8A8', '#C8C8C8', '#D8D8D8']
            }
        },
        dusk: {
            clear: {
                gradient: 'linear-gradient(to bottom, #FF4500 0%, #FF6347 50%, #FFB6C1 100%)',
                colors: ['#FF4500', '#FF6347', '#FFB6C1']
            },
            cloudy: {
                gradient: 'linear-gradient(to bottom, #8B4513 0%, #CD853F 50%, #DEB887 100%)',
                colors: ['#8B4513', '#CD853F', '#DEB887']
            },
            rain: {
                gradient: 'linear-gradient(to bottom, #483D8B 0%, #6A5ACD 50%, #9370DB 100%)',
                colors: ['#483D8B', '#6A5ACD', '#9370DB']
            },
            thunderstorm: {
                gradient: 'linear-gradient(to bottom, #191970 0%, #483D8B 50%, #4B0082 100%)',
                colors: ['#191970', '#483D8B', '#4B0082']
            },
            snow: {
                gradient: 'linear-gradient(to bottom, #9370DB 0%, #DDA0DD 50%, #EE82EE 100%)',
                colors: ['#9370DB', '#DDA0DD', '#EE82EE']
            },
            fog: {
                gradient: 'linear-gradient(to bottom, #696969 0%, #808080 50%, #A9A9A9 100%)',
                colors: ['#696969', '#808080', '#A9A9A9']
            }
        },
        night: {
            clear: {
                gradient: 'linear-gradient(to bottom, #000428 0%, #004e92 50%, #191970 100%)',
                colors: ['#000428', '#004e92', '#191970']
            },
            cloudy: {
                gradient: 'linear-gradient(to bottom, #0F0F0F 0%, #2F2F2F 50%, #4F4F4F 100%)',
                colors: ['#0F0F0F', '#2F2F2F', '#4F4F4F']
            },
            rain: {
                gradient: 'linear-gradient(to bottom, #000000 0%, #191970 50%, #000080 100%)',
                colors: ['#000000', '#191970', '#000080']
            },
            thunderstorm: {
                gradient: 'linear-gradient(to bottom, #000000 0%, #1C1C1C 50%, #2F4F4F 100%)',
                colors: ['#000000', '#1C1C1C', '#2F4F4F']
            },
            snow: {
                gradient: 'linear-gradient(to bottom, #191970 0%, #4B0082 50%, #6A0DAD 100%)',
                colors: ['#191970', '#4B0082', '#6A0DAD']
            },
            fog: {
                gradient: 'linear-gradient(to bottom, #1C1C1C 0%, #2F2F2F 50%, #3F3F3F 100%)',
                colors: ['#1C1C1C', '#2F2F2F', '#3F3F3F']
            }
        }
    },

    // Dynamic color adjustments based on weather intensity
    weatherIntensityModifiers: {
        light: 0.2,
        moderate: 0,
        heavy: -0.2,
        extreme: -0.4
    },

    // Special weather conditions
    specialConditions: {
        rainbow: {
            probability: 0.15, // After rain during sun
            gradient: 'linear-gradient(45deg, #FF0000, #FF7F00, #FFFF00, #00FF00, #0000FF, #4B0082, #9400D3)'
        },
        aurora: {
            probability: 0.05, // Night clear at high latitudes
            gradient: 'linear-gradient(to bottom, #00FF00 0%, #0000FF 50%, #FF00FF 100%)'
        }
    },

    getCurrentTimeOfDay() {
        const hour = new Date().getHours() + new Date().getMinutes() / 60;

        for (const [period, times] of Object.entries(this.timeOfDay)) {
            if (period === 'night') {
                if (hour >= times.start || hour < times.end) return period;
            } else {
                if (hour >= times.start && hour < times.end) return period;
            }
        }
        return 'day';
    },

    getWeatherCategory(condition) {
        const conditionMap = {
            'clear': ['clear', 'sunny'],
            'cloudy': ['cloudy', 'partly cloudy', 'overcast', 'clouds', 'scattered clouds', 'broken clouds'],
            'rain': ['rain', 'drizzle', 'showers', 'light rain', 'moderate rain', 'heavy rain'],
            'thunderstorm': ['thunderstorm', 'thunder', 'lightning'],
            'snow': ['snow', 'sleet', 'blizzard', 'light snow', 'heavy snow'],
            'fog': ['fog', 'mist', 'haze', 'smoke']
        };

        const lowerCondition = condition.toLowerCase();
        for (const [category, keywords] of Object.entries(conditionMap)) {
            if (keywords.some(keyword => lowerCondition.includes(keyword))) {
                return category;
            }
        }
        return 'clear';
    },

    getWeatherIntensity(description) {
        const intensityKeywords = {
            light: ['light', 'slight', 'weak'],
            moderate: ['moderate', 'normal'],
            heavy: ['heavy', 'strong', 'intense'],
            extreme: ['extreme', 'severe', 'violent']
        };

        const lowerDesc = description.toLowerCase();
        for (const [intensity, keywords] of Object.entries(intensityKeywords)) {
            if (keywords.some(keyword => lowerDesc.includes(keyword))) {
                return intensity;
            }
        }
        return 'moderate';
    },

    applyTheme(weatherCondition, weatherDescription = '') {
        const timeOfDay = this.getCurrentTimeOfDay();
        const weatherCategory = this.getWeatherCategory(weatherCondition);
        const weatherIntensity = this.getWeatherIntensity(weatherDescription);

        const themeData = this.backgrounds[timeOfDay][weatherCategory] || this.backgrounds[timeOfDay].clear;
        let background = themeData.gradient;

        // Apply intensity modifier
        const modifier = this.weatherIntensityModifiers[weatherIntensity];
        if (modifier !== 0) {
            background = this.adjustGradientBrightness(themeData, modifier);
        }

        // Check for special conditions
        const specialEffect = this.checkSpecialConditions(timeOfDay, weatherCategory);
        if (specialEffect) {
            this.applySpecialEffect(specialEffect);
        }

        // Apply the background with smooth transition
        const bgElement = document.getElementById('background');
        bgElement.style.background = background;

        // Apply complementary UI adjustments
        this.adjustUIColors(themeData.colors);

        return { timeOfDay, weatherCategory, weatherIntensity };
    },

    adjustGradientBrightness(themeData, modifier) {
        const adjustedColors = themeData.colors.map(color => {
            return this.adjustColorBrightness(color, modifier);
        });

        return `linear-gradient(to bottom, ${adjustedColors.join(', ')})`;
    },

    adjustColorBrightness(color, amount) {
        const usePound = color[0] === '#';
        const col = usePound ? color.slice(1) : color;
        const num = parseInt(col, 16);
        let r = (num >> 16) + amount * 255;
        let g = ((num >> 8) & 0x00FF) + amount * 255;
        let b = (num & 0x0000FF) + amount * 255;
        r = r > 255 ? 255 : r < 0 ? 0 : r;
        g = g > 255 ? 255 : g < 0 ? 0 : g;
        b = b > 255 ? 255 : b < 0 ? 0 : b;
        return (usePound ? '#' : '') + (r << 16 | g << 8 | b).toString(16).padStart(6, '0');
    },

    adjustUIColors(themeColors) {
        // Adjust UI element colors based on background
        const avgBrightness = this.getAverageBrightness(themeColors);

        if (avgBrightness < 0.3) {
            // Dark theme adjustments
            document.documentElement.style.setProperty('--text-primary', 'rgba(255, 255, 255, 1)');
            document.documentElement.style.setProperty('--text-secondary', 'rgba(255, 255, 255, 0.7)');
        } else if (avgBrightness > 0.7) {
            // Light theme adjustments
            document.documentElement.style.setProperty('--text-primary', 'rgba(0, 0, 0, 0.9)');
            document.documentElement.style.setProperty('--text-secondary', 'rgba(0, 0, 0, 0.7)');
        }
    },

    getAverageBrightness(colors) {
        const rgbValues = colors.map(color => {
            const hex = color.replace('#', '');
            const r = parseInt(hex.substr(0, 2), 16) / 255;
            const g = parseInt(hex.substr(2, 2), 16) / 255;
            const b = parseInt(hex.substr(4, 2), 16) / 255;
            return (r + g + b) / 3;
        });

        return rgbValues.reduce((a, b) => a + b, 0) / rgbValues.length;
    },

    checkSpecialConditions(timeOfDay, weatherCategory) {
        // Rainbow possibility after rain during sunny periods
        if (weatherCategory === 'clear' && this.previousWeather === 'rain' &&
            ['morning', 'afternoon'].includes(timeOfDay)) {
            if (Math.random() < this.specialConditions.rainbow.probability) {
                return 'rainbow';
            }
        }

        // Aurora possibility during clear nights at high latitudes
        if (weatherCategory === 'clear' && timeOfDay === 'night') {
            const lat = parseFloat(localStorage.getItem('latitude') || '0');
            if (Math.abs(lat) > 55 && Math.random() < this.specialConditions.aurora.probability) {
                return 'aurora';
            }
        }

        this.previousWeather = weatherCategory;
        return null;
    },

    applySpecialEffect(effect) {
        const effectsContainer = document.getElementById('weather-effects');

        switch (effect) {
            case 'rainbow':
                const rainbow = document.createElement('div');
                rainbow.className = 'rainbow-effect';
                rainbow.style.cssText = `
                    position: absolute;
                    top: 20%;
                    left: -10%;
                    right: -10%;
                    height: 300px;
                    background: ${this.specialConditions.rainbow.gradient};
                    opacity: 0.3;
                    filter: blur(20px);
                    transform: rotate(-5deg);
                    pointer-events: none;
                `;
                effectsContainer.appendChild(rainbow);
                break;

            case 'aurora':
                for (let i = 0; i < 3; i++) {
                    const aurora = document.createElement('div');
                    aurora.className = 'aurora-effect';
                    aurora.style.cssText = `
                        position: absolute;
                        top: ${-20 + i * 20}%;
                        left: ${-10 + i * 10}%;
                        right: ${-10 - i * 10}%;
                        height: 200px;
                        background: ${this.specialConditions.aurora.gradient};
                        opacity: ${0.1 + i * 0.05};
                        filter: blur(${30 + i * 10}px);
                        animation: aurora-wave ${10 + i * 2}s ease-in-out infinite;
                        pointer-events: none;
                    `;
                    effectsContainer.appendChild(aurora);
                }
                break;
        }
    },

    updateDateTime() {
        const now = new Date();
        const timeString = now.toLocaleTimeString('en-US', {
            hour: '2-digit',
            minute: '2-digit',
            hour12: true
        });

        const currentTimeEl = document.getElementById('current-time');
        if (currentTimeEl) {
            currentTimeEl.textContent = timeString;
        }

        // Update theme if hour changes
        if (this.lastHour !== now.getHours()) {
            this.lastHour = now.getHours();
            if (window.WeatherApp && window.WeatherApp.currentData) {
                this.applyTheme(
                    window.WeatherApp.currentData.weather.main,
                    window.WeatherApp.currentData.weather.description
                );
            }
        }
    }
};

// Add aurora wave animation
const style = document.createElement('style');
style.textContent = `
    @keyframes aurora-wave {
        0%, 100% {
            transform: translateY(0) scaleY(1);
        }
        50% {
            transform: translateY(-20px) scaleY(1.2);
        }
    }
`;
document.head.appendChild(style);

// Initialize theme engine
setInterval(() => ThemeEngine.updateDateTime(), 1000);
ThemeEngine.updateDateTime();