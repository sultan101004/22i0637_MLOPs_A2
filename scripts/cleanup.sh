#!/bin/bash

# Cleanup Script
# Removes all deployed resources and optionally cleans up Docker images

set -e

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

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

echo -e "${YELLOW}"
echo "╔═══════════════════════════════════════════════╗"
echo "║          Cleanup Script                       ║"
echo "╚═══════════════════════════════════════════════╝"
echo -e "${NC}"

echo "This script will clean up:"
echo "  1. Docker Compose containers and volumes"
echo "  2. Kubernetes resources"
echo "  3. Optionally: Docker images"
echo ""

read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Cleanup cancelled"
    exit 0
fi

# Clean Docker Compose
log_info "Cleaning up Docker Compose..."
if docker compose ps -q 2>/dev/null | grep -q .; then
    docker compose down -v
    log_success "Docker Compose cleaned up"
else
    log_info "No Docker Compose containers found"
fi

# Clean Kubernetes
log_info "Cleaning up Kubernetes resources..."
if kubectl get namespace microservices &>/dev/null; then
    kubectl delete namespace microservices --timeout=60s
    log_success "Kubernetes namespace deleted"
else
    log_info "Kubernetes namespace not found"
fi

# Optional: Clean Docker images
echo ""
read -p "Remove Docker images? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Removing Docker images..."
    docker rmi frontend:latest backend:latest auth-service:latest 2>/dev/null || true
    log_success "Docker images removed"
fi

# Optional: Stop Minikube
echo ""
read -p "Stop Minikube? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v minikube &> /dev/null && minikube status &> /dev/null; then
        log_info "Stopping Minikube..."
        minikube stop
        log_success "Minikube stopped"
    else
        log_info "Minikube is not running"
    fi
fi

# Optional: Delete Minikube
echo ""
read -p "Delete Minikube cluster? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v minikube &> /dev/null; then
        log_warning "This will delete the entire Minikube cluster!"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            minikube delete
            log_success "Minikube cluster deleted"
        fi
    fi
fi

echo ""
echo -e "${GREEN}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Cleanup completed!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${NC}"

