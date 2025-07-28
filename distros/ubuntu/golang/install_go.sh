## install latest golang version and validate the installation in ubuntu
#!/bin/bash
set -e
set -o pipefail

# Install Go using the official tarball
if ! command -v go >/dev/null 2>&1; then
    echo "Installing Go..."
    wget https://go.dev/dl/go1.20.5.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.20.5.linux-amd64.tar.gz
    rm go1.20.5.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
else
    echo "Go is already installed."
    export PATH=$PATH:/usr/local/go/bin
fi

# Validate the installation
if command -v go >/dev/null 2>&1; then
    echo "Go has been installed successfully."
else
    echo "Failed to install Go."
    exit 1
fi

# Display the installed version
echo "Installed Go version: $(go version | head -n 1)"

# Clean up
## Remove the tarball if it exists
if [ -f go1.20.5.linux-amd64.tar.gz ]; then
    rm go1.20.5.linux-amd64.tar.gz
fi
echo "Installation complete."
exit 0