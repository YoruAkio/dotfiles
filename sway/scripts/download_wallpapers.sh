#!/bin/bash

# Script to download initial wallpapers from Unsplash
# This is a helper script to populate the wallpaper directory

set -e

WALLPAPER_DIR="$HOME/.config/sway/walls"

# Create directory if it doesn't exist
mkdir -p "$WALLPAPER_DIR"

# Function to download a wallpaper with a given keyword and filename
download_wallpaper() {
    local keyword="$1"
    local filename="$2"
    local url="https://source.unsplash.com/1920x1080/?${keyword}"
    local target="${WALLPAPER_DIR}/${filename}.jpg"
    
    echo "Downloading wallpaper with keyword '${keyword}' to ${target}..."
    
    if command -v curl >/dev/null 2>&1; then
        curl -L "$url" -o "$target"
    elif command -v wget >/dev/null 2>&1; then
        wget "$url" -O "$target"
    else
        echo "Error: Neither curl nor wget is installed. Please install one of them."
        return 1
    fi
    
    echo "Downloaded $target"
}

# Main function
main() {
    echo "Downloading wallpapers to $WALLPAPER_DIR..."
    
    # Download some nice wallpapers with various themes
    download_wallpaper "nature,forest" "forest"
    download_wallpaper "mountain,landscape" "mountain"
    download_wallpaper "ocean,waves" "ocean"
    download_wallpaper "abstract,colorful" "abstract"
    download_wallpaper "minimal,design" "minimal"
    download_wallpaper "space,galaxy" "space"
    download_wallpaper "cityscape,night" "city"
    download_wallpaper "technology,dark" "tech"
    
    echo ""
    echo "Downloaded 8 wallpapers to $WALLPAPER_DIR"
    echo "Run your random_wall.sh script to apply one of them!"
}

# Run the main function
main 