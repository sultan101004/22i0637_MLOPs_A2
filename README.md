# Full-Stack Microservices Application with Authentication

A complete microservices architecture demonstrating modern DevOps practices with containerization, orchestration, and deployment on Kubernetes/Minikube.

![Architecture](docs/architecture-diagram.png)

## 🎯 Project Overview

This project implements a production-ready microservices application featuring:

- **Frontend**: React SPA with responsive UI for auth flows
- **Backend**: Node.js REST API with protected endpoints
- **Auth Service**: Dedicated microservice for authentication (JWT-based)
- **Database**: PostgreSQL with persistent storage
- **Containerization**: Docker with multi-stage builds
- **Orchestration**: Kubernetes manifests with 3 replicas per service
- **Security**: Password hashing (bcrypt), JWT tokens, secrets management

## 📁 Project Structure

```
fullstack-microservices/
├── frontend/                   # React application
│   ├── src/
│   │   ├── components/        # Login, Signup, ForgotPassword, etc.
│   │   ├── App.js
│   │   └── index.js
│   ├── Dockerfile
│   ├── nginx.conf
│   └── package.json
├── backend/                    # Backend REST API
│   ├── server.js
│   ├── Dockerfile
│   ├── package.json
│   └── README.md
├── auth-service/              # Authentication microservice
│   ├── server.js
│   ├── Dockerfile
│   ├── package.json
│   └── README.md
├── db/                        # Database initialization
│   ├── init.sql
│   └── README.md
├── k8s/                       # Kubernetes manifests
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── secrets.yaml
│   ├── pv-pvc.yaml
│   ├── db-deployment.yaml
│   ├── auth-deployment.yaml
│   ├── backend-deployment.yaml
│   ├── frontend-deployment.yaml
│   ├── ingress.yaml
│   └── kustomization.yaml
├── docs/                      # Documentation
│   ├── deployment-guide.md
│   ├── demo-script.md
│   └── architecture-diagram.png
├── scripts/                   # Automation scripts
│   ├── demo-test.sh
│   ├── build-images.sh
│   └── deploy-k8s.sh
├── docker-compose.yml         # Local development
└── README.md                  # This file
```

## ✨ Features

### Authentication
- ✅ User signup with validation
- ✅ Login with JWT access/refresh tokens
- ✅ Forgot password with secure token generation
- ✅ Reset password with token verification
- ✅ Password hashing with bcrypt (10 rounds)
- ✅ Token-based stateless authentication

### Microservices Architecture
- ✅ Service isolation with clear boundaries
- ✅ Inter-service communication via HTTP
- ✅ Independent scaling (3 replicas each)
- ✅ Health checks and readiness probes
- ✅ Configuration via ConfigMaps and Secrets

### DevOps & Deployment
- ✅ Dockerfiles with multi-stage builds
- ✅ Docker Compose for local development
- ✅ Kubernetes manifests with best practices
- ✅ PersistentVolume for database
- ✅ NodePort services for external access
- ✅ Resource requests and limits
- ✅ Liveness and readiness probes

## 🚀 Quick Start

### Prerequisites

- Docker (20.10+)
- Docker Compose (1.29+)
- Minikube (1.30+)
- kubectl (1.26+)
- Node.js 18+ (for local development)

### Option 1: Docker Compose (Recommended for Local Dev)

```bash
# Clone the repository
cd fullstack-microservices

# Start all services
docker compose up --build

# Access the application
# Frontend: http://localhost:3000
# Auth Service: http://localhost:3001
# Backend: http://localhost:5000
```

**Test the application:**
```bash
# Signup
curl -X POST http://localhost:3001/signup \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com","password":"SecurePass123"}'

# Login
curl -X POST http://localhost:3001/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john@example.com","password":"SecurePass123"}'

# Get profile (use token from login)
TOKEN="<access-token>"
curl -H "Authorization: Bearer $TOKEN" http://localhost:5000/profile
```

### Option 2: Kubernetes on Minikube

See detailed guide in [docs/deployment-guide.md](docs/deployment-guide.md)

```bash
# 1. Start Minikube
minikube start --cpus=4 --memory=8192

# 2. Build and load images
eval $(minikube docker-env)
docker build -t frontend:latest ./frontend
docker build -t backend:latest ./backend
docker build -t auth-service:latest ./auth-service

# 3. Deploy to Kubernetes
kubectl apply -f k8s/

# 4. Check deployment
kubectl get pods -n microservices

# 5. Access frontend
minikube service frontend-service -n microservices

# 6. Get Minikube IP for API access
minikube ip
```

## 🔧 Configuration

### Environment Variables

**Auth Service** (`.env`):
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

**Backend** (`.env`):
```bash
PORT=5000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=authdb
DB_USER=postgres
DB_PASSWORD=postgres
AUTH_SERVICE_URL=http://localhost:3001
```

**Frontend** (`.env`):
```bash
REACT_APP_AUTH_SERVICE_URL=http://localhost:3001
REACT_APP_BACKEND_SERVICE_URL=http://localhost:5000
```

## 📊 API Endpoints

### Auth Service (Port 3001)

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/signup` | Register new user | No |
| POST | `/login` | Login and get tokens | No |
| POST | `/forgot-password` | Request password reset | No |
| POST | `/reset-password` | Reset password with token | No |
| POST | `/verify-token` | Verify JWT token | No |
| POST | `/refresh-token` | Get new access token | No |
| GET | `/health` | Health check | No |

### Backend Service (Port 5000)

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/profile` | Get user profile | Yes |
| PUT | `/profile` | Update profile | Yes |
| GET | `/users` | List all users | Yes |
| GET | `/public-info` | Public endpoint | No |
| GET | `/health` | Health check | No |

### Frontend (Port 3000/80)

- `/login` - Login page
- `/signup` - Signup page
- `/forgot-password` - Password recovery
- `/reset-password` - Password reset with token
- `/dashboard` - User dashboard (protected)

## 🧪 Testing

### Automated Tests

```bash
# Run demo test script
./scripts/demo-test.sh

# Or run individual service tests
cd auth-service && npm test
cd backend && npm test
cd frontend && npm test
```

### Manual Testing

See [docs/demo-script.md](docs/demo-script.md) for step-by-step testing instructions.

## 🎬 Demo Video

Follow the script in [docs/demo-script.md](docs/demo-script.md) to record a demo showing:

1. Starting Minikube
2. Building and loading images
3. Deploying with kubectl
4. Showing 3 replicas running
5. Testing signup/login flows
6. Making authenticated API calls
7. Viewing data in dashboard

## 📈 Monitoring & Health Checks

Each service exposes a `/health` endpoint:

```bash
# Docker Compose
curl http://localhost:3001/health  # Auth
curl http://localhost:5000/health  # Backend

# Kubernetes (get NodePort first)
MINIKUBE_IP=$(minikube ip)
curl http://$MINIKUBE_IP:30001/health  # Auth
curl http://$MINIKUBE_IP:30000/health  # Backend
```

## 🛠️ Development

### Local Development (without Docker)

```bash
# Terminal 1: Start PostgreSQL
docker run -d -p 5432:5432 \
  -e POSTGRES_DB=authdb \
  -e POSTGRES_PASSWORD=postgres \
  postgres:15-alpine

# Terminal 2: Auth Service
cd auth-service
npm install
npm run dev

# Terminal 3: Backend
cd backend
npm install
npm run dev

# Terminal 4: Frontend
cd frontend
npm install
npm start
```

### Database Access

```bash
# Docker Compose
docker exec -it postgres-db psql -U postgres -d authdb

# Kubernetes
kubectl port-forward -n microservices svc/postgres-service 5432:5432
psql -h localhost -U postgres -d authdb
```

## 🔒 Security Notes

### For Production

1. **Change all default secrets** in `.env` and Kubernetes secrets
2. **Use external secret managers**: Vault, AWS Secrets Manager, etc.
3. **Enable HTTPS** with proper TLS certificates
4. **Implement rate limiting** on auth endpoints
5. **Use httpOnly cookies** instead of localStorage for tokens
6. **Add CORS** with specific origins (not wildcard)
7. **Enable database SSL** connections
8. **Implement audit logging**
9. **Use network policies** to restrict pod-to-pod communication
10. **Regular security updates** and dependency scanning

### Current Demo Limitations

⚠️ **This is a demo application. Do NOT use in production without:**
- Changing all default passwords and secrets
- Implementing proper secret management
- Adding rate limiting and DDoS protection
- Using HTTPS everywhere
- Implementing proper logging and monitoring
- Adding comprehensive error handling
- Implementing database backups
- Adding CI/CD pipelines with security scanning

## 📝 Architecture

### Service Communication Flow

```
User → Frontend (React SPA)
         ↓
    ┌────┴────┐
    ↓         ↓
Auth Service  Backend Service
    ↓         ↓
    └────┬────┘
         ↓
    PostgreSQL
```

### Authentication Flow

1. User submits credentials to Auth Service
2. Auth Service validates and returns JWT tokens
3. Frontend stores tokens (localStorage in demo)
4. Frontend sends token in Authorization header
5. Backend verifies token with Auth Service
6. Backend returns protected data

## 🎓 Learning Resources

This project demonstrates:

- **Microservices Architecture**: Service isolation, API design
- **Containerization**: Docker, multi-stage builds, optimization
- **Orchestration**: Kubernetes deployments, services, scaling
- **Authentication**: JWT tokens, password hashing, secure flows
- **DevOps**: CI/CD-ready, infrastructure as code
- **Best Practices**: Health checks, resource limits, secrets management

## 🐛 Troubleshooting

### Docker Compose Issues

```bash
# View logs
docker compose logs -f [service-name]

# Restart services
docker compose restart

# Clean restart
docker compose down -v
docker compose up --build
```

### Kubernetes Issues

```bash
# Check pod status
kubectl get pods -n microservices

# View logs
kubectl logs -n microservices <pod-name>

# Describe pod
kubectl describe pod -n microservices <pod-name>

# Check events
kubectl get events -n microservices --sort-by='.lastTimestamp'
```

### Common Issues

1. **ImagePullBackOff**: Ensure images are built and loaded into Minikube
2. **CrashLoopBackOff**: Check logs for errors, verify DB connectivity
3. **Connection refused**: Ensure services are using correct service names
4. **401 Unauthorized**: Verify token is valid and not expired

## 🤝 Contributing

Contributions welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## ✅ Acceptance Criteria Checklist

- [x] Complete frontend with Signup, Login, Forgot Password, Dashboard
- [x] Backend service with protected endpoints
- [x] Separate auth microservice with JWT implementation
- [x] PostgreSQL database with persistent storage
- [x] Dockerfiles for all services
- [x] docker-compose.yml for local development
- [x] Kubernetes manifests with 3 replicas
- [x] PersistentVolume/PersistentVolumeClaim for database
- [x] ConfigMaps and Secrets
- [x] Health checks and resource limits
- [x] NodePort services for external access
- [x] Documentation (README, deployment guide, demo script)
- [x] Test scripts for automated validation
- [x] Architecture diagram
- [x] Security best practices (bcrypt, JWT, secrets)

## 📞 Support

For issues or questions:
- Create an issue in the repository
- Check existing documentation
- Review logs for error messages

---

**Built with ❤️ for learning microservices, Docker, and Kubernetes**

