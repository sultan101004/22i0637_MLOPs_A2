#!/bin/bash

# Demo Test Script
# Automated end-to-end testing for the microservices application
# Tests: Health checks, Signup, Login, Protected endpoints, Password reset

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
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

# Configuration
ENVIRONMENT=${1:-"kubernetes"}  # Default to kubernetes, can pass "docker" for Docker Compose

if [ "$ENVIRONMENT" == "docker" ]; then
    log_info "Testing Docker Compose deployment"
    AUTH_URL="http://localhost:3001"
    BACKEND_URL="http://localhost:5000"
elif [ "$ENVIRONMENT" == "kubernetes" ]; then
    log_info "Testing Kubernetes deployment"
    MINIKUBE_IP=$(minikube ip 2>/dev/null || echo "localhost")
    AUTH_URL="http://$MINIKUBE_IP:30001"
    BACKEND_URL="http://$MINIKUBE_IP:30000"
else
    log_error "Unknown environment: $ENVIRONMENT"
    echo "Usage: $0 [docker|kubernetes]"
    exit 1
fi

log_info "Auth Service URL: $AUTH_URL"
log_info "Backend URL: $BACKEND_URL"
echo ""

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Generate random email for testing
RANDOM_EMAIL="test_$(date +%s)@example.com"
PASSWORD="TestPassword123!"
NAME="Test User"

# Test function
run_test() {
    local test_name=$1
    local test_command=$2
    
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log_info "Testing: $test_name"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if eval "$test_command"; then
        log_success "$test_name - PASSED"
        ((TESTS_PASSED++))
        return 0
    else
        log_error "$test_name - FAILED"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Wait for services to be ready
wait_for_service() {
    local url=$1
    local service_name=$2
    local max_attempts=30
    local attempt=0
    
    log_info "Waiting for $service_name to be ready..."
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -s -f "$url" > /dev/null 2>&1; then
            log_success "$service_name is ready!"
            return 0
        fi
        
        attempt=$((attempt + 1))
        echo -n "."
        sleep 2
    done
    
    echo ""
    log_error "$service_name is not responding after $((max_attempts * 2)) seconds"
    return 1
}

# Start tests
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════╗"
echo "║   Microservices Demo Test Suite              ║"
echo "║   Environment: $ENVIRONMENT"
echo "╚═══════════════════════════════════════════════╝"
echo -e "${NC}"

# Test 1: Wait for services
run_test "Service Availability" "wait_for_service $AUTH_URL/health 'Auth Service' && wait_for_service $BACKEND_URL/health 'Backend Service'"

# Test 2: Auth Service Health Check
run_test "Auth Service Health Check" '
    RESPONSE=$(curl -s -w "\n%{http_code}" "$AUTH_URL/health")
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | head -n-1)
    
    echo "Response: $BODY"
    echo "HTTP Code: $HTTP_CODE"
    
    [ "$HTTP_CODE" == "200" ] && echo "$BODY" | grep -q "ok"
'

# Test 3: Backend Service Health Check
run_test "Backend Service Health Check" '
    RESPONSE=$(curl -s -w "\n%{http_code}" "$BACKEND_URL/health")
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | head -n-1)
    
    echo "Response: $BODY"
    echo "HTTP Code: $HTTP_CODE"
    
    [ "$HTTP_CODE" == "200" ] && echo "$BODY" | grep -q "ok"
'

# Test 4: Public Endpoint (No Auth)
run_test "Backend Public Endpoint" '
    RESPONSE=$(curl -s -w "\n%{http_code}" "$BACKEND_URL/public-info")
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | head -n-1)
    
    echo "Response: $BODY"
    echo "HTTP Code: $HTTP_CODE"
    
    [ "$HTTP_CODE" == "200" ] && echo "$BODY" | grep -q "public"
'

# Test 5: User Signup
run_test "User Signup" '
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$AUTH_URL/signup" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"$NAME\",\"email\":\"$RANDOM_EMAIL\",\"password\":\"$PASSWORD\"}")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | head -n-1)
    
    echo "Email: $RANDOM_EMAIL"
    echo "Response: $BODY"
    echo "HTTP Code: $HTTP_CODE"
    
    [ "$HTTP_CODE" == "201" ] && echo "$BODY" | grep -q "created"
'

# Test 6: User Login
run_test "User Login" '
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$AUTH_URL/login" \
        -H "Content-Type: application/json" \
        -d "{\"email\":\"$RANDOM_EMAIL\",\"password\":\"$PASSWORD\"}")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | head -n-1)
    
    echo "Response: $BODY"
    echo "HTTP Code: $HTTP_CODE"
    
    # Extract access token
    ACCESS_TOKEN=$(echo "$BODY" | grep -o "\"accessToken\":\"[^\"]*\"" | cut -d"\"" -f4)
    
    if [ -z "$ACCESS_TOKEN" ]; then
        log_error "No access token received"
        return 1
    fi
    
    echo "Access Token: ${ACCESS_TOKEN:0:50}..."
    
    # Save token for next tests
    echo "$ACCESS_TOKEN" > /tmp/demo_test_token
    
    [ "$HTTP_CODE" == "200" ] && [ ! -z "$ACCESS_TOKEN" ]
'

# Test 7: Protected Endpoint (No Token)
run_test "Protected Endpoint Without Token (Should Fail)" '
    RESPONSE=$(curl -s -w "\n%{http_code}" "$BACKEND_URL/profile")
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | head -n-1)
    
    echo "Response: $BODY"
    echo "HTTP Code: $HTTP_CODE"
    
    # Should return 401 Unauthorized
    [ "$HTTP_CODE" == "401" ]
'

# Test 8: Protected Endpoint (With Token)
run_test "Protected Endpoint With Token" '
    if [ ! -f /tmp/demo_test_token ]; then
        log_error "Token file not found"
        return 1
    fi
    
    ACCESS_TOKEN=$(cat /tmp/demo_test_token)
    
    RESPONSE=$(curl -s -w "\n%{http_code}" "$BACKEND_URL/profile" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | head -n-1)
    
    echo "Response: $BODY"
    echo "HTTP Code: $HTTP_CODE"
    
    [ "$HTTP_CODE" == "200" ] && echo "$BODY" | grep -q "$RANDOM_EMAIL"
'

# Test 9: Get All Users (Protected)
run_test "Get All Users (Protected Endpoint)" '
    if [ ! -f /tmp/demo_test_token ]; then
        log_error "Token file not found"
        return 1
    fi
    
    ACCESS_TOKEN=$(cat /tmp/demo_test_token)
    
    RESPONSE=$(curl -s -w "\n%{http_code}" "$BACKEND_URL/users" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | head -n-1)
    
    echo "Response: $BODY"
    echo "HTTP Code: $HTTP_CODE"
    
    [ "$HTTP_CODE" == "200" ] && echo "$BODY" | grep -q "count"
'

# Test 10: Forgot Password
run_test "Forgot Password" '
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$AUTH_URL/forgot-password" \
        -H "Content-Type: application/json" \
        -d "{\"email\":\"$RANDOM_EMAIL\"}")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | head -n-1)
    
    echo "Response: $BODY"
    echo "HTTP Code: $HTTP_CODE"
    
    # Extract reset token (only available in demo mode)
    RESET_TOKEN=$(echo "$BODY" | grep -o "\"resetToken\":\"[^\"]*\"" | cut -d"\"" -f4)
    
    if [ ! -z "$RESET_TOKEN" ]; then
        echo "Reset Token: ${RESET_TOKEN:0:50}..."
        echo "$RESET_TOKEN" > /tmp/demo_test_reset_token
    fi
    
    [ "$HTTP_CODE" == "200" ]
'

# Test 11: Reset Password
run_test "Reset Password" '
    if [ ! -f /tmp/demo_test_reset_token ]; then
        log_warning "Reset token not found, skipping test"
        return 0  # Skip but dont fail
    fi
    
    RESET_TOKEN=$(cat /tmp/demo_test_reset_token)
    NEW_PASSWORD="NewPassword456!"
    
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$AUTH_URL/reset-password" \
        -H "Content-Type: application/json" \
        -d "{\"token\":\"$RESET_TOKEN\",\"newPassword\":\"$NEW_PASSWORD\"}")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | head -n-1)
    
    echo "Response: $BODY"
    echo "HTTP Code: $HTTP_CODE"
    
    [ "$HTTP_CODE" == "200" ] && echo "$BODY" | grep -q "success"
'

# Test 12: Login with New Password
run_test "Login With New Password" '
    if [ ! -f /tmp/demo_test_reset_token ]; then
        log_warning "Reset token not found, skipping test"
        return 0  # Skip but dont fail
    fi
    
    NEW_PASSWORD="NewPassword456!"
    
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$AUTH_URL/login" \
        -H "Content-Type: application/json" \
        -d "{\"email\":\"$RANDOM_EMAIL\",\"password\":\"$NEW_PASSWORD\"}")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | head -n-1)
    
    echo "Response: $BODY"
    echo "HTTP Code: $HTTP_CODE"
    
    [ "$HTTP_CODE" == "200" ] && echo "$BODY" | grep -q "accessToken"
'

# Cleanup
rm -f /tmp/demo_test_token /tmp/demo_test_reset_token

# Print summary
echo ""
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════╗"
echo "║            Test Summary                       ║"
echo "╚═══════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${GREEN}Tests Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Tests Failed: $TESTS_FAILED${NC}"
echo "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✓ All tests passed successfully!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 0
else
    echo -e "\n${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}✗ Some tests failed. Please review the output above.${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 1
fi

