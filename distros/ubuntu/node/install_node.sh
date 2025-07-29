## Install latest node.js version along with npm using nvm and validate the installation in ubuntu
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
NODEJS="📗"

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

# Install nvm (Node Version Manager)
if [ ! -d "$HOME/.nvm" ]; then
    print_info "${NODEJS} Installing nvm (Node Version Manager)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    print_success "nvm installed successfully"
else
    print_success "nvm is already installed"
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
fi

# Install latest node.js version along with npm
print_info "Installing latest Node.js version..."
nvm install node
print_success "Node.js installed successfully"

# Validate the installation
if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
    print_success "Node.js and npm have been installed successfully"
else
    print_error "Failed to install Node.js and npm"
    exit 1
fi

# Display the installed versions
print_info "Installed Node.js version: ${BOLD}$(node -v)${NC}"
print_info "Installed npm version: ${BOLD}$(npm -v)${NC}"

# Clean up
## Remove the nvm installation script if it exists
if [ -f "$HOME/.nvm/install.sh" ]; then
    rm "$HOME/.nvm/install.sh"
fi
print_success "Node.js installation complete"
exit 0