# Ubuntu installation script
#!/bin/bash

# Get script directory and source common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_LIB_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")/lib"
source "$COMMON_LIB_DIR/common.sh"

set -o pipefail
# Remove set -e to allow script to continue on errors

# Get error log file from parent script or use default
ERROR_LOG="${1:-error.log}"
init_error_log "$ERROR_LOG"

# Script directory for dotfiles
DOTFILES_DIR="$HOME/.dotfiles"

# Start Ubuntu installation
display_script_header "Ubuntu Dotfiles Installation" "$UBUNTU"

# Update package lists once at the beginning
safe_execute "Updating package lists" "sudo apt update"

# Essential packages for development
print_subsection "${PACKAGE} Installing Essential Packages"

# Install basic tools
safe_execute "Installing curl" "sudo apt install -y curl"
safe_execute "Installing wget" "sudo apt install -y wget"
safe_execute "Installing git" "sudo apt install -y git"
safe_execute "Installing vim" "sudo apt install -y vim"
safe_execute "Installing build-essential" "sudo apt install -y build-essential"
safe_execute "Installing software-properties-common" "sudo apt install -y software-properties-common"
safe_execute "Installing apt-transport-https" "sudo apt install -y apt-transport-https"
safe_execute "Installing ca-certificates" "sudo apt install -y ca-certificates"
safe_execute "Installing gnupg" "sudo apt install -y gnupg"
safe_execute "Installing lsb-release" "sudo apt install -y lsb-release"

# Development environment setup
print_subsection "${TOOL} Setting up Development Environment"

# Check if individual installation scripts exist and run them
scripts=(
    "node/install_node.sh:Node.js"
    "cpp/install_cpp.sh:C++ Development Tools" 
    "rust/install_rust.sh:Rust"
    "golang/install_go.sh:Go"
    "docker/install_docker.sh:Docker"
    "shell/install_shell_cosmetics.sh:Shell Cosmetics"
)

for script_info in "${scripts[@]}"; do
    IFS=':' read -r script_path description <<< "$script_info"
    full_script_path="$DOTFILES_DIR/distros/ubuntu/$script_path"
    
    if [ -f "$full_script_path" ]; then
        safe_run_script "$full_script_path" "$description"
    else
        print_warning "Script not found: $script_path"
    fi
done

# Configuration symlinks
print_subsection "${LINK} Creating Configuration Symlinks"

# Nvim configuration
nvim_source="$DOTFILES_DIR/common/nvim"
nvim_target="$HOME/.config/nvim"
if [ -d "$nvim_source" ]; then
    safe_symlink "$nvim_source" "$nvim_target" "Neovim configuration"
else
    print_warning "Neovim configuration source not found: $nvim_source"
fi

# Git configuration
git_source="$DOTFILES_DIR/common/git"
if [ -d "$git_source" ]; then
    for config_file in "$git_source"/*; do
        if [ -f "$config_file" ]; then
            filename=$(basename "$config_file")
            target="$HOME/.$filename"
            safe_symlink "$config_file" "$target" "Git $filename"
        fi
    done
else
    print_warning "Git configuration source not found: $git_source"
fi

# Theme configuration
theme_source="$DOTFILES_DIR/common/themes"
theme_target="$HOME/.themes"
if [ -d "$theme_source" ]; then
    safe_symlink "$theme_source" "$theme_target" "Themes"
else
    print_warning "Themes source not found: $theme_source"
fi

# Shell configuration
shell_source="$DOTFILES_DIR/common/zshell"
if [ -d "$shell_source" ]; then
    for config_file in "$shell_source"/*; do
        if [ -f "$config_file" ]; then
            filename=$(basename "$config_file")
            target="$HOME/.$filename"
            safe_symlink "$config_file" "$target" "Shell $filename"
        fi
    done
else
    print_warning "Shell configuration source not found: $shell_source"
fi

# Final system update and cleanup
print_subsection "${CONFIG} Final System Configuration"
safe_execute "Updating package cache" "sudo apt update"
safe_execute "Upgrading system packages" "sudo apt upgrade -y"
safe_execute "Removing unnecessary packages" "sudo apt autoremove -y"
safe_execute "Cleaning package cache" "sudo apt autoclean"

# Finalize script
finalize_script "Ubuntu Installation" "$UBUNTU"

# Print next steps
## install lolcrab
print_info "Next steps:"
print_info "1. Install lolcrab for additional shell cosmetics: 'cargo install lolcrab'"