#!/bin/bash

# Ubuntu Dotfiles Validation Script
# This script validates all installed packages and configurations

set -e

# Color codes for pretty printing
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
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

# Function to print section headers
print_header() {
    echo -e "\n${BOLD}${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}$1${NC}"
    echo -e "${BOLD}${BLUE}════════════════════════════════════════${NC}\n"
}

# Function to print subsection headers
print_subsection() {
    echo -e "\n${BOLD}${PURPLE}── $1 ──${NC}\n"
}

# Function to validate command existence and version
validate_command() {
    local cmd=$1
    local name=$2
    local version_flag=${3:-"--version"}
    
    if command -v "$cmd" >/dev/null 2>&1; then
        local version=$(eval "$cmd $version_flag 2>/dev/null | head -n 1" 2>/dev/null || echo "Version unavailable")
        echo -e "${GREEN}${SUCCESS}${NC} ${BOLD}$name${NC} is installed"
        echo -e "   ${CYAN}→${NC} Version: $version"
        echo -e "   ${CYAN}→${NC} Location: $(which "$cmd")"
    else
        echo -e "${RED}${FAILURE}${NC} ${BOLD}$name${NC} is not installed"
        return 1
    fi
}

# Function to validate file/directory existence
validate_path() {
    local path=$1
    local name=$2
    local type=${3:-"file"}
    
    if [ -e "$path" ]; then
        if [ "$type" = "file" ]; then
            echo -e "${GREEN}${SUCCESS}${NC} ${BOLD}$name${NC} exists"
            echo -e "   ${CYAN}→${NC} Path: $path"
            echo -e "   ${CYAN}→${NC} Size: $(du -h "$path" 2>/dev/null | cut -f1 || echo "Unknown")"
        else
            echo -e "${GREEN}${SUCCESS}${NC} ${BOLD}$name${NC} directory exists"
            echo -e "   ${CYAN}→${NC} Path: $path"
            echo -e "   ${CYAN}→${NC} Contents: $(ls -1 "$path" 2>/dev/null | wc -l || echo "0") items"
        fi
    else
        echo -e "${RED}${FAILURE}${NC} ${BOLD}$name${NC} does not exist"
        echo -e "   ${CYAN}→${NC} Expected path: $path"
        return 1
    fi
}

# Function to validate symlink
validate_symlink() {
    local link_path=$1
    local target_path=$2
    local name=$3
    
    if [ -L "$link_path" ]; then
        local actual_target=$(readlink "$link_path")
        if [ "$actual_target" = "$target_path" ]; then
            echo -e "${GREEN}${SUCCESS}${NC} ${BOLD}$name${NC} symlink is correct"
            echo -e "   ${CYAN}→${NC} Link: $link_path"
            echo -e "   ${CYAN}→${NC} Target: $target_path"
        else
            echo -e "${YELLOW}${WARNING}${NC} ${BOLD}$name${NC} symlink exists but points to wrong target"
            echo -e "   ${CYAN}→${NC} Link: $link_path"
            echo -e "   ${CYAN}→${NC} Expected: $target_path"
            echo -e "   ${CYAN}→${NC} Actual: $actual_target"
            return 1
        fi
    else
        echo -e "${RED}${FAILURE}${NC} ${BOLD}$name${NC} symlink does not exist"
        echo -e "   ${CYAN}→${NC} Expected link: $link_path"
        return 1
    fi
}

# Function to validate group membership
validate_group() {
    local group=$1
    local name=$2
    
    if groups "$USER" | grep -q "\b$group\b"; then
        echo -e "${GREEN}${SUCCESS}${NC} User ${BOLD}$USER${NC} is in ${BOLD}$name${NC} group"
    else
        echo -e "${RED}${FAILURE}${NC} User ${BOLD}$USER${NC} is not in ${BOLD}$name${NC} group"
        return 1
    fi
}

# Function to validate shell
validate_shell() {
    local expected_shell=$1
    local name=$2
    
    if [ "$SHELL" = "$expected_shell" ]; then
        echo -e "${GREEN}${SUCCESS}${NC} Default shell is ${BOLD}$name${NC}"
        echo -e "   ${CYAN}→${NC} Shell: $SHELL"
    else
        echo -e "${YELLOW}${WARNING}${NC} Default shell is not ${BOLD}$name${NC}"
        echo -e "   ${CYAN}→${NC} Current: $SHELL"
        echo -e "   ${CYAN}→${NC} Expected: $expected_shell"
        return 1
    fi
}

# Start validation
echo -e "${BOLD}${CYAN}🚀 Starting Ubuntu Dotfiles Validation${NC}"
echo -e "${CYAN}Date: $(date)${NC}"
echo -e "${CYAN}User: $USER${NC}"
echo -e "${CYAN}Hostname: $(hostname)${NC}"

# Track validation results
total_checks=0
passed_checks=0
failed_checks=0

check_result() {
    total_checks=$((total_checks + 1))
    if [ $? -eq 0 ]; then
        passed_checks=$((passed_checks + 1))
    else
        failed_checks=$((failed_checks + 1))
    fi
}

# Core System Tools
print_header "${PACKAGE} Core System Tools"

validate_command "git" "Git" "--version"
check_result

# Programming Languages
print_header "${PACKAGE} Programming Languages"

print_subsection "Node.js & npm"
validate_command "node" "Node.js" "--version"
check_result
validate_command "npm" "npm" "--version"
check_result
validate_path "$HOME/.nvm" "NVM directory" "directory"
check_result

print_subsection "C++ Development"
validate_command "g++" "G++ Compiler" "--version"
check_result
validate_command "cmake" "CMake" "--version"
check_result

print_subsection "Rust Development"
validate_command "rustc" "Rust Compiler" "--version"
check_result
validate_command "cargo" "Cargo" "--version"
check_result
validate_path "$HOME/.cargo" "Cargo directory" "directory"
check_result

print_subsection "Go Development"
validate_command "go" "Go" "version"
check_result

# Container Tools
print_header "${TOOL} Container Tools"

validate_command "docker" "Docker" "--version"
check_result
validate_command "docker-compose" "Docker Compose" "--version"
check_result
validate_group "docker" "Docker"
check_result

# Shell & Terminal Tools
print_header "${TOOL} Shell & Terminal Tools"

print_subsection "Shell Configuration"
validate_command "zsh" "ZSH" "--version"
check_result
validate_shell "$(which zsh)" "ZSH"
check_result

print_subsection "Terminal Enhancement Tools"
validate_command "fortune" "Fortune" "--version"
check_result
validate_command "cowsay" "Cowsay" "--version"
check_result
validate_command "lolcrab" "Lolcrab" "--version"
check_result
validate_command "pfetch" "Pfetch" "--version"
check_result
validate_command "fzf" "FZF" "--version"
check_result
validate_command "eza" "Eza" "--version"
check_result
validate_command "zoxide" "Zoxide" "--version"
check_result
validate_command "bat" "Bat" "--version"
check_result
validate_command "delta" "Git Delta" "--version"
check_result
validate_command "tldr" "TLDR" "--version"
check_result
validate_command "thefuck" "TheFuck" "--version"
check_result
validate_command "rg" "Ripgrep" "--version"
check_result

# Text Editor
print_header "${TOOL} Text Editor"

validate_command "nvim" "Neovim" "--version"
check_result

# Configuration Files
print_header "${CONFIG} Configuration Files"

# Get the dotfiles directory (assuming script is run from dotfiles root)
DOTFILES_DIR="$(pwd)"

print_subsection "Git Configuration"
validate_symlink "$HOME/.gitconfig" "$DOTFILES_DIR/common/git/.gitconfig" "Git config"
check_result

print_subsection "Shell Configuration"
validate_symlink "$HOME/.zshrc" "$DOTFILES_DIR/common/zshell/.zshrc" "ZSH config"
check_result
validate_symlink "$HOME/.p10k.zsh" "$DOTFILES_DIR/common/zshell/.p10k.zsh" "Powerlevel10k config"
check_result

print_subsection "Neovim Configuration"
validate_path "$HOME/.config/nvim" "Neovim config directory" "directory"
check_result

print_subsection "Bat Configuration"
validate_path "$HOME/.config/bat/themes" "Bat themes directory" "directory"
check_result

# Summary
print_header "📊 Validation Summary"

echo -e "${BOLD}Total Checks:${NC} $total_checks"
echo -e "${GREEN}${BOLD}Passed:${NC} $passed_checks"
echo -e "${RED}${BOLD}Failed:${NC} $failed_checks"

if [ $failed_checks -eq 0 ]; then
    echo -e "\n${GREEN}${BOLD}🎉 All validations passed! Your dotfiles setup is complete.${NC}"
    exit 0
else
    echo -e "\n${YELLOW}${BOLD}⚠️  Some validations failed. Please check the above output for details.${NC}"
    exit 1
fi