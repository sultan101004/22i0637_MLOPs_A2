# Quick Start Guide

Get the microservices application running in less than 5 minutes!

## 🚀 Option 1: Docker Compose (Fastest)

### One-Line Start

```bash
docker compose up -d --build
```

### Access the Application

- **Frontend**: http://localhost:3000
- **Auth API**: http://localhost:3001
- **Backend API**: http://localhost:5000

### Test It

1. Open http://localhost:3000 in your browser
2. Click "Sign Up"
3. Create an account
4. Login and see your dashboard

### Stop It

```bash
docker compose down
```

---

## 🎯 Option 2: Kubernetes on Minikube

### Prerequisites

- Minikube installed
- kubectl installed
- Docker installed

### Quick Deploy

```bash
# Start Minikube
minikube start --cpus=4 --memory=8192

# Build and deploy (automated script)
./scripts/deploy-k8s.sh

# Get URL
minikube service frontend-service -n microservices
```

### Or Manual Steps

```bash
# 1. Start Minikube
minikube start --cpus=4 --memory=8192

# 2. Build images in Minikube
eval $(minikube docker-env)
docker build -t frontend:latest ./frontend
docker build -t backend:latest ./backend
docker build -t auth-service:latest ./auth-service

# 3. Deploy
kubectl apply -f k8s/

# 4. Wait for pods (30-60 seconds)
kubectl get pods -n microservices -w

# 5. Access
minikube ip  # Get IP address
# Frontend: http://<IP>:30080
# Auth: http://<IP>:30001
# Backend: http://<IP>:30000
```

---

## 🧪 Quick Test

### Docker Compose

```bash
# Run automated tests
./scripts/demo-test.sh docker
```

### Kubernetes

```bash
# Run automated tests
./scripts/demo-test.sh kubernetes
```

### Manual API Test

```bash
# Signup
curl -X POST http://localhost:3001/signup \
  -H "Content-Type: application/json" \
  -d '{"name":"Alice","email":"alice@example.com","password":"Test123!"}'

# Login
curl -X POST http://localhost:3001/login \
  -H "Content-Type: application/json" \
  -d '{"email":"alice@example.com","password":"Test123!"}'
```

---

## 📋 What's Running?

After successful startup:

- **Frontend** (React): Port 3000 or 30080
  - Login, Signup, Dashboard, Password Reset

- **Backend** (Node.js): Port 5000 or 30000
  - Protected API endpoints
  - User profile management

- **Auth Service** (Node.js): Port 3001 or 30001
  - JWT token generation
  - Password hashing & verification
  - Password reset flow

- **Database** (PostgreSQL): Port 5432
  - User data storage
  - Persistent across restarts

---

## 🔍 Verify It's Working

### Check Health

```bash
# Docker Compose
curl http://localhost:3001/health
curl http://localhost:5000/health

# Kubernetes
MINIKUBE_IP=$(minikube ip)
curl http://$MINIKUBE_IP:30001/health
curl http://$MINIKUBE_IP:30000/health
```

### Check Pods (Kubernetes)

```bash
kubectl get pods -n microservices
```

Expected: 10 pods total (3 + 3 + 3 + 1)

### Check Services (Kubernetes)

```bash
kubectl get svc -n microservices
```

---

## 🛑 Stop Everything

### Docker Compose

```bash
docker compose down
# Or remove volumes too:
docker compose down -v
```

### Kubernetes

```bash
kubectl delete -f k8s/
# Or delete namespace:
kubectl delete namespace microservices

# Stop Minikube
minikube stop
```

---

## 🆘 Troubleshooting

### Docker Compose Issues

**Problem**: Port already in use
```bash
# Find and kill process
lsof -i :3000  # Mac/Linux
netstat -ano | findstr :3000  # Windows
```

**Problem**: Containers won't start
```bash
# Check logs
docker compose logs
# Restart
docker compose restart
```

### Kubernetes Issues

**Problem**: ImagePullBackOff
```bash
# Rebuild images in Minikube's Docker
eval $(minikube docker-env)
docker build -t frontend:latest ./frontend
docker build -t backend:latest ./backend
docker build -t auth-service:latest ./auth-service
```

**Problem**: Pods not ready
```bash
# Check logs
kubectl logs -n microservices <pod-name>
# Describe pod
kubectl describe pod -n microservices <pod-name>
```

**Problem**: Can't access services
```bash
# Get Minikube IP
minikube ip
# Use this IP with NodePort numbers
```

---

## 📚 Next Steps

1. **Explore the UI**: Try all auth flows
2. **Test APIs**: Use curl or Postman
3. **Read Docs**: See [README.md](README.md) for details
4. **Watch Demo**: Follow [docs/demo-script.md](docs/demo-script.md)
5. **Scale Services**: Try `kubectl scale deployment`

---

## 💡 Key Features to Test

- ✅ User Signup with validation
- ✅ Login with JWT tokens
- ✅ Forgot Password flow
- ✅ Reset Password with token
- ✅ Protected Dashboard
- ✅ API authentication with Bearer token

---

## 🎯 Success Criteria

You know it's working when:

1. ✅ All health endpoints return 200 OK
2. ✅ You can sign up a new user
3. ✅ You can login and see the dashboard
4. ✅ Dashboard shows your user information
5. ✅ (K8s only) `kubectl get pods` shows 10 running pods

---

**Need help?** Check [docs/deployment-guide.md](docs/deployment-guide.md) for detailed instructions!

