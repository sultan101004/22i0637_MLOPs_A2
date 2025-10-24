# Backend Service

Main backend service providing protected API endpoints for user data and business logic.

## Features

- **Protected Endpoints** with JWT authentication
- **User Profile Management**
- **Public Endpoints** for non-authenticated requests
- **Token Verification** via Auth Service
- **Database Integration** with PostgreSQL

## Tech Stack

- Node.js + Express
- PostgreSQL for data storage
- Axios for inter-service communication
- JWT verification via Auth Service

## API Endpoints

### GET `/health`
Health check endpoint (public).

**Response (200):**
```json
{
  "status": "ok",
  "service": "backend"
}
```

### GET `/public-info`
Public endpoint accessible without authentication.

**Response (200):**
```json
{
  "message": "This is a public endpoint",
  "service": "backend",
  "timestamp": "2025-10-24T..."
}
```

### GET `/profile` 🔒
Get authenticated user's profile.

**Headers:**
```
Authorization: Bearer <access-token>
```

**Response (200):**
```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "created_at": "2025-10-24T..."
}
```

### PUT `/profile` 🔒
Update authenticated user's profile.

**Headers:**
```
Authorization: Bearer <access-token>
```

**Request:**
```json
{
  "name": "Jane Doe"
}
```

**Response (200):**
```json
{
  "message": "Profile updated successfully",
  "user": {
    "id": 1,
    "name": "Jane Doe",
    "email": "john@example.com",
    "created_at": "2025-10-24T..."
  }
}
```

### GET `/users` 🔒
Get list of all users (demo endpoint).

**Headers:**
```
Authorization: Bearer <access-token>
```

**Response (200):**
```json
{
  "count": 5,
  "users": [...]
}
```

## Environment Variables

See `.env.example`:

```bash
PORT=5000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=authdb
DB_USER=postgres
DB_PASSWORD=postgres
AUTH_SERVICE_URL=http://localhost:3001
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

## Authentication Flow

1. User logs in via Auth Service and receives JWT token
2. Frontend stores token and sends it in `Authorization` header
3. Backend extracts token and verifies with Auth Service
4. If valid, backend processes request and returns data

## Docker

```bash
docker build -t backend:latest .
docker run -p 5000:5000 --env-file .env backend:latest
```

## Testing Protected Endpoints

```bash
# Login and get token
TOKEN=$(curl -s -X POST http://localhost:3001/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}' \
  | jq -r .accessToken)

# Call protected endpoint
curl -H "Authorization: Bearer $TOKEN" http://localhost:5000/profile
```

