# Kubernetes Manifests

Complete Kubernetes deployment configuration for the microservices application.

## Structure

```
k8s/
├── namespace.yaml              # Namespace definition
├── configmap.yaml              # Non-sensitive configuration
├── secrets.yaml                # Sensitive data (base64 encoded)
├── pv-pvc.yaml                 # PersistentVolume and PersistentVolumeClaim
├── db-deployment.yaml          # PostgreSQL deployment (1 replica)
├── auth-deployment.yaml        # Auth service (3 replicas)
├── backend-deployment.yaml     # Backend service (3 replicas)
├── frontend-deployment.yaml    # Frontend service (3 replicas)
├── ingress.yaml                # Optional Ingress configuration
├── kustomization.yaml          # Kustomize configuration
└── README.md                   # This file
```

## Prerequisites

1. **Minikube** installed and running
2. **kubectl** configured
3. Docker images built and loaded into Minikube

## Quick Start

### 1. Start Minikube

```bash
minikube start --cpus=4 --memory=8192
```

### 2. Build and Load Docker Images

**Option A: Using Minikube's Docker daemon**
```bash
eval $(minikube -p minikube docker-env)

# Build images
docker build -t frontend:latest ./frontend
docker build -t backend:latest ./backend
docker build -t auth-service:latest ./auth-service
```

**Option B: Build locally and load**
```bash
docker build -t frontend:latest ./frontend
docker build -t backend:latest ./backend
docker build -t auth-service:latest ./auth-service

minikube image load frontend:latest
minikube image load backend:latest
minikube image load auth-service:latest
```

### 3. Apply Kubernetes Manifests

```bash
# Apply all manifests
kubectl apply -f k8s/

# Or use kustomize
kubectl apply -k k8s/
```

### 4. Verify Deployment

```bash
# Check namespace
kubectl get ns

# Check all resources
kubectl get all -n microservices

# Check pods (should see 3 replicas for each service)
kubectl get pods -n microservices

# Check services
kubectl get svc -n microservices

# Check persistent volume
kubectl get pv,pvc -n microservices
```

Expected output:
```
NAME                                        READY   STATUS    RESTARTS   AGE
pod/auth-service-deployment-xxx-xxx         1/1     Running   0          2m
pod/auth-service-deployment-xxx-yyy         1/1     Running   0          2m
pod/auth-service-deployment-xxx-zzz         1/1     Running   0          2m
pod/backend-deployment-xxx-xxx              1/1     Running   0          2m
pod/backend-deployment-xxx-yyy              1/1     Running   0          2m
pod/backend-deployment-xxx-zzz              1/1     Running   0          2m
pod/frontend-deployment-xxx-xxx             1/1     Running   0          2m
pod/frontend-deployment-xxx-yyy             1/1     Running   0          2m
pod/frontend-deployment-xxx-zzz             1/1     Running   0          2m
pod/postgres-deployment-xxx-xxx             1/1     Running   0          3m
```

### 5. Access the Application

**Frontend:**
```bash
# Get URL
minikube service frontend-service -n microservices --url

# Or access via NodePort
minikube ip  # Get Minikube IP
# Then open http://<MINIKUBE_IP>:30080
```

**Auth Service:**
```bash
minikube service auth-service-nodeport -n microservices --url
# Or http://<MINIKUBE_IP>:30001
```

**Backend Service:**
```bash
minikube service backend-service-nodeport -n microservices --url
# Or http://<MINIKUBE_IP>:30000
```

### 6. Test the Application

```bash
# Get Minikube IP
MINIKUBE_IP=$(minikube ip)

# Test auth service health
curl http://$MINIKUBE_IP:30001/health

# Test backend health
curl http://$MINIKUBE_IP:30000/health

# Signup
curl -X POST http://$MINIKUBE_IP:30001/signup \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"Test123!"}'

# Login
curl -X POST http://$MINIKUBE_IP:30001/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!"}'

# Save token
TOKEN="<access-token-from-login>"

# Get profile
curl -H "Authorization: Bearer $TOKEN" http://$MINIKUBE_IP:30000/profile
```

## Configuration

### ConfigMap (configmap.yaml)

Non-sensitive configuration:
- Database host/port/name
- Service URLs
- Environment settings

### Secrets (secrets.yaml)

Sensitive data (base64 encoded):
- Database credentials
- JWT secrets

**Decode secrets:**
```bash
echo "cG9zdGdyZXM=" | base64 -d
```

**Create new secrets:**
```bash
echo -n "your-secret" | base64
```

### Resource Limits

| Service | Requests | Limits |
|---------|----------|--------|
| Frontend | 64Mi / 50m | 128Mi / 100m |
| Backend | 128Mi / 100m | 256Mi / 200m |
| Auth Service | 128Mi / 100m | 256Mi / 200m |
| PostgreSQL | 256Mi / 250m | 512Mi / 500m |

## Scaling

```bash
# Scale auth service to 5 replicas
kubectl scale deployment auth-service-deployment -n microservices --replicas=5

# Verify
kubectl get pods -n microservices -l app=auth-service
```

## Troubleshooting

### Check Pod Logs
```bash
kubectl logs -n microservices <pod-name>
kubectl logs -n microservices <pod-name> --previous  # Previous container
```

### Check Pod Details
```bash
kubectl describe pod -n microservices <pod-name>
```

### Check Events
```bash
kubectl get events -n microservices --sort-by='.lastTimestamp'
```

### Common Issues

**1. ImagePullBackOff**
- Ensure images are loaded: `minikube image ls`
- Use `imagePullPolicy: IfNotPresent` in deployments

**2. CrashLoopBackOff**
- Check logs: `kubectl logs -n microservices <pod-name>`
- Verify database is running and accessible

**3. Pods Not Ready**
- Check readiness probe: `kubectl describe pod -n microservices <pod-name>`
- Verify service dependencies (DB → Auth → Backend → Frontend)

### Access Database
```bash
# Forward PostgreSQL port
kubectl port-forward -n microservices svc/postgres-service 5432:5432

# Connect with psql
psql -h localhost -U postgres -d authdb
```

## Optional: Ingress

Enable Ingress (requires `minikube tunnel` in separate terminal):

```bash
# Enable ingress addon
minikube addons enable ingress

# Apply ingress
kubectl apply -f k8s/ingress.yaml

# Add to /etc/hosts
echo "$(minikube ip) microservices.local" | sudo tee -a /etc/hosts

# Start tunnel (keep running)
minikube tunnel

# Access at http://microservices.local
```

## Cleanup

```bash
# Delete all resources
kubectl delete -f k8s/
# Or
kubectl delete -k k8s/

# Delete namespace (removes everything)
kubectl delete namespace microservices

# Stop Minikube
minikube stop

# Delete Minikube cluster
minikube delete
```

## Production Considerations

1. **Secrets Management**: Use sealed secrets or external secret managers
2. **Persistent Storage**: Use proper storage classes (not hostPath)
3. **TLS/SSL**: Add TLS certificates for ingress
4. **Monitoring**: Add Prometheus/Grafana
5. **Logging**: Add ELK or Loki stack
6. **Resource Limits**: Adjust based on load testing
7. **High Availability**: Use anti-affinity rules
8. **Backups**: Implement database backup strategy
9. **Network Policies**: Add network segmentation
10. **Security**: Implement pod security policies

