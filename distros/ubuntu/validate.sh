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
        return 1
    fi
    return 0
}

display_script_header "Ubuntu Dotfiles Validation" "$SEARCH"

# Run comprehensive validation suites
print_header "${SEARCH} Basic System Validation"
run_validation validate_command "bash" "Bash Shell"
run_validation validate_command "git" "Git"
run_validation validate_path "$HOME" "directory" "Home Directory"
run_validation validate_path "$HOME/.dotfiles" "directory" "Dotfiles Directory"

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
print_header "${TOOL} Development Tools"
run_validation validate_session_commands \
    "node:Node.js" \
    "npm:NPM" \
    "rustc:Rust Compiler" \
    "cargo:Cargo" \
    "go:Go" \
    "g++:C++ Compiler" \
    "docker:Docker"

# Container Tools
print_header "${TOOL} Container Tools"
run_validation validate_command_new_session "docker" "Docker" "Docker Engine"
run_validation validate_command_new_session "docker-compose" "Docker Compose" "Docker Compose"
run_validation validate_user_group "docker" "$USER"

# Shell & Terminal Tools
print_header "${TOOL} Shell & Terminal Tools"

print_subsection "Shell Configuration"
run_validation validate_command_new_session "zsh" "ZSH" "ZSH Shell"
run_validation validate_shell_config "zsh"

print_subsection "Terminal Enhancement Tools"
run_validation validate_session_commands \
    "zsh:ZSH Shell" \
    "fortune:fortune" \
    "cowsay:cowsay" \
    "lolcrab:lolcrab" \
    "pfetch:pfetch" \
    "fzf:fzf" \
    "fd:fd-find" \
    "eza:eza" \
    "zoxide:zoxide" \
    "delta:git-delta" \
    "tldr:tldr" \
    "rg:ripgrep" \
    "bat:bat" \
    "thefuck:thefuck" \
    "nvim:Neovim" \
    "tailscale:Tailscale CLI" \
    "gh:GitHub CLI"

print_subsection "FZF Validation"
# Validate FZF installation and key bindings
run_validation validate_command_new_session "fzf" "FZF" "Fuzzy Finder"
if command -v fzf >/dev/null 2>&1; then
    print_info "Validating FZF environment variables..."
    run_validation validate_env_var "FZF_DEFAULT_COMMAND" "FZF default command"
    run_validation validate_env_var "FZF_DEFAULT_OPTS" "FZF default options"
fi

# Text Editor
print_header "${TOOL} Text Editor"
run_validation validate_command_new_session "nvim" "Neovim" "Neovim Text Editor"

# Configuration Files
print_header "${CONFIG} Configuration Files"

# Get the dotfiles directory
DOTFILES_DIR="$HOME/.dotfiles"

print_subsection "Git Configuration"
run_validation validate_symlink "$HOME/.gitconfig" "$DOTFILES_DIR/common/git/.gitconfig" "Git config"
if [ -f "$HOME/.gitconfig" ]; then
    print_info "Validating git configuration settings..."
    # Check if git config has basic settings
    if git config --global user.name >/dev/null 2>&1 && git config --global user.email >/dev/null 2>&1; then
        print_success "Git user configuration is set"
    else
        print_warning "Git user configuration may need to be set (name/email)"
    fi
fi

print_subsection "Shell Aliases and Functions"
# Validate important aliases are available in new shell session
if command -v zsh >/dev/null 2>&1; then
    print_info "Validating shell aliases..."
    
    # Test fd alias
    if zsh -c 'source ~/.zshrc 2>/dev/null && command -v fd >/dev/null 2>&1'; then
        print_success "fd alias is configured correctly"
    else
        print_warning "fd alias may not be configured"
    fi
    
    # Test thefuck aliases
    if zsh -c 'source ~/.zshrc 2>/dev/null && command -v fuck >/dev/null 2>&1'; then
        print_success "thefuck aliases are configured correctly"
    else
        print_warning "thefuck aliases may not be configured"
    fi
fi

print_subsection "Shell Configuration"
run_validation validate_symlink "$HOME/.zshrc" "$DOTFILES_DIR/common/zshell/.zshrc" "ZSH config"
run_validation validate_symlink "$HOME/.p10k.zsh" "$DOTFILES_DIR/common/zshell/.p10k.zsh" "Powerlevel10k config"
run_validation validate_symlink "$HOME/.config/fzf-config.zsh" "$DOTFILES_DIR/common/zshell/fzf-config.zsh" "FZF config"

print_subsection "FZF Integration"
run_validation validate_path "$HOME/.config/fzf-git.sh" "directory" "FZF Git integration"
run_validation validate_path "$HOME/.config/fzf-git.sh/fzf-git.sh" "file" "FZF Git script"

# Validate FZF functions are loaded in a new shell session
if [ -f "$HOME/.config/fzf-config.zsh" ]; then
    print_info "Validating FZF configuration functions..."
    # Test if FZF functions are available in new zsh session
    if zsh -c 'source ~/.config/fzf-config.zsh && type _fzf_comprun >/dev/null 2>&1'; then
        print_success "FZF completion functions are loaded correctly"
    else
        print_warning "FZF completion functions may not be loading properly"
    fi
fi

print_subsection "Neovim Configuration"
run_validation validate_path "$HOME/.config/nvim" "directory" "Neovim config directory"

print_subsection "Bat Configuration"
run_validation validate_path "$HOME/.config/bat/themes" "directory" "Bat themes directory"
if [ -d "$HOME/.config/bat/themes" ]; then
    print_info "Validating bat theme files..."
    run_validation validate_path "$HOME/.config/bat/themes/tokyonight_night.tmTheme" "file" "Tokyo Night theme"
fi
run_validation validate_env_var "BAT_THEME" "Bat theme setting"

# Additional CLI Tools Validation
print_header "${TOOL} Additional CLI Tools"
run_validation validate_command_new_session "tailscale" "Tailscale" "Tailscale CLI"
run_validation validate_command_new_session "gh" "GitHub CLI" "GitHub CLI"

# Python and Package Management
print_header "${TOOL} Python and Package Management"
run_validation validate_command_new_session "python3.11" "Python 3.11" "Python 3.11"
run_validation validate_command_new_session "pipx" "pipx" "pipx Package Manager"

print_header "${TOOL} Environment Variables and PATH"

print_subsection "Essential PATH Validation"
# Validate important directories are in PATH
print_info "Validating PATH configuration..."

# Check for important directories in PATH
if echo "$PATH" | grep -q "/usr/local/bin"; then
    print_success "/usr/local/bin found in PATH ✓"
else
    print_warning "/usr/local/bin not found in PATH"
fi

if echo "$PATH" | grep -q "$HOME/.local/bin"; then
    print_success "Local bin found in PATH ✓"
else
    print_warning "$HOME/.local/bin not found in PATH"
fi

# Check language-specific paths
if command -v go >/dev/null 2>&1; then
    if echo "$PATH" | grep -q "/usr/local/go/bin"; then
        print_success "Go bin found in PATH ✓"
    else
        print_warning "/usr/local/go/bin not found in PATH"
    fi
fi

if [ -d "$HOME/.cargo" ]; then
    if echo "$PATH" | grep -q "$HOME/.cargo/bin"; then
        print_success "Rust cargo bin found in PATH ✓"
    else
        print_warning "$HOME/.cargo/bin not found in PATH"
    fi
fi

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