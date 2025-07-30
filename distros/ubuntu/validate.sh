#!/bin/bash

# Ubuntu Dotfiles Validation Script
# This script validates all installed packages and configurations

# Get script directory and source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_LIB_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")/lib"
source "$COMMON_LIB_DIR/common.sh"
source "$COMMON_LIB_DIR/validation.sh"

set -e

# Initialize validation
init_error_log "validation.log"
display_script_header "Ubuntu Dotfiles Validation" "$SEARCH"

# Run comprehensive validation suites
run_validation_suite "basic"

print_header "${PACKAGE} Package Validation"

# Essential packages validation
validate_package "curl" "cURL"
validate_package "git" "Git"
validate_package "vim" "Vim"
validate_package "build-essential" "Build Essential"

# Development tools validation
run_validation_suite "development-new-session"

# Container Tools
print_header "${TOOL} Container Tools"

validate_command "docker" "Docker"
validate_command "docker-compose" "Docker Compose"  
validate_user_group "docker" "$USER"

# Shell & Terminal Tools - Use new session validation for recently installed tools
print_header "${TOOL} Shell & Terminal Tools"

print_subsection "Shell Configuration"
validate_command "zsh" "ZSH"
validate_shell_config "zsh"

print_subsection "Terminal Enhancement Tools (New Session Validation)"
# Use the new session validation for all shell tools that might have been installed in same session
run_validation_suite "shell-tools"

# Text Editor
print_header "${TOOL} Text Editor"

# Validate Neovim using new session check since it might have been just installed
validate_command_new_session "nvim" "Neovim" "Neovim Text Editor"

# Configuration Files
print_header "${CONFIG} Configuration Files"

# Get the dotfiles directory
DOTFILES_DIR="$HOME/.dotfiles"

print_subsection "Git Configuration"
validate_symlink "$HOME/.gitconfig" "$DOTFILES_DIR/common/git/.gitconfig" "Git config"

print_subsection "Shell Configuration"
validate_symlink "$HOME/.zshrc" "$DOTFILES_DIR/common/zshell/.zshrc" "ZSH config"
validate_symlink "$HOME/.p10k.zsh" "$DOTFILES_DIR/common/zshell/.p10k.zsh" "Powerlevel10k config"

print_subsection "Neovim Configuration"
validate_path "$HOME/.config/nvim" "directory" "Neovim config directory"

print_subsection "Bat Configuration"
validate_path "$HOME/.config/bat/themes" "directory" "Bat themes directory"

# Finalize validation
finalize_script "Ubuntu Dotfiles Validation" "$SEARCH"