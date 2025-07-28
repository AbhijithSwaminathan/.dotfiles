# Install docker and docker compose and configure it in ubuntu
#!/bin/bash
set -e
set -o pipefail

# Install Docker
if ! command -v docker >/dev/null 2>&1; then
    echo "Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
else
    echo "Docker is already installed."
fi 

# Add the current user to the docker group to run docker commands without sudo
if ! groups $USER | grep -q '\bdocker\b'; then
    echo "Adding user $USER to the docker group..."
    sudo usermod -aG docker $USER
    echo "Please log out and log back in to apply the group changes."
else
    echo "User $USER is already in the docker group."
fi

# Validate the installation
if command -v docker >/dev/null 2>&1; then
    echo "Docker has been installed successfully."
else
    echo "Failed to install Docker."
    exit 1
fi
# Display the installed version
echo "Installed Docker version: $(docker --version | head -n 1)"


# Install Docker Compose
if ! command -v docker-compose >/dev/null 2>&1; then
    echo "Installing Docker Compose..."
    sudo apt-get install -y docker-compose
else
    echo "Docker Compose is already installed."
fi

# Validate the installation
if command -v docker-compose >/dev/null 2>&1; then
    echo "Docker Compose has been installed successfully."
else
    echo "Failed to install Docker Compose."
    exit 1
fi  

# Display the installed version
echo "Installed Docker Compose version: $(docker-compose --version | head -n 1)"

# Clean up
echo "Installation complete."
exit 0