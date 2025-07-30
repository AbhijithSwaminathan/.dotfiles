## install latest golang version and validate the installation in ubuntu
#!/bin/bash

# Get script directory and source common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_LIB_DIR="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")/lib"
source "$COMMON_LIB_DIR/common.sh"

# Get error log file from parent script
ERROR_LOG="${1:-error.log}"
init_error_log "$ERROR_LOG"

# Go version configuration
GO_VERSION="1.20.5"
GO_TARBALL="go${GO_VERSION}.linux-amd64.tar.gz"

# Start Go installation
display_script_header "Go Installation" "$GOLANG"

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
# Create a temporary Go file for testing
TEMP_GO_FILE=$(mktemp --suffix=.go)
cat > "$TEMP_GO_FILE" << 'EOF'
package main

import "fmt"

func main() {
    fmt.Println("Hello, World!")
}
EOF

if go run "$TEMP_GO_FILE" >/dev/null 2>&1; then
    print_success "Go compilation test passed"
else
    print_error "Go compilation test failed"
fi

# Clean up temporary file
rm -f "$TEMP_GO_FILE"

# Display the installed version with error handling
GO_VERSION_OUTPUT=$(go version 2>/dev/null || echo "Version check failed")
print_info "Installed Go version: ${BOLD}${GO_VERSION_OUTPUT}${NC}"

# Verify Go environment
print_info "Checking Go environment..."
GOROOT=$(go env GOROOT 2>/dev/null || echo "unknown")
GOPATH=$(go env GOPATH 2>/dev/null || echo "unknown")

print_info "GOROOT: ${BOLD}${GOROOT}${NC}"
print_info "GOPATH: ${BOLD}${GOPATH}${NC}"

# Finalize script
finalize_script "Go Installation" "$GOLANG"  