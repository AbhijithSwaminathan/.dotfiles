## Invoke installation scripts based on distro in the distros/<distro_name>/install_script.sh format
#!/bin/bash

# Color codes for pretty printing
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Icons for pretty printing
SUCCESS="✅"
FAILURE="❌"
WARNING="⚠️"
INFO="ℹ️"
SEARCH="🔍"
ROCKET="🚀"

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

print_header() {
    echo -e "\n${BOLD}${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}$1${NC}"
    echo -e "${BOLD}${BLUE}════════════════════════════════════════${NC}\n"
}

# Start installation
print_header "${ROCKET} Starting Dotfiles Installation"
print_info "Date: $(date)"
print_info "User: $USER"
print_info "Hostname: $(hostname)"

# Check the distro
print_info "${SEARCH} Detecting distribution..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
    print_success "Detected distribution: ${BOLD}${DISTRO}${NC}"
    print_info "Distribution version: $VERSION"
else
    print_error "Unsupported distribution - /etc/os-release not found"
    exit 1
fi

INSTALL_SCRIPT="distros/${DISTRO}/install_script.sh"

print_info "Looking for installation script: ${BOLD}${INSTALL_SCRIPT}${NC}"

if [ -f "$INSTALL_SCRIPT" ]; then
    print_success "Found installation script for ${BOLD}${DISTRO}${NC}"
    print_info "Starting installation process..."
    echo ""
    bash "$INSTALL_SCRIPT"
    if [ $? -eq 0 ]; then
        echo ""
        print_success "Installation completed successfully for ${BOLD}${DISTRO}${NC}"
        print_info "Run ${BOLD}distros/${DISTRO}/validate.sh${NC} to validate your installation"
    else
        echo ""
        print_error "Installation failed for ${BOLD}${DISTRO}${NC}"
        exit 1
    fi
else
    print_error "No installation script found for ${BOLD}${DISTRO}${NC}"
    print_info "Expected script location: ${BOLD}${INSTALL_SCRIPT}${NC}"
    exit 1
fi

## Run validation script
VALIDATE_SCRIPT="distros/${DISTRO}/validate.sh"
print_info "Looking for validation script: ${BOLD}${VALIDATE_SCRIPT}${NC}"
if [ -f "$VALIDATE_SCRIPT" ]; then
    print_success "Found validation script for ${BOLD}${DISTRO}${NC}"
    print_info "Starting validation process..."
    echo ""
    bash "$VALIDATE_SCRIPT"
    if [ $? -eq 0 ]; then
        echo ""
        print_success "Validation completed successfully for ${BOLD}${DISTRO}${NC}"
    else
        echo ""
        print_error "Validation failed for ${BOLD}${DISTRO}${NC}"
        exit 1
    fi
else
    print_error "No validation script found for ${BOLD}${DISTRO}${NC}"
    print_info "Expected script location: ${BOLD}${VALIDATE_SCRIPT}${NC}"
    exit 1
fi