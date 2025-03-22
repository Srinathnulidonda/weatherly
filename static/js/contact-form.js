document.addEventListener('DOMContentLoaded', function() {
    // Get the contact form element
    const contactForm = document.getElementById('contactForm');
    const formResponse = document.getElementById('formResponse');
    
    // Add submit event listener to the form
    if (contactForm) {
        // Set up the form to use formsubmit.co
        contactForm.setAttribute('action', 'https://formsubmit.co/todolist.notification@gmail.com');
        contactForm.setAttribute('method', 'POST');
        
        // Add necessary formsubmit.co fields
        const formSubmitFields = `
            <input type="hidden" name="_subject" value="New Contact Form Submission - Nalanda High School">
            <input type="hidden" name="_captcha" value="false">
            <input type="hidden" name="_next" value="${window.location.href}?submitted=true">
            <input type="hidden" name="_template" value="box">
            <input type="hidden" name="_autoresponse" value="Thank you for contacting Nalanda High School. We have received your message and will get back to you as soon as possible.">
        `;
        contactForm.insertAdjacentHTML('afterbegin', formSubmitFields);
        
        contactForm.addEventListener('submit', function(event) {
            // Prevent default to do our validation first
            event.preventDefault();
            
            // Validate the form
            let isValid = true;
            const formInputs = contactForm.querySelectorAll('input[required], textarea[required], select[required]');
            
            formInputs.forEach(input => {
                if (!validateField(input)) {
                    isValid = false;
                }
            });
            
            if (!isValid) {
                showFormMessage('Please fill in all required fields correctly.', 'error');
                return;
            }
            
            // Clear any existing response messages
            if (formResponse) {
                formResponse.style.display = 'none';
            }
            
            // Submit the form directly
            contactForm.submit();
        });
    }
    
    // Function to show form response message
    function showFormMessage(message, type) {
        if (formResponse) {
            formResponse.textContent = message;
            formResponse.style.display = 'block';
            
            // Clear any existing classes and add new ones
            formResponse.className = 'alert';
            
            switch(type) {
                case 'success':
                    formResponse.classList.add('alert-success');
                    break;
                case 'error':
                    formResponse.classList.add('alert-danger');
                    break;
                case 'info':
                    formResponse.classList.add('alert-info');
                    break;
                default:
                    formResponse.classList.add('alert-secondary');
            }
            
            // Scroll to the response message
            formResponse.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }
    }
    
    // Function to show success modal
    function showSuccessModal() {
        // Check if Bootstrap is available
        if (typeof bootstrap !== 'undefined') {
            const successModal = new bootstrap.Modal(document.getElementById('successModal'));
            successModal.show();
        } else {
            // Fallback if Bootstrap's JS is not available
            const modal = document.getElementById('successModal');
            if (modal) {
                modal.classList.add('show');
                modal.style.display = 'block';
                document.body.classList.add('modal-open');
                
                // Add backdrop
                const backdrop = document.createElement('div');
                backdrop.classList.add('modal-backdrop', 'fade', 'show');
                document.body.appendChild(backdrop);
                
                // Add close functionality
                const closeButtons = modal.querySelectorAll('[data-bs-dismiss="modal"]');
                closeButtons.forEach(button => {
                    button.addEventListener('click', function() {
                        modal.classList.remove('show');
                        modal.style.display = 'none';
                        document.body.classList.remove('modal-open');
                        if (document.querySelector('.modal-backdrop')) {
                            document.body.removeChild(document.querySelector('.modal-backdrop'));
                        }
                    });
                });
            }
        }
    }
    
    // Add form field validation
    if (contactForm) {
        const formInputs = contactForm.querySelectorAll('input, textarea, select');
        formInputs.forEach(input => {
            input.addEventListener('blur', function() {
                validateField(this);
            });
            
            input.addEventListener('input', function() {
                // Remove error styling when user starts typing
                this.classList.remove('is-invalid');
            });
        });
    }
    
    // Function to validate individual form fields
    function validateField(field) {
        if (field.hasAttribute('required') && !field.value.trim()) {
            field.classList.add('is-invalid');
            return false;
        }
        
        if (field.type === 'email' && field.value) {
            const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailPattern.test(field.value)) {
                field.classList.add('is-invalid');
                return false;
            }
        }
        
        if (field.id === 'phone' && field.value) {
            const phonePattern = /^\d{10}$/;
            if (!phonePattern.test(field.value.replace(/\D/g, ''))) {
                field.classList.add('is-invalid');
                return false;
            }
        }
        
        field.classList.remove('is-invalid');
        field.classList.add('is-valid');
        return true;
    }
    
    // Add some hover effects to social links
    const socialLinks = document.querySelectorAll('.social-links a');
    socialLinks.forEach(link => {
        link.addEventListener('mouseenter', function() {
            this.style.backgroundColor = '#ff8c00';
            this.style.transform = 'translateY(-3px)';
        });
        
        link.addEventListener('mouseleave', function() {
            this.style.backgroundColor = 'rgba(255, 140, 0, 0.8)';
            this.style.transform = 'translateY(0)';
        });
    });
    
    // Check if user is returning after form submission (from the redirect)
    window.addEventListener('load', function() {
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.has('submitted')) {
            // Show the success modal
            showSuccessModal();
            
            // Remove the query parameter without refreshing the page
            const newUrl = window.location.pathname;
            window.history.replaceState({}, document.title, newUrl);
        }
    });
});