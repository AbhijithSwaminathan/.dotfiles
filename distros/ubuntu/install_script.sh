# Ubuntu installation script
#!/bin/bash

set -e
set -o pipefail

# Color codes for pretty printing
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Icons for pretty printing
SUCCESS="✅"
FAILURE="❌"
WARNING="⚠️"
INFO="ℹ️"
PACKAGE="📦"
CONFIG="⚙️"
TOOL="🔧"
LINK="🔗"
UBUNTU="🐧"

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

print_header() {
    echo -e "\n${BOLD}${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}$1${NC}"
    echo -e "${BOLD}${BLUE}════════════════════════════════════════${NC}\n"
}

print_subsection() {
    echo -e "\n${BOLD}${PURPLE}── $1 ──${NC}\n"
}

# Start Ubuntu installation
print_header "${UBUNTU} Ubuntu Dotfiles Installation"

# Install git
print_subsection "${PACKAGE} Installing Core System Tools"
if ! command -v git &> /dev/null; then
    print_info "Installing Git..."
    sudo apt update
    sudo apt install -y git
    print_success "Git installed successfully"
else
    print_success "Git is already installed"
fi

## Symlink .gitconfig if it exists remove and symlink
print_subsection "${CONFIG} Configuring Git"
if [ -f ~/.gitconfig ]; then
    print_warning "Removing existing .gitconfig..."
    rm -f ~/.gitconfig
fi
ln -s "$(pwd)/common/git/.gitconfig" ~/.gitconfig
print_success "Git configuration symlinked successfully"

# Install Programming Languages
print_header "${PACKAGE} Installing Programming Languages"
print_info "Installing Node.js, C++, Rust, and Go..."

## Install Node.js
print_subsection "Installing Node.js"
bash distros/ubuntu/node/install_node.sh

## Install C++
print_subsection "Installing C++ Development Tools"
bash distros/ubuntu/cpp/install_cpp.sh

## Install Rust
print_subsection "Installing Rust"
bash distros/ubuntu/rust/install_rust.sh

## Install Go
print_subsection "Installing Go"
bash distros/ubuntu/golang/install_go.sh

# Install Tools
print_header "${TOOL} Installing Development Tools"

## Install Docker
print_subsection "Installing Docker"
bash distros/ubuntu/docker/install_docker.sh

## Install Shell Cosmetics
print_header "${CONFIG} Installing Shell & Terminal Enhancements"
bash distros/ubuntu/shell/install_shell_cosmetics.sh

print_header "${SUCCESS} Ubuntu Installation Complete"
print_success "All components have been installed successfully!"
print_info "Run ${BOLD}distros/ubuntu/validate.sh${NC} to validate your installation"