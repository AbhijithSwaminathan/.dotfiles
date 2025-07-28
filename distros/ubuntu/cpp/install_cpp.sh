## Install cpp 20 version using a package manager and validate the installation and install cmake in ubuntu
#!/bin/bash
set -e
set -o pipefail

# Install C++ 20 version using a package manager
if ! command -v g++ >/dev/null 2>&1; then
    echo "Installing g++..."
    sudo apt-get update
    sudo apt-get install -y g++-11
else
    echo "g++ is already installed."
fi

# Validate the installation
if command -v g++ >/dev/null 2>&1; then
    echo "g++ has been installed successfully."
else
    echo "Failed to install g++."
    exit 1
fi

# Install CMake
if ! command -v cmake >/dev/null 2>&1; then
    echo "Installing CMake..."
    sudo apt-get install -y cmake
else
    echo "CMake is already installed."
fi

# Validate the installation
if command -v cmake >/dev/null 2>&1; then
    echo "CMake has been installed successfully."
else
    echo "Failed to install CMake."
    exit 1
fi

# Display the installed versions
echo "Installed g++ version: $(g++ --version | head -n 1)"
echo "Installed CMake version: $(cmake --version | head -n 1)"

# Clean up
echo "Installation complete."
exit 0