## Install rust and cargo and validation the installation in ubuntu
#!/bin/bash
set -e
set -o pipefail

# Install Rust using rustup
if ! command -v rustup >/dev/null 2>&1; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    export PATH="$HOME/.cargo/bin:$PATH"
else
    echo "Rust is already installed."
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Validate the installation
if command -v rustc >/dev/null 2>&1 && command -v cargo >/dev/null 2>&1; then
    echo "Rust and Cargo have been installed successfully."
else
    echo "Failed to install Rust and Cargo."
    exit 1
fi

# Display the installed versions
echo "Installed Rust version: $(rustc --version | head -n 1)"
echo "Installed Cargo version: $(cargo --version | head -n 1)"

# Clean up
## remove the rustup installation script if it exists
if [ -f "$HOME/.cargo/bin/rustup" ]; then
    rm "$HOME/.cargo/bin/rustup"
fi
echo "Installation complete."
exit 0