## Install latest node.js version along with npm using nvm and validate the installation in ubuntu
#!/bin/bash

set -e
set -o pipefail

# Install nvm (Node Version Manager)
if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
else
    echo "nvm is already installed."
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
fi

# Install latest node.js version along with npm
nvm install node

# Validate the installation
if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
    echo "Node.js and npm have been installed successfully."
else
    echo "Failed to install Node.js and npm."
    exit 1
fi

# Display the installed versions
echo "Installed Node.js version: $(node -v)"
echo "Installed npm version: $(npm -v)"

# Clean up
## Remove the nvm installation script if it exists
if [ -f "$HOME/.nvm/install.sh" ]; then
    rm "$HOME/.nvm/install.sh"
fi
echo "Installation complete."
exit 0