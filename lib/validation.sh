#!/bin/bash

# Validation Library for Dotfiles Installation
# This library provides reusable validation functions

# Source common library for shared functionality
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Function to validate if a command is installed and working
validate_command() {
    local cmd="$1"
    local name="${2:-$cmd}"
    local expected_version="${3:-}"
    
    print_info "Validating $name..."
    
    # Check command in current session first
    local cmd_found_current=false
    if command -v "$cmd" >/dev/null 2>&1; then
        cmd_found_current=true
    fi
    
    # Check command in new shell session with fresh environment
    local cmd_found_new=false
    if bash -c "
        # Source common shell configurations to get updated PATH
        [ -f \$HOME/.bashrc ] && source \$HOME/.bashrc 2>/dev/null || true
        [ -f \$HOME/.zshrc ] && source \$HOME/.zshrc 2>/dev/null || true
        [ -f \$HOME/.cargo/env ] && source \$HOME/.cargo/env 2>/dev/null || true
        export PATH=\"\$HOME/.local/bin:\$PATH\"
        command -v $cmd
    " >/dev/null 2>&1; then
        cmd_found_new=true
    fi
    
    # Determine if command is available
    if [ "$cmd_found_current" = true ]; then
        # Available in current session
        local cmd_path=$(command -v "$cmd")
    elif [ "$cmd_found_new" = true ]; then
        # Available in new session but not current
        print_success "$name is installed (available in new shell sessions)"
        return 0
    else
        # Not found in either session
        print_error "$name is not installed or not in PATH"
        return 1
    fi
    
    # If version checking is requested and command is available in current session
    if [ -n "$expected_version" ]; then
        local actual_version
        case "$cmd" in
            "node")
                actual_version=$(node --version 2>/dev/null | cut -d'v' -f2)
                ;;
            "npm")
                actual_version=$(npm --version 2>/dev/null)
                ;;
            "rustc")
                actual_version=$(rustc --version 2>/dev/null | cut -d' ' -f2)
                ;;
            "cargo")
                actual_version=$(cargo --version 2>/dev/null | cut -d' ' -f2)
                ;;
            "go")
                actual_version=$(go version 2>/dev/null | cut -d' ' -f3 | cut -d'o' -f2)
                ;;
            "docker")
                actual_version=$(docker --version 2>/dev/null | cut -d' ' -f3 | cut -d',' -f1)
                ;;
            "g++"|"gcc")
                actual_version=$(g++ --version 2>/dev/null | head -1 | cut -d' ' -f4)
                ;;
            *)
                # Generic version check - try common patterns
                if $cmd --version >/dev/null 2>&1; then
                    actual_version=$($cmd --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
                else
                    actual_version="unknown"
                fi
                ;;
        esac
        
        if [ -n "$actual_version" ] && [ "$actual_version" != "unknown" ]; then
            print_success "$name $actual_version is installed (expected: $expected_version)"
        else
            print_warning "$name is installed but version could not be determined"
        fi
    else
        print_success "$name is installed and available"
    fi
    
    return 0
}

# Function to validate commands specifically in new shell sessions (for recently installed tools)
validate_command_new_session() {
    local cmd="$1"
    local name="${2:-$cmd}"
    local description="${3:-$name}"
    
    print_info "Validating $description in new shell session..."
    
    # Try to use zsh if available, fallback to bash
    local shell_cmd="bash"
    if command -v zsh >/dev/null 2>&1; then
        shell_cmd="zsh"
    fi
    
    # Check command in new shell session with all environment sources
    if $shell_cmd -c "
        # Source all possible shell configurations based on shell type
        if [ '$shell_cmd' = 'zsh' ]; then
            [ -f \$HOME/.zshrc ] && source \$HOME/.zshrc 2>/dev/null || true
            [ -f \$HOME/.zprofile ] && source \$HOME/.zprofile 2>/dev/null || true
        else
            [ -f \$HOME/.bashrc ] && source \$HOME/.bashrc 2>/dev/null || true
            [ -f \$HOME/.bash_profile ] && source \$HOME/.bash_profile 2>/dev/null || true
        fi
        
        [ -f \$HOME/.profile ] && source \$HOME/.profile 2>/dev/null || true
        [ -f \$HOME/.cargo/env ] && source \$HOME/.cargo/env 2>/dev/null || true
        
        # Add common paths where tools might be installed
        export PATH=\"\$HOME/.local/bin:\$HOME/.cargo/bin:/usr/local/bin:\$PATH\"
        
        # For FZF, check if it's in the home directory too
        [ -f \$HOME/.fzf.bash ] && source \$HOME/.fzf.bash 2>/dev/null || true
        [ -f \$HOME/.fzf.zsh ] && source \$HOME/.fzf.zsh 2>/dev/null || true
        
        # Check if command exists and try to get version
        if command -v $cmd >/dev/null 2>&1; then
            echo \"Command found: \$(command -v $cmd)\"
            if $cmd --version >/dev/null 2>&1; then
                echo \"Version: \$($cmd --version 2>/dev/null | head -1)\"
            fi
            exit 0
        else
            exit 1
        fi
    " 2>/dev/null; then
        print_success "$description is available in new shell sessions"
        return 0
    else
        print_error "$description is not available even in new shell sessions"
        return 1
    fi
}

# Function to validate commands specifically with proper shell environment 
validate_command_with_shell() {
    local cmd="$1"
    local name="${2:-$cmd}"
    local description="${3:-$name}"
    
    print_info "Validating $description with shell environment..."
    
    # First check in current session
    if command -v "$cmd" >/dev/null 2>&1; then
        print_success "$description is available in current session"
        return 0
    fi
    
    # Try with different shell environments
    local found=0
    
    # Try with bash environment
    if bash -c "
        export PATH=\"\$HOME/.local/bin:\$HOME/.cargo/bin:/usr/local/bin:\$PATH\"
        [ -f \$HOME/.bashrc ] && source \$HOME/.bashrc 2>/dev/null || true
        [ -f \$HOME/.profile ] && source \$HOME/.profile 2>/dev/null || true
        [ -f \$HOME/.cargo/env ] && source \$HOME/.cargo/env 2>/dev/null || true
        command -v $cmd >/dev/null 2>&1
    " 2>/dev/null; then
        print_success "$description is available with bash environment"
        found=1
    fi
    
    # Try with zsh environment if available
    if [ $found -eq 0 ] && command -v zsh >/dev/null 2>&1; then
        if zsh -c "
            export PATH=\"\$HOME/.local/bin:\$HOME/.cargo/bin:/usr/local/bin:\$PATH\"
            [ -f \$HOME/.zshrc ] && source \$HOME/.zshrc 2>/dev/null || true
            [ -f \$HOME/.zprofile ] && source \$HOME/.zprofile 2>/dev/null || true
            [ -f \$HOME/.profile ] && source \$HOME/.profile 2>/dev/null || true
            [ -f \$HOME/.cargo/env ] && source \$HOME/.cargo/env 2>/dev/null || true
            command -v $cmd >/dev/null 2>&1
        " 2>/dev/null; then
            print_success "$description is available with zsh environment"
            found=1
        fi
    fi
    
    if [ $found -eq 0 ]; then
        print_error "$description is not available in any shell environment"
        return 1
    fi
    
    return 0
}

# Function to validate multiple commands that might be in new sessions
validate_session_commands() {
    local commands=("$@")
    local failed_count=0
    
    print_info "Validating commands in new shell sessions..."
    
    for cmd_info in "${commands[@]}"; do
        # Parse command info (format: "command:name" or just "command")
        local cmd_name=$(echo "$cmd_info" | cut -d: -f1)
        local display_name=$(echo "$cmd_info" | cut -d: -f2)
        [ "$display_name" = "$cmd_name" ] && display_name="$cmd_name"
        
        if ! validate_command_new_session "$cmd_name" "$display_name"; then
            ((failed_count++))
        fi
    done
    
    if [ $failed_count -eq 0 ]; then
        print_success "All commands validated successfully"
        return 0
    else
        print_warning "$failed_count command(s) failed validation"
        return 1
    fi
}

# Function to validate if a file or directory exists
validate_path() {
    local path="$1"
    local type="${2:-file}" # file, directory, symlink
    local description="${3:-$path}"
    
    print_info "Validating $description..."
    
    case "$type" in
        "file")
            if [ -f "$path" ]; then
                print_success "$description exists and is a regular file"
                return 0
            else
                print_error "$description does not exist or is not a regular file"
                return 1
            fi
            ;;
        "directory")
            if [ -d "$path" ]; then
                print_success "$description exists and is a directory"
                return 0
            else
                print_error "$description does not exist or is not a directory"
                return 1
            fi
            ;;
        "symlink")
            if [ -L "$path" ]; then
                local target=$(readlink "$path")
                if [ -e "$path" ]; then
                    print_success "$description is a valid symlink pointing to: $target"
                    return 0
                else
                    print_error "$description is a broken symlink pointing to: $target"
                    return 1
                fi
            else
                print_error "$description is not a symlink"
                return 1
            fi
            ;;
        *)
            if [ -e "$path" ]; then
                print_success "$description exists"
                return 0
            else
                print_error "$description does not exist"
                return 1
            fi
            ;;
    esac
}

# Function to validate symlink
validate_symlink() {
    local symlink_path="$1"
    local expected_target="${2:-}"
    local description="${3:-$symlink_path}"
    
    print_info "Validating symlink: $description..."
    
    if [ ! -L "$symlink_path" ]; then
        print_error "$description is not a symlink"
        return 1
    fi
    
    local actual_target=$(readlink "$symlink_path")
    
    if [ ! -e "$symlink_path" ]; then
        print_error "$description is a broken symlink pointing to: $actual_target"
        return 1
    fi
    
    if [ -n "$expected_target" ]; then
        if [ "$actual_target" = "$expected_target" ]; then
            print_success "$description correctly points to: $expected_target"
        else
            print_warning "$description points to: $actual_target (expected: $expected_target)"
        fi
    else
        print_success "$description is a valid symlink pointing to: $actual_target"
    fi
    
    return 0
}

# Function to validate if user is in a specific group
validate_user_group() {
    local group_name="$1"
    local user="${2:-$USER}"
    
    print_info "Validating user $user membership in group $group_name..."
    
    if groups "$user" 2>/dev/null | grep -q "\b$group_name\b"; then
        print_success "User $user is a member of group $group_name"
        return 0
    else
        print_error "User $user is not a member of group $group_name"
        return 1
    fi
}

# Function to validate environment variable
validate_env_var() {
    local var_name="$1"
    local expected_value="${2:-}"
    local description="${3:-$var_name}"
    
    print_info "Validating environment variable: $description..."
    
    if [ -z "${!var_name}" ]; then
        print_error "Environment variable $var_name is not set"
        return 1
    fi
    
    if [ -n "$expected_value" ]; then
        if [ "${!var_name}" = "$expected_value" ]; then
            print_success "$var_name is set to expected value: $expected_value"
        else
            print_warning "$var_name is set to: ${!var_name} (expected: $expected_value)"
        fi
    else
        print_success "$var_name is set to: ${!var_name}"
    fi
    
    return 0
}

# Function to validate if a path exists in an environment variable
validate_path_in_env() {
    local path_to_check="$1"
    local env_var="$2"
    local description="${3:-$path_to_check in $env_var}"
    
    print_info "Validating $description..."
    
    # Get the environment variable value
    local env_value="${!env_var}"
    
    if [ -z "$env_value" ]; then
        print_error "$env_var environment variable is not set"
        return 1
    fi
    
    # Check if the path is in the environment variable
    if echo "$env_value" | grep -q "$path_to_check"; then
        print_success "$description ✓"
        return 0
    else
        print_error "$path_to_check not found in $env_var"
        print_info "Current $env_var: $env_value"
        return 1
    fi
}

# Function to validate shell configuration
validate_shell_config() {
    local shell_name="${1:-bash}"
    local config_file=""
    
    case "$shell_name" in
        "bash")
            config_file="$HOME/.bashrc"
            ;;
        "zsh")
            config_file="$HOME/.zshrc"
            ;;
        "fish")
            config_file="$HOME/.config/fish/config.fish"
            ;;
        *)
            print_error "Unsupported shell: $shell_name"
            return 1
            ;;
    esac
    
    print_info "Validating $shell_name configuration..."
    
    if [ -f "$config_file" ]; then
        print_success "$shell_name configuration file exists: $config_file"
        return 0
    else
        print_error "$shell_name configuration file not found: $config_file"
        return 1
    fi
}

# Function to validate package installation (Ubuntu/Debian)
validate_package() {
    local package_name="$1"
    local description="${2:-$package_name}"
    
    print_info "Validating package: $description..."
    
    if dpkg -l | grep -q "^ii  $package_name "; then
        local version=$(dpkg -l | grep "^ii  $package_name " | awk '{print $3}')
        print_success "$description is installed (version: $version)"
        return 0
    else
        print_error "$description is not installed"
        return 1
    fi
}

# Function to validate service status
validate_service() {
    local service_name="$1"
    local expected_status="${2:-active}" # active, inactive, enabled, disabled
    local description="${3:-$service_name}"
    
    print_info "Validating service: $description..."
    
    case "$expected_status" in
        "active")
            if systemctl is-active --quiet "$service_name"; then
                print_success "$description service is active and running"
                return 0
            else
                print_error "$description service is not active"
                return 1
            fi
            ;;
        "enabled")
            if systemctl is-enabled --quiet "$service_name"; then
                print_success "$description service is enabled"
                return 0
            else
                print_error "$description service is not enabled"
                return 1
            fi
            ;;
        "inactive")
            if ! systemctl is-active --quiet "$service_name"; then
                print_success "$description service is inactive (as expected)"
                return 0
            else
                print_error "$description service is active (expected inactive)"
                return 1
            fi
            ;;
        "disabled")
            if ! systemctl is-enabled --quiet "$service_name"; then
                print_success "$description service is disabled (as expected)"
                return 0
            else
                print_error "$description service is enabled (expected disabled)"
                return 1
            fi
            ;;
        *)
            print_error "Unknown service status: $expected_status"
            return 1
            ;;
    esac
}

# Function to run comprehensive validation
run_validation_suite() {
    local validation_type="${1:-basic}" # basic, development, system
    
    print_header "${SEARCH} Running $validation_type Validation Suite"
    
    case "$validation_type" in
        "basic")
            validate_command "bash" "Bash Shell"
            validate_command "git" "Git"
            validate_path "$HOME" "directory" "Home Directory"
            validate_path "$HOME/.dotfiles" "directory" "Dotfiles Directory"
            ;;
        "development")
            validate_command "node" "Node.js"
            validate_command "npm" "NPM"
            validate_command "rustc" "Rust Compiler"
            validate_command "cargo" "Cargo"
            validate_command "go" "Go"
            validate_command "g++" "C++ Compiler"
            validate_command "docker" "Docker"
            ;;
        "development-new-session")
            # Validate development tools in new shell sessions (for same-session installations)
            validate_session_commands \
                "node:Node.js" \
                "npm:NPM" \
                "rustc:Rust Compiler" \
                "cargo:Cargo" \
                "go:Go" \
                "g++:C++ Compiler" \
                "docker:Docker"
            ;;
        "system")
            validate_shell_config "bash"
            validate_env_var "HOME"
            validate_env_var "PATH"
            validate_user_group "sudo" "$USER"
            ;;
        "shell-tools")
            # Validate shell enhancement tools specifically
            validate_session_commands \
                "zsh:ZSH Shell" \
                "fortune:fortune" \
                "cowsay:cowsay" \
                "lolcrab:lolcrab" \
                "pfetch:pfetch" \
                "fzf:fzf" \
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
            ;;
        "full")
            run_validation_suite "basic"
            run_validation_suite "development"
            run_validation_suite "system"
            ;;
        "full-new-session")
            run_validation_suite "basic"
            run_validation_suite "development-new-session"
            run_validation_suite "system"
            ;;
        *)
            print_error "Unknown validation type: $validation_type"
            return 1
            ;;
    esac
}
