// Chat Bot Implementation (Mobile-Friendly)
document.addEventListener('DOMContentLoaded', () => {
    // Add chatbot HTML if it doesn't exist
    if (!document.querySelector('.chatbot-container')) {
        const chatbotHTML = `
            <div class="chatbot-container">
                <div class="chatbot-button" aria-label="Open chat">
                    <i class="fas fa-comments"></i>
                </div>
                <div class="chatbot-box">
                    <div class="chatbot-header">
                        <h3>Chat Support</h3>
                        <button class="chatbot-close" aria-label="Close chat">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                    <div class="chatbot-messages">
                        <div class="message bot">
                            <div class="message-content">Hello! How can I help you today?</div>
                        </div>
                    </div>
                    <form class="chatbot-input-form">
                        <input 
                            type="text" 
                            class="chatbot-input" 
                            placeholder="Type your message..." 
                            aria-label="Type your message"
                        >
                        <button type="submit" class="chatbot-send" aria-label="Send message">
                            <i class="fas fa-paper-plane"></i>
                        </button>
                    </form>
                </div>
            </div>
        `;
        document.body.insertAdjacentHTML('beforeend', chatbotHTML);
    }

    // Chatbot elements
    const chatbotButton = document.querySelector('.chatbot-button');
    const chatbotBox = document.querySelector('.chatbot-box');
    const chatbotClose = document.querySelector('.chatbot-close');
    const chatbotForm = document.querySelector('.chatbot-input-form');
    const chatbotInput = document.querySelector('.chatbot-input');
    const chatbotMessages = document.querySelector('.chatbot-messages');

    if (!chatbotButton || !chatbotBox) return;

    // Toggle chatbot visibility
    chatbotButton.addEventListener('click', () => {
        chatbotBox.classList.add('active');
        chatbotButton.classList.add('hidden');
        chatbotInput.focus();
    });

    chatbotClose.addEventListener('click', () => {
        chatbotBox.classList.remove('active');
        chatbotButton.classList.remove('hidden');
    });

    // Simple responses (can be expanded to use an API)
    const botResponses = {
        'hi': 'Hello! How can I help you today?',
        'hello': 'Hi there! What can I assist you with?',
        'help': 'I can help with information about our services, pricing, or scheduling. What would you like to know?',
        'contact': 'You can reach our team at contact@example.com or call us at (123) 456-7890.',
        'pricing': 'Our pricing plans start at $29.99 per month. Would you like more details about our packages?',
        'hours': 'We are open Monday to Friday, 9 AM to 5 PM EST.',
        'thanks': 'You\'re welcome! Is there anything else I can help with?',
        'thank you': 'You\'re welcome! Is there anything else I can help with?',
        'bye': 'Goodbye! Feel free to chat again if you have more questions.'
    };

    // Default response for unrecognized messages
    const defaultResponse = "I'm sorry, I don't understand that. Can you try rephrasing or ask about our services, pricing, or contact information?";

    // Process user message
    const processMessage = (message) => {
        message = message.toLowerCase().trim();

        // Check for matching keywords
        for (const [key, response] of Object.entries(botResponses)) {
            if (message.includes(key)) {
                return response;
            }
        }

        return defaultResponse;
    };

    // Add message to chat
    const addMessage = (content, isUser = false) => {
        const messageClass = isUser ? 'user' : 'bot';
        const messageHTML = `
            <div class="message ${messageClass}">
                <div class="message-content">${content}</div>
            </div>
        `;
        chatbotMessages.insertAdjacentHTML('beforeend', messageHTML);
        chatbotMessages.scrollTop = chatbotMessages.scrollHeight;
    };

    // Handle form submission
    chatbotForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const message = chatbotInput.value.trim();
        if (!message) return;

        // Add user message
        addMessage(message, true);
        chatbotInput.value = '';

        // Simulate typing delay
        setTimeout(() => {
            const botResponse = processMessage(message);
            addMessage(botResponse);
        }, 500 + Math.random() * 500); // Random delay between 500-1000ms
    });

    // Close chatbot when clicking outside
    document.addEventListener('click', (e) => {
        if (
            chatbotBox.classList.contains('active') &&
            !chatbotBox.contains(e.target) &&
            e.target !== chatbotButton
        ) {
            chatbotBox.classList.remove('active');
            chatbotButton.classList.remove('hidden');
        }
    });
});