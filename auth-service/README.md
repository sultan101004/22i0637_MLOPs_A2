# Authentication Service

Dedicated microservice handling all authentication operations including signup, login, password reset, and JWT token management.

## Features

- **User Registration** with email validation
- **Login** with JWT token issuance
- **Password Reset Flow** with secure token generation
- **Token Verification** for other services
- **Refresh Token** support for extended sessions
- **Secure Password Hashing** using bcrypt (10 rounds)

## Tech Stack

- Node.js + Express
- PostgreSQL for user storage
- bcryptjs for password hashing
- jsonwebtoken for JWT generation
- crypto for secure token generation

## API Endpoints

### POST `/signup`
Register a new user.

**Request:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass123"
}
```

**Response (201):**
```json
{
  "message": "User created successfully",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "created_at": "2025-10-24T..."
  }
}
```

### POST `/login`
Authenticate and receive tokens.

**Request:**
```json
{
  "email": "john@example.com",
  "password": "SecurePass123"
}
```

**Response (200):**
```json
{
  "message": "Login successful",
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  }
}
```

### POST `/forgot-password`
Request password reset token.

**Request:**
```json
{
  "email": "john@example.com"
}
```

**Response (200):**
```json
{
  "message": "If the email exists, a reset link has been sent",
  "resetToken": "abc123..." 
}
```

Note: `resetToken` is only returned in demo mode. In production, this would be sent via email.

### POST `/reset-password`
Reset password using token.

**Request:**
```json
{
  "token": "abc123...",
  "newPassword": "NewSecurePass456"
}
```

**Response (200):**
```json
{
  "message": "Password reset successful"
}
```

### POST `/verify-token`
Verify JWT token (used by other services).

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "valid": true,
  "userId": 1
}
```

### POST `/refresh-token`
Get new access token using refresh token.

**Request:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Response (200):**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}
```

### GET `/health`
Health check endpoint.

**Response (200):**
```json
{
  "status": "ok",
  "service": "auth-service"
}
```

## Environment Variables

See `.env.example`:

```bash
PORT=3001
DB_HOST=localhost
DB_PORT=5432
DB_NAME=authdb
DB_USER=postgres
DB_PASSWORD=postgres
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_REFRESH_SECRET=your-refresh-secret-key-change-in-production
```

## Local Development

```bash
# Install dependencies
npm install

# Start server
npm start

# Development with hot reload
npm run dev

# Run tests
npm test
```

## Security Considerations

1. **JWT Secrets**: Change default secrets in production
2. **Password Reset**: In production, send tokens via email (not in response)
3. **HTTPS**: Always use HTTPS in production
4. **Rate Limiting**: Add rate limiting for auth endpoints
5. **Token Expiry**: Access tokens expire in 1 hour, refresh tokens in 7 days
6. **Password Policy**: Minimum 6 characters (increase for production)

## Docker

```bash
docker build -t auth-service:latest .
docker run -p 3001:3001 --env-file .env auth-service:latest
```

