const axios = require('axios');

// HTTP Request Helper
class HttpRequestHelper {
    static async handleRequest(method, requestUrl, requestBody = null, headers = {}) {
        try {
            const config = {
                method,
                url: requestUrl,
                headers: {
                    'Content-Type': 'application/json',
                    ...headers
                }
            };

            if (requestBody) {
                config.data = requestBody;
            }

            const response = await axios(config);
            
            return {
                statusCode: response.status,
                body: typeof response.data === 'string' ? response.data : JSON.stringify(response.data)
            };
        } catch (error) {
            return {
                statusCode: error.response?.status || 500,
                body: error.response?.data || error.message
            };
        }
    }

    static async sendPostRequestAsync(requestUrl, requestBody, headers = null) {
        const body = typeof requestBody === 'string' ? JSON.parse(requestBody) : requestBody;
        return this.handleRequest('POST', requestUrl, body, headers);
    }

    static async sendGetRequestAsync(requestUrl, headers = null) {
        return this.handleRequest('GET', requestUrl, null, headers);
    }

    static async sendDeleteRequestAsync(requestUrl, headers = null) {
        return this.handleRequest('DELETE', requestUrl, null, headers);
    }

    static async sendPatchRequestAsync(requestUrl, requestBody, headers = null) {
        const body = typeof requestBody === 'string' ? JSON.parse(requestBody) : requestBody;
        return this.handleRequest('PATCH', requestUrl, body, headers);
    }

    static async sendPutRequestAsync(requestUrl, requestBody, headers = null) {
        const body = typeof requestBody === 'string' ? JSON.parse(requestBody) : requestBody;
        return this.handleRequest('PUT', requestUrl, body, headers);
    }
}

// Mail Service
class MailService {
    async sendMailAsync(to, subject, message) {
        const requestUrl = "http://localhost:3000/api";
        
        const requestBody = {
            to,
            subject,
            message
        };

        return await HttpRequestHelper.sendPostRequestAsync(
            requestUrl, 
            JSON.stringify(requestBody), 
            null
        );
    }
}

// Enhanced Mail Service with message escaping
class MailService1 {
    async sendMailAsync(to, subject, message) {
        const requestUrl = "http://localhost:3000/api";

        // Escape special characters in message
        const escapedMessage = message
            .replace(/"/g, '\\"')
            .replace(/\r/g, '')
            .replace(/\n/g, ' ');

        const requestBody = {
            to,
            subject,
            message: escapedMessage
        };

        return await HttpRequestHelper.sendPostRequestAsync(
            requestUrl,
            JSON.stringify(requestBody),
            null
        );
    }
}

// Payment Service for MoMo
class PaymentService {
    async createMoMoPaymentAsync(amount, orderInfo, redirectUrl, callbackUrl) {
        const requestUrl = "http://localhost:3000/api/momo";
        
        const requestBody = {
            amount: Math.floor(amount), // Convert to integer
            orderInfo,
            redirectUrl,
            callbackUrl
        };

        try {
            const response = await axios.post(requestUrl, requestBody, {
                headers: {
                    'Content-Type': 'application/json'
                }
            });

            if (response.status >= 200 && response.status < 300) {
                return typeof response.data === 'string' 
                    ? response.data 
                    : JSON.stringify(response.data);
            } else {
                throw new Error(`Failed to create MoMo payment. Status code: ${response.status}`);
            }
        } catch (error) {
            throw new Error(`Failed to create MoMo payment. Error: ${error.message}`);
        }
    }
}
// Export classes
module.exports = {
    HttpRequestHelper,
    MailService,
    MailService1,
    PaymentService,
    RevenueService,
    AuthService
};

// Usage examples:
/*
// Import services
const { MailService, PaymentService, AuthService, RevenueService } = require('./services');

// Mail Service
const mailService = new MailService();
mailService.sendMailAsync("test@example.com", "Test Subject", "Test Message")
    .then(result => {
        console.log('Mail sent:', result.statusCode, result.body);
    })
    .catch(error => {
        console.error('Mail error:', error.message);
    });

// Payment Service
const paymentService = new PaymentService();
paymentService.createMoMoPaymentAsync(
    100000, 
    "Order #123", 
    "http://example.com/success", 
    "http://example.com/callback"
).then(result => {
    console.log('Payment created:', result);
}).catch(error => {
    console.error('Payment error:', error.message);
});

// Revenue Service
const revenueService = new RevenueService();
revenueService.getRevenueStatsAsync(
    new Date('2024-01-01'), 
    new Date('2024-12-31')
).then(stats => {
    console.log('Revenue stats:', stats.statusCode, stats.body);
}).catch(error => {
    console.error('Revenue error:', error.message);
});

// Auth Service
const authService = new AuthService();
authService.loginAsync("user@example.com", "password")
    .then(loginResult => {
        console.log('Login result:', loginResult.statusCode, loginResult.body);
    })
    .catch(error => {
        console.error('Login error:', error.message);
    });

// Using async/await
async function example() {
    try {
        const mailService = new MailService();
        const result = await mailService.sendMailAsync(
            "test@example.com",
            "Hello",
            "This is a test message"
        );
        console.log('Success:', result);
    } catch (error) {
        console.error('Error:', error.message);
    }
}
*/