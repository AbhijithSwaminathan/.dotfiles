#!/bin/bash

# Ubuntu Dotfiles Validation Script
# This script validates all installed packages and configurations

# Get script directory and source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_LIB_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")/lib"
source "$COMMON_LIB_DIR/common.sh"
source "$COMMON_LIB_DIR/validation.sh"

# Initialize validation with error tracking
VALIDATION_ERRORS=0
init_error_log "validation.log"

# Function to run validation and track errors without exiting
run_validation() {
    local validation_func="$1"
    shift
    
    if ! "$validation_func" "$@"; then
        ((VALIDATION_ERRORS++))
    fi
}

display_script_header "Ubuntu Dotfiles Validation" "$SEARCH"

# Run comprehensive validation suites
run_validation run_validation_suite "basic"

print_header "${PACKAGE} Package Validation"

# Essential packages validation
run_validation validate_package "curl" "cURL"
run_validation validate_package "git" "Git"
run_validation validate_package "vim" "Vim"
run_validation validate_package "build-essential" "Build Essential"

# Additional essential packages that might be installed
run_validation validate_package "wget" "Wget"
run_validation validate_package "unzip" "Unzip"
run_validation validate_package "software-properties-common" "Software Properties Common"

# Development tools validation
run_validation run_validation_suite "development-new-session"

# Container Tools
print_header "${TOOL} Container Tools"

run_validation validate_command_new_session "docker" "Docker" "Docker Engine"
run_validation validate_command_new_session "docker-compose" "Docker Compose" "Docker Compose"
run_validation validate_user_group "docker" "$USER"

# Shell & Terminal Tools - Use new session validation for recently installed tools
print_header "${TOOL} Shell & Terminal Tools"

print_subsection "Shell Configuration"
run_validation validate_command_new_session "zsh" "ZSH" "ZSH Shell"
run_validation validate_shell_config "zsh"

print_subsection "Terminal Enhancement Tools (New Session Validation)"
# Use the new session validation for all shell tools that might have been installed in same session
run_validation run_validation_suite "shell-tools"

# Text Editor
print_header "${TOOL} Text Editor"

# Validate Neovim using new session check since it might have been just installed
run_validation validate_command_new_session "nvim" "Neovim" "Neovim Text Editor"

# Configuration Files
print_header "${CONFIG} Configuration Files"

# Get the dotfiles directory
DOTFILES_DIR="$HOME/.dotfiles"

print_subsection "Git Configuration"
run_validation validate_symlink "$HOME/.gitconfig" "$DOTFILES_DIR/common/git/.gitconfig" "Git config"

print_subsection "Shell Configuration"
run_validation validate_symlink "$HOME/.zshrc" "$DOTFILES_DIR/common/zshell/.zshrc" "ZSH config"
run_validation validate_symlink "$HOME/.p10k.zsh" "$DOTFILES_DIR/common/zshell/.p10k.zsh" "Powerlevel10k config"

print_subsection "Neovim Configuration"
run_validation validate_path "$HOME/.config/nvim" "directory" "Neovim config directory"

print_subsection "Bat Configuration"
run_validation validate_path "$HOME/.config/bat/themes" "directory" "Bat themes directory"

# Additional CLI Tools Validation
print_header "${TOOL} Additional CLI Tools"
run_validation validate_command_new_session "tailscale" "Tailscale" "Tailscale CLI"
run_validation validate_command_new_session "gh" "GitHub CLI" "GitHub CLI"

# Python and Package Management
print_header "${TOOL} Python and Package Management"
run_validation validate_command_new_session "python3.11" "Python 3.11" "Python 3.11"
run_validation validate_command_new_session "pipx" "pipx" "pipx Package Manager"

# Programming Language Environments
print_header "${TOOL} Programming Language Environments"
print_subsection "Go Environment"
if run_validation validate_command_new_session "go" "Go" "Go Programming Language"; then
    # Additional Go environment validation
    print_info "Validating Go environment variables..."
    run_validation validate_env_var "GOROOT"
    run_validation validate_env_var "GOPATH"
fi

print_subsection "Rust Environment"
if run_validation validate_command_new_session "rustc" "Rust Compiler" "Rust Compiler"; then
    run_validation validate_command_new_session "cargo" "Cargo" "Rust Package Manager"
    # Check if Rust environment file exists
    run_validation validate_path "$HOME/.cargo/env" "file" "Rust environment file"
fi

# Validation Summary
print_header "${SEARCH} Validation Summary"

if [ $VALIDATION_ERRORS -eq 0 ]; then
    print_success "All validations passed successfully! ✅"
    echo ""
    print_info "Your dotfiles installation is complete and all components are working correctly."
    exit_status=0
else
    print_error "Validation completed with $VALIDATION_ERRORS error(s) ❌"
    echo ""
    print_warning "Some components may need attention. Check the validation output above."
    print_info "You can re-run specific installation scripts to fix issues, or"
    print_info "run this validation script again after making corrections."
    exit_status=1
fi

# Finalize validation
finalize_script "Ubuntu Dotfiles Validation" "$SEARCH"

# Exit with appropriate status code
exit $exit_status