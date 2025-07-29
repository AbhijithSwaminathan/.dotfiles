## Install rust and cargo and validation the installation in ubuntu
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
RUST="🦀"

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
    echo "[ERROR] [$(date '+%Y-%m-%d %H:%M:%S')] Rust: $1" >> "$ERROR_LOG"
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
    else
        print_error "$name is not available or not working"
    fi
}

# Install Rust using rustup
if ! command -v rustup >/dev/null 2>&1; then
    print_info "${RUST} Installing Rust using rustup..."
    
    # Download and install rustup
    if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; then
        print_success "Rust installer completed successfully"
    else
        print_error "Failed to download or install Rust"
        return 1
    fi
    
    # Load Rust environment
    if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
        print_success "Rust environment loaded successfully"
    else
        print_warning "Rust environment file not found, adding to PATH manually"
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
else
    print_success "Rust is already installed"
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Verify installations
verify_command "rustc" "Rust compiler"
verify_command "cargo" "Cargo package manager"

# Test basic functionality
print_info "Testing Rust compilation..."
if echo 'fn main(){println!("Hello, World!");}' | rustc - -o /tmp/test_rust 2>/dev/null && rm -f /tmp/test_rust; then
    print_success "Rust compilation test passed"
else
    print_error "Rust compilation test failed"
fi

# Display the installed versions with error handling
RUST_VERSION=$(rustc --version 2>/dev/null || echo "Version check failed")
CARGO_VERSION=$(cargo --version 2>/dev/null || echo "Version check failed")

print_info "Installed Rust version: ${BOLD}${RUST_VERSION}${NC}"
print_info "Installed Cargo version: ${BOLD}${CARGO_VERSION}${NC}"

# Clean up
if [ -f "$HOME/.cargo/bin/rustup" ]; then
    print_info "Cleaning up installation files..."
    rm "$HOME/.cargo/bin/rustup"
fi

if [ $ERRORS -eq 0 ]; then
    print_success "Rust installation completed successfully"
else
    print_error "Rust installation completed with $ERRORS error(s)"
fi

# Return the error count for parent script to capture
return $ERRORS  