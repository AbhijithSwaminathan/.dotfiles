## install latest golang version and validate the installation in ubuntu
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
GOLANG="🐹"

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

# Install Go using the official tarball
if ! command -v go >/dev/null 2>&1; then
    print_info "${GOLANG} Installing Go..."
    print_info "Downloading Go 1.20.5..."
    wget https://go.dev/dl/go1.20.5.linux-amd64.tar.gz
    print_info "Extracting Go to /usr/local..."
    sudo tar -C /usr/local -xzf go1.20.5.linux-amd64.tar.gz
    rm go1.20.5.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    print_success "Go installed successfully"
else
    print_success "Go is already installed"
    export PATH=$PATH:/usr/local/go/bin
fi

# Validate the installation
if command -v go >/dev/null 2>&1; then
    print_success "Go has been installed successfully"
else
    print_error "Failed to install Go"
    exit 1
fi

# Display the installed version
print_info "Installed Go version: ${BOLD}$(go version | head -n 1)${NC}"

# Clean up
## Remove the tarball if it exists
if [ -f go1.20.5.linux-amd64.tar.gz ]; then
    rm go1.20.5.linux-amd64.tar.gz
fi
print_success "Go installation complete"
exit 0