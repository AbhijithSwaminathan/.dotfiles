## Install latest node.js version along with npm using nvm and validate the installation in ubuntu
#!/bin/bash

# Get script directory and source common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_LIB_DIR="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")/lib"
source "$COMMON_LIB_DIR/common.sh"

# Get error log file from parent script
ERROR_LOG="${1:-error.log}"
init_error_log "$ERROR_LOG"

# Start Node.js installation
display_script_header "Node.js Installation" "$NODEJS"

# Install nvm (Node Version Manager)
if [ ! -d "$HOME/.nvm" ]; then
    print_info "${NODEJS} Installing nvm (Node Version Manager)..."
    
    # Download and install nvm
    if curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash; then
        print_success "nvm downloaded and installed successfully"
    else
        print_error "Failed to download or install nvm"
    fi
    
    # Load nvm
    export NVM_DIR="$HOME/.nvm"
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        source "$NVM_DIR/nvm.sh"
        print_success "nvm loaded successfully"
    else
        print_error "Failed to load nvm"
    fi
else
    print_success "nvm is already installed"
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"  # This loads nvm
fi

# Verify nvm is working
if ! command -v nvm >/dev/null 2>&1; then
    print_error "nvm is not working properly"
fi

# Install latest node.js version along with npm
safe_execute "Installing latest Node.js version" "nvm install node"

# Set default node version
safe_execute "Setting default Node.js version" "nvm alias default node"

# Verify installations
verify_command "node" "Node.js"
verify_command "npm" "npm"

# Display the installed versions
NODE_VERSION=$(node -v 2>/dev/null || echo "unknown")
NPM_VERSION=$(npm -v 2>/dev/null || echo "unknown")

print_info "Installed Node.js version: ${BOLD}${NODE_VERSION}${NC}"
print_info "Installed npm version: ${BOLD}${NPM_VERSION}${NC}"

# Clean up
if [ -f "$HOME/.nvm/install.sh" ]; then
    print_info "Cleaning up installation files..."
    rm "$HOME/.nvm/install.sh"
fi

# Finalize script
finalize_script "Node.js Installation" "$NODEJS"