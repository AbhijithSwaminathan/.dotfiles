## Invoke installation scripts based on distro in the distros/<distro_name>/install_script.sh format
#!/bin/bash

# Check if running with bash
if [ -z "$BASH_VERSION" ]; then
    echo "Error: This script requires bash to run."
    echo "Please run with: bash $0"
    exit 1
fi

set -e
set -o pipefail

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
    ERRORS=$((ERRORS + 1))
}

print_warning() {
    echo -e "${YELLOW}${WARNING}${NC} ${BOLD}$1${NC}"
}

print_header() {
    echo -e "\n${BOLD}${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}$1${NC}"
    echo -e "${BOLD}${BLUE}════════════════════════════════════════${NC}\n"
}

# Error handling function
handle_error() {
    local exit_code=$?
    local line_number=$1
    print_error "Error occurred in main installation script at line $line_number (exit code: $exit_code)"
    print_error "Installation failed. Please check the error messages above."
    exit $exit_code
}

# Trap errors
trap 'handle_error ${LINENO}' ERR

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
    
    # Display distribution information
    if [ -n "${VERSION:-}" ]; then
        print_info "Distribution version: $VERSION"
    fi
    if [ -n "${VERSION_CODENAME:-}" ]; then
        print_info "Codename: $VERSION_CODENAME"
    fi
else
    print_error "Unsupported distribution - /etc/os-release not found"
    print_error "This script requires a Linux distribution with /etc/os-release"
    exit 1
fi

INSTALL_SCRIPT="distros/${DISTRO}/install_script.sh"

print_info "Looking for installation script: ${BOLD}${INSTALL_SCRIPT}${NC}"

# Check if the installation script exists
if [ ! -f "$INSTALL_SCRIPT" ]; then
    print_error "No installation script found for ${BOLD}${DISTRO}${NC}"
    print_info "Expected script location: ${BOLD}${INSTALL_SCRIPT}${NC}"
    print_info "Supported distributions:"
    for script in distros/*/install_script.sh; do
        if [ -f "$script" ]; then
            distro_name=$(basename $(dirname "$script"))
            print_info "  - $distro_name"
        fi
    done
    exit 1
fi

# Check if script is executable
if [ ! -x "$INSTALL_SCRIPT" ]; then
    print_warning "Making installation script executable..."
    if ! chmod +x "$INSTALL_SCRIPT"; then
        print_error "Failed to make installation script executable"
        exit 1
    fi
fi

print_success "Found installation script for ${BOLD}${DISTRO}${NC}"
print_info "Starting installation process..."
echo ""

# Run the installation script
if bash "$INSTALL_SCRIPT"; then
    echo ""
    print_success "Installation completed successfully for ${BOLD}${DISTRO}${NC}"
    
    # Check if validation script exists and offer to run it
    VALIDATE_SCRIPT="distros/${DISTRO}/validate.sh"
    if [ -f "$VALIDATE_SCRIPT" ]; then
        print_info "Validation script found: ${BOLD}${VALIDATE_SCRIPT}${NC}"
        print_info "Run ${BOLD}bash ${VALIDATE_SCRIPT}${NC} to validate your installation"
        
        # Optionally auto-run validation (uncomment if desired)
        # print_info "Running validation automatically..."
        # if bash "$VALIDATE_SCRIPT"; then
        #     print_success "Validation completed successfully!"
        # else
        #     print_warning "Validation completed with warnings - check output above"
        # fi
    else
        print_warning "No validation script found for ${BOLD}${DISTRO}${NC}"
    fi
    
    exit 0
else
    echo ""
    print_error "Installation failed for ${BOLD}${DISTRO}${NC}"
    print_error "Please check the error messages above for details"
    print_info "You can try running the installation script directly:"
    print_info "  ${BOLD}bash ${INSTALL_SCRIPT}${NC}"
    exit 1
fi