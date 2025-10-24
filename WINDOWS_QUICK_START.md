# Windows Quick Start Guide

## Prerequisites

1. **Start Docker Desktop**
   - Open Docker Desktop from Start menu
   - Wait for "Docker Desktop is running" message
   - Check system tray for Docker whale icon

## Running the Application

### Option 1: Docker Compose (Recommended for Windows)

```powershell
# Navigate to project directory
cd "C:\Users\ideal\Desktop\22i0637_MLOPs_A2"

# Start all services
docker compose up -d --build

# This will:
# - Build all Docker images
# - Start 4 containers (Frontend, Backend, Auth, Database)
# - Takes 2-3 minutes first time
```

### Accessing the Application

Once running (wait for "docker compose up" to finish):

- **Frontend (Browser)**: http://localhost:3000
- **Auth Service API**: http://localhost:3001
- **Backend API**: http://localhost:5000

### Testing in Browser

1. Open http://localhost:3000
2. Click "Sign Up"
3. Create account:
   - Name: Your Name
   - Email: test@example.com
   - Password: Test123!
4. Click "Login"
5. View your dashboard!

### Testing with PowerShell/API

```powershell
# Test health endpoints
Invoke-WebRequest -Uri http://localhost:3001/health
Invoke-WebRequest -Uri http://localhost:5000/health

# Signup (using curl if available)
curl -X POST http://localhost:3001/signup `
  -H "Content-Type: application/json" `
  -d '{"name":"Test User","email":"test@example.com","password":"Test123!"}'

# Login
curl -X POST http://localhost:3001/login `
  -H "Content-Type: application/json" `
  -d '{"email":"test@example.com","password":"Test123!"}'
```

### Viewing Logs

```powershell
# View all logs
docker compose logs -f

# View specific service logs
docker compose logs -f frontend
docker compose logs -f auth-service
docker compose logs -f backend
docker compose logs -f db
```

### Checking Status

```powershell
# Check if containers are running
docker compose ps

# Should show:
# - frontend (healthy)
# - backend (healthy)
# - auth-service (healthy)
# - postgres-db (healthy)
```

### Stopping the Application

```powershell
# Stop services (preserves data)
docker compose stop

# Stop and remove containers
docker compose down

# Stop and remove everything including data
docker compose down -v
```

## Troubleshooting

### Port Already in Use

If you get "port already in use" error:

```powershell
# Find process using port (e.g., 3000)
netstat -ano | findstr :3000

# Kill process (replace PID with actual number)
taskkill /PID <PID> /F
```

### Docker Compose Not Found

```powershell
# Try with hyphen instead
docker-compose up -d --build
```

### Containers Won't Start

```powershell
# Check Docker is running
docker info

# Restart Docker Desktop
# Right-click Docker icon → Restart Docker Desktop

# Clear and rebuild
docker compose down -v
docker compose up -d --build
```

### View Container Details

```powershell
# List all containers
docker ps -a

# View container logs
docker logs <container-name>

# Example:
docker logs auth-service
docker logs backend
```

## What's Running?

After successful start:

| Service | Port | URL |
|---------|------|-----|
| Frontend | 3000 | http://localhost:3000 |
| Auth Service | 3001 | http://localhost:3001 |
| Backend | 5000 | http://localhost:5000 |
| PostgreSQL | 5432 | localhost:5432 |

## Testing Script (PowerShell)

Save this as `test.ps1`:

```powershell
# Test all services
Write-Host "Testing Auth Service..." -ForegroundColor Cyan
Invoke-WebRequest -Uri http://localhost:3001/health

Write-Host "Testing Backend..." -ForegroundColor Cyan
Invoke-WebRequest -Uri http://localhost:5000/health

Write-Host "Testing Frontend..." -ForegroundColor Cyan
Invoke-WebRequest -Uri http://localhost:3000

Write-Host "All services are running!" -ForegroundColor Green
```

Run with: `powershell .\test.ps1`

## Next Steps

Once running successfully:

1. ✅ Test in browser (http://localhost:3000)
2. ✅ Try signup and login
3. ✅ View dashboard
4. ✅ Test forgot password flow
5. ✅ Check `README.md` for more details
6. ✅ Try Kubernetes deployment (requires Minikube)

## Expected First Run Time

- **First time**: 5-10 minutes (downloads base images, builds)
- **Subsequent runs**: 1-2 minutes

## Signs It's Working

✅ `docker compose ps` shows all services "Up (healthy)"
✅ http://localhost:3000 shows login page
✅ Health endpoints return 200 OK
✅ No error messages in logs

## Common Issues

### Issue: "Cannot connect to Docker daemon"
**Solution**: Start Docker Desktop and wait for it to be ready

### Issue: "Port 3000 is already allocated"
**Solution**: Stop the service using that port or change port in docker-compose.yml

### Issue: "Build failed"
**Solution**: 
```powershell
docker compose down -v
docker system prune -f
docker compose up -d --build
```

---

**Need Help?** Check `README.md` or `docs/deployment-guide.md`

