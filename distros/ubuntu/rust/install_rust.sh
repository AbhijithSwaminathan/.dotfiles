## Install rust and cargo and validation the installation in ubuntu
#!/bin/bash

# Get script directory and source common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_LIB_DIR="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")/lib"
source "$COMMON_LIB_DIR/common.sh"

# Get error log file from parent script
ERROR_LOG="${1:-error.log}"
init_error_log "$ERROR_LOG"

# Start Rust installation
display_script_header "Rust Installation" "$RUST"

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

# Finalize script
finalize_script "Rust Installation" "$RUST"

# Return the error count for parent script to capture
return $ERRORS  