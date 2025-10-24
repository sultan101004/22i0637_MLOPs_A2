# Frontend Service

React-based frontend application providing a responsive UI for user authentication and dashboard.

## Features

- **Signup**: User registration with validation
- **Login**: Secure authentication with JWT tokens
- **Forgot Password**: Password recovery flow
- **Reset Password**: Token-based password reset
- **Dashboard**: Protected route showing user profile information

## Tech Stack

- React 18
- React Router for navigation
- Axios for API calls
- Modern CSS with gradient backgrounds

## Environment Variables

Create a `.env` file based on `.env.example`:

```bash
REACT_APP_AUTH_SERVICE_URL=http://localhost:3001
REACT_APP_BACKEND_SERVICE_URL=http://localhost:5000
```

## Local Development

```bash
# Install dependencies
npm install

# Start development server
npm start

# Run tests
npm test

# Build for production
npm run build
```

## Security Notes

⚠️ **Important**: This demo uses `localStorage` for token storage. In production:
- Use `httpOnly` cookies for tokens
- Implement proper CSRF protection
- Use secure token refresh mechanisms
- Consider using a state management library like Redux for better token handling

## API Integration

The frontend communicates with:
- **Auth Service** (port 3001): `/signup`, `/login`, `/forgot-password`, `/reset-password`
- **Backend Service** (port 5000): `/profile` (protected endpoint)

## Docker

Build and run with Docker:

```bash
docker build -t frontend:latest .
docker run -p 3000:3000 frontend:latest
```

