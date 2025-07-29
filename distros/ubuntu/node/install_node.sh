## Install latest node.js version along with npm using nvm and validate the installation in ubuntu
#!/bin/bash

# Get error log file from parent script
ERROR_LOG="${1:-error.log}"

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
    echo "[ERROR] [$(date '+%Y-%m-%d %H:%M:%S')] Node.js: $1" >> "$ERROR_LOG"
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
        return 0
    else
        print_error "$name is not available or not working"
        return 1
    fi
}

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

if [ $ERRORS -eq 0 ]; then
    print_success "Node.js installation completed successfully"
else
    print_error "Node.js installation completed with $ERRORS error(s)"
fi

# Return the error count for parent script to capture
return $ERRORS