# Install docker and docker compose and configure it in ubuntu
#!/bin/bash
set -e
set -o pipefail

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

# Function to print colored output
print_info() {
    echo -e "${CYAN}${INFO}${NC} ${BOLD}$1${NC}"
}

print_success() {
    echo -e "${GREEN}${SUCCESS}${NC} ${BOLD}$1${NC}"
}

print_error() {
    echo -e "${RED}${FAILURE}${NC} ${BOLD}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}${WARNING}${NC} ${BOLD}$1${NC}"
}

# Install Docker
if ! command -v docker >/dev/null 2>&1; then
    print_info "${DOCKER} Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y docker.io
    print_info "Starting Docker service..."
    sudo systemctl start docker
    sudo systemctl enable docker
    print_success "Docker installed and started successfully"
else
    print_success "Docker is already installed"
fi 

# Add the current user to the docker group to run docker commands without sudo
if ! groups $USER | grep -q '\bdocker\b'; then
    print_info "Adding user ${BOLD}$USER${NC} to the docker group..."
    sudo usermod -aG docker $USER
    print_warning "Please log out and log back in to apply the group changes"
else
    print_success "User ${BOLD}$USER${NC} is already in the docker group"
fi

# Validate the installation
if command -v docker >/dev/null 2>&1; then
    print_success "Docker has been installed successfully"
else
    print_error "Failed to install Docker"
    exit 1
fi
# Display the installed version
print_info "Installed Docker version: ${BOLD}$(docker --version | head -n 1)${NC}"


# Install Docker Compose
if ! command -v docker-compose >/dev/null 2>&1; then
    print_info "Installing Docker Compose..."
    sudo apt-get install -y docker-compose
    print_success "Docker Compose installed successfully"
else
    print_success "Docker Compose is already installed"
fi

# Validate the installation
if command -v docker-compose >/dev/null 2>&1; then
    print_success "Docker Compose has been installed successfully"
else
    print_error "Failed to install Docker Compose"
    exit 1
fi  

# Display the installed version
print_info "Installed Docker Compose version: ${BOLD}$(docker-compose --version | head -n 1)${NC}"

# Clean up
print_success "Docker installation complete"
exit 0