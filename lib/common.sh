#!/bin/bash

# Common Shell Library for Dotfiles Installation
# This library provides reusable functions for all installation scripts

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
SEARCH="🔍"
ROCKET="🚀"

# Language/Tool specific icons
NODEJS="📗"
RUST="🦀"
GOLANG="🐹"
CPP="⚙️"
DOCKER="🐳"
SHELL_ICON="🐚"
UBUNTU="🐧"

# Global error tracking
ERRORS=0
ERROR_LOG=""

# Function to initialize error logging
init_error_log() {
    local error_log="${1:-error.log}"
    ERROR_LOG="$error_log"
    # Clear previous error log
    > "$ERROR_LOG"
}

# Function to log errors
log_error() {
    local error_msg="$1"
    local script_name="${2:-common}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$script_name] ERROR: $error_msg" >> "$ERROR_LOG"
    ERRORS=$((ERRORS + 1))
}

# Function to print colored output
print_info() {
    echo -e "${CYAN}${INFO}${NC} ${BOLD}$1${NC}"
}

print_success() {
    echo -e "${GREEN}${SUCCESS}${NC} ${BOLD}$1${NC}"
}

print_error() {
    echo -e "${RED}${FAILURE}${NC} ${BOLD}$1${NC}"
    local script_name="${2:-$(basename "${BASH_SOURCE[2]}")}"
    log_error "$1" "$script_name"
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
    else
        print_error "$name is not available or not working"
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

# Function to safely run subscript
safe_run_script() {
    local script_path="$1"
    local description="$2"
    
    if [ ! -f "$script_path" ]; then
        print_error "Script not found: $script_path"
        return 1
    fi
    
    print_info "Running $description..."
    # Pass the ERROR_LOG path to the subscript and capture its error count
    bash "$script_path" "$ERROR_LOG"
    local subscript_errors=$?
    
    if [ $subscript_errors -eq 0 ]; then
        print_success "$description completed successfully"
        return 0
    else
        print_error "$description failed with $subscript_errors error(s)"
        # Add the subscript errors to our total error count
        ERRORS=$((ERRORS + subscript_errors))
        return $subscript_errors
    fi
}

# Function to show final error summary
show_error_summary() {
    if [ $ERRORS -gt 0 ]; then
        print_header "${FAILURE} Installation Summary"
        print_error "Installation completed with $ERRORS error(s)"
        print_warning "Error details have been logged to: ${BOLD}$ERROR_LOG${NC}"
        echo ""
        print_info "Error Summary:"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        if [ -f "$ERROR_LOG" ] && [ -s "$ERROR_LOG" ]; then
            cat "$ERROR_LOG" | while read line; do
                echo -e "${RED}  $line${NC}"
            done
        else
            echo -e "${RED}  No detailed error information available${NC}"
        fi
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        print_info "You can review the full error log with: ${BOLD}cat $ERROR_LOG${NC}"
        print_info "Try fixing the issues and re-running the installation"
    else
        print_header "${SUCCESS} Installation Summary"
        print_success "All components installed successfully with no errors!"
        # Remove empty error log
        [ -f "$ERROR_LOG" ] && rm "$ERROR_LOG"
    fi
}

# Function to check if running with bash
check_bash() {
    if [ -z "$BASH_VERSION" ]; then
        echo "Error: This script requires bash to run."
        echo "Please run with: bash $0"
        exit 1
    fi
}

# Function to get script directory (useful for relative paths)
get_script_dir() {
    echo "$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
}

# Function to get dotfiles root directory
get_dotfiles_dir() {
    echo "$HOME/.dotfiles"
}

# Function to display script header with information
display_script_header() {
    local script_name="$1"
    local icon="${2:-$TOOL}"
    
    print_header "${icon} ${script_name}"
    print_info "Date: $(date)"
    print_info "User: $USER"
    print_info "Hostname: $(hostname)"
    echo ""
}

# Function to finalize script execution
finalize_script() {
    local script_name="$1"
    local icon="${2:-$SUCCESS}"
    
    if [ $ERRORS -eq 0 ]; then
        print_success "$script_name completed successfully"
    else
        print_error "$script_name completed with $ERRORS error(s)"
    fi
    
    # Return the error count for parent script to capture
    return $ERRORS
}
