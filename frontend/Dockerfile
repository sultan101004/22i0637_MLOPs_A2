# Frontend Dockerfile
# Multi-stage build for optimized production image

# Stage 1: Build
FROM node:18-alpine AS build

WORKDIR /app

# Build arguments for React environment variables
ARG REACT_APP_AUTH_SERVICE_URL=http://localhost:3001
ARG REACT_APP_BACKEND_SERVICE_URL=http://localhost:5001

# Set as environment variables for build
ENV REACT_APP_AUTH_SERVICE_URL=$REACT_APP_AUTH_SERVICE_URL
ENV REACT_APP_BACKEND_SERVICE_URL=$REACT_APP_BACKEND_SERVICE_URL

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --only=production

# Copy source code
COPY . .

# Build the app
RUN npm run build

# Stage 2: Production
FROM nginx:alpine

# Copy built assets from build stage
COPY --from=build /app/build /usr/share/nginx/html

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

