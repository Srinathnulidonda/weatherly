// Wait for the DOM to be fully loaded
document.addEventListener('DOMContentLoaded', function () {
  // Use requestAnimationFrame for better performance on mobile
  requestAnimationFrame(function () {
    // Initialize components with performance considerations
    initializeHeroSlider();
    initializeNotificationBanner();
    initializeAboutSection();

    // Initialize AOS with mobile-optimized settings
    if (typeof AOS !== 'undefined') {
      AOS.init({
        duration: 800,         // Slightly faster animations for mobile
        once: true,            // Only animate once for better performance
        offset: 50,            // Smaller offset works better on small screens
        disable: 'mobile',     // Disable on mobile if performance issues
        startEvent: 'DOMContentLoaded' // Start earlier
      });
    }
  });

  // Register service worker for better mobile performance if supported
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('/sw.js').catch(function (error) {
      console.log('Service Worker registration failed:', error);
    });
  }
});

/**
* Initialize the Hero Slider with Bootstrap Carousel
* Optimized for mobile devices
*/
function initializeHeroSlider() {
  // Get the hero slider element
  const heroSlider = document.getElementById('heroSlider');

  // If Bootstrap is loaded, we can use its JavaScript API
  if (heroSlider && typeof bootstrap !== 'undefined') {
    // Initialize the Bootstrap Carousel with mobile-friendly settings
    const carousel = new bootstrap.Carousel(heroSlider, {
      interval: 7000,     // Longer interval for mobile (less distracting)
      pause: 'hover',     // Pause on mouse hover
      wrap: true,         // Cycle continuously
      keyboard: true,     // Allow keyboard navigation
      touch: true         // Enable touch support natively
    });

    // Add enhanced swipe support for touch devices
    addSwipeSupport(heroSlider, carousel);

    // Add passive event listeners for better scroll performance
    heroSlider.addEventListener('touchstart', function () { }, { passive: true });
    heroSlider.addEventListener('touchmove', function () { }, { passive: true });
  }

  // Optimize images for mobile - use responsive images
  const slides = document.querySelectorAll('.carousel-item img');
  if (slides.length > 0) {
    // Only preload the next image, not all (conserve bandwidth)
    if (slides.length > 1) {
      const nextImg = new Image();
      nextImg.src = slides[1].src;
    }

    // Check if we're on a mobile device based on screen width
    const isMobile = window.innerWidth < 768;

    // Add appropriate classes for responsive images
    slides.forEach(img => {
      if (isMobile && img.dataset.mobileSrc) {
        img.src = img.dataset.mobileSrc;
      }
    });
  }
}

/**
* Add enhanced swipe support for the carousel on touch devices
* @param {HTMLElement} element - The carousel element
* @param {Object} carousel - The Bootstrap carousel instance
*/
function addSwipeSupport(element, carousel) {
  let touchStartX = 0;
  let touchEndX = 0;
  let touchStartY = 0;
  let touchEndY = 0;

  // Detect touch start with passive listener for better performance
  element.addEventListener('touchstart', function (e) {
    touchStartX = e.changedTouches[0].screenX;
    touchStartY = e.changedTouches[0].screenY;
  }, { passive: true });

  // Detect touch end and determine direction
  element.addEventListener('touchend', function (e) {
    touchEndX = e.changedTouches[0].screenX;
    touchEndY = e.changedTouches[0].screenY;
    handleSwipe();
  }, { passive: true });

  // Handle the swipe based on direction, ensuring vertical scrolls aren't affected
  function handleSwipe() {
    const xDiff = touchEndX - touchStartX;
    const yDiff = touchEndY - touchStartY;

    // Only register as horizontal swipe if x movement is greater than y movement
    if (Math.abs(xDiff) > Math.abs(yDiff)) {
      if (xDiff < -50) {
        // Swipe left, go to next slide
        carousel.next();
      } else if (xDiff > 50) {
        // Swipe right, go to previous slide
        carousel.prev();
      }
    }
  }
}

/**
* Initialize the Notification Banner with optimized marquee animation
*/
function initializeNotificationBanner() {
  const marqueeElement = document.querySelector('.marquee');

  if (!marqueeElement) return;

  // Use IntersectionObserver to only animate when visible
  if ('IntersectionObserver' in window) {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          // Start animation when visible
          startMarquee(marqueeElement);
        } else {
          // Pause animation when not visible to save resources
          pauseMarquee(marqueeElement);
        }
      });
    });

    observer.observe(marqueeElement);
  } else {
    // Fallback for browsers that don't support IntersectionObserver
    startMarquee(marqueeElement);
  }
}

/**
* Start the marquee animation with optimized settings
* @param {HTMLElement} marqueeElement - The marquee element
*/
function startMarquee(marqueeElement) {
  // Clone the marquee content for smoother infinite scrolling
  const content = marqueeElement.innerHTML;
  marqueeElement.innerHTML = content + content;

  // Pause marquee on hover/touch
  const marqueeContainer = document.querySelector('.marquee-container');
  if (marqueeContainer) {
    marqueeContainer.addEventListener('mouseenter', function () {
      marqueeElement.style.animationPlayState = 'paused';
    });

    marqueeContainer.addEventListener('mouseleave', function () {
      marqueeElement.style.animationPlayState = 'running';
    });

    // Add touch support for mobile
    marqueeContainer.addEventListener('touchstart', function () {
      marqueeElement.style.animationPlayState = 'paused';
    }, { passive: true });

    marqueeContainer.addEventListener('touchend', function () {
      marqueeElement.style.animationPlayState = 'running';
    }, { passive: true });
  }

  // Adjust animation speed based on content length and device
  const isMobile = window.innerWidth < 768;
  const textWidth = marqueeElement.scrollWidth / 2;
  // Slower animation on mobile to make it easier to read
  const duration = isMobile ? Math.max(textWidth / 30, 15) : Math.max(textWidth / 50, 10);
  marqueeElement.style.animationDuration = duration + 's';

  // Use transform instead of left for better performance
  marqueeElement.style.animationName = 'marquee-transform';
}

/**
* Pause the marquee animation to save resources
* @param {HTMLElement} marqueeElement - The marquee element
*/
function pauseMarquee(marqueeElement) {
  marqueeElement.style.animationPlayState = 'paused';
}

/**
* Initialize the About Section with interactive features
* Optimized for mobile
*/
function initializeAboutSection() {
  // Add touch effects to feature items
  const featureItems = document.querySelectorAll('.feature-item');

  featureItems.forEach(item => {
    // Add focus accessibility for keyboard navigation
    item.setAttribute('tabindex', '0');

    // Use click for mobile instead of hover
    item.addEventListener('click', function () {
      animateFeatureIcon(this);
    });

    // Still use mouseenter for desktop
    item.addEventListener('mouseenter', function () {
      animateFeatureIcon(this);
    });
  });

  // Make "Discover Our Story" button interactive for touch
  const discoverButton = document.querySelector('.animated-btn');
  if (discoverButton) {
    // Use touchstart for mobile
    discoverButton.addEventListener('touchstart', function () {
      const icon = this.querySelector('i');
      if (icon) {
        icon.classList.add('fa-bounce');
      }
    }, { passive: true });

    // Use touchend for mobile
    discoverButton.addEventListener('touchend', function () {
      const icon = this.querySelector('i');
      if (icon) {
        icon.classList.remove('fa-bounce');
      }
    }, { passive: true });

    // Keep mouse events for desktop
    discoverButton.addEventListener('mouseenter', function () {
      const icon = this.querySelector('i');
      if (icon) {
        icon.classList.add('fa-bounce');
      }
    });

    discoverButton.addEventListener('mouseleave', function () {
      const icon = this.querySelector('i');
      if (icon) {
        icon.classList.remove('fa-bounce');
      }
    });
  }

  // Lazy load images with better mobile support
  lazyLoadImages();
}

/**
* Animate feature icon with performance considerations
* @param {HTMLElement} element - The feature item element
*/
function animateFeatureIcon(element) {
  const icon = element.querySelector('i');
  if (icon && !icon.classList.contains('fa-beat')) {
    icon.classList.add('fa-beat');
    setTimeout(() => {
      icon.classList.remove('fa-beat');
    }, 1000);
  }
}

/**
* Implement lazy loading for images with better mobile support
*/
function lazyLoadImages() {
  // Check if the browser supports Intersection Observer
  if ('IntersectionObserver' in window) {
    const imgObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const img = entry.target;

          // Check if we should load mobile-specific image
          const isMobile = window.innerWidth < 768;
          if (isMobile && img.dataset.mobileSrc) {
            img.src = img.dataset.mobileSrc;
          } else if (img.dataset.src) {
            img.src = img.dataset.src;
          }

          img.removeAttribute('data-src');
          img.removeAttribute('data-mobile-src');

          // Add fade-in effect
          img.classList.add('fade-in');

          observer.unobserve(img);
        }
      });
    }, {
      rootMargin: '50px', // Load images earlier for mobile
      threshold: 0.1      // Trigger earlier
    });

    // Target all images that need lazy loading
    const lazyImages = document.querySelectorAll('img[data-src]');
    lazyImages.forEach(img => {
      imgObserver.observe(img);
    });
  } else {
    // Fallback for browsers without IntersectionObserver
    // Load images immediately but with a small delay to not block rendering
    setTimeout(function () {
      const lazyImages = document.querySelectorAll('img[data-src]');
      lazyImages.forEach(img => {
        if (window.innerWidth < 768 && img.dataset.mobileSrc) {
          img.src = img.dataset.mobileSrc;
        } else if (img.dataset.src) {
          img.src = img.dataset.src;
        }
        img.removeAttribute('data-src');
        img.removeAttribute('data-mobile-src');
      });
    }, 300);
  }
}

/**
* Debounced window resize handler for better performance
*/
const debouncedResize = debounce(function () {
  // Adjust notification banner for small screens
  const notificationWrapper = document.querySelector('.notification-wrapper');
  if (notificationWrapper) {
    if (window.innerWidth < 768) {
      notificationWrapper.classList.add('flex-column', 'align-items-start');
    } else {
      notificationWrapper.classList.remove('flex-column', 'align-items-start');
    }
  }

  // Reinitialize AOS on resize for proper animations
  if (typeof AOS !== 'undefined') {
    AOS.refresh();
  }
}, 250);

window.addEventListener('resize', debouncedResize);

/**
* Simple debounce function to limit how often a function runs
* @param {Function} func - The function to debounce
* @param {number} wait - The debounce time in milliseconds
* @return {Function} - The debounced function
*/
function debounce(func, wait) {
  let timeout;
  return function () {
    const context = this;
    const args = arguments;
    clearTimeout(timeout);
    timeout = setTimeout(function () {
      func.apply(context, args);
    }, wait);
  };
}

/**
* Optimized back to top button functionality
* Using IntersectionObserver instead of scroll event for better performance
*/
if ('IntersectionObserver' in window) {
  const backToTopButton = document.querySelector('.back-to-top');
  if (backToTopButton) {
    // Create a marker element to observe
    const marker = document.createElement('div');
    marker.style.position = 'absolute';
    marker.style.top = '300px';
    marker.style.left = '0';
    marker.style.width = '1px';
    marker.style.height = '1px';
    marker.style.pointerEvents = 'none';
    document.body.appendChild(marker);

    const observer = new IntersectionObserver((entries) => {
      // Show/hide button based on marker visibility
      if (entries[0].isIntersecting) {
        backToTopButton.classList.remove('show');
      } else {
        backToTopButton.classList.add('show');
      }
    }, {
      threshold: 0
    });

    observer.observe(marker);

    // Handle back to top action with smooth scroll
    backToTopButton.addEventListener('click', function (e) {
      e.preventDefault();
      window.scrollTo({
        top: 0,
        behavior: 'smooth'
      });
    });
  }
} else {
  // Fallback to scroll event for older browsers
  window.addEventListener('scroll', function () {
    const backToTopButton = document.querySelector('.back-to-top');
    if (backToTopButton) {
      if (window.pageYOffset > 300) {
        backToTopButton.classList.add('show');
      } else {
        backToTopButton.classList.remove('show');
      }
    }
  }, { passive: true }); // Passive listener for better performance
}

/**
* Add any necessary polyfills for older mobile browsers
*/
(function () {
  // Polyfill for requestAnimationFrame
  if (!window.requestAnimationFrame) {
    window.requestAnimationFrame = function (callback) {
      return setTimeout(callback, 16); // 60fps equivalent
    };
  }
})();

/**
* Add mobile-specific CSS rules dynamically
*/
(function addMobileStyles() {
  if (window.innerWidth < 768) {
    const mobileStyles = document.createElement('style');
    mobileStyles.innerHTML = `
          .feature-item { 
              padding: 15px 10px;
              margin-bottom: 15px; 
          }
          .carousel-item img {
              max-height: 300px;
              object-fit: cover;
          }
          .marquee {
              font-size: 14px;
          }
          .back-to-top {
              right: 15px;
              bottom: 15px;
          }
          /* Define transform-based marquee animation */
          @keyframes marquee-transform {
              0% { transform: translateX(0); }
              100% { transform: translateX(-50%); }
          }
      `;
    document.head.appendChild(mobileStyles);
  }
})();