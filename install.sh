## Invoke installation scripts based on distro in the distros/<distro_name>/install_script.sh format
#!/bin/bash

# Get script directory and source common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Check if running with bash
check_bash

set -o pipefail
# Remove set -e to allow scripts to continue on errors

# Initialize error logging
init_error_log "$(pwd)/error.log"
SCRIPT_START_TIME=$(date)

# Start installation
display_script_header "Starting Dotfiles Installation" "$ROCKET"

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
    show_error_summary
    exit 1
fi

INSTALL_SCRIPT="$HOME/.dotfiles/distros/${DISTRO}/install_script.sh"

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
    show_error_summary
    exit 1
fi

# Check if script is executable
if [ ! -x "$INSTALL_SCRIPT" ]; then
    print_warning "Making installation script executable..."
    if ! chmod +x "$INSTALL_SCRIPT"; then
        print_error "Failed to make installation script executable"
    fi
fi

print_success "Found installation script for ${BOLD}${DISTRO}${NC}"
print_info "Starting installation process..."
print_info "Error log will be written to: ${BOLD}${ERROR_LOG}${NC}"
echo ""

# Run the installation script using common library function
safe_run_script "$INSTALL_SCRIPT" "installation process for ${BOLD}${DISTRO}${NC}"

# Check if validation script exists and offer to run it
VALIDATE_SCRIPT="$HOME/.dotfiles/distros/${DISTRO}/validate.sh"
if [ -f "$VALIDATE_SCRIPT" ]; then
    print_info "Validation script found: ${BOLD}${VALIDATE_SCRIPT}${NC}"
    print_info "Running validation to check installation status..."
    echo ""
    
    if bash "$VALIDATE_SCRIPT"; then
        print_success "Validation completed successfully!"
    else
        print_warning "Validation completed with warnings - some components may need attention"
    fi
else
    print_warning "No validation script found for ${BOLD}${DISTRO}${NC}"
fi

# Show final summary
echo ""
show_error_summary