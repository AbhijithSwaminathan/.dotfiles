## Install ZSHELL and other components
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
SHELL_ICON="🐚"
TOOL="🔧"
LINK="🔗"

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

print_subsection() {
    echo -e "\n${BOLD}${PURPLE}── $1 ──${NC}\n"
}

## Install ZSH using apt
print_subsection "${SHELL_ICON} Installing ZSH Shell"
if ! command -v zsh &> /dev/null; then
    print_info "Installing ZSH..."
    sudo apt update
    sudo apt install -y zsh
    print_success "ZSH installed successfully"
else
    print_success "ZSH is already installed"
fi

### Make ZSH the default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    print_info "Changing default shell to ZSH..."
    chsh -s "$(which zsh)"
    print_success "Default shell changed to ZSH"
else
    print_success "ZSH is already the default shell"
fi

## Install Helper tools
print_subsection "${TOOL} Installing Terminal Enhancement Tools"

### Install fortune, cowsay
if ! command -v fortune &> /dev/null || ! command -v cowsay &> /dev/null; then
    print_info "Installing fortune and cowsay..."
    sudo apt install -y fortune cowsay
    print_success "fortune and cowsay installed successfully"
else
    print_success "fortune and cowsay are already installed"
fi

### Install lolcrab cargo install lolcrab
if ! command -v lolcrab &> /dev/null; then
    print_info "Installing lolcrab..."
    cargo install lolcrab
    print_success "lolcrab installed successfully"
else
    print_success "lolcrab is already installed"
fi

### Install pfetch
print_info "Installing pfetch..."
wget https://github.com/dylanaraps/pfetch/archive/master.zip
unzip master.zip
sudo install pfetch-master/pfetch /usr/local/bin/
rm -rf pfetch-master master.zip
print_success "pfetch installed successfully"

### Install fzf
if ! command -v fzf &> /dev/null; then
    print_info "Installing fzf..."
    sudo apt install -y fzf
    print_success "fzf installed successfully"
else
    print_success "fzf is already installed"
fi

### Install eza
if ! command -v eza &> /dev/null; then
    print_info "Installing eza..."
    sudo apt install -y eza
    print_success "eza installed successfully"
else
    print_success "eza is already installed"
fi

### Install zoxide
if ! command -v zoxide &> /dev/null; then
    print_info "Installing zoxide..."
    sudo apt install -y zoxide
    print_success "zoxide installed successfully"
else
    print_success "zoxide is already installed"
fi

### Install bat
if ! command -v bat &> /dev/null; then
    print_info "Installing bat..."
    sudo apt install -y bat
    print_success "bat installed successfully"
else
    print_success "bat is already installed"
fi

#### Configure bat theme
print_info "Configuring bat themes..."
mkdir -p "$(bat --config-dir)/themes"
##### Copy all items in common/themes to bat themes directory
cp -r "$(pwd)/common/themes/"* "$(bat --config-dir)/themes/"
##### Build bat cache
bat cache --build
print_success "bat themes configured successfully"

### Install git-delta
if ! command -v delta &> /dev/null; then
    print_info "Installing git-delta..."
    sudo apt install -y git-delta
    print_success "git-delta installed successfully"
else
    print_success "git-delta is already installed"
fi

### Install tldr
if ! command -v tldr &> /dev/null; then
    print_info "Installing tldr..."
    sudo apt install -y tldr
    print_success "tldr installed successfully"
else
    print_success "tldr is already installed"
fi

### Install thefuck
if ! command -v thefuck &> /dev/null; then
    print_info "Installing thefuck..."
    sudo apt install -y thefuck
    print_success "thefuck installed successfully"
else
    print_success "thefuck is already installed"
fi

## Install neovim
print_subsection "${TOOL} Installing Text Editor"
if ! command -v nvim &> /dev/null; then
    print_info "Installing Neovim..."
    sudo apt install -y neovim
    print_success "Neovim installed successfully"
else
    print_success "Neovim is already installed"
fi

### Install ripgrep
if ! command -v rg &> /dev/null; then
    print_info "Installing ripgrep..."
    sudo apt install -y ripgrep
    print_success "ripgrep installed successfully"
else
    print_success "ripgrep is already installed"
fi

## Configuration Setup
print_subsection "${CONFIG} Setting up Configuration Files"

### Symlink common/nvim folder and all its content in repo to ~/.config/nvim if it exists remove and symlink
print_info "Setting up Neovim configuration..."
if [ -d ~/.config/nvim ]; then
    print_warning "Removing existing nvim config..."
    rm -rf ~/.config/nvim
fi
mkdir -p ~/.config/nvim
ln -s "$(pwd)/common/nvim" ~/.config/nvim
print_success "Neovim configuration symlinked successfully"

### Symlink zshrc in common/zshell in repo, if .zshrc exists then remove and symlink
print_info "Setting up ZSH configuration..."
if [ -f ~/.zshrc ]; then
    print_warning "Removing existing .zshrc..."
    rm ~/.zshrc
fi
ln -s "$(pwd)/common/zshell/.zshrc" ~/.zshrc
print_success "ZSH configuration symlinked successfully"

### Symlink common/.p10k.zsh in repo, if .p10k.zsh exists then remove and symlink
print_info "Setting up Powerlevel10k configuration..."
if [ -f ~/.p10k.zsh ]; then
    print_warning "Removing existing .p10k.zsh..."
    rm ~/.p10k.zsh
fi
ln -s "$(pwd)/common/zshell/.p10k.zsh" ~/.p10k.zsh
print_success "Powerlevel10k configuration symlinked successfully"

print_success "Shell and terminal enhancements installation complete!"

