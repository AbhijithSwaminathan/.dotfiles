## Install rust and cargo and validation the installation in ubuntu
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
RUST="🦀"

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

# Install Rust using rustup
if ! command -v rustup >/dev/null 2>&1; then
    print_info "${RUST} Installing Rust using rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    export PATH="$HOME/.cargo/bin:$PATH"
    print_success "Rust installed successfully"
else
    print_success "Rust is already installed"
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Validate the installation
if command -v rustc >/dev/null 2>&1 && command -v cargo >/dev/null 2>&1; then
    print_success "Rust and Cargo have been installed successfully"
else
    print_error "Failed to install Rust and Cargo"
    exit 1
fi

# Display the installed versions
print_info "Installed Rust version: ${BOLD}$(rustc --version | head -n 1)${NC}"
print_info "Installed Cargo version: ${BOLD}$(cargo --version | head -n 1)${NC}"

# Clean up
## remove the rustup installation script if it exists
if [ -f "$HOME/.cargo/bin/rustup" ]; then
    rm "$HOME/.cargo/bin/rustup"
fi
print_success "Rust installation complete"
exit 0