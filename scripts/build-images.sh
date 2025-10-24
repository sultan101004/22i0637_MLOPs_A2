#!/bin/bash

# Build Docker Images Script
# Builds all microservice images for use with Minikube or Docker Compose

set -e  # Exit on error

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════╗"
echo "║     Building Microservices Docker Images      ║"
echo "╚═══════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if we should use Minikube's Docker daemon
if command -v minikube &> /dev/null && minikube status &> /dev/null; then
    echo -e "${BLUE}[INFO]${NC} Minikube is running. Using Minikube's Docker daemon..."
    eval $(minikube -p minikube docker-env)
fi

# Build Frontend
echo -e "\n${BLUE}[1/3]${NC} Building Frontend..."
docker build -t frontend:latest ./frontend
echo -e "${GREEN}✓${NC} Frontend image built successfully"

# Build Backend
echo -e "\n${BLUE}[2/3]${NC} Building Backend..."
docker build -t backend:latest ./backend
echo -e "${GREEN}✓${NC} Backend image built successfully"

# Build Auth Service
echo -e "\n${BLUE}[3/3]${NC} Building Auth Service..."
docker build -t auth-service:latest ./auth-service
echo -e "${GREEN}✓${NC} Auth Service image built successfully"

# Verify images
echo -e "\n${BLUE}[INFO]${NC} Verifying images..."
docker images | grep -E "frontend|backend|auth-service" | grep latest

echo -e "\n${GREEN}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ All images built successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${NC}"

echo -e "Next steps:"
echo -e "  ${BLUE}Docker Compose:${NC}  docker compose up"
echo -e "  ${BLUE}Kubernetes:${NC}      kubectl apply -f k8s/"

