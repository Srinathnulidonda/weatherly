const WeatherAnimations = {
    activeAnimation: null,
    animationFrame: null,
    particleSystem: null,

    config: {
        rain: {
            particleCount: 150,
            particleSize: { width: 2, height: 15 },
            speed: { min: 600, max: 1000 },
            angle: 10,
            opacity: { min: 0.4, max: 0.7 }
        },
        snow: {
            particleCount: 100,
            particleSize: { min: 5, max: 15 },
            speed: { min: 50, max: 150 },
            swayAmount: 50,
            opacity: { min: 0.4, max: 0.9 }
        },
        thunderstorm: {
            lightningInterval: { min: 3000, max: 8000 },
            lightningDuration: 300,
            flashOpacity: 0.8
        },
        fog: {
            layers: 3,
            opacity: { min: 0.1, max: 0.3 },
            speed: 20
        },
        clouds: {
            count: 6,
            size: { min: 100, max: 300 },
            speed: { min: 20, max: 60 },
            opacity: { min: 0.3, max: 0.7 }
        }
    },

    clear() {
        if (this.animationFrame) {
            cancelAnimationFrame(this.animationFrame);
            this.animationFrame = null;
        }

        if (this.particleSystem) {
            this.particleSystem.destroy();
            this.particleSystem = null;
        }

        const container = document.getElementById('weather-effects');
        container.innerHTML = '';
        container.style.filter = '';
    },

    createRain() {
        this.clear();
        const container = document.getElementById('weather-effects');
        const config = this.config.rain;

        this.particleSystem = new ParticleSystem(container, {
            type: 'rain',
            count: config.particleCount,
            create: () => {
                const drop = document.createElement('div');
                drop.className = 'raindrop';
                drop.style.cssText = `
                    position: absolute;
                    width: ${config.particleSize.width}px;
                    height: ${config.particleSize.height}px;
                    background: linear-gradient(to bottom, transparent, rgba(174, 194, 224, 0.6));
                    border-radius: 0 0 50% 50%;
                    transform: rotate(${config.angle}deg);
                    pointer-events: none;
                `;
                return drop;
            },
            update: (particle, deltaTime) => {
                const speed = particle.speed || (Math.random() *
                    (config.speed.max - config.speed.min) + config.speed.min);
                const x = parseFloat(particle.style.left);
                const y = parseFloat(particle.style.top);

                const newY = y + (speed * deltaTime / 1000);
                const newX = x + (config.angle * deltaTime / 1000);

                if (newY > window.innerHeight) {
                    // Create splash effect
                    this.createRainSplash(x, window.innerHeight - 20);
                    // Reset position
                    particle.style.left = Math.random() * window.innerWidth + 'px';
                    particle.style.top = '-20px';
                    particle.speed = speed;
                } else {
                    particle.style.top = newY + 'px';
                    particle.style.left = newX + 'px';
                }

                particle.style.opacity = Math.random() *
                    (config.opacity.max - config.opacity.min) + config.opacity.min;
            }
        });

        this.particleSystem.start();
    },

    createRainSplash(x, y) {
        const container = document.getElementById('weather-effects');
        const splash = document.createElement('div');
        splash.style.cssText = `
            position: absolute;
            left: ${x}px;
            top: ${y}px;
            width: 20px;
            height: 10px;
            border: 2px solid rgba(174, 194, 224, 0.4);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            pointer-events: none;
        `;
        container.appendChild(splash);

        // Animate splash
        let scale = 1;
        let opacity = 0.4;
        const animate = () => {
            scale += 0.2;
            opacity -= 0.05;

            if (opacity <= 0) {
                splash.remove();
                return;
            }

            splash.style.transform = `translate(-50%, -50%) scale(${scale}, ${scale * 0.3})`;
            splash.style.opacity = opacity;
            requestAnimationFrame(animate);
        };
        requestAnimationFrame(animate);
    },

    createSnow() {
        this.clear();
        const container = document.getElementById('weather-effects');
        const config = this.config.snow;

        const snowflakeSymbols = ['❄', '❅', '❆'];

        this.particleSystem = new ParticleSystem(container, {
            type: 'snow',
            count: config.particleCount,
            create: () => {
                const flake = document.createElement('div');
                flake.className = 'snowflake';
                flake.textContent = snowflakeSymbols[Math.floor(Math.random() * snowflakeSymbols.length)];

                const size = Math.random() *
                    (config.particleSize.max - config.particleSize.min) + config.particleSize.min;

                flake.style.cssText = `
                    position: absolute;
                    color: white;
                    font-size: ${size}px;
                    text-shadow: 0 0 5px rgba(255, 255, 255, 0.8);
                    pointer-events: none;
                    user-select: none;
                `;

                flake.swayOffset = Math.random() * Math.PI * 2;
                flake.swaySpeed = Math.random() * 2 + 1;
                flake.fallSpeed = Math.random() *
                    (config.speed.max - config.speed.min) + config.speed.min;

                return flake;
            },
            update: (particle, deltaTime) => {
                const y = parseFloat(particle.style.top);
                const time = Date.now() / 1000;

                // Sway motion
                const swayX = Math.sin(time * particle.swaySpeed + particle.swayOffset) * config.swayAmount;

                const newY = y + (particle.fallSpeed * deltaTime / 1000);

                if (newY > window.innerHeight) {
                    particle.style.left = Math.random() * window.innerWidth + 'px';
                    particle.style.top = '-30px';
                } else {
                    particle.style.top = newY + 'px';
                    particle.style.transform = `translateX(${swayX}px) rotate(${time * 50}deg)`;
                }

                particle.style.opacity = Math.random() *
                    (config.opacity.max - config.opacity.min) + config.opacity.min;
            }
        });

        this.particleSystem.start();
    },

    createClouds() {
        this.clear();
        const container = document.getElementById('weather-effects');
        const config = this.config.clouds;

        for (let i = 0; i < config.count; i++) {
            const cloud = this.createCloud();
            const size = Math.random() *
                (config.size.max - config.size.min) + config.size.min;
            const speed = Math.random() *
                (config.speed.max - config.speed.min) + config.speed.min;
            const opacity = Math.random() *
                (config.opacity.max - config.opacity.min) + config.opacity.min;

            cloud.style.cssText += `
                width: ${size}px;
                height: ${size * 0.6}px;
                top: ${Math.random() * 60}%;
                opacity: ${opacity};
                animation: drift ${speed}s linear infinite;
            `;

            container.appendChild(cloud);
        }

        // Add drift animation
        if (!document.getElementById('drift-animation')) {
            const style = document.createElement('style');
            style.id = 'drift-animation';
            style.textContent = `
                @keyframes drift {
                    from {
                        transform: translateX(-100%);
                    }
                    to {
                        transform: translateX(calc(100vw + 100%));
                    }
                }
            `;
            document.head.appendChild(style);
        }
    },

    createCloud() {
        const cloud = document.createElement('div');
        cloud.className = 'cloud';
        cloud.style.cssText = `
            position: absolute;
            background: rgba(255, 255, 255, 0.7);
            border-radius: 100px;
            filter: blur(2px);
            pointer-events: none;
        `;

        // Create cloud puffs
        const puffCount = 3 + Math.floor(Math.random() * 3);
        for (let i = 0; i < puffCount; i++) {
            const puff = document.createElement('div');
            const size = 40 + Math.random() * 40;
            const x = i * 30 - 20 + Math.random() * 40;
            const y = Math.random() * 20 - 10;

            puff.style.cssText = `
                position: absolute;
                width: ${size}px;
                height: ${size}px;
                background: rgba(255, 255, 255, 0.7);
                border-radius: 50%;
                left: ${x}px;
                top: ${y}px;
            `;
            cloud.appendChild(puff);
        }

        return cloud;
    },

    createThunderstorm() {
        this.createRain();
        const container = document.getElementById('weather-effects');
        const config = this.config.thunderstorm;

        // Darken the scene
        container.style.filter = 'brightness(0.7)';

        const createLightning = () => {
            if (this.activeAnimation !== 'thunderstorm') return;

            const flash = document.createElement('div');
            flash.style.cssText = `
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: white;
                opacity: 0;
                pointer-events: none;
                z-index: 1000;
            `;
            document.body.appendChild(flash);

            // Create lightning bolt
            const bolt = document.createElement('div');
            const x = Math.random() * window.innerWidth;
            bolt.style.cssText = `
                position: absolute;
                left: ${x}px;
                top: 0;
                width: 2px;
                height: 60%;
                background: white;
                box-shadow: 0 0 10px 5px rgba(255, 255, 255, 0.8);
                clip-path: polygon(
                    0 0, 60% 40%, 40% 40%, 100% 100%, 
                    40% 60%, 60% 60%, 0 0
                );
                pointer-events: none;
            `;
            container.appendChild(bolt);

            // Animate flash
            flash.style.transition = `opacity ${config.lightningDuration}ms`;
            flash.style.opacity = config.flashOpacity;

            setTimeout(() => {
                flash.style.opacity = '0';
                bolt.remove();
                setTimeout(() => flash.remove(), config.lightningDuration);
            }, 50);

            // Thunder sound effect (optional)
            this.playThunderSound();

            // Schedule next lightning
            const nextInterval = Math.random() *
                (config.lightningInterval.max - config.lightningInterval.min) +
                config.lightningInterval.min;
            setTimeout(createLightning, nextInterval);
        };

        // Start lightning after a delay
        setTimeout(createLightning, 2000);
    },

    createFog() {
        this.clear();
        const container = document.getElementById('weather-effects');
        const config = this.config.fog;

        for (let i = 0; i < config.layers; i++) {
            const fog = document.createElement('div');
            fog.className = 'fog-layer';

            const opacity = config.opacity.min +
                (config.opacity.max - config.opacity.min) * (i / config.layers);

            fog.style.cssText = `
                position: absolute;
                top: ${i * 33}%;
                left: -100%;
                width: 300%;
                height: 40%;
                background: linear-gradient(to right, 
                    transparent, 
                    rgba(220, 220, 220, ${opacity}),
                    rgba(220, 220, 220, ${opacity}),
                    transparent
                );
                filter: blur(40px);
                animation: fog-drift ${config.speed + i * 5}s linear infinite;
                pointer-events: none;
            `;

            container.appendChild(fog);
        }

        // Add fog animation
        if (!document.getElementById('fog-animation')) {
            const style = document.createElement('style');
            style.id = 'fog-animation';
            style.textContent = `
                @keyframes fog-drift {
                    from {
                        transform: translateX(0);
                    }
                    to {
                        transform: translateX(33.33%);
                    }
                }
            `;
            document.head.appendChild(style);
        }
    },

    playThunderSound() {
        // Optional: Add thunder sound effect
        // const audio = new Audio('/sounds/thunder.mp3');
        // audio.volume = 0.5;
        // audio.play().catch(e => console.log('Thunder sound failed:', e));
    },

    startAnimation(weatherCategory) {
        this.activeAnimation = weatherCategory;

        switch (weatherCategory) {
            case 'rain':
                this.createRain();
                break;
            case 'snow':
                this.createSnow();
                break;
            case 'cloudy':
                this.createClouds();
                break;
            case 'thunderstorm':
                this.createThunderstorm();
                break;
            case 'fog':
                this.createFog();
                break;
            default:
                this.clear();
        }
    }
};

// Particle System for efficient animation handling
class ParticleSystem {
    constructor(container, options) {
        this.container = container;
        this.options = options;
        this.particles = [];
        this.isRunning = false;
        this.lastTime = 0;
    }

    start() {
        this.isRunning = true;

        // Create initial particles
        for (let i = 0; i < this.options.count; i++) {
            const particle = this.options.create();
            particle.style.left = Math.random() * window.innerWidth + 'px';
            particle.style.top = Math.random() * window.innerHeight - window.innerHeight + 'px';
            this.container.appendChild(particle);
            this.particles.push(particle);
        }

        // Start animation loop
        this.animate(0);
    }

    animate(currentTime) {
        if (!this.isRunning) return;

        const deltaTime = currentTime - this.lastTime;
        this.lastTime = currentTime;

        // Update all particles
        this.particles.forEach(particle => {
            if (this.options.update) {
                this.options.update(particle, deltaTime);
            }
        });

        WeatherAnimations.animationFrame = requestAnimationFrame((time) => this.animate(time));
    }

    destroy() {
        this.isRunning = false;
        this.particles.forEach(particle => particle.remove());
        this.particles = [];
    }
}