# 🚀 Personal Dotfiles

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-ZSH-green.svg)](https://zsh.sourceforge.io/)
[![Platform](https://img.shields.io/badge/Platform-Ubuntu%20%7C%20Arch-blue.svg)](https://ubuntu.com/)
[![Neovim](https://img.shields.io/badge/Editor-Neovim-brightgreen.svg)](https://neovim.io/)
[![Validation](https://img.shields.io/badge/Validation-Automated-blue.svg)](https://github.com/AbhijithSwaminathan/.dotfiles)
[![Made with ❤️](https://img.shields.io/badge/Made%20with-❤️-red.svg)](https://github.com/AbhijithSwaminathan/.dotfiles)

> A comprehensive, battle-tested development environment setup with modern tools, enhanced shell experience, beautiful terminal aesthetics, and robust validation system.

## 📋 Overview

This repository contains a **modular, automated dotfiles setup** that transforms your development environment with carefully curated tools and configurations. Built with a focus on developer productivity, terminal aesthetics, seamless cross-language development support, and **comprehensive validation** to ensure everything works perfectly.

### 🎯 Key Features

- **🔧 Modular Installation**: Install specific components or everything at once with smart dependency handling
- **🎨 Beautiful Terminal**: Enhanced ZSH with Powerlevel10k, custom themes, and rich colors
- **⚡ Developer Productivity**: Modern CLI tools that supercharge your workflow with smart integrations
- **🌍 Multi-Language Support**: Pre-configured environments for Node.js, Rust, Go, C++, and Python
- **🔍 Smart Search**: Advanced FZF integration with enhanced previews, git integration, and inline commands
- **📝 Rich Text Editing**: Neovim with comprehensive plugin ecosystem and custom configurations
- **🐳 Container Ready**: Docker and container development tools with user group management
- **✅ Robust Validation**: Comprehensive validation system with shell context awareness and error tracking
- **🛡️ Error Recovery**: Advanced error handling with detailed logging and recovery mechanisms
- **🔄 Session Management**: Smart shell environment detection and proper configuration loading

---

## 🛠️ What Gets Installed

### 🐚 Shell & Terminal Experience

| Tool | Description | Links |
|------|-------------|--------|
| **ZSH** | Modern shell with advanced features | [📖 Official](https://zsh.sourceforge.io/) |
| **Powerlevel10k** | Beautiful and fast ZSH theme | [📖 GitHub](https://github.com/romkatv/powerlevel10k) |
| **Zinit** | Flexible ZSH plugin manager | [📖 GitHub](https://github.com/zdharma-continuum/zinit) |

### 🔍 Search & Navigation

| Tool | Description | Links |
|------|-------------|--------|
| **FZF** | Command-line fuzzy finder with enhanced previews | [📖 GitHub](https://github.com/junegunn/fzf) |
| **FZF-Git** | Git integration for FZF with advanced shortcuts | [📖 GitHub](https://github.com/junegunn/fzf-git.sh) |
| **fd** | Fast and user-friendly alternative to `find` | [📖 GitHub](https://github.com/sharkdp/fd) |
| **ripgrep** | Ultra-fast text search tool | [📖 GitHub](https://github.com/BurntSushi/ripgrep) |
| **zoxide** | Smart directory jumper that learns your habits | [📖 GitHub](https://github.com/ajeetdsouza/zoxide) |

### 📁 File Management & Viewing

| Tool | Description | Links |
|------|-------------|--------|
| **eza** | Modern replacement for `ls` with git integration | [📖 GitHub](https://github.com/eza-community/eza) |
| **bat** | Syntax-highlighted `cat` clone with git integration | [📖 GitHub](https://github.com/sharkdp/bat) |
| **delta** | Beautiful diff viewer with syntax highlighting | [📖 GitHub](https://github.com/dandavison/delta) |

### ✨ Terminal Enhancement

| Tool | Description | Links |
|------|-------------|--------|
| **pfetch** | Minimal system information display | [📖 GitHub](https://github.com/dylanaraps/pfetch) |
| **fortune** | Random quotes and sayings | [📖 Manual](https://linux.die.net/man/6/fortune) |
| **cowsay** | ASCII art speech bubbles | [📖 GitHub](https://github.com/piuccio/cowsay) |
| **lolcrab** | Colorful text display similar to lolcat | [📖 Crates.io](https://crates.io/crates/lolcrab) |
| **thefuck** | Corrects your previous console command | [📖 GitHub](https://github.com/nvbn/thefuck) |

### 📝 Development Tools

| Tool | Description | Links |
|------|-------------|--------|
| **Neovim** | Hyperextensible Vim-based text editor | [📖 Official](https://neovim.io/) |
| **tldr** | Simplified man pages with practical examples | [📖 GitHub](https://github.com/tldr-pages/tldr) |

### 🌐 Development Environments

#### 🟢 Node.js Ecosystem
| Tool | Description | Links |
|------|-------------|--------|
| **Node.js** | JavaScript runtime built on Chrome's V8 engine | [📖 Official](https://nodejs.org/) |
| **NPM** | Node.js package manager | [📖 Official](https://npmjs.com/) |
| **NVM** | Node Version Manager for easy version switching | [📖 GitHub](https://github.com/nvm-sh/nvm) |

#### 🦀 Rust Ecosystem
| Tool | Description | Links |
|------|-------------|--------|
| **Rust** | Systems programming language focused on safety | [📖 Official](https://rust-lang.org/) |
| **Cargo** | Rust's package manager and build system | [📖 Official](https://doc.rust-lang.org/cargo/) |

#### 🐹 Go Ecosystem
| Tool | Description | Links |
|------|-------------|--------|
| **Go** | Open source programming language by Google | [📖 Official](https://golang.org/) |
| **Go Tools** | Complete Go development toolchain | [📖 Documentation](https://pkg.go.dev/) |

#### ⚙️ C++ Development
| Tool | Description | Links |
|------|-------------|--------|
| **GCC/G++** | GNU Compiler Collection for C++ | [📖 Official](https://gcc.gnu.org/) |
| **Build Essential** | Essential packages for compiling software | [📖 Ubuntu](https://packages.ubuntu.com/build-essential) |
| **CMake** | Cross-platform build system generator | [📖 Official](https://cmake.org/) |
| **Ninja** | Small build system with focus on speed | [📖 GitHub](https://github.com/ninja-build/ninja) |

#### 🐍 Python Environment
| Tool | Description | Links |
|------|-------------|--------|
| **Python 3.11** | Latest Python interpreter | [📖 Official](https://python.org/) |
| **pipx** | Install and run Python applications in isolated environments | [📖 GitHub](https://github.com/pypa/pipx) |

### 🐳 Container & DevOps

| Tool | Description | Links |
|------|-------------|--------|
| **Docker** | Containerization platform | [📖 Official](https://docker.com/) |
| **Docker Compose** | Multi-container Docker application orchestration | [📖 Official](https://docs.docker.com/compose/) |

### 🔗 Networking & Collaboration

| Tool | Description | Links |
|------|-------------|--------|
| **GitHub CLI** | Official GitHub command line tool | [📖 Official](https://cli.github.com/) |
| **Tailscale** | Secure network connectivity solution | [📖 Official](https://tailscale.com/) |

---

## 🚀 Quick Start

### 📥 Installation

```bash
# Clone the repository
git clone https://github.com/AbhijithSwaminathan/.dotfiles.git ~/.dotfiles

# Navigate to dotfiles directory
cd ~/.dotfiles

# Make installation script executable
chmod +x install.sh

# Run the installation
./install.sh
```

### 🎯 Selective Installation

Install specific components:

```bash
# Install only shell enhancements
cd ~/.dotfiles/distros/ubuntu/shell
./install_shell_cosmetics.sh

# Install Node.js environment
cd ~/.dotfiles/distros/ubuntu/node
./install_node.sh

# Install Rust environment
cd ~/.dotfiles/distros/ubuntu/rust
./install_rust.sh

# Install Go environment
cd ~/.dotfiles/distros/ubuntu/golang
./install_go.sh

# Install C++ development tools
cd ~/.dotfiles/distros/ubuntu/cpp
./install_cpp.sh

# Install Docker
cd ~/.dotfiles/distros/ubuntu/docker
./install_docker.sh
```

### ✅ Validation & Verification

After installation, run the comprehensive validation:

```bash
# Validate entire installation
cd ~/.dotfiles/distros/ubuntu
./validate.sh

# Run standalone validation script (from anywhere)
~/.dotfiles/validate ubuntu

# Or let it auto-detect your distribution
~/.dotfiles/validate
```

The validation system checks:
- ✅ **Command availability** in new shell sessions
- ✅ **Configuration file symlinks** and integrity  
- ✅ **Environment variables** and PATH settings
- ✅ **Shell context compatibility** (ZSH/Bash)
- ✅ **Package installations** and versions
- ✅ **Development environment** setups
- ✅ **Container tools** and user permissions
- ✅ **Git configuration** and aliases
- ✅ **Terminal enhancement tools** functionality

### 🔧 Standalone Validation Runner

A convenient standalone validation script is available:

```bash
# Show usage and available distributions
~/.dotfiles/validate --help

# Validate specific distribution
~/.dotfiles/validate ubuntu
~/.dotfiles/validate arch

# Auto-detect and validate current system
~/.dotfiles/validate
```

---

## 📁 Repository Structure

```
.dotfiles/
├── 📁 common/                  # Shared configurations
│   ├── 📁 git/                 # Git configuration
│   ├── 📁 nvim/                # Neovim configuration
│   ├── 📁 themes/              # Color themes
│   └── 📁 zshell/              # ZSH configurations
│       ├── .zshrc              # Main ZSH config
│       ├── .p10k.zsh           # Powerlevel10k config
│       └── fzf-config.zsh      # FZF enhancements
├── 📁 distros/                 # Distribution-specific scripts
│   ├── 📁 ubuntu/              # Ubuntu-specific installations
│   │   ├── install_script.sh   # Main Ubuntu installer
│   │   ├── validate.sh         # Validation script
│   │   ├── 📁 shell/           # Shell enhancement installer
│   │   ├── 📁 node/            # Node.js installer
│   │   ├── 📁 rust/            # Rust installer
│   │   ├── 📁 golang/          # Go installer
│   │   ├── 📁 cpp/             # C++ tools installer
│   │   └── 📁 docker/          # Docker installer
│   └── 📁 arch/                # Arch Linux support (coming soon)
├── 📁 lib/                     # Shared library functions
│   ├── common.sh               # Common utilities and formatting
│   └── validation.sh           # Advanced validation functions
├── validate                    # Standalone validation runner script
└── install.sh                  # Main installation entry point
```

---

## 🎨 Key Features & Enhancements

### 🌈 Enhanced Terminal Experience

- **Rich Colors**: Custom color schemes optimized for readability and aesthetics
- **Smart Completion**: Intelligent tab completion with live previews and context awareness
- **Git Integration**: Visual git status, branch previews, and enhanced diff visualization
- **File Previews**: Syntax-highlighted file content with directory statistics in terminal
- **Directory Navigation**: Enhanced with tree views, file counts, and smart bookmarking

### ⚡ Developer Productivity Boosters

- **Fuzzy Search Everything**: Files, directories, git branches, command history with enhanced previews
- **Smart Aliases**: Frequently used commands with intelligent shortcuts and parameter completion
- **Session Management**: Auto-restore terminal sessions and development environments
- **Error Correction**: Automatic command correction with thefuck integration
- **Quick Navigation**: Jump to frequently used directories instantly with zoxide
- **Inline Commands**: FZF configurations with inline command execution for better performance
- **Multi-Shell Support**: Proper ZSH/Bash context handling and configuration loading

### 🔧 Advanced Architecture & Reliability

- **DRY Principle**: Shared library system eliminates code duplication across scripts
- **Independent Components**: Install only what you need with smart dependency resolution
- **Cross-Platform Ready**: Support for multiple Linux distributions with extensible design
- **Comprehensive Validation**: Multi-level validation system with shell context awareness
- **Robust Error Handling**: Advanced error tracking, logging, and recovery mechanisms
- **Session-Aware Validation**: Tests commands in both current and new shell sessions
- **Environment Detection**: Smart detection of shell types and proper configuration sourcing

### 🛡️ Validation & Quality Assurance

- **Shell Context Awareness**: Prevents ZSH configuration loading in Bash environments
- **Multi-Session Testing**: Validates tools in both current session and fresh environments  
- **Error Tracking**: Comprehensive error logging with detailed failure analysis
- **Command Argument Handling**: Special validation for tools requiring specific arguments
- **Environment Variable Validation**: Ensures all PATH and environment settings are correct
- **Symlink Integrity**: Validates configuration file symlinks and target existence
- **User Permission Checks**: Validates Docker group membership and other access requirements

---

## 🛡️ System Requirements

### 🐧 Supported Platforms

- **Ubuntu 20.04+** ✅ (Fully tested)
- **Ubuntu 22.04+** ✅ (Fully tested)  
- **Arch Linux** 🚧 (Coming soon)

### 📋 Prerequisites

- **Git** - For cloning and managing the repository
- **Curl/Wget** - For downloading packages and tools  
- **Sudo access** - Required for system package installation
- **Internet connection** - For downloading tools and dependencies
- **Bash/ZSH** - Compatible shell environment (ZSH recommended)

### 🔍 Validation Requirements

The validation system requires:
- **Command availability** in new shell sessions
- **Proper shell context** (prevents ZSH config loading in Bash)
- **Environment variable** access and PATH configuration
- **File system permissions** for symlink creation and validation

---

## 🐛 Troubleshooting

### Common Issues & Solutions

#### ❌ Validation Failures
```bash
# If validation reports errors, check the detailed log
cat ~/.dotfiles/distros/ubuntu/validation.log

# Re-run specific component installation
cd ~/.dotfiles/distros/ubuntu/shell
./install_shell_cosmetics.sh

# Validate again
~/.dotfiles/validate
```

#### 🔧 Shell Context Issues
```bash
# If ZSH configurations aren't loading properly
source ~/.zshrc

# Check environment variables
echo $SHELL
echo $PATH
```

#### 🐳 Docker Permission Issues
```bash
# Add user to docker group if validation fails
sudo usermod -aG docker $USER
newgrp docker

# Validate docker access
docker run hello-world
```

#### 🔍 FZF Integration Problems
```bash
# Reload FZF configuration
source ~/.config/fzf-config.zsh

# Test FZF functionality
fzf --version
```

---

## 🏗️ Architecture & Design

### 📚 Shared Library System

The dotfiles use a **DRY (Don't Repeat Yourself)** approach with shared libraries:

- **`lib/common.sh`**: Formatting, logging, error handling, and utility functions
- **`lib/validation.sh`**: Comprehensive validation functions with shell context awareness
- **Modular Scripts**: Each installation component is self-contained yet uses shared functionality

### 🔄 Shell Context Management

Advanced shell environment handling:
- **Auto-detection**: Automatically detects whether running in Bash or ZSH
- **Context Prevention**: Prevents ZSH configurations from loading in Bash environments
- **Multi-Session Testing**: Validates tools in both current and fresh shell sessions
- **Environment Sourcing**: Properly sources shell configurations for accurate testing

### 📊 Validation Architecture

Multi-layered validation system:
1. **Command Validation**: Tests tool availability in multiple contexts
2. **Path Validation**: Verifies file/directory existence and permissions
3. **Symlink Validation**: Ensures configuration symlinks point to correct targets
4. **Environment Validation**: Checks PATH and environment variable settings
5. **Integration Validation**: Tests tool integrations and functionality
6. **Session Validation**: Validates in both current and new shell sessions

---

## 🤝 Contributing

Contributions are welcome! Whether it's bug fixes, new features, or additional platform support:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **ZSH Community** for the amazing shell experience and plugin ecosystem
- **Neovim Team** for the exceptional editor and extensible architecture
- **FZF Contributors** for the incredible fuzzy finder that transforms terminal workflow
- **Rust Community** for creating blazingly fast CLI tools (fd, ripgrep, bat, eza, etc.)
- **Open Source Contributors** who created the incredible tools integrated in this setup
- **Terminal Enthusiasts** who inspired beautiful, productive terminal configurations
- **DevOps Community** for containerization tools and modern development practices

---

<div align="center">

**Made with ❤️ for developers who love beautiful, productive, and reliable terminals**

*Featuring advanced validation, shell context awareness, and battle-tested configurations*

[⭐ Star this repo](https://github.com/AbhijithSwaminathan/.dotfiles) if you found it helpful!

</div>