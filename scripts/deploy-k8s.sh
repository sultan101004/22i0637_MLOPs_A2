#!/bin/bash

# Kubernetes Deployment Script
# Automates the deployment process to Minikube

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════╗"
echo "║   Kubernetes Deployment Automation Script     ║"
echo "╚═══════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if Minikube is installed
if ! command -v minikube &> /dev/null; then
    log_error "Minikube is not installed. Please install it first."
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    log_error "kubectl is not installed. Please install it first."
    exit 1
fi

# Check if Minikube is running
if ! minikube status &> /dev/null; then
    log_warning "Minikube is not running. Starting Minikube..."
    minikube start --cpus=4 --memory=8192
    log_success "Minikube started"
else
    log_success "Minikube is already running"
fi

# Configure Docker to use Minikube's daemon
log_info "Configuring Docker to use Minikube's daemon..."
eval $(minikube -p minikube docker-env)
log_success "Docker configured"

# Build images
log_info "Building Docker images..."
./scripts/build-images.sh || {
    log_error "Failed to build images"
    exit 1
}

# Deploy to Kubernetes
log_info "Deploying to Kubernetes..."
kubectl apply -f k8s/
log_success "Kubernetes manifests applied"

# Wait for pods to be ready
log_info "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n microservices --timeout=120s || log_warning "Database took longer than expected"
kubectl wait --for=condition=ready pod -l app=auth-service -n microservices --timeout=120s || log_warning "Auth service took longer than expected"
kubectl wait --for=condition=ready pod -l app=backend -n microservices --timeout=120s || log_warning "Backend took longer than expected"
kubectl wait --for=condition=ready pod -l app=frontend -n microservices --timeout=120s || log_warning "Frontend took longer than expected"

# Show deployment status
echo ""
log_info "Deployment Status:"
kubectl get pods -n microservices
echo ""
kubectl get svc -n microservices

# Get access URLs
echo ""
log_info "Access URLs:"
MINIKUBE_IP=$(minikube ip)
echo -e "  ${GREEN}Frontend:${NC}     http://$MINIKUBE_IP:30080"
echo -e "  ${GREEN}Auth Service:${NC} http://$MINIKUBE_IP:30001/health"
echo -e "  ${GREEN}Backend:${NC}      http://$MINIKUBE_IP:30000/health"

echo ""
log_info "Or use minikube service:"
echo "  minikube service frontend-service -n microservices"

echo ""
echo -e "${GREEN}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Deployment completed successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${NC}"

log_info "Run './scripts/demo-test.sh kubernetes' to test the deployment"

