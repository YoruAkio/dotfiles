#!/bin/bash

# Script to set wallpaper on Sway startup
# This reads the wallpaper path from .current and applies it

set -e

# Define paths
SWAY_CONFIG_DIR="$HOME/.config/sway"
WALLS_DIR="$SWAY_CONFIG_DIR/walls"
CURRENT_WALL_FILE="$WALLS_DIR/.current"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Check if the current wallpaper file exists
if [[ ! -f "$CURRENT_WALL_FILE" ]]; then
    log "ERROR: No current wallpaper file found at $CURRENT_WALL_FILE"
    exit 1
fi

# Read the wallpaper path from .current file
WALLPAPER=$(cat "$CURRENT_WALL_FILE")

# Check if the wallpaper exists
if [[ ! -f "$WALLPAPER" ]]; then
    log "ERROR: Wallpaper does not exist: $WALLPAPER"
    exit 1
fi

log "Setting wallpaper: $WALLPAPER"

# Kill any existing swaybg instances to avoid duplicates
pkill -f swaybg || true

# Set the wallpaper using swaybg (more reliable method)
swaybg -i "$WALLPAPER" -m fill &

# Also set it via swaymsg for compatibility
swaymsg output '*' bg "$WALLPAPER" fill

log "Wallpaper set successfully!"