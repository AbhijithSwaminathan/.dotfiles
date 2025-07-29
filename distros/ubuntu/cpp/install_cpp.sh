## Install cpp 20 version using a package manager and validate the installation and install cmake in ubuntu
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
CPP="⚙️"

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

# Install C++ 20 version using a package manager
if ! command -v g++ >/dev/null 2>&1; then
    print_info "${CPP} Installing g++ compiler..."
    sudo apt-get update
    sudo apt-get install -y g++-11
    print_success "g++ installed successfully"
else
    print_success "g++ is already installed"
fi

# Validate the installation
if command -v g++ >/dev/null 2>&1; then
    print_success "g++ has been installed successfully"
else
    print_error "Failed to install g++"
    exit 1
fi

# Install CMake
if ! command -v cmake >/dev/null 2>&1; then
    print_info "Installing CMake..."
    sudo apt-get install -y cmake
    print_success "CMake installed successfully"
else
    print_success "CMake is already installed"
fi

# Validate the installation
if command -v cmake >/dev/null 2>&1; then
    print_success "CMake has been installed successfully"
else
    print_error "Failed to install CMake"
    exit 1
fi

# Display the installed versions
print_info "Installed g++ version: ${BOLD}$(g++ --version | head -n 1)${NC}"
print_info "Installed CMake version: ${BOLD}$(cmake --version | head -n 1)${NC}"

# Clean up
print_success "C++ development tools installation complete"
exit 0