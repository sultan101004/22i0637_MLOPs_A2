# Deployment Guide

Complete step-by-step guide for deploying the microservices application using Docker Compose and Kubernetes on Minikube.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Docker Compose Deployment](#docker-compose-deployment)
3. [Kubernetes Deployment](#kubernetes-deployment)
4. [Accessing the Application](#accessing-the-application)
5. [Testing](#testing)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software

| Software | Minimum Version | Installation |
|----------|----------------|--------------|
| Docker | 20.10+ | [Install Docker](https://docs.docker.com/get-docker/) |
| Docker Compose | 1.29+ | [Install Compose](https://docs.docker.com/compose/install/) |
| Minikube | 1.30+ | [Install Minikube](https://minikube.sigs.k8s.io/docs/start/) |
| kubectl | 1.26+ | [Install kubectl](https://kubernetes.io/docs/tasks/tools/) |
| Node.js | 18+ | [Install Node.js](https://nodejs.org/) |

### System Requirements

**For Docker Compose:**
- 4 GB RAM
- 10 GB disk space
- Windows 10/11, macOS 10.15+, or Linux

**For Kubernetes/Minikube:**
- 8 GB RAM
- 20 GB disk space
- Virtualization enabled in BIOS
- Windows 10/11, macOS 10.15+, or Linux

### Verify Installation

```bash
# Docker
docker --version
docker compose version

# Kubernetes
minikube version
kubectl version --client

# Node.js (optional, for local dev)
node --version
npm --version
```

---

## Docker Compose Deployment

Docker Compose is the fastest way to run the entire stack locally for development and testing.

### Step 1: Clone the Repository

```bash
git clone <repository-url>
cd fullstack-microservices
```

### Step 2: Review Configuration

Check the `docker-compose.yml` file and adjust if needed. Default ports:
- Frontend: 3000
- Auth Service: 3001
- Backend: 5000
- PostgreSQL: 5432

### Step 3: Start Services

```bash
# Build and start all services
docker compose up --build

# Or run in detached mode
docker compose up -d --build
```

Expected output:
```
[+] Running 5/5
 ✔ Network microservices-network       Created
 ✔ Volume "db-data"                    Created
 ✔ Container postgres-db               Started
 ✔ Container auth-service              Started
 ✔ Container backend                   Started
 ✔ Container frontend                  Started
```

### Step 4: Verify Services

```bash
# Check running containers
docker compose ps

# Should show all services as "Up" or "healthy"
```

Expected output:
```
NAME                IMAGE                        STATUS
frontend            fullstack-frontend           Up (healthy)
backend             fullstack-backend            Up (healthy)
auth-service        fullstack-auth-service       Up (healthy)
postgres-db         postgres:15-alpine           Up (healthy)
```

### Step 5: Check Logs

```bash
# View all logs
docker compose logs -f

# View specific service logs
docker compose logs -f auth-service
docker compose logs -f backend
docker compose logs -f frontend
docker compose logs -f db
```

### Step 6: Test Services

```bash
# Test health endpoints
curl http://localhost:3001/health  # Auth service
curl http://localhost:5000/health  # Backend
curl http://localhost:3000         # Frontend

# All should return 200 OK
```

### Step 7: Access Frontend

Open your browser and navigate to:
```
http://localhost:3000
```

You should see the login page.

### Step 8: Stop Services

```bash
# Stop services (preserves data)
docker compose stop

# Stop and remove containers (preserves volumes)
docker compose down

# Stop and remove everything including volumes
docker compose down -v
```

---

## Kubernetes Deployment

Deploy the application on Kubernetes using Minikube for a production-like environment.

### Step 1: Start Minikube

```bash
# Start Minikube with sufficient resources
minikube start --cpus=4 --memory=8192 --disk-size=20g

# Verify Minikube is running
minikube status
```

Expected output:
```
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

### Step 2: Configure Docker to Use Minikube's Daemon

This allows you to build images directly in Minikube without needing to push to a registry.

**Linux/macOS:**
```bash
eval $(minikube -p minikube docker-env)
```

**Windows (PowerShell):**
```powershell
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
```

**Windows (CMD):**
```cmd
@FOR /f "tokens=*" %i IN ('minikube -p minikube docker-env --shell cmd') DO @%i
```

### Step 3: Build Docker Images

Build all images in Minikube's Docker environment:

```bash
# Frontend
cd frontend
docker build -t frontend:latest .
cd ..

# Backend
cd backend
docker build -t backend:latest .
cd ..

# Auth Service
cd auth-service
docker build -t auth-service:latest .
cd ..
```

**Or use the build script:**
```bash
chmod +x scripts/build-images.sh
./scripts/build-images.sh
```

### Step 4: Verify Images

```bash
# List images in Minikube
minikube image ls | grep -E "frontend|backend|auth-service"
```

You should see:
```
docker.io/library/frontend:latest
docker.io/library/backend:latest
docker.io/library/auth-service:latest
```

### Step 5: Deploy to Kubernetes

Apply all Kubernetes manifests:

```bash
# Apply all manifests
kubectl apply -f k8s/

# Or use kustomize
kubectl apply -k k8s/
```

Expected output:
```
namespace/microservices created
configmap/app-config created
secret/app-secrets created
persistentvolume/postgres-pv created
persistentvolumeclaim/postgres-pvc created
deployment.apps/postgres-deployment created
service/postgres-service created
deployment.apps/auth-service-deployment created
service/auth-service created
deployment.apps/backend-deployment created
service/backend-service created
deployment.apps/frontend-deployment created
service/frontend-service created
```

**Or use the deploy script:**
```bash
chmod +x scripts/deploy-k8s.sh
./scripts/deploy-k8s.sh
```

### Step 6: Monitor Deployment

```bash
# Watch pods starting up
kubectl get pods -n microservices -w

# Wait for all pods to be Running (Ctrl+C to stop watching)
```

Expected output (may take 1-3 minutes):
```
NAME                                        READY   STATUS    RESTARTS   AGE
auth-service-deployment-abc123-xyz          1/1     Running   0          1m
auth-service-deployment-def456-uvw          1/1     Running   0          1m
auth-service-deployment-ghi789-rst          1/1     Running   0          1m
backend-deployment-jkl012-opq               1/1     Running   0          1m
backend-deployment-mno345-lmn               1/1     Running   0          1m
backend-deployment-pqr678-ijk               1/1     Running   0          1m
frontend-deployment-stu901-fgh              1/1     Running   0          1m
frontend-deployment-vwx234-def              1/1     Running   0          1m
frontend-deployment-yza567-abc              1/1     Running   0          1m
postgres-deployment-bcd890-xyz              1/1     Running   0          2m
```

### Step 7: Verify Deployment

```bash
# Check all resources
kubectl get all -n microservices

# Check persistent volume
kubectl get pv,pvc -n microservices

# Check configmap and secrets
kubectl get configmap,secret -n microservices
```

### Step 8: Check Pod Health

```bash
# View pod details
kubectl describe pods -n microservices

# Check specific pod
kubectl describe pod -n microservices <pod-name>

# View logs
kubectl logs -n microservices <pod-name>
```

---

## Accessing the Application

### Docker Compose Access

| Service | URL | Description |
|---------|-----|-------------|
| Frontend | http://localhost:3000 | Web UI |
| Auth Service | http://localhost:3001 | Auth API |
| Backend | http://localhost:5000 | Backend API |
| PostgreSQL | localhost:5432 | Database |

### Kubernetes Access

#### Method 1: Using `minikube service` (Recommended)

```bash
# Frontend (opens in browser)
minikube service frontend-service -n microservices

# Auth Service (get URL)
minikube service auth-service-nodeport -n microservices --url

# Backend (get URL)
minikube service backend-service-nodeport -n microservices --url
```

#### Method 2: Using NodePort with Minikube IP

```bash
# Get Minikube IP
minikube ip
# Example output: 192.168.49.2

# Access services at:
# Frontend:     http://<MINIKUBE_IP>:30080
# Auth Service: http://<MINIKUBE_IP>:30001
# Backend:      http://<MINIKUBE_IP>:30000
```

Example:
```bash
MINIKUBE_IP=$(minikube ip)
echo "Frontend:     http://$MINIKUBE_IP:30080"
echo "Auth Service: http://$MINIKUBE_IP:30001"
echo "Backend:      http://$MINIKUBE_IP:30000"
```

#### Method 3: Port Forwarding

```bash
# Forward frontend port
kubectl port-forward -n microservices svc/frontend-service 3000:80

# Forward auth service port (in another terminal)
kubectl port-forward -n microservices svc/auth-service 3001:3001

# Forward backend port (in another terminal)
kubectl port-forward -n microservices svc/backend-service 5000:5000

# Access at:
# Frontend:     http://localhost:3000
# Auth Service: http://localhost:3001
# Backend:      http://localhost:5000
```

---

## Testing

### Manual Testing via Browser

1. **Access Frontend**
   ```bash
   # Docker Compose
   open http://localhost:3000
   
   # Kubernetes
   minikube service frontend-service -n microservices
   ```

2. **Sign Up**
   - Click "Sign Up"
   - Enter name, email, password
   - Submit form
   - Should redirect to login

3. **Login**
   - Enter email and password
   - Click "Login"
   - Should redirect to dashboard

4. **View Dashboard**
   - See user information
   - Verify profile data displayed

5. **Test Forgot Password**
   - Go to login page
   - Click "Forgot Password"
   - Enter email
   - Check console for reset token

6. **Test Reset Password**
   - Go to "Reset Password" page
   - Enter token from previous step
   - Enter new password
   - Submit and login with new password

### Automated API Testing

#### Docker Compose

```bash
# Set base URLs
AUTH_URL="http://localhost:3001"
BACKEND_URL="http://localhost:5000"

# Test health endpoints
curl $AUTH_URL/health
curl $BACKEND_URL/health

# Signup
curl -X POST $AUTH_URL/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "Test123!"
  }'

# Login and save token
TOKEN=$(curl -s -X POST $AUTH_URL/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!"
  }' | jq -r .accessToken)

echo "Token: $TOKEN"

# Get profile (protected endpoint)
curl -H "Authorization: Bearer $TOKEN" $BACKEND_URL/profile

# Get all users (protected endpoint)
curl -H "Authorization: Bearer $TOKEN" $BACKEND_URL/users
```

#### Kubernetes

```bash
# Get Minikube IP
MINIKUBE_IP=$(minikube ip)

# Set base URLs
AUTH_URL="http://$MINIKUBE_IP:30001"
BACKEND_URL="http://$MINIKUBE_IP:30000"

# Test health endpoints
curl $AUTH_URL/health
curl $BACKEND_URL/health

# Signup
curl -X POST $AUTH_URL/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "K8s Test User",
    "email": "k8s@example.com",
    "password": "Test123!"
  }'

# Login and save token
TOKEN=$(curl -s -X POST $AUTH_URL/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "k8s@example.com",
    "password": "Test123!"
  }' | jq -r .accessToken)

echo "Token: $TOKEN"

# Get profile (protected endpoint)
curl -H "Authorization: Bearer $TOKEN" $BACKEND_URL/profile
```

### Automated Test Script

Run the complete test suite:

```bash
chmod +x scripts/demo-test.sh
./scripts/demo-test.sh
```

This script tests:
- Health endpoints
- Signup flow
- Login flow
- Protected endpoints
- Forgot password
- Reset password

---

## Troubleshooting

### Docker Compose Issues

#### Containers Won't Start

```bash
# Check logs
docker compose logs

# Restart specific service
docker compose restart auth-service

# Clean restart
docker compose down -v
docker compose up --build
```

#### Port Already in Use

```bash
# Find process using port 3000
lsof -i :3000  # macOS/Linux
netstat -ano | findstr :3000  # Windows

# Kill process or change port in docker-compose.yml
```

#### Database Connection Issues

```bash
# Verify database is running
docker compose ps db

# Check database logs
docker compose logs db

# Connect to database
docker exec -it postgres-db psql -U postgres -d authdb

# Verify tables exist
\dt
```

### Kubernetes Issues

#### ImagePullBackOff

```bash
# Verify images are built
minikube image ls | grep -E "frontend|backend|auth"

# If missing, rebuild
eval $(minikube docker-env)
docker build -t frontend:latest ./frontend
# ... etc
```

#### CrashLoopBackOff

```bash
# Check logs
kubectl logs -n microservices <pod-name>

# Check previous container logs
kubectl logs -n microservices <pod-name> --previous

# Describe pod for events
kubectl describe pod -n microservices <pod-name>

# Common causes:
# - Database not ready (check DB pod)
# - Missing environment variables (check configmap/secrets)
# - Application error (check logs)
```

#### Pods Not Ready

```bash
# Check readiness probe
kubectl describe pod -n microservices <pod-name>

# Look for "Readiness probe failed" in events

# Check if service dependencies are ready
kubectl get pods -n microservices

# Wait for database to be ready first
kubectl wait --for=condition=ready pod -l app=postgres -n microservices --timeout=300s
```

#### Service Not Accessible

```bash
# Verify service exists
kubectl get svc -n microservices

# Check endpoints
kubectl get endpoints -n microservices

# Test from within cluster
kubectl run test-pod -n microservices --image=curlimages/curl -i --rm --restart=Never -- \
  curl http://auth-service:3001/health

# Check NodePort
kubectl get svc -n microservices frontend-service -o yaml | grep nodePort
```

#### Persistent Volume Issues

```bash
# Check PV and PVC
kubectl get pv,pvc -n microservices

# Describe PVC
kubectl describe pvc postgres-pvc -n microservices

# If pending:
# - Check PV exists
# - Verify storage class matches
# - Ensure PV capacity meets PVC request
```

### Network Issues

#### Services Can't Communicate

```bash
# Test DNS resolution
kubectl run test-dns -n microservices --image=busybox -i --rm --restart=Never -- \
  nslookup postgres-service

# Test connectivity
kubectl run test-connect -n microservices --image=curlimages/curl -i --rm --restart=Never -- \
  curl -v http://auth-service:3001/health

# Check network policies (if any)
kubectl get networkpolicies -n microservices
```

### Common Error Messages

#### "connect ECONNREFUSED"

**Cause**: Service trying to connect to another service that's not ready.

**Solution**:
```bash
# Check if target service is running
kubectl get pods -n microservices

# Check service endpoints
kubectl get endpoints -n microservices

# Verify service URL in logs/config
kubectl logs -n microservices <pod-name>
```

#### "password authentication failed"

**Cause**: Database credentials mismatch.

**Solution**:
```bash
# Check secrets
kubectl get secret app-secrets -n microservices -o yaml

# Decode password
echo "cG9zdGdyZXM=" | base64 -d

# Verify environment variables in pod
kubectl exec -n microservices <pod-name> -- env | grep DB_
```

#### "Invalid or expired token"

**Cause**: Token expired or JWT secret mismatch.

**Solution**:
1. Get a fresh token by logging in again
2. Verify JWT secrets match across services
3. Check token expiry (default: 1 hour)

### Useful Commands

```bash
# View all resources
kubectl get all -n microservices

# Delete and redeploy
kubectl delete -f k8s/
kubectl apply -f k8s/

# Scale deployment
kubectl scale deployment auth-service-deployment -n microservices --replicas=5

# Restart deployment
kubectl rollout restart deployment auth-service-deployment -n microservices

# View events
kubectl get events -n microservices --sort-by='.lastTimestamp'

# Shell into pod
kubectl exec -it -n microservices <pod-name> -- /bin/sh

# Port forward for debugging
kubectl port-forward -n microservices <pod-name> 3001:3001
```

---

## Next Steps

After successful deployment:

1. **Explore the Application**: Test all features (signup, login, dashboard)
2. **Review Architecture**: Understand service communication
3. **Check Monitoring**: View logs and metrics
4. **Try Scaling**: Scale services up/down
5. **Test Failover**: Delete a pod and watch it recover
6. **Record Demo**: Follow [demo-script.md](demo-script.md)

## Support

For additional help:
- Check [README.md](../README.md) for overview
- Review service-specific READMEs in each service folder
- Check logs for error messages
- Create an issue in the repository

---

**Deployment guide complete! Your microservices application should now be running successfully.**

