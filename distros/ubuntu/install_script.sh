# Ubuntu installation script
#!/bin/bash

set -o pipefail
# Remove set -e to allow script to continue on errors

# Get error log file from parent script
ERROR_LOG="${1:-error.log}"

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
PACKAGE="📦"
CONFIG="⚙️"
TOOL="🔧"
LINK="🔗"
UBUNTU="🐧"

# Error tracking
ERRORS=0
SCRIPT_DIR="$HOME/.dotfiles/"

# Function to log errors
log_error() {
    local error_msg="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [ubuntu-install] ERROR: $error_msg" >> "$ERROR_LOG"
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
    log_error "$1"
}

print_warning() {
    echo -e "${YELLOW}${WARNING}${NC} ${BOLD}$1${NC}"
}

print_header() {
    echo -e "\n${BOLD}${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}$1${NC}"
    echo -e "${BOLD}${BLUE}════════════════════════════════════════${NC}\n"
}

print_subsection() {
    echo -e "\n${BOLD}${PURPLE}── $1 ──${NC}\n"
}

# Error handling function
handle_error() {
    local exit_code=$?
    local line_number=$1
    print_error "Error occurred in script at line $line_number (exit code: $exit_code)"
    print_error "Installation failed. Please check the error messages above."
    exit $exit_code
}

# Trap errors
trap 'handle_error ${LINENO}' ERR

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

# Function to safely create symlink
safe_symlink() {
    local source="$1"
    local target="$2"
    local description="$3"
    
    # Check if source exists
    if [ ! -e "$source" ]; then
        print_error "Source file/directory does not exist: $source"
        return 1
    fi
    
    # Remove existing target if it exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        print_warning "Removing existing $description..."
        if ! rm -rf "$target"; then
            print_error "Failed to remove existing $description"
            return 1
        fi
    fi
    
    # Create parent directory if needed
    local parent_dir=$(dirname "$target")
    if [ ! -d "$parent_dir" ]; then
        print_info "Creating parent directory: $parent_dir"
        if ! mkdir -p "$parent_dir"; then
            print_error "Failed to create parent directory: $parent_dir"
            return 1
        fi
    fi
    
    # Create symlink
    print_info "Creating symlink for $description..."
    if ln -s "$source" "$target"; then
        print_success "$description symlinked successfully"
        return 0
    else
        print_error "Failed to create symlink for $description"
        return 1
    fi
}

# Function to safely run subscript
safe_run_script() {
    local script_path="$1"
    local description="$2"
    
    if [ ! -f "$script_path" ]; then
        print_error "Script not found: $script_path"
        return 1
    fi
    
    print_info "Running $description..."
    if bash "$script_path"; then
        print_success "$description completed successfully"
        return 0
    else
        print_error "$description failed"
        return 1
    fi
}

# Start Ubuntu installation
print_header "${UBUNTU} Ubuntu Dotfiles Installation"

# Update package lists once at the beginning
safe_execute "Updating package lists" "sudo apt update"

# Symlink common/bash/.bashrc 
safe_symlink "$SCRIPT_DIR/common/bash/.bashrc" "$HOME/.bashrc" "Bash configuration"

# Install git
print_subsection "${PACKAGE} Installing Core System Tools"
if ! command -v git &> /dev/null; then
    safe_execute "Installing Git" "sudo apt install -y git"
    
    # Verify git installation
    if ! command -v git &> /dev/null; then
        print_error "Git installation verification failed"
        exit 1
    fi
else
    print_success "Git is already installed"
fi

## Symlink .gitconfig if it exists remove and symlink
print_subsection "${CONFIG} Configuring Git"
safe_symlink "$SCRIPT_DIR/common/git/.gitconfig" "$HOME/.gitconfig" "Git configuration"

# Install Programming Languages
print_header "${PACKAGE} Installing Programming Languages"
print_info "Installing Node.js, C++, Rust, and Go..."

## Install Node.js
print_subsection "Installing Node.js"
safe_run_script "$SCRIPT_DIR/distros/ubuntu/node/install_node.sh" "Node.js installation"

## Install C++
print_subsection "Installing C++ Development Tools"
safe_run_script "$SCRIPT_DIR/distros/ubuntu/cpp/install_cpp.sh" "C++ development tools installation"

## Install Rust
print_subsection "Installing Rust"
safe_run_script "$SCRIPT_DIR/distros/ubuntu/rust/install_rust.sh" "Rust installation"

## Install Go
print_subsection "Installing Go"
safe_run_script "$SCRIPT_DIR/distros/ubuntu/golang/install_go.sh" "Go installation"

# Install Tools
print_header "${TOOL} Installing Development Tools"

## Install Docker
print_subsection "Installing Docker"
safe_run_script "$SCRIPT_DIR/distros/ubuntu/docker/install_docker.sh" "Docker installation"

## Install Shell Cosmetics
print_header "${CONFIG} Installing Shell & Terminal Enhancements"
safe_run_script "$SCRIPT_DIR/distros/ubuntu/shell/install_shell_cosmetics.sh" "Shell and terminal enhancements"

# Final status check
if [ $ERRORS -eq 0 ]; then
    print_header "${SUCCESS} Ubuntu Installation Complete"
    print_success "All components have been installed successfully!"
    print_info "Run ${BOLD}distros/ubuntu/validate.sh${NC} to validate your installation"
else
    print_header "${FAILURE} Installation Completed with Errors"
    print_error "Installation completed with $ERRORS error(s)"
    print_warning "Some components may not have been installed correctly"
    print_info "Run ${BOLD}distros/ubuntu/validate.sh${NC} to check what needs to be fixed"
fi

# Return non-zero exit code for error detection but don't exit hard
return $ERRORS 2>/dev/null || exit $ERRORS