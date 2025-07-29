# Install docker and docker compose and configure it in ubuntu
#!/bin/bash

# Get error log file from parent script
ERROR_LOG="${1:-/tmp/dotfiles_error.log}"

# Color codes for pretty printing
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Icons for pretty printing
SUCCESS="✅"
FAILURE="❌"
WARNING="⚠️"
INFO="ℹ️"
DOCKER="🐳"

# Error tracking
ERRORS=0

# Function to print colored output
print_info() {
    echo -e "${CYAN}${INFO}${NC} ${BOLD}$1${NC}"
}

print_success() {
    echo -e "${GREEN}${SUCCESS}${NC} ${BOLD}$1${NC}"
}

print_error() {
    echo -e "${RED}${FAILURE}${NC} ${BOLD}$1${NC}"
    echo "[ERROR] [$(date '+%Y-%m-%d %H:%M:%S')] Docker: $1" >> "$ERROR_LOG"
    ERRORS=$((ERRORS + 1))
}

print_warning() {
    echo -e "${YELLOW}${WARNING}${NC} ${BOLD}$1${NC}"
}

# Function to safely execute commands
safe_execute() {
    local description="$1"
    shift
    local cmd="$@"
    
    print_info "$description"
    if eval "$cmd"; then
        print_success "$description completed successfully"
        return 0
    else
        print_error "$description failed"
        return 1
    fi
}

# Function to verify command installation
verify_command() {
    local cmd="$1"
    local name="$2"
    
    if command -v "$cmd" >/dev/null 2>&1; then
        print_success "$name is available and working"
        return 0
    else
        print_error "$name is not available or not working"
        return 1
    fi
}

# Function to verify service status
verify_service() {
    local service="$1"
    local name="$2"
    
    if systemctl is-active --quiet "$service"; then
        print_success "$name service is running"
        return 0
    else
        print_warning "$name service is not running"
        return 1
    fi
}

# Install Docker
if ! command -v docker >/dev/null 2>&1; then
    print_info "${DOCKER} Installing Docker..."
    safe_execute "Installing Docker package" "sudo apt-get install -y docker.io"
    
    # Start Docker service
    safe_execute "Starting Docker service" "sudo systemctl start docker"
    safe_execute "Enabling Docker service" "sudo systemctl enable docker"
    
    # Verify Docker installation
    verify_command "docker" "Docker"
    verify_service "docker" "Docker"
else
    print_success "Docker is already installed"
    
    # Ensure Docker service is running
    if ! systemctl is-active --quiet docker; then
        safe_execute "Starting Docker service" "sudo systemctl start docker"
    fi
fi 

# Add the current user to the docker group to run docker commands without sudo
if ! groups $USER | grep -q '\bdocker\b'; then
    print_info "Adding user ${BOLD}$USER${NC} to the docker group..."
    if sudo usermod -aG docker $USER; then
        print_success "User ${BOLD}$USER${NC} added to docker group successfully"
        print_warning "Please log out and log back in to apply the group changes"
    else
        print_error "Failed to add user to docker group"
    fi
else
    print_success "User ${BOLD}$USER${NC} is already in the docker group"
fi

# Test Docker functionality (with sudo since group change requires logout)
print_info "Testing Docker functionality..."
if sudo docker run --rm hello-world >/dev/null 2>&1; then
    print_success "Docker functionality test passed"
else
    print_warning "Docker functionality test failed (this may be normal if no internet connection)"
fi

# Display the installed version with error handling
DOCKER_VERSION=$(docker --version 2>/dev/null || echo "Version check failed")
print_info "Installed Docker version: ${BOLD}${DOCKER_VERSION}${NC}"

# Install Docker Compose
if ! command -v docker-compose >/dev/null 2>&1; then
    safe_execute "Installing Docker Compose" "sudo apt-get install -y docker-compose"
    
    # Verify Docker Compose installation
    verify_command "docker-compose" "Docker Compose"
else
    print_success "Docker Compose is already installed"
fi

# Display the installed version with error handling
DOCKER_COMPOSE_VERSION=$(docker-compose --version 2>/dev/null || echo "Version check failed")
print_info "Installed Docker Compose version: ${BOLD}${DOCKER_COMPOSE_VERSION}${NC}"

if [ $ERRORS -eq 0 ]; then
    print_success "Docker installation completed successfully"
else
    print_error "Docker installation completed with $ERRORS error(s)"
fi

# Return non-zero exit code for error detection but don't exit hard
return $ERRORS 2>/dev/null  