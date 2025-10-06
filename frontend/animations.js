class WeatherAnimations {
    constructor() {
        this.canvas = document.getElementById('weatherCanvas');
        this.ctx = this.canvas.getContext('2d');
        this.scene = document.getElementById('weatherScene');
        this.effects = document.getElementById('weatherEffects');

        this.particles = [];
        this.animationId = null;
        this.currentWeather = null;
        this.lightningTimeout = null;

        this.setupCanvas();
        window.addEventListener('resize', () => this.setupCanvas());
    }

    setupCanvas() {
        this.canvas.width = window.innerWidth;
        this.canvas.height = window.innerHeight;
    }

    clear() {
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
        this.particles = [];
        this.scene.innerHTML = '';
        this.effects.innerHTML = '';

        if (this.animationId) {
            cancelAnimationFrame(this.animationId);
            this.animationId = null;
        }

        if (this.lightningTimeout) {
            clearTimeout(this.lightningTimeout);
            this.lightningTimeout = null;
        }
    }

    startAnimation(weatherData) {
        this.clear();
        this.currentWeather = weatherData;

        const weatherMain = weatherData.weather.main.toLowerCase();
        const description = weatherData.weather.description.toLowerCase();
        const isNight = weatherData.weather.icon.includes('n');
        const temp = weatherData.temperature.current;
        const windSpeed = weatherData.details.wind_speed;
        const clouds = weatherData.details.clouds;

        this.setSceneEffects(weatherMain, isNight, temp);

        switch (weatherMain) {
            case 'clear':
                if (isNight) {
                    this.animateStars();
                    this.animateMoon();
                } else {
                    this.animateSun();
                    if (temp > 25) this.animateHeatWaves();
                }
                break;

            case 'clouds':
                this.animateClouds(clouds);
                if (description.includes('few')) {
                    if (!isNight) this.animateSunRays();
                }
                break;

            case 'rain':
                this.animateRain(description.includes('heavy') ? 'heavy' : 'normal');
                this.animateClouds(80);
                if (windSpeed > 5) this.animateWind();
                break;

            case 'drizzle':
                this.animateRain('light');
                this.animateMist();
                break;

            case 'thunderstorm':
                this.animateRain('heavy');
                this.animateThunderstorm();
                this.animateClouds(90);
                this.animateWind();
                break;

            case 'snow':
                this.animateSnow(description.includes('heavy') ? 'heavy' : 'normal');
                this.animateClouds(70);
                if (temp < -5) this.animateFrost();
                break;

            case 'mist':
            case 'fog':
                this.animateFog();
                break;

            case 'haze':
                this.animateHaze();
                break;

            case 'dust':
            case 'sand':
                this.animateDust();
                this.animateWind();
                break;

            case 'ash':
                this.animateAsh();
                break;

            case 'squall':
            case 'tornado':
                this.animateTornado();
                break;
        }

        if (windSpeed > 10) {
            this.animateStrongWind();
        }
    }

    setSceneEffects(weather, isNight, temp) {
        const scene = this.scene;
        scene.style.filter = '';

        if (isNight) {
            scene.style.filter = 'brightness(0.7)';
        }

        if (weather === 'mist' || weather === 'fog') {
            scene.style.filter += ' blur(2px)';
        }

        if (weather === 'haze') {
            scene.style.filter += ' sepia(0.3) brightness(1.1)';
        }

        if (temp < 0) {
            scene.style.filter += ' hue-rotate(-10deg) brightness(1.1)';
        } else if (temp > 35) {
            scene.style.filter += ' hue-rotate(10deg) contrast(1.1)';
        }
    }

    animateSun() {
        const sun = document.createElement('div');
        sun.className = 'sun';
        sun.innerHTML = `
            <div class="sun-core"></div>
            <div class="sun-rays">
                ${Array(12).fill(0).map((_, i) => `<div class="sun-ray" style="transform: rotate(${i * 30}deg)"></div>`).join('')}
            </div>
        `;
        this.scene.appendChild(sun);

        const style = document.createElement('style');
        style.textContent = `
            .sun {
                position: absolute;
                top: 10%;
                right: 10%;
                width: 120px;
                height: 120px;
            }
            .sun-core {
                position: absolute;
                width: 100%;
                height: 100%;
                background: radial-gradient(circle, #FFD700 0%, #FFA500 70%, transparent 100%);
                border-radius: 50%;
                box-shadow: 0 0 60px #FFD700;
                animation: sunPulse 4s ease-in-out infinite;
            }
            .sun-rays {
                position: absolute;
                width: 100%;
                height: 100%;
                animation: sunRotate 60s linear infinite;
            }
            .sun-ray {
                position: absolute;
                top: -40%;
                left: 47%;
                width: 6px;
                height: 40%;
                background: linear-gradient(to bottom, #FFD700, transparent);
                transform-origin: bottom center;
            }
            @keyframes sunPulse {
                0%, 100% { transform: scale(1); opacity: 0.9; }
                50% { transform: scale(1.1); opacity: 1; }
            }
            @keyframes sunRotate {
                from { transform: rotate(0deg); }
                to { transform: rotate(360deg); }
            }
        `;
        document.head.appendChild(style);
    }

    animateMoon() {
        const moon = document.createElement('div');
        moon.className = 'moon';
        moon.innerHTML = `
            <div class="moon-surface"></div>
            <div class="moon-glow"></div>
        `;
        this.scene.appendChild(moon);

        const style = document.createElement('style');
        style.textContent = `
            .moon {
                position: absolute;
                top: 10%;
                right: 10%;
                width: 100px;
                height: 100px;
            }
            .moon-surface {
                position: absolute;
                width: 100%;
                height: 100%;
                background: radial-gradient(circle at 30% 30%, #FFFACD 0%, #F0E68C 50%, #DAA520 100%);
                border-radius: 50%;
                overflow: hidden;
                box-shadow: 0 0 40px rgba(255, 250, 205, 0.5);
            }
            .moon-surface::before {
                content: '';
                position: absolute;
                width: 100%;
                height: 100%;
                background: radial-gradient(circle at 70% 70%, transparent 0%, rgba(0, 0, 0, 0.1) 100%);
            }
            .moon-glow {
                position: absolute;
                top: -20%;
                left: -20%;
                width: 140%;
                height: 140%;
                background: radial-gradient(circle, rgba(255, 250, 205, 0.3) 0%, transparent 70%);
                animation: moonGlow 3s ease-in-out infinite;
            }
            @keyframes moonGlow {
                0%, 100% { opacity: 0.5; }
                50% { opacity: 0.8; }
            }
        `;
        document.head.appendChild(style);
    }

    animateStars() {
        for (let i = 0; i < 150; i++) {
            this.particles.push({
                x: Math.random() * this.canvas.width,
                y: Math.random() * this.canvas.height,
                size: Math.random() * 2,
                brightness: Math.random(),
                twinkleSpeed: Math.random() * 0.02 + 0.005
            });
        }

        const animate = () => {
            this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

            this.particles.forEach(star => {
                star.brightness += (Math.random() - 0.5) * star.twinkleSpeed;
                star.brightness = Math.max(0.3, Math.min(1, star.brightness));

                this.ctx.beginPath();
                this.ctx.arc(star.x, star.y, star.size, 0, Math.PI * 2);
                this.ctx.fillStyle = `rgba(255, 255, 255, ${star.brightness})`;
                this.ctx.fill();

                if (star.size > 1.5) {
                    this.ctx.beginPath();
                    this.ctx.arc(star.x, star.y, star.size * 2, 0, Math.PI * 2);
                    this.ctx.fillStyle = `rgba(255, 255, 255, ${star.brightness * 0.3})`;
                    this.ctx.fill();
                }
            });

            this.animationId = requestAnimationFrame(animate);
        };
        animate();
    }

    animateClouds(coverage) {
        const cloudCount = Math.ceil(coverage / 20);

        for (let i = 0; i < cloudCount; i++) {
            this.particles.push({
                x: Math.random() * (this.canvas.width + 200) - 200,
                y: Math.random() * this.canvas.height * 0.4,
                width: Math.random() * 250 + 150,
                height: Math.random() * 80 + 60,
                speed: Math.random() * 0.3 + 0.1,
                opacity: Math.random() * 0.4 + (coverage / 200)
            });
        }

        const animate = () => {
            this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

            this.particles.forEach(cloud => {
                cloud.x += cloud.speed;
                if (cloud.x > this.canvas.width + cloud.width) {
                    cloud.x = -cloud.width;
                }

                this.ctx.fillStyle = `rgba(255, 255, 255, ${cloud.opacity})`;
                this.drawCloud(cloud.x, cloud.y, cloud.width, cloud.height);
            });

            this.animationId = requestAnimationFrame(animate);
        };
        animate();
    }

    drawCloud(x, y, width, height) {
        const circles = [
            { x: x + width * 0.2, y: y, r: height * 0.6 },
            { x: x + width * 0.5, y: y - height * 0.2, r: height * 0.8 },
            { x: x + width * 0.8, y: y, r: height * 0.6 },
            { x: x + width * 0.3, y: y + height * 0.1, r: height * 0.5 },
            { x: x + width * 0.7, y: y + height * 0.1, r: height * 0.5 }
        ];

        circles.forEach(circle => {
            this.ctx.beginPath();
            this.ctx.arc(circle.x, circle.y, circle.r, 0, Math.PI * 2);
            this.ctx.fill();
        });
    }

    animateRain(intensity = 'normal') {
        const dropCount = intensity === 'heavy' ? 200 : intensity === 'light' ? 50 : 100;

        for (let i = 0; i < dropCount; i++) {
            this.particles.push({
                x: Math.random() * this.canvas.width,
                y: Math.random() * this.canvas.height - this.canvas.height,
                length: Math.random() * 20 + (intensity === 'heavy' ? 20 : 10),
                speed: Math.random() * 5 + (intensity === 'heavy' ? 15 : 10),
                opacity: Math.random() * 0.3 + (intensity === 'heavy' ? 0.5 : 0.3),
                wind: 0
            });
        }

        const animate = () => {
            this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

            this.particles.forEach(drop => {
                drop.y += drop.speed;
                drop.x += drop.wind;

                if (drop.y > this.canvas.height) {
                    drop.y = -drop.length;
                    drop.x = Math.random() * this.canvas.width;

                    this.createRipple(drop.x, this.canvas.height - 10);
                }

                this.ctx.beginPath();
                this.ctx.moveTo(drop.x, drop.y);
                this.ctx.lineTo(drop.x + drop.wind * 2, drop.y + drop.length);
                this.ctx.strokeStyle = `rgba(174, 194, 224, ${drop.opacity})`;
                this.ctx.lineWidth = intensity === 'heavy' ? 2 : 1;
                this.ctx.stroke();
            });

            this.animationId = requestAnimationFrame(animate);
        };
        animate();
    }

    createRipple(x, y) {
        const ripple = document.createElement('div');
        ripple.className = 'ripple';
        ripple.style.left = x + 'px';
        ripple.style.top = y + 'px';
        this.effects.appendChild(ripple);

        setTimeout(() => ripple.remove(), 1000);

        if (!document.querySelector('#ripple-style')) {
            const style = document.createElement('style');
            style.id = 'ripple-style';
            style.textContent = `
                .ripple {
                    position: absolute;
                    width: 20px;
                    height: 20px;
                    border: 2px solid rgba(174, 194, 224, 0.5);
                    border-radius: 50%;
                    transform: translate(-50%, -50%);
                    animation: rippleExpand 1s ease-out forwards;
                }
                @keyframes rippleExpand {
                    to {
                        width: 60px;
                        height: 60px;
                        opacity: 0;
                    }
                }
            `;
            document.head.appendChild(style);
        }
    }

    animateSnow(intensity = 'normal') {
        const flakeCount = intensity === 'heavy' ? 150 : 80;

        for (let i = 0; i < flakeCount; i++) {
            this.particles.push({
                x: Math.random() * this.canvas.width,
                y: Math.random() * this.canvas.height,
                size: Math.random() * 4 + (intensity === 'heavy' ? 3 : 2),
                speedX: Math.random() * 2 - 1,
                speedY: Math.random() * 2 + (intensity === 'heavy' ? 2 : 1),
                opacity: Math.random() * 0.6 + 0.4,
                wobble: Math.random() * Math.PI * 2,
                wobbleSpeed: Math.random() * 0.05 + 0.02
            });
        }

        const animate = () => {
            this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

            this.particles.forEach(flake => {
                flake.wobble += flake.wobbleSpeed;
                flake.x += flake.speedX + Math.sin(flake.wobble) * 0.5;
                flake.y += flake.speedY;

                if (flake.y > this.canvas.height) {
                    flake.y = -flake.size;
                    flake.x = Math.random() * this.canvas.width;
                }

                if (flake.x > this.canvas.width) flake.x = 0;
                if (flake.x < 0) flake.x = this.canvas.width;

                this.ctx.beginPath();
                this.ctx.arc(flake.x, flake.y, flake.size, 0, Math.PI * 2);

                const gradient = this.ctx.createRadialGradient(
                    flake.x, flake.y, 0,
                    flake.x, flake.y, flake.size
                );
                gradient.addColorStop(0, `rgba(255, 255, 255, ${flake.opacity})`);
                gradient.addColorStop(1, `rgba(255, 255, 255, ${flake.opacity * 0.5})`);

                this.ctx.fillStyle = gradient;
                this.ctx.fill();
            });

            this.animationId = requestAnimationFrame(animate);
        };
        animate();
    }

    animateThunderstorm() {
        const createLightning = () => {
            const lightning = document.createElement('div');
            lightning.className = 'lightning';
            this.effects.appendChild(lightning);

            setTimeout(() => {
                lightning.remove();
                this.effects.style.backgroundColor = 'rgba(255, 255, 255, 0.8)';
                setTimeout(() => {
                    this.effects.style.backgroundColor = 'transparent';
                }, 100);
            }, 200);

            this.lightningTimeout = setTimeout(createLightning, Math.random() * 5000 + 2000);
        };

        createLightning();

        const style = document.createElement('style');
        style.textContent = `
            .lightning {
                position: absolute;
                top: 0;
                left: ${Math.random() * 80 + 10}%;
                width: 2px;
                height: 100%;
                background: linear-gradient(to bottom, 
                    transparent 0%, 
                    rgba(255, 255, 255, 0.8) 50%, 
                    transparent 100%);
                filter: blur(1px);
                animation: lightning 0.2s ease-out forwards;
            }
            @keyframes lightning {
                0% { opacity: 0; transform: scaleY(0); }
                50% { opacity: 1; }
                100% { opacity: 0; transform: scaleY(1); }
            }
        `;
        document.head.appendChild(style);
    }

    animateFog() {
        for (let i = 0; i < 30; i++) {
            this.particles.push({
                x: Math.random() * this.canvas.width,
                y: Math.random() * this.canvas.height,
                radius: Math.random() * 150 + 100,
                speedX: Math.random() * 0.5 - 0.25,
                speedY: Math.random() * 0.5 - 0.25,
                opacity: Math.random() * 0.03 + 0.02
            });
        }

        const animate = () => {
            this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

            this.particles.forEach(fog => {
                fog.x += fog.speedX;
                fog.y += fog.speedY;

                if (fog.x > this.canvas.width + fog.radius) fog.x = -fog.radius;
                if (fog.x < -fog.radius) fog.x = this.canvas.width + fog.radius;
                if (fog.y > this.canvas.height + fog.radius) fog.y = -fog.radius;
                if (fog.y < -fog.radius) fog.y = this.canvas.height + fog.radius;

                const gradient = this.ctx.createRadialGradient(
                    fog.x, fog.y, 0,
                    fog.x, fog.y, fog.radius
                );
                gradient.addColorStop(0, `rgba(255, 255, 255, ${fog.opacity})`);
                gradient.addColorStop(0.5, `rgba(255, 255, 255, ${fog.opacity * 0.5})`);
                gradient.addColorStop(1, 'rgba(255, 255, 255, 0)');

                this.ctx.fillStyle = gradient;
                this.ctx.fillRect(
                    fog.x - fog.radius,
                    fog.y - fog.radius,
                    fog.radius * 2,
                    fog.radius * 2
                );
            });

            this.animationId = requestAnimationFrame(animate);
        };
        animate();
    }

    animateWind() {
        this.particles.forEach(particle => {
            if (particle.wind !== undefined) {
                particle.wind = this.currentWeather.details.wind_speed / 10;
            }
        });
    }

    animateHeatWaves() {
        const heatWave = document.createElement('div');
        heatWave.className = 'heat-wave';
        this.effects.appendChild(heatWave);

        const style = document.createElement('style');
        style.textContent = `
            .heat-wave {
                position: absolute;
                bottom: 0;
                left: 0;
                width: 100%;
                height: 30%;
                background: linear-gradient(to top, 
                    rgba(255, 100, 0, 0.1) 0%, 
                    transparent 100%);
                filter: blur(40px);
                animation: heatShimmer 3s ease-in-out infinite;
            }
            @keyframes heatShimmer {
                0%, 100% { transform: translateY(0) scaleY(1); }
                50% { transform: translateY(-10px) scaleY(1.1); }
            }
        `;
        document.head.appendChild(style);
    }

    animateDust() {
        for (let i = 0; i < 100; i++) {
            this.particles.push({
                x: -50,
                y: Math.random() * this.canvas.height,
                size: Math.random() * 3 + 1,
                speedX: Math.random() * 5 + 3,
                speedY: Math.random() * 2 - 1,
                opacity: Math.random() * 0.3 + 0.1,
                rotation: Math.random() * Math.PI * 2,
                rotationSpeed: Math.random() * 0.1 - 0.05
            });
        }

        const animate = () => {
            this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

            this.particles.forEach(dust => {
                dust.x += dust.speedX;
                dust.y += dust.speedY;
                dust.rotation += dust.rotationSpeed;

                if (dust.x > this.canvas.width + 50) {
                    dust.x = -50;
                    dust.y = Math.random() * this.canvas.height;
                }

                this.ctx.save();
                this.ctx.translate(dust.x, dust.y);
                this.ctx.rotate(dust.rotation);

                this.ctx.fillStyle = `rgba(139, 69, 19, ${dust.opacity})`;
                this.ctx.fillRect(-dust.size / 2, -dust.size / 2, dust.size, dust.size);

                this.ctx.restore();
            });

            this.animationId = requestAnimationFrame(animate);
        };
        animate();
    }
}