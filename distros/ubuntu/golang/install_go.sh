## install latest golang version and validate the installation in ubuntu
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
GOLANG="🐹"

# Error tracking
ERRORS=0
GO_VERSION="1.20.5"
GO_TARBALL="go${GO_VERSION}.linux-amd64.tar.gz"

# Function to print colored output
print_info() {
    echo -e "${CYAN}${INFO}${NC} ${BOLD}$1${NC}"
}

print_success() {
    echo -e "${GREEN}${SUCCESS}${NC} ${BOLD}$1${NC}"
}

print_error() {
    echo -e "${RED}${FAILURE}${NC} ${BOLD}$1${NC}"
    echo "[ERROR] [$(date '+%Y-%m-%d %H:%M:%S')] Go: $1" >> "$ERROR_LOG"
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

# Install Go using the official tarball
if ! command -v go >/dev/null 2>&1; then
    print_info "${GOLANG} Installing Go..."
    
    # Download Go
    print_info "Downloading Go ${GO_VERSION}..."
    if wget -q "https://go.dev/dl/${GO_TARBALL}"; then
        print_success "Go tarball downloaded successfully"
    else
        print_error "Failed to download Go tarball"
        return 1
    fi
    
    # Verify download
    if [ ! -f "$GO_TARBALL" ]; then
        print_error "Go tarball not found after download"
        return 1
    fi
    
    # Remove existing Go installation if present
    if [ -d "/usr/local/go" ]; then
        print_warning "Removing existing Go installation..."
        if ! sudo rm -rf /usr/local/go; then
            print_error "Failed to remove existing Go installation"
            return 1
        fi
    fi
    
    # Extract Go
    safe_execute "Extracting Go to /usr/local" "sudo tar -C /usr/local -xzf $GO_TARBALL"
    
    # Clean up tarball
    safe_execute "Cleaning up downloaded files" "rm -f $GO_TARBALL"
    
    # Add to PATH for current session
    export PATH=$PATH:/usr/local/go/bin
    print_success "Go installed successfully"
else
    print_success "Go is already installed"
    export PATH=$PATH:/usr/local/go/bin
fi

# Verify installation
verify_command "go" "Go"

# Test basic functionality
print_info "Testing Go compilation..."
if echo 'package main; func main(){println("Hello, World!")}' | go run - 2>/dev/null; then
    print_success "Go compilation test passed"
else
    print_error "Go compilation test failed"
fi

# Display the installed version with error handling
GO_VERSION_OUTPUT=$(go version 2>/dev/null || echo "Version check failed")
print_info "Installed Go version: ${BOLD}${GO_VERSION_OUTPUT}${NC}"

# Verify Go environment
print_info "Checking Go environment..."
GOROOT=$(go env GOROOT 2>/dev/null || echo "unknown")
GOPATH=$(go env GOPATH 2>/dev/null || echo "unknown")

print_info "GOROOT: ${BOLD}${GOROOT}${NC}"
print_info "GOPATH: ${BOLD}${GOPATH}${NC}"

if [ $ERRORS -eq 0 ]; then
    print_success "Go installation completed successfully"
    print_info "Note: You may need to add '/usr/local/go/bin' to your PATH in your shell profile"
else
    print_error "Go installation completed with $ERRORS error(s)"
fi

# Return non-zero exit code for error detection but don't exit hard
return $ERRORS 2>/dev/null || exit $ERRORS