## Installation Script
#!/bin/bash

# This script sets up the environment by copying or symlinking configuration files.
# It is intended to be run from the home directory of the user.
# Ensure the script is run from the home directory
if [ "$PWD" != "$HOME" ]; then
    echo "Please run this script from your home directory."
    exit 1
fi

# Check if the .dotfiles directory exists
if [ ! -d "$HOME/.dotfiles" ]; then
    echo "The .dotfiles directory does not exist. Please clone the repository first."
    exit 1
fi

# Source the helper functions
source "$HOME/.dotfiles/helper/file_place.sh"


# Run the file placement script
bash "$HOME/.dotfiles/helper/file_place.sh"
