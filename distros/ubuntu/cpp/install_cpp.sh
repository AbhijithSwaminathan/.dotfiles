## Install cpp 20 version using a package manager and validate the installation and install cmake in ubuntu
#!/bin/bash

# Get script directory and source common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_LIB_DIR="$(dirname "$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")")/lib"
source "$COMMON_LIB_DIR/common.sh"

# Get error log file from parent script
ERROR_LOG="${1:-error.log}"
init_error_log "$ERROR_LOG"

# Start C++ installation
display_script_header "C++ Development Tools Installation" "$CPP"

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

# Finalize script
finalize_script "C++ Development Tools Installation" "$CPP"  