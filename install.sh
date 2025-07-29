## Invoke installation scripts based on distro in the distros/<distro_name>/install_script.sh format
#!/bin/bash

# Check if running with bash
if [ -z "$BASH_VERSION" ]; then
    echo "Error: This script requires bash to run."
    echo "Please run with: bash $0"
    exit 1
fi

set -o pipefail
# Remove set -e to allow scripts to continue on errors

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

# Error tracking and logging
ERRORS=0
ERROR_LOG="$(pwd)/error.log"  # Use absolute path for consistency
SCRIPT_START_TIME=$(date)

# Clear previous error log
> "$ERROR_LOG"

# Function to log errors
log_error() {
    local error_msg="$1"
    local script_name="${2:-main}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$script_name] ERROR: $error_msg" >> "$ERROR_LOG"
    ERRORS=$((ERRORS + 1))
}

# Function to print colored output
print_info() {
    echo -e "${CYAN}${INFO}${NC} ${BOLD}$1${NC}"
}

print_success() {
    echo -e "${GREEN}${SUCCESS}${NC} ${BOLD}$1${NC}"
}

print_error() {
    echo -e "${RED}${FAILURE}${NC} ${BOLD}$1${NC}"
    log_error "$1" "main"
}

print_warning() {
    echo -e "${YELLOW}${WARNING}${NC} ${BOLD}$1${NC}"
}

print_header() {
    echo -e "\n${BOLD}${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}$1${NC}"
    echo -e "${BOLD}${BLUE}════════════════════════════════════════${NC}\n"
}

# Function to show final error summary
show_error_summary() {
    if [ $ERRORS -gt 0 ]; then
        print_header "${FAILURE} Installation Summary"
        print_error "Installation completed with $ERRORS error(s)"
        print_warning "Error details have been logged to: ${BOLD}$ERROR_LOG${NC}"
        echo ""
        print_info "Error Summary:"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        if [ -f "$ERROR_LOG" ] && [ -s "$ERROR_LOG" ]; then
            cat "$ERROR_LOG" | while read line; do
                echo -e "${RED}  $line${NC}"
            done
        else
            echo -e "${RED}  No detailed error information available${NC}"
        fi
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        print_info "You can review the full error log with: ${BOLD}cat $ERROR_LOG${NC}"
        print_info "Try fixing the issues and re-running the installation"
    else
        print_header "${SUCCESS} Installation Summary"
        print_success "All components installed successfully with no errors!"
        # Remove empty error log
        [ -f "$ERROR_LOG" ] && rm "$ERROR_LOG"
    fi
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

# Run the installation script and pass the error log path
bash "$INSTALL_SCRIPT" "$ERROR_LOG"
SUBSCRIPT_EXIT_CODE=$?

if [ $SUBSCRIPT_EXIT_CODE -eq 0 ]; then
    echo ""
    print_success "Installation process completed for ${BOLD}${DISTRO}${NC}"
else
    echo ""
    print_warning "Installation process completed with some issues for ${BOLD}${DISTRO}${NC}"
    print_info "Installation script reported $SUBSCRIPT_EXIT_CODE error(s)"
    # Add the subscript errors to our main error count
    ERRORS=$((ERRORS + SUBSCRIPT_EXIT_CODE))
fi

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

# Exit with appropriate code but don't use hard exit
if [ $ERRORS -eq 0 ]; then
    print_info "Installation completed successfully!"
else
    print_info "Installation completed with errors. Check the summary above."
fi