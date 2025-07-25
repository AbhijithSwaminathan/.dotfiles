## Install Node 

## Install Node Version Manager (NVM)
if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing Node Version Manager (NVM)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    echo "NVM installed successfully."
else
    echo "NVM is already installed."
fi

# Check if NVM is installed
if command -v nvm &> /dev/null; then
    echo "NVM is installed. Loading NVM..."
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm
else
    echo "NVM is not installed. Please install NVM to manage Node.js versions."
    exit 1
fi

# Install the latest Node.js version using NVM
if nvm ls | grep -q "v$(nvm version-remote)"; then
    echo "Latest Node.js version is already installed."
else
    echo "Installing the latest Node.js version..."
    nvm install node
    echo "Node.js installed successfully."
fi

# Verify Node.js installation
if command -v node &> /dev/null; then
    echo "Node.js version: $(node -v)"
else
    echo "Node.js installation failed. Please check the installation process."
    exit 1
fi

# Verify NPM installation
if command -v npm &> /dev/null; then
    echo "NPM version: $(npm -v)"
else
    echo "NPM installation failed. Please check the installation process."
    exit 1
fi