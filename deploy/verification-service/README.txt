Verification Service

1. Copy `.env.example` to `.env` and fill in your SMTP settings.
2. Install dependencies:
   npm install
3. Start the service:
   npm start
4. Default API base URL:
   http://127.0.0.1:3000/api/auth

Endpoints:
- POST /api/auth/send-code
  body: { "email": "user@example.com" }
- POST /api/auth/verify-code
  body: { "email": "user@example.com", "code": "123456" }
- GET /health

Notes:
- Codes expire in 5 minutes by default.
- The same email can only request another code after 60 seconds.
- Current storage is in-memory. Restarting the service will clear pending codes.
- For production, you should replace in-memory storage with Redis or a database.
