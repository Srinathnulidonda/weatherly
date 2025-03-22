// Utility: Debounce function for performance
const debounce = (func, wait) => {
    let timeout;
    return (...args) => {
        clearTimeout(timeout);
        timeout = setTimeout(() => func(...args), wait);
    };
};

// Service Worker Registration (Lazy Load)
if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        // Delay SW registration slightly for faster initial load
        setTimeout(() => {
            navigator.serviceWorker.register('/sw.js')
                .then(reg => console.log('SW registered:', reg.scope))
                .catch(err => console.error('SW failed:', err));
        }, 100);
    });
}

// Navbar Active Link Highlight (Efficient)
// document.addEventListener('DOMContentLoaded', () => {
//     const navLinks = document.querySelectorAll('.navbar-nav .nav-link');
//     const currentPath = window.location.pathname;

//     navLinks.forEach(link => {
//         link.classList.toggle('active',
//             link.getAttribute('href') === currentPath ||
//             (currentPath === '/' && link.getAttribute('href') === '/index.html')
//         );
//     });
// });

// AOS Initialization (Optimized)
document.addEventListener('DOMContentLoaded', () => {
    AOS.init({
        duration: 800, // Faster animation for smoothness
        once: true,
        offset: 80,    // Trigger earlier for better UX
        easing: 'ease-out-quart', // Smoother easing
        disable: 'mobile' // Disable on mobile for performance
    });
});

// Counter Animation (jQuery-Free, Smooth)
document.addEventListener('DOMContentLoaded', () => {
    const counters = document.querySelectorAll('.counter');
    if (!counters.length) return;

    const animateCounter = (el, start, end, duration) => {
        let startTime = null;
        const step = (timestamp) => {
            if (!startTime) startTime = timestamp;
            const progress = Math.min((timestamp - startTime) / duration, 1);
            const easedProgress = 1 - Math.pow(1 - progress, 4); // Ease-out-quart
            el.textContent = Math.floor(easedProgress * (end - start) + start);
            if (progress < 1) requestAnimationFrame(step);
        };
        requestAnimationFrame(step);
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const counter = entry.target;
                const end = parseInt(counter.getAttribute('data-count'), 10);
                if (!isNaN(end)) animateCounter(counter, 0, end, 2000);
                observer.unobserve(counter);
            }
        });
    }, { threshold: 0.5 });

    counters.forEach(counter => observer.observe(counter));
});

// Form Submission Handling (Lightweight)
document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('contactForm');
    if (!form) return;

    form.addEventListener('submit', (e) => {
        e.preventDefault();
        const modal = document.getElementById('successModal');
        if (modal) {
            new bootstrap.Modal(modal).show();
            form.reset();
        }
    });
});

// Back to Top Button (Smooth Scroll with Enhanced Visibility Controls)
document.addEventListener('DOMContentLoaded', () => {
    const backToTop = document.querySelector('.back-to-top');
    if (!backToTop) return;

    // Add a class to control visibility through CSS transitions
    const scrollHandler = debounce(() => {
        backToTop.classList.toggle('visible', window.scrollY > 300);
    }, 50); // Debounced for performance

    window.addEventListener('scroll', scrollHandler);

    backToTop.addEventListener('click', (e) => {
        e.preventDefault();
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    });

    // Check initial scroll position
    scrollHandler();

    // Accessibility enhancement - hide from screen readers when not visible
    const observer = new MutationObserver((mutations) => {
        mutations.forEach((mutation) => {
            if (mutation.attributeName === 'class') {
                const isVisible = backToTop.classList.contains('visible');
                backToTop.setAttribute('aria-hidden', !isVisible);
            }
        });
    });

    observer.observe(backToTop, { attributes: true });
});

// Sticky Header (Efficient)
let lastScroll = 0;
const header = document.querySelector('.header');
if (header) {
    const stickyHandler = debounce(() => {
        const currentScroll = window.scrollY;
        header.classList.toggle('sticky', currentScroll > 50 && currentScroll <= lastScroll);
        lastScroll = currentScroll;
    }, 20);

    window.addEventListener('scroll', stickyHandler);
}