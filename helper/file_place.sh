## Copy/symlink file to the destination

## Function to copy the file to location
copy_file() {
    local source_file="$1"
    local destination_file="$2"
    if [ -f "$source_file" ]; then
        cp "$source_file" "$destination_file"
        echo "Copied $source_file to $destination_file"
    else
        echo "Source file $source_file does not exist."
    fi
}

## Function to Symlink the file to location
symlink_file() {
    local source_file="$1"
    local destination_file="$2"
    if [ -f "$source_file" ]; then
        ln -sf "$source_file" "$destination_file"
        echo "Symlinked $source_file to $destination_file"
    else
        echo "Source file $source_file does not exist."
    fi
}

## Bashrc file
bashrc_source="$HOME/.dotfiles/bash/.bashrc"
bashrc_destination="$HOME/.bashrc"
if [ -f "$bashrc_source" ]; then
    symlink_file "$bashrc_source" "$bashrc_destination"
else
    echo "Bashrc source file $bashrc_source does not exist."
fi