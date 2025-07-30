## Install ZSHELL and other components
#!/bin/bash

# Get script directory and source common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_LIB_DIR="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")/lib"
source "$COMMON_LIB_DIR/common.sh"

# Get error log file from parent script
ERROR_LOG="${1:-error.log}"
init_error_log "$ERROR_LOG"

# Script directory for dotfiles
DOTFILES_DIR="$HOME/.dotfiles"

# Start Shell installation
display_script_header "Shell and Terminal Enhancements Installation" "$SHELL_ICON"

## Install ZSH using apt
print_subsection "${SHELL_ICON} Installing ZSH Shell"
if ! command -v zsh &> /dev/null; then
    safe_execute "Installing ZSH" "sudo apt install -y zsh"
    verify_command "zsh" "ZSH"
else
    print_success "ZSH is already installed"
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
    # Check if cargo is available in current session
    if ! command -v cargo &> /dev/null; then
        # Try to source Rust environment and run in a new shell session
        print_info "Cargo not found in current session, trying to install lolcrab in new shell with Rust environment..."
        safe_execute "Installing lolcrab with Rust environment" \
            "bash -c 'source \$HOME/.cargo/env 2>/dev/null || true; if command -v cargo &>/dev/null; then cargo install lolcrab; else echo \"Cargo still not available - Rust must be installed first\" >&2; exit 1; fi'"
    else
        safe_execute "Installing lolcrab" "cargo install lolcrab"
    fi
    
    # Verify installation - also try in new shell if not found in current session
    if ! command -v lolcrab &> /dev/null; then
        # Try to verify in new shell with Rust environment
        if bash -c 'source $HOME/.cargo/env 2>/dev/null || true; command -v lolcrab' &>/dev/null; then
            print_success "lolcrab installed successfully (available in new shell sessions)"
        else
            print_error "Failed to install lolcrab - Rust/Cargo may not be properly installed"
        fi
    else
        verify_command "lolcrab" "lolcrab"
    fi
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
    safe_execute "Cleaning up pfetch installation files" "rm -rf pfetch-master master.zip"
    verify_command "pfetch" "pfetch"
else
    print_success "pfetch is already installed"
fi

### Install terminal tools
for tool in "fd-find" "eza" "zoxide" "delta:git-delta" "tldr" "rg:ripgrep"; do
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

### Install fzf from git
#### git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
#### ~/.fzf/install
if [ ! -d "$HOME/.fzf" ]; then
    print_info "Installing fzf..."
    if git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"; then
        print_success "fzf cloned successfully"
    else
        print_error "Failed to clone fzf"
        return 1
    fi
    if "$HOME/.fzf/install"; then
        print_success "fzf installed successfully"
    else
        print_error "Failed to install fzf"
        return 1
    fi
fi
## Verify fzf installation
if command -v fzf &> /dev/null; then
    print_success "fzf is installed and working"
else
    print_error "fzf installation failed"
    return 1
fi


### FZF Extras
#### Clone fzf-git.sh repository for enhanced git integration
FZF_GIT_DIR="$HOME/.config/fzf-git.sh"
if [ ! -d "$FZF_GIT_DIR" ]; then
    print_info "Setting up fzf-git.sh for enhanced git integration..."
    if safe_execute "Creating fzf-git config directory" "mkdir -p \"$HOME/.config\"" && \
       safe_execute "Cloning fzf-git.sh repository" "git clone https://github.com/junegunn/fzf-git.sh.git \"$FZF_GIT_DIR\""; then
        print_success "fzf-git.sh setup completed"
    else
        print_error "Failed to setup fzf-git.sh"
    fi
else
    print_success "fzf-git.sh is already configured"
fi

#### alias fd=fdfind
alias fd=fdfind

### Install bat
if ! command -v bat &> /dev/null; then
    print_info "Installing bat..."
    
    # Download bat .deb package
    safe_execute "Downloading bat package" "wget https://github.com/sharkdp/bat/releases/download/v0.25.0/bat_0.25.0_amd64.deb"
    
    # Install the package
    safe_execute "Installing bat package" "sudo dpkg -i bat_0.25.0_amd64.deb"
    
    # Fix any dependency issues
    safe_execute "Fixing bat dependencies" "sudo apt-get install -f"
    
    # Clean up downloaded package
    safe_execute "Cleaning up bat installation files" "rm -f bat_0.25.0_amd64.deb"
    
    # Verify installation
    verify_command "bat" "bat"
    
    # Show version for confirmation
    if command -v bat &> /dev/null; then
        print_info "Installed bat version: $(bat --version)"
    fi
else
    print_success "bat is already installed"
fi

### Install thefuck
if ! command -v thefuck &> /dev/null; then
    print_info "Installing thefuck..."

    # Adding deadsnakes repository for Python 3.11
    safe_execute "Adding deadsnakes repository" "sudo add-apt-repository ppa:deadsnakes/ppa -y"
    
    # Install Python 3.11 and required packages
    safe_execute "Installing Python 3.11 and distutils" "sudo apt update && sudo apt install -y python3.11 python3.11-distutils python3.11-venv"
    
    # Install pip for Python 3.11
    safe_execute "Installing pip for Python 3.11" "python3.11 -m ensurepip --upgrade"
    
    # Install pipx
    safe_execute "Installing pipx" "python3.11 -m pip install --user pipx"
    safe_execute "Ensuring pipx path" "python3.11 -m pipx ensurepath --force"
    
    # Install thefuck using pipx with Python 3.11 - run in new shell to ensure PATH is updated
    safe_execute "Installing thefuck with pipx in new shell session" \
        "bash -c 'export PATH=\"\$HOME/.local/bin:\$PATH\"; pipx install --python python3.11 thefuck'"
    
    # Verify installation - check both current session and new shell with updated PATH
    if ! command -v thefuck &> /dev/null; then
        # Try to verify in new shell with updated PATH
        if bash -c 'export PATH="$HOME/.local/bin:$PATH"; command -v thefuck' &>/dev/null; then
            print_success "thefuck installed successfully (available in new shell sessions)"
        else
            print_error "Failed to install thefuck"
        fi
    else
        verify_command "thefuck" "thefuck"
    fi
else
    print_success "thefuck is already installed"
fi

#### Configure bat theme
if command -v bat &> /dev/null; then
    print_info "Configuring bat themes..."
    
    BAT_CONFIG_DIR=$(bat --config-dir 2>/dev/null || echo "$HOME/.config/bat")
    
    if safe_execute "Creating bat themes directory" "mkdir -p \"$BAT_CONFIG_DIR/themes\""; then
        print_success "Created bat themes directory"
    else
        print_error "Failed to create bat themes directory"
        return 1
    fi
    
    # Copy themes if they exist
    if [ -d "$DOTFILES_DIR/common/themes" ]; then
        if cp -r "$DOTFILES_DIR/common/themes/"* "$BAT_CONFIG_DIR/themes/" 2>/dev/null; then
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
if [ -d "$DOTFILES_DIR/common/nvim" ]; then
    # First create symlink to the nvim directory itself
    safe_symlink "$DOTFILES_DIR/common/nvim" "$HOME/.config/nvim" "Neovim configuration"
else
    print_error "Neovim configuration directory not found: $DOTFILES_DIR/common/nvim"
fi

### Symlink ZSH configuration
if [ -f "$DOTFILES_DIR/common/zshell/.zshrc" ]; then
    safe_symlink "$DOTFILES_DIR/common/zshell/.zshrc" "$HOME/.zshrc" "ZSH configuration"
else
    print_error "ZSH configuration file not found: $DOTFILES_DIR/common/zshell/.zshrc"
fi

### Symlink Powerlevel10k configuration
if [ -f "$DOTFILES_DIR/common/zshell/.p10k.zsh" ]; then
    safe_symlink "$DOTFILES_DIR/common/zshell/.p10k.zsh" "$HOME/.p10k.zsh" "Powerlevel10k configuration"
else
    print_error "Powerlevel10k configuration file not found: $DOTFILES_DIR/common/zshell/.p10k.zsh"
fi

### Symlink FZF configuration
if [ -f "$DOTFILES_DIR/common/zshell/fzf-config.zsh" ]; then
    # Create .config directory if it doesn't exist
    safe_execute "Creating .config directory" "mkdir -p \"$HOME/.config\""
    safe_symlink "$DOTFILES_DIR/common/zshell/fzf-config.zsh" "$HOME/.config/fzf-config.zsh" "FZF configuration"
else
    print_error "FZF configuration file not found: $DOTFILES_DIR/common/zshell/fzf-config.zsh"
fi

### Symlink Git configuration
if [ -f "$DOTFILES_DIR/common/git/.gitconfig" ]; then
    safe_symlink "$DOTFILES_DIR/common/git/.gitconfig" "$HOME/.gitconfig" "Git configuration"
else
    print_error "Git configuration file not found: $DOTFILES_DIR/common/git/.gitconfig"
fi

# Install Tailscale CLI
if ! command -v tailscale &> /dev/null; then
    safe_execute "Installing Tailscale CLI" "curl -fsSL https://tailscale.com/install.sh | sh"
    verify_command "tailscale" "Tailscale CLI"
else
    print_success "Tailscale CLI is already installed"
fi

## Install github-cli
if ! command -v gh &> /dev/null; then
    print_info "Installing GitHub CLI..."
    safe_execute "Adding GitHub CLI repository and installing" \
        "curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg && 
         echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\" | sudo tee /etc/apt/sources.list.d/github-cli.list && 
         sudo apt update && sudo apt install -y gh"
    verify_command "gh" "GitHub CLI"
else
    print_success "GitHub CLI is already installed"
fi

### Source ~/.zshrc (only if we're in ZSH)
if [ -f "$HOME/.zshrc" ]; then
    if [ -n "$ZSH_VERSION" ]; then
        print_info "Sourcing ~/.zshrc to apply changes..."
        source "$HOME/.zshrc"
        print_success "Sourced ~/.zshrc successfully"
    else
        print_info "Skipping ~/.zshrc sourcing (not in ZSH shell)"
        print_info "Please restart your terminal or run 'zsh' to use the new configuration"
    fi
else
    print_warning "No ~/.zshrc file found to source"
fi

### Make ZSH the default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    safe_execute "Changing default shell to ZSH" "chsh -s $(which zsh)"
else
    print_success "ZSH is already the default shell"
fi

# Finalize script
finalize_script "Shell and Terminal Enhancements Installation" "$SHELL_ICON"
