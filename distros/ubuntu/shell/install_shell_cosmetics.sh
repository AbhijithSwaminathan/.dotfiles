## Install ZSHELL and other components
#!/bin/bash

# Get error log file from parent script
ERROR_LOG="${1:-/tmp/dotfiles_error.log}"

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

# Error tracking
ERRORS=0
SCRIPT_DIR="$HOME/.dotfiles/"

# Function to print colored output
print_info() {
    echo -e "${CYAN}${INFO}${NC} ${BOLD}$1${NC}"
}

print_success() {
    echo -e "${GREEN}${SUCCESS}${NC} ${BOLD}$1${NC}"
}

print_error() {
    echo -e "${RED}${FAILURE}${NC} ${BOLD}$1${NC}"
    echo "[ERROR] [$(date '+%Y-%m-%d %H:%M:%S')] Shell: $1" >> "$ERROR_LOG"
    ERRORS=$((ERRORS + 1))
}

print_warning() {
    echo -e "${YELLOW}${WARNING}${NC} ${BOLD}$1${NC}"
}

print_subsection() {
    echo -e "\n${BOLD}${PURPLE}── $1 ──${NC}\n"
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

# Function to safely create symlink
safe_symlink() {
    local source="$1"
    local target="$2"
    local description="$3"
    
    # Check if source exists
    if [ ! -e "$source" ]; then
        print_error "Source file/directory does not exist: $source"
        return 1
    fi
    
    # Remove existing target if it exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        print_warning "Removing existing $description..."
        if ! rm -rf "$target"; then
            print_error "Failed to remove existing $description"
            return 1
        fi
    fi
    
    # Create parent directory if needed
    local parent_dir=$(dirname "$target")
    if [ ! -d "$parent_dir" ]; then
        print_info "Creating parent directory: $parent_dir"
        if ! mkdir -p "$parent_dir"; then
            print_error "Failed to create parent directory: $parent_dir"
            return 1
        fi
    fi
    
    # Create symlink
    print_info "Creating symlink for $description..."
    if ln -s "$source" "$target"; then
        print_success "$description symlinked successfully"
        return 0
    else
        print_error "Failed to create symlink for $description"
        return 1
    fi
}

## Install ZSH using apt
print_subsection "${SHELL_ICON} Installing ZSH Shell"
if ! command -v zsh &> /dev/null; then
    safe_execute "Installing ZSH" "sudo apt install -y zsh"
    verify_command "zsh" "ZSH"
else
    print_success "ZSH is already installed"
fi

### Make ZSH the default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    safe_execute "Changing default shell to ZSH" "chsh -s $(which zsh)"
else
    print_success "ZSH is already the default shell"
fi

## Install Helper tools
print_subsection "${TOOL} Installing Terminal Enhancement Tools"

### Install fortune, cowsay
if ! command -v fortune &> /dev/null || ! command -v cowsay &> /dev/null; then
    safe_execute "Installing fortune and cowsay" "sudo apt install -y fortune cowsay"
    verify_command "fortune" "fortune"
    verify_command "cowsay" "cowsay"
else
    print_success "fortune and cowsay are already installed"
fi

### Install lolcrab cargo install lolcrab
if ! command -v lolcrab &> /dev/null; then
    # Check if cargo is available
    if ! command -v cargo &> /dev/null; then
        print_error "Cargo is not available - Rust must be installed first"
        return 1
    fi
    safe_execute "Installing lolcrab" "cargo install lolcrab"
    verify_command "lolcrab" "lolcrab"
else
    print_success "lolcrab is already installed"
fi

### Install pfetch
if ! command -v pfetch &> /dev/null; then
    print_info "Installing pfetch..."
    
    # Download pfetch
    if wget -q https://github.com/dylanaraps/pfetch/archive/master.zip; then
        print_success "pfetch downloaded successfully"
    else
        print_error "Failed to download pfetch"
        return 1
    fi
    
    # Extract and install
    if unzip -q master.zip && sudo install pfetch-master/pfetch /usr/local/bin/; then
        print_success "pfetch installed successfully"
    else
        print_error "Failed to extract or install pfetch"
        return 1
    fi
    
    # Clean up
    rm -rf pfetch-master master.zip
    verify_command "pfetch" "pfetch"
else
    print_success "pfetch is already installed"
fi

### Install terminal tools
for tool in "fzf" "eza" "zoxide" "bat" "delta:git-delta" "tldr" "thefuck" "rg:ripgrep"; do
    tool_name=$(echo "$tool" | cut -d: -f1)
    package_name=$(echo "$tool" | cut -d: -f2)
    [ "$package_name" = "$tool_name" ] && package_name="$tool_name"
    
    if ! command -v "$tool_name" &> /dev/null; then
        safe_execute "Installing $package_name" "sudo apt install -y $package_name"
        verify_command "$tool_name" "$package_name"
    else
        print_success "$package_name is already installed"
    fi
done

#### Configure bat theme
if command -v bat &> /dev/null; then
    print_info "Configuring bat themes..."
    
    BAT_CONFIG_DIR=$(bat --config-dir 2>/dev/null || echo "$HOME/.config/bat")
    
    if mkdir -p "$BAT_CONFIG_DIR/themes"; then
        print_success "Created bat themes directory"
    else
        print_error "Failed to create bat themes directory"
        return 1
    fi
    
    # Copy themes if they exist
    if [ -d "$SCRIPT_DIR/common/themes" ]; then
        if cp -r "$SCRIPT_DIR/common/themes/"* "$BAT_CONFIG_DIR/themes/" 2>/dev/null; then
            print_success "Bat themes copied successfully"
            
            # Build bat cache
            if bat cache --build >/dev/null 2>&1; then
                print_success "Bat cache built successfully"
            else
                print_warning "Failed to build bat cache (this may be normal)"
            fi
        else
            print_warning "Failed to copy bat themes (source directory may be empty)"
        fi
    else
        print_warning "Bat themes directory not found in dotfiles"
    fi
fi

## Install neovim
print_subsection "${TOOL} Installing Text Editor"
if ! command -v nvim &> /dev/null; then
    safe_execute "Installing Neovim" "sudo apt install -y neovim"
    verify_command "nvim" "Neovim"
else
    print_success "Neovim is already installed"
fi

## Configuration Setup
print_subsection "${CONFIG} Setting up Configuration Files"

### Symlink Neovim configuration
if [ -d "$SCRIPT_DIR/common/nvim" ]; then
    # First create symlink to the nvim directory itself
    safe_symlink "$SCRIPT_DIR/common/nvim" "$HOME/.config/nvim" "Neovim configuration"
else
    print_error "Neovim configuration directory not found: $SCRIPT_DIR/common/nvim"
fi

### Symlink ZSH configuration
if [ -f "$SCRIPT_DIR/common/zshell/.zshrc" ]; then
    safe_symlink "$SCRIPT_DIR/common/zshell/.zshrc" "$HOME/.zshrc" "ZSH configuration"
else
    print_error "ZSH configuration file not found: $SCRIPT_DIR/common/zshell/.zshrc"
fi

### Symlink Powerlevel10k configuration
if [ -f "$SCRIPT_DIR/common/zshell/.p10k.zsh" ]; then
    safe_symlink "$SCRIPT_DIR/common/zshell/.p10k.zsh" "$HOME/.p10k.zsh" "Powerlevel10k configuration"
else
    print_error "Powerlevel10k configuration file not found: $SCRIPT_DIR/common/zshell/.p10k.zsh"
fi

# Final status check
if [ $ERRORS -eq 0 ]; then
    print_success "Shell and terminal enhancements installation completed successfully!"
    print_info "Note: You may need to log out and log back in for all changes to take effect"
else
    print_error "Shell and terminal enhancements installation completed with $ERRORS error(s)"
    print_warning "Some components may not have been installed or configured correctly"
fi
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

## Install rust-fd-find
if ! command -v fd &> /dev/null; then
    print_info "Installing fd-find..."
    sudo apt install -y fd-find
    # Create symlink for fd to be accessible as 'fd'
    if [ ! -L /usr/local/bin/fd ]; then
        sudo ln -s /usr/bin/fdfind /usr/local/bin/fd
        print_success "fd symlink created successfully"
    else
        print_success "fd symlink already exists"
    fi
else
    print_success "fd-find is already installed"
fi

### Clone https://github.com/junegunn/fzf-git.sh.git into ~/.config/fzf-git
if [ ! -d "$HOME/.config/fzf-git" ]; then
    print_info "Cloning fzf-git repository..."
    git clone https://github.com/junegunn/fzf-git.sh.git "$HOME/.config/fzf-git"
fi
print_success "fzf-git repository cloned successfully"

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
cp -r "$SCRIPT_DIR/common/themes/"* "$(bat --config-dir)/themes/"
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
ln -s "$SCRIPT_DIR/common/nvim" ~/.config/nvim
print_success "Neovim configuration symlinked successfully"

### Symlink zshrc in common/zshell in repo, if .zshrc exists then remove and symlink
print_info "Setting up ZSH configuration..."
if [ -f ~/.zshrc ]; then
    print_warning "Removing existing .zshrc..."
    rm ~/.zshrc
fi
ln -s "$SCRIPT_DIR/common/zshell/.zshrc" ~/.zshrc
print_success "ZSH configuration symlinked successfully"

### Symlink common/.p10k.zsh in repo, if .p10k.zsh exists then remove and symlink
print_info "Setting up Powerlevel10k configuration..."
if [ -f ~/.p10k.zsh ]; then
    print_warning "Removing existing .p10k.zsh..."
    rm ~/.p10k.zsh
fi
ln -s "$SCRIPT_DIR/common/zshell/.p10k.zsh" ~/.p10k.zsh
print_success "Powerlevel10k configuration symlinked successfully"

# Source .zshrc file
print_info "Sourcing .zshrc file..."
source ~/.zshrc
if [ $? -eq 0 ]; then
    print_success ".zshrc sourced successfully"
else
    print_error "Failed to source .zshrc"
    exit 1
fi

# Install tailscale cli
if ! command -v tailscale &> /dev/null; then
    print_info "Installing Tailscale CLI..."
    if curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.gpg | sudo gpg --dearmor -o /usr/share/keyrings/tailscale-archive-keyring.gpg && \
       echo "deb [signed-by=/usr/share/keyrings/tailscale-archive-keyring.gpg] https://pkgs.tailscale.com/stable/ubuntu focal main" | sudo tee /etc/apt/sources.list.d/tailscale.list && \
       sudo apt update && sudo apt install -y tailscale; then
        print_success "Tailscale CLI installed successfully"
    else
        print_error "Failed to install Tailscale CLI"
        return 1
    fi
else
    print_success "Tailscale CLI is already installed"
fi

## Install github-cli
if ! command -v gh &> /dev/null; then
    print_info "Installing GitHub CLI..."
    if curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
       echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list && \
       sudo apt update && sudo apt install -y gh; then
        print_success "GitHub CLI installed successfully"
    else
        print_error "Failed to install GitHub CLI"
        return 1
    fi
else
    print_success "GitHub CLI is already installed"
fi

print_success "Shell and terminal enhancements installation complete!"

# Return the error count for parent script to capture
return $ERRORS  

