# Demo Recording Script

Complete script for recording a demonstration video of the microservices application deployment and functionality.

## 🎥 Recording Setup

### Prerequisites
- Screen recording software (OBS Studio, Loom, QuickTime, etc.)
- Terminal with clear font (14-16pt)
- Browser ready
- Clean desktop
- Minikube not running (start fresh)

### Recording Settings
- **Resolution**: 1920x1080 (1080p)
- **Frame Rate**: 30 FPS
- **Duration**: 8-12 minutes
- **Audio**: Optional voiceover or text annotations

---

## 📝 Demo Script

### Part 1: Introduction (30 seconds)

**Show on Screen:**
```
Title: Full-Stack Microservices Application
      with Docker, Kubernetes, and Authentication

Features:
- React Frontend
- Node.js Backend & Auth Service
- PostgreSQL Database
- Docker Containerization
- Kubernetes Orchestration (3 replicas)
- JWT Authentication
```

**Say/Annotate:**
> "This demo shows a production-ready microservices application with user authentication, deployed on Kubernetes using Minikube."

---

### Part 2: Project Structure (30 seconds)

**Terminal 1:**
```bash
# Show project structure
tree -L 2 -I 'node_modules|build'

# Or use ls
ls -la
```

**Show:**
- `frontend/` - React application
- `backend/` - REST API
- `auth-service/` - Authentication microservice
- `db/` - Database initialization
- `k8s/` - Kubernetes manifests
- `docker-compose.yml` - Local development
- `README.md` - Documentation

**Say/Annotate:**
> "The project follows a clean microservices architecture with separate services for frontend, backend, authentication, and database."

---

### Part 3: Docker Compose Demo (2 minutes)

**Terminal 1:**
```bash
# Start with Docker Compose
docker compose up -d --build

# Watch services start
docker compose ps

# Show logs (briefly)
docker compose logs --tail=50
```

**Wait for services to be healthy (show this in video):**
```bash
# Check health status
docker compose ps
```

**Expected Output:**
```
NAME           STATUS
frontend       Up (healthy)
backend        Up (healthy)
auth-service   Up (healthy)
postgres-db    Up (healthy)
```

**Test API:**
```bash
# Health checks
curl http://localhost:3001/health
curl http://localhost:5000/health

# Signup
curl -X POST http://localhost:3001/signup \
  -H "Content-Type: application/json" \
  -d '{"name":"Demo User","email":"demo@example.com","password":"Demo123!"}'

# Login and get token
curl -X POST http://localhost:3001/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@example.com","password":"Demo123!"}'
```

**Browser:**
- Open http://localhost:3000
- Show login page (don't interact yet)

**Terminal 1:**
```bash
# Stop Docker Compose
docker compose down
```

**Say/Annotate:**
> "All services running locally with Docker Compose. Now let's deploy to Kubernetes for production-like environment with scaling."

---

### Part 4: Kubernetes Deployment (3-4 minutes)

#### 4.1 Start Minikube

**Terminal 1:**
```bash
# Start Minikube
minikube start --cpus=4 --memory=8192

# Verify
minikube status

# Check kubectl
kubectl cluster-info
```

**Say/Annotate:**
> "Starting Minikube - a local Kubernetes cluster for development and testing."

#### 4.2 Build Docker Images

**Terminal 1:**
```bash
# Configure Docker to use Minikube's daemon
eval $(minikube -p minikube docker-env)

# Verify Docker is using Minikube
docker info | grep -i "Name:"

# Build images
echo "Building Frontend..."
docker build -t frontend:latest ./frontend

echo "Building Backend..."
docker build -t backend:latest ./backend

echo "Building Auth Service..."
docker build -t auth-service:latest ./auth-service

# Verify images
minikube image ls | grep -E "frontend|backend|auth-service"
```

**Say/Annotate:**
> "Building Docker images directly in Minikube's environment. This avoids pushing to a remote registry."

#### 4.3 Deploy to Kubernetes

**Terminal 1:**
```bash
# Show Kubernetes manifests
ls -la k8s/

# Apply manifests
kubectl apply -f k8s/

# Watch pods starting
kubectl get pods -n microservices -w
```

**Expected Output (show this happening):**
```
NAME                                     READY   STATUS              RESTARTS   AGE
postgres-deployment-xxx                  0/1     ContainerCreating   0          5s
auth-service-deployment-xxx              0/1     ContainerCreating   0          5s
...

postgres-deployment-xxx                  1/1     Running             0          30s
auth-service-deployment-xxx              1/1     Running             0          45s
backend-deployment-xxx                   1/1     Running             0          50s
frontend-deployment-xxx                  1/1     Running             0          55s
...
```

**Say/Annotate:**
> "Deploying to Kubernetes. Watch the pods transition from ContainerCreating to Running state."

#### 4.4 Verify Deployment

**Terminal 1:**
```bash
# Stop watching (Ctrl+C)

# Show all pods (should show 3 replicas each)
kubectl get pods -n microservices

# Show services
kubectl get svc -n microservices

# Show deployments
kubectl get deployments -n microservices

# Show replica counts
kubectl get deployments -n microservices -o wide
```

**Expected Output - HIGHLIGHT THIS:**
```
NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
auth-service-deployment       3/3     3            3           2m
backend-deployment            3/3     3            3           2m
frontend-deployment           3/3     3            3           2m
postgres-deployment           1/1     1            1           2m
```

**Say/Annotate:**
> "🎯 SUCCESS! All services deployed with 3 replicas each (except database which has 1 for data consistency)."

#### 4.5 Show Persistent Volume

**Terminal 1:**
```bash
# Show persistent volume for database
kubectl get pv,pvc -n microservices

# Show configmaps and secrets
kubectl get configmap,secret -n microservices
```

**Say/Annotate:**
> "Persistent storage ensures database data survives pod restarts. ConfigMaps and Secrets manage configuration."

---

### Part 5: Access and Test Application (3-4 minutes)

#### 5.1 Get Access URLs

**Terminal 1:**
```bash
# Get Minikube IP
MINIKUBE_IP=$(minikube ip)
echo "Minikube IP: $MINIKUBE_IP"

# Show URLs
echo "Frontend:     http://$MINIKUBE_IP:30080"
echo "Auth Service: http://$MINIKUBE_IP:30001"
echo "Backend:      http://$MINIKUBE_IP:30000"

# Or use minikube service
minikube service frontend-service -n microservices --url
minikube service auth-service-nodeport -n microservices --url
minikube service backend-service-nodeport -n microservices --url
```

#### 5.2 Test API Endpoints

**Terminal 2 (split screen):**
```bash
# Set variables
MINIKUBE_IP=$(minikube ip)
AUTH_URL="http://$MINIKUBE_IP:30001"
BACKEND_URL="http://$MINIKUBE_IP:30000"

# Test health endpoints
echo "Testing Auth Service..."
curl $AUTH_URL/health

echo "Testing Backend..."
curl $BACKEND_URL/health

# Signup new user
echo "Creating new user..."
curl -X POST $AUTH_URL/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Alice Smith",
    "email": "alice@example.com",
    "password": "SecurePass123!"
  }' | jq

# Login
echo "Logging in..."
TOKEN=$(curl -s -X POST $AUTH_URL/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@example.com",
    "password": "SecurePass123!"
  }' | jq -r .accessToken)

echo "Token received: ${TOKEN:0:50}..."

# Call protected endpoint
echo "Fetching profile (protected endpoint)..."
curl -H "Authorization: Bearer $TOKEN" $BACKEND_URL/profile | jq

echo "✅ JWT authentication working!"
```

**Say/Annotate:**
> "Testing the full authentication flow: signup → login → JWT token → protected endpoint access."

#### 5.3 Browser Testing

**Browser (show side-by-side with terminal):**

1. **Open Frontend:**
   ```
   http://<MINIKUBE_IP>:30080
   ```

2. **Sign Up Flow:**
   - Click "Sign Up"
   - Fill form:
     - Name: "Bob Johnson"
     - Email: "bob@example.com"
     - Password: "Test123!"
   - Click "Sign Up"
   - Should redirect to login page

3. **Login Flow:**
   - Enter email: bob@example.com
   - Enter password: Test123!
   - Click "Login"
   - Should redirect to dashboard

4. **Dashboard:**
   - Show user information displayed:
     - Name: Bob Johnson
     - Email: bob@example.com
     - User ID
     - Created timestamp
   - **Highlight**: Data fetched from protected `/profile` endpoint using JWT token

5. **Forgot Password:**
   - Logout
   - Click "Forgot Password"
   - Enter email
   - Show "reset token sent" message
   - (Note: In production, token would be emailed)

**Say/Annotate:**
> "Complete user authentication flow working in the browser. JWT tokens stored securely (localStorage in this demo)."

---

### Part 6: Demonstrate Scalability & Resilience (2 minutes)

#### 6.1 Show Load Balancing

**Terminal 1:**
```bash
# Show which pods are running
kubectl get pods -n microservices -l app=auth-service -o wide

# Make multiple requests to see load balancing
for i in {1..10}; do
  curl -s http://$MINIKUBE_IP:30001/health | jq -r .service
done
```

**Say/Annotate:**
> "Kubernetes automatically load balances requests across the 3 auth service replicas."

#### 6.2 Test Self-Healing

**Terminal 1:**
```bash
# Delete one auth service pod
kubectl delete pod -n microservices -l app=auth-service --field-selector=status.phase=Running | head -1

# Watch it recreate automatically
kubectl get pods -n microservices -l app=auth-service -w
```

**Show:**
- Pod being terminated
- New pod being created
- Pod becoming ready
- Still have 3 replicas

**Terminal 2 (while watching):**
```bash
# Service still works during pod replacement
curl http://$MINIKUBE_IP:30001/health
```

**Say/Annotate:**
> "Kubernetes self-healing: when a pod is deleted, it's automatically recreated to maintain desired replica count."

#### 6.3 Scale Up

**Terminal 1:**
```bash
# Scale auth service to 5 replicas
kubectl scale deployment auth-service-deployment -n microservices --replicas=5

# Watch scaling
kubectl get pods -n microservices -l app=auth-service

# Should show 5 pods running
```

**Say/Annotate:**
> "Easy horizontal scaling: from 3 to 5 replicas with a single command."

---

### Part 7: Review Architecture (1 minute)

**Show Diagram:**
Display `docs/architecture-diagram.png` or draw:

```
┌─────────────┐
│   Browser   │
└──────┬──────┘
       │
       ↓
┌─────────────────┐
│   Frontend      │ (3 replicas)
│   (React SPA)   │
└────────┬────────┘
         │
    ┌────┴────┐
    ↓         ↓
┌─────────┐ ┌──────────┐
│  Auth   │ │ Backend  │ (3 replicas each)
│ Service │ │ Service  │
└────┬────┘ └────┬─────┘
     │           │
     └─────┬─────┘
           ↓
     ┌──────────┐
     │PostgreSQL│ (1 replica + PV)
     └──────────┘
```

**Terminal:**
```bash
# Show all resources
kubectl get all -n microservices
```

**Say/Annotate:**
> "Complete microservices architecture: isolated services, load balancing, persistent storage, and horizontal scaling."

---

### Part 8: Cleanup & Summary (30 seconds)

**Terminal 1:**
```bash
# Show easy cleanup
kubectl delete namespace microservices

# Or keep for further exploration
echo "To clean up: kubectl delete -f k8s/"
echo "To stop Minikube: minikube stop"
```

**Show Summary Slide:**
```
✅ Demonstrated:
• Microservices architecture (Frontend, Backend, Auth, DB)
• Docker containerization with multi-stage builds
• Kubernetes deployment with 3 replicas
• JWT authentication (signup, login, protected endpoints)
• Persistent storage (PostgreSQL)
• Load balancing & self-healing
• Horizontal scaling

📂 Repository includes:
• Complete source code
• Dockerfiles & docker-compose.yml
• Kubernetes manifests
• Comprehensive documentation
• Automated test scripts

🚀 Production-ready foundation for:
• Microservices development
• Cloud-native applications
• DevOps best practices
```

---

## 🎬 Post-Recording Checklist

- [ ] Video shows Minikube startup
- [ ] Clear view of building Docker images
- [ ] Kubernetes deployment with `kubectl apply`
- [ ] **3 replicas visible** for auth, backend, frontend
- [ ] Signup flow working in browser
- [ ] Login flow working in browser
- [ ] Dashboard showing user data
- [ ] Terminal showing JWT token usage
- [ ] Protected endpoint access with Authorization header
- [ ] Self-healing demonstration (pod deletion/recreation)
- [ ] Architecture diagram or explanation

## 📤 Export & Share

### Video Formats
- **MP4** (H.264) - Most compatible
- **WebM** - Web-friendly
- **MOV** - High quality

### Compression
```bash
# Using ffmpeg for compression
ffmpeg -i demo.mov -vcodec h264 -acodec mp3 demo-compressed.mp4
```

### Upload Destinations
- YouTube (unlisted/public)
- Google Drive / Dropbox
- Loom
- Included in repository (if < 100MB)

---

## 🎤 Optional Voiceover Script

### Opening
"Hello! Today I'll demonstrate a full-stack microservices application with authentication, built with React, Node.js, and PostgreSQL, fully containerized with Docker and orchestrated on Kubernetes."

### Docker Compose
"First, let's see it running locally with Docker Compose. All four services start up: frontend, backend, authentication service, and database. Health checks pass, and we can quickly test the API endpoints."

### Kubernetes
"Now for the main event: deploying to Kubernetes on Minikube. We start Minikube, build our Docker images, and deploy using kubectl apply. Watch as Kubernetes creates our pods..."

### Replicas
"Notice we have three replicas for each service, providing high availability and load balancing. The database has one replica with persistent storage to ensure data consistency."

### Testing
"Let's test the application. I'll sign up a new user, which creates an account in the database. Then logging in returns a JWT access token. Using this token, we can access protected endpoints in the backend service."

### Browser
"The same flows work seamlessly in the browser. Sign up, login, and the dashboard displays user data fetched from the protected profile endpoint."

### Scaling
"Kubernetes makes scaling trivial. Deleting a pod? It's automatically recreated. Need more capacity? Scale from three to five replicas instantly."

### Closing
"This project demonstrates production-ready microservices with Docker, Kubernetes, JWT authentication, persistent storage, and modern DevOps practices. All code, documentation, and deployment guides are in the repository. Thank you!"

---

## 📋 Quick Reference Commands

### Essential Commands for Demo

```bash
# Setup
minikube start --cpus=4 --memory=8192
eval $(minikube docker-env)

# Build
docker build -t frontend:latest ./frontend
docker build -t backend:latest ./backend
docker build -t auth-service:latest ./auth-service

# Deploy
kubectl apply -f k8s/

# Verify
kubectl get pods -n microservices
kubectl get svc -n microservices

# Access
MINIKUBE_IP=$(minikube ip)
echo "http://$MINIKUBE_IP:30080"  # Frontend
echo "http://$MINIKUBE_IP:30001"  # Auth
echo "http://$MINIKUBE_IP:30000"  # Backend

# Test
curl http://$MINIKUBE_IP:30001/health
TOKEN=$(curl -s -X POST http://$MINIKUBE_IP:30001/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@example.com","password":"Test123!"}' | jq -r .accessToken)
curl -H "Authorization: Bearer $TOKEN" http://$MINIKUBE_IP:30000/profile

# Scale
kubectl scale deployment auth-service-deployment -n microservices --replicas=5

# Cleanup
kubectl delete -f k8s/
minikube stop
```

---

**Ready to record! Good luck! 🎥🚀**

