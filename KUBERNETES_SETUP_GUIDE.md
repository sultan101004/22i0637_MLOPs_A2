# Kubernetes Deployment Guide - Step by Step

## ✅ What You've Already Accomplished

You have successfully:
- ✅ Built a complete microservices application
- ✅ Containerized all services with Docker
- ✅ Deployed locally with Docker Compose
- ✅ Tested full authentication flow (signup, login, dashboard)

## 🚀 Next Step: Kubernetes Deployment

To deploy the same application on Kubernetes with **3 replicas per service**, follow these steps:

---

## 📥 Step 1: Install Minikube

### Windows Installation

**Option A: Direct Download (Recommended)**

1. Open PowerShell as Administrator
2. Run these commands:

```powershell
# Download Minikube
New-Item -Path 'c:\' -Name 'minikube' -ItemType Directory -Force
Invoke-WebRequest -OutFile 'c:\minikube\minikube.exe' -Uri 'https://github.com/kubernetes/minikube/releases/latest/download/minikube-windows-amd64.exe' -UseBasicParsing

# Add to PATH
$oldPath = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine)
if ($oldPath -notlike "*c:\minikube*") {
    [Environment]::SetEnvironmentVariable('Path', "$oldPath;c:\minikube", [EnvironmentVariableTarget]::Machine)
}
```

3. Close and reopen PowerShell
4. Verify: `minikube version`

**Option B: Using Chocolatey**

```powershell
choco install minikube -y
```

### Mac/Linux Installation

```bash
# Mac
brew install minikube

# Linux
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

---

## 🎯 Step 2: Start Minikube

```powershell
# Start with sufficient resources
minikube start --cpus=4 --memory=8192 --disk-size=20g

# Verify it's running
minikube status
```

Expected output:
```
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
```

---

## 🔧 Step 3: Stop Docker Compose (Important!)

Before deploying to Kubernetes, stop the Docker Compose services to free up ports:

```powershell
docker compose down
```

---

## 🏗️ Step 4: Build Docker Images for Minikube

Configure Docker to use Minikube's Docker daemon:

```powershell
# Set environment to use Minikube's Docker
minikube docker-env | Invoke-Expression

# Verify
docker info | Select-String "Name:"
# Should show something like "minikube"
```

Now build all images:

```powershell
# Build images (this will take 5-10 minutes)
docker build -t frontend:latest ./frontend
docker build -t backend:latest ./backend
docker build -t auth-service:latest ./auth-service
```

Verify images are in Minikube:
```powershell
minikube image ls | Select-String "frontend|backend|auth"
```

---

## 📦 Step 5: Deploy to Kubernetes

```powershell
# Apply all Kubernetes manifests
kubectl apply -f k8s/

# Watch pods starting (press Ctrl+C when done)
kubectl get pods -n microservices -w
```

Wait for all pods to show `Running` status (1-3 minutes).

---

## ✅ Step 6: Verify Deployment

Check that you have **3 replicas** of each service:

```powershell
# View all pods
kubectl get pods -n microservices

# Should show:
# - 3 auth-service pods
# - 3 backend pods  
# - 3 frontend pods
# - 1 postgres pod

# View deployments
kubectl get deployments -n microservices
```

Expected output:
```
NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
auth-service-deployment     3/3     3            3           2m
backend-deployment          3/3     3            3           2m
frontend-deployment         3/3     3            3           2m
postgres-deployment         1/1     1            1           2m
```

Check services:
```powershell
kubectl get svc -n microservices
```

---

## 🌐 Step 7: Access the Application

### Get Access URLs

```powershell
# Get Minikube IP
$MINIKUBE_IP = minikube ip
Write-Host "Minikube IP: $MINIKUBE_IP"

# Access URLs
Write-Host "Frontend:     http://${MINIKUBE_IP}:30080"
Write-Host "Auth Service: http://${MINIKUBE_IP}:30001"
Write-Host "Backend:      http://${MINIKUBE_IP}:30000"
```

### Option A: Open in Browser via minikube service

```powershell
# Automatically open frontend (easiest method)
minikube service frontend-service -n microservices
```

### Option B: Manual Access

Open your browser and go to:
- **Frontend**: http://<MINIKUBE_IP>:30080
- **Auth API**: http://<MINIKUBE_IP>:30001/health
- **Backend API**: http://<MINIKUBE_IP>:30000/health

Replace `<MINIKUBE_IP>` with the actual IP from `minikube ip` command.

---

## 🧪 Step 8: Test the Application

### Test in Browser

1. Open the frontend URL
2. Sign up with new credentials
3. Login
4. View dashboard

### Test via API

```powershell
$MINIKUBE_IP = minikube ip
$AUTH_URL = "http://${MINIKUBE_IP}:30001"
$BACKEND_URL = "http://${MINIKUBE_IP}:30000"

# Test health
Invoke-WebRequest -Uri "${AUTH_URL}/health"
Invoke-WebRequest -Uri "${BACKEND_URL}/health"

# Signup
$signupData = @{
    name = "K8s Test User"
    email = "k8s@example.com"
    password = "Test123!"
} | ConvertTo-Json

Invoke-RestMethod -Uri "${AUTH_URL}/signup" -Method Post -ContentType "application/json" -Body $signupData

# Login and get token
$loginData = @{
    email = "k8s@example.com"
    password = "Test123!"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "${AUTH_URL}/login" -Method Post -ContentType "application/json" -Body $loginData
$token = $response.accessToken

# Get profile (protected endpoint)
$headers = @{Authorization = "Bearer $token"}
Invoke-RestMethod -Uri "${BACKEND_URL}/profile" -Headers $headers
```

---

## 📊 Step 9: Explore Kubernetes Features

### View Logs

```powershell
# View logs from a specific pod
kubectl logs -n microservices <pod-name>

# Follow logs in real-time
kubectl logs -f -n microservices <pod-name>

# View logs from all auth service pods
kubectl logs -l app=auth-service -n microservices
```

### Scale Services

```powershell
# Scale auth service to 5 replicas
kubectl scale deployment auth-service-deployment -n microservices --replicas=5

# Verify
kubectl get pods -n microservices -l app=auth-service

# Scale back to 3
kubectl scale deployment auth-service-deployment -n microservices --replicas=3
```

### Test Self-Healing

```powershell
# Delete a pod (Kubernetes will recreate it automatically)
kubectl delete pod -n microservices -l app=auth-service | Select-Object -First 1

# Watch it recreate
kubectl get pods -n microservices -l app=auth-service -w
```

### Access Pod Shell

```powershell
# Get pod name
kubectl get pods -n microservices

# Shell into a pod
kubectl exec -it -n microservices <pod-name> -- /bin/sh
```

### View Resource Usage

```powershell
# Resource usage by pods
kubectl top pods -n microservices

# Resource usage by nodes
kubectl top nodes
```

---

## 🧹 Step 10: Cleanup

### Stop and Remove Everything

```powershell
# Delete all Kubernetes resources
kubectl delete -f k8s/

# Or delete namespace (removes everything)
kubectl delete namespace microservices

# Stop Minikube
minikube stop

# Delete Minikube cluster (if you want to start fresh)
minikube delete
```

### Keep Minikube, Just Stop Services

```powershell
# Just delete the app
kubectl delete namespace microservices

# Minikube stays running for future use
```

---

## 🔍 Troubleshooting

### Pods Not Starting

```powershell
# Check pod status
kubectl get pods -n microservices

# Describe pod to see events
kubectl describe pod -n microservices <pod-name>

# Check logs
kubectl logs -n microservices <pod-name>
```

### ImagePullBackOff Error

```powershell
# Verify images are in Minikube
minikube image ls | Select-String "frontend|backend|auth"

# If missing, rebuild
minikube docker-env | Invoke-Expression
docker build -t frontend:latest ./frontend
docker build -t backend:latest ./backend
docker build -t auth-service:latest ./auth-service
```

### Database Connection Issues

```powershell
# Check if postgres pod is running
kubectl get pods -n microservices -l app=postgres

# Check postgres logs
kubectl logs -n microservices -l app=postgres

# Verify service exists
kubectl get svc -n microservices postgres-service
```

### Can't Access Services

```powershell
# Verify services are exposed
kubectl get svc -n microservices

# Check NodePort numbers
kubectl get svc -n microservices frontend-service -o yaml

# Verify Minikube IP
minikube ip

# Test with port forwarding instead
kubectl port-forward -n microservices svc/frontend-service 3000:80
# Then access http://localhost:3000
```

---

## 📚 Learning Resources

### Kubernetes Concepts Demonstrated

- **Deployments**: Manages pod replicas and rolling updates
- **Services**: Load balancing and service discovery
- **ConfigMaps**: Non-sensitive configuration
- **Secrets**: Sensitive data (credentials)
- **PersistentVolumes**: Persistent storage for database
- **Namespaces**: Resource isolation
- **Health Probes**: Liveness and readiness checks
- **Resource Limits**: CPU and memory constraints

### Key Commands Reference

```powershell
# View everything in namespace
kubectl get all -n microservices

# Describe any resource
kubectl describe <resource-type> <resource-name> -n microservices

# Delete resources
kubectl delete <resource-type> <resource-name> -n microservices

# Watch resource changes
kubectl get <resource-type> -n microservices -w

# Port forward for debugging
kubectl port-forward -n microservices <pod-name> <local-port>:<pod-port>

# Execute commands in pod
kubectl exec -it -n microservices <pod-name> -- <command>

# View events
kubectl get events -n microservices --sort-by='.lastTimestamp'
```

---

## ✅ Success Criteria

You'll know everything is working when:

1. ✅ `kubectl get pods -n microservices` shows 10 pods (3+3+3+1) all Running
2. ✅ `kubectl get deployments -n microservices` shows 3/3 replicas for each service
3. ✅ You can access the frontend in your browser
4. ✅ You can signup/login successfully
5. ✅ Dashboard displays user information
6. ✅ All health endpoints return 200 OK

---

## 🎯 What's Next?

After successful Kubernetes deployment, you can explore:

1. **CI/CD**: Add GitHub Actions workflow
2. **Monitoring**: Install Prometheus & Grafana
3. **Ingress**: Set up ingress controller with domain
4. **TLS**: Add SSL certificates
5. **Auto-scaling**: Configure HPA (Horizontal Pod Autoscaler)
6. **Service Mesh**: Try Istio or Linkerd
7. **Helm Charts**: Package your application

---

## 🎓 Learning Outcomes

By completing this deployment, you'll have:

- ✅ Deployed a production-like Kubernetes cluster
- ✅ Managed 3 replicas per service
- ✅ Configured persistent storage
- ✅ Implemented service discovery
- ✅ Used ConfigMaps and Secrets
- ✅ Set up health checks
- ✅ Exposed services externally
- ✅ Demonstrated horizontal scaling
- ✅ Experienced self-healing infrastructure

---

**Good luck with your Kubernetes deployment! 🚀**

For questions or issues, check the troubleshooting section or refer to the main README.md.

