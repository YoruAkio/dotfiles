#!/bin/bash

# Exit on error
set -e

# Define paths
SWAY_CONFIG_DIR="$HOME/.config/sway"
WALLPAPER_SCRIPT="$SWAY_CONFIG_DIR/scripts/get_wallpaper_color.py"
SWAY_COLOR_CONFIG="$SWAY_CONFIG_DIR/generated_colors.conf"
WAYBAR_COLOR_CONFIG="$HOME/.config/waybar/colors.css"
CURRENT_WALLPAPER_FILE="$SWAY_CONFIG_DIR/walls/.current"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Check if this is a configuration reload or new wallpaper request
is_reload_only() {
    if [[ "$1" == "--reload-only" ]]; then
        return 0
    fi
    return 1
}

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    for cmd in swaybg python3 waybar; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log "ERROR: Missing dependencies: ${missing_deps[*]}"
        log "Please install with 'sudo pacman -S ${missing_deps[*]}'"
        exit 1
    fi
    
    # Check if Python has PIL installed
    if ! python3 -c "import PIL" >/dev/null 2>&1; then
        log "ERROR: Python PIL module not found. Install with 'pip install pillow'"
        exit 1
    fi
}

# Get the current wallpaper or select a new random one
get_wallpaper() {
    local reload_only=$1
    local wallpaper=""
    
    # If reload only and current wallpaper exists, use it
    if [[ "$reload_only" == "true" ]] && [[ -f "$CURRENT_WALLPAPER_FILE" ]]; then
        wallpaper=$(cat "$CURRENT_WALLPAPER_FILE")
        if [[ -f "$wallpaper" ]]; then
            log "Using existing wallpaper: $wallpaper"
            return 0
        else
            log "Saved wallpaper not found, selecting new one"
        fi
    fi
    
    # Run the Python script to select a random wallpaper and generate color themes
    wallpaper=$(python3 "$WALLPAPER_SCRIPT")
    if [ $? -ne 0 ] || [ -z "$wallpaper" ]; then
        log "Error selecting wallpaper. Using fallback wallpaper."
        # Use a fallback image if the Python script fails
        wallpaper="/usr/share/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png"
    fi
    
    # Save the current wallpaper path
    echo "$wallpaper" > "$CURRENT_WALLPAPER_FILE"
    log "Saved current wallpaper path to $CURRENT_WALLPAPER_FILE"
    
    WALLPAPER=$wallpaper
    
    # Wait for color configuration files to be written
    for i in {1..10}; do
        if [[ -f "$SWAY_COLOR_CONFIG" && -f "$WAYBAR_COLOR_CONFIG" ]]; then
            log "Color configurations generated successfully"
            break
        fi
        if [[ $i -eq 10 ]]; then
            log "WARNING: Timeout waiting for color configuration files"
        fi
        sleep 0.2
    done
    
    return 0
}

# Set the wallpaper
set_wallpaper() {
    WALLPAPER=$(cat "$CURRENT_WALLPAPER_FILE")
    log "Setting wallpaper: $WALLPAPER"
    
    # Kill any existing swaybg instances
    pkill -f swaybg || true
    
    # Set the wallpaper using swaybg directly (more reliable than swaymsg)
    swaybg -i "$WALLPAPER" -m fill &
    
    # Also set it via swaymsg for compatibility
    swaymsg output '*' bg "$WALLPAPER" fill
    
    log "Wallpaper set successfully"
}

# Reload sway config
reload_sway() {
    log "Reloading sway config..."
    swaymsg reload

    # Reload kitty configuration
    pkill -SIGUSR1 kitty || true
    
    # Restart dunst to apply new colors
    pkill -f dunst || true
    sleep 0.5
    dunst &
    
    log "Reloaded sway config and restarted dunst"
}

# Main function
main() {
    local reload_only=false
    
    # Check if this is a reload-only request
    if is_reload_only "$1"; then
        reload_only=true
        log "Configuration reload only, keeping current wallpaper"
    else
        log "Starting wallpaper and theme generation..."
    fi
    
    # Check dependencies
    check_dependencies
    
    # Get the wallpaper (new or existing)
    get_wallpaper "$reload_only"
    
    # Set the wallpaper
    set_wallpaper
    
    # Reload sway config
    reload_sway
    
    log "Theme application complete!"
}

# Run the main function with any passed arguments
main "$@"