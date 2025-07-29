## Install cpp 20 version using a package manager and validate the installation and install cmake in ubuntu
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
CPP="⚙️"

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
    echo "[ERROR] [$(date '+%Y-%m-%d %H:%M:%S')] C++: $1" >> "$ERROR_LOG"
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

# Install C++ 20 version using a package manager
if ! command -v g++ --version >/dev/null 2>&1; then
    safe_execute "${CPP} Installing g++ compiler" "sudo apt-get install -y build-essential g++"
    
    # Verify installation
    verify_command "g++ --version" "g++ compiler"
else
    print_success "g++ is already installed"
fi

# Install CMake
if ! command -v cmake >/dev/null 2>&1; then
    safe_execute "Installing CMake" "sudo apt-get install -y cmake"
    
    # Verify installation
    verify_command "cmake" "CMake"
else
    print_success "CMake is already installed"
fi

# Display the installed versions with error handling
print_info "Checking installed versions..."

GCC_VERSION=$(g++ --version 2>/dev/null | head -n 1 || echo "Version check failed")
CMAKE_VERSION=$(cmake --version 2>/dev/null | head -n 1 || echo "Version check failed")

print_info "Installed g++ version: ${BOLD}${GCC_VERSION}${NC}"
print_info "Installed CMake version: ${BOLD}${CMAKE_VERSION}${NC}"

# Test basic functionality
print_info "Testing g++ compilation..."
if echo 'int main(){return 0;}' | g++ -x c++ -o /tmp/test_cpp - 2>/dev/null && rm -f /tmp/test_cpp; then
    print_success "g++ compilation test passed"
else
    print_error "g++ compilation test failed"
fi

if [ $ERRORS -eq 0 ]; then
    print_success "C++ development tools installation completed successfully"
else
    print_error "C++ development tools installation completed with $ERRORS error(s)"
fi

# Return the error count for parent script to capture
return $ERRORS  