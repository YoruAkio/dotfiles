#!/bin/bash

# Script to manually select a wallpaper 
# This uses the wofi launcher on Sway

set -e

# Define paths
SWAY_CONFIG_DIR="$HOME/.config/sway"
WALLS_DIR="$SWAY_CONFIG_DIR/walls"
WALLPAPER_SCRIPT="$SWAY_CONFIG_DIR/scripts/get_wallpaper_color.py"
CURRENT_WALLPAPER_FILE="$WALLS_DIR/.current"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to select a wallpaper using wofi
select_wallpaper() {
    # Check if wofi is installed
    if ! command -v wofi >/dev/null 2>&1; then
        log "ERROR: wofi is not installed. Please install it with 'sudo pacman -S wofi'"
        return 1
    fi
    
    # Create a list of available wallpapers
    local wallpapers=()
    for file in "$WALLS_DIR"/*.{jpg,jpeg,png}; do
        # Skip if no files match the pattern
        [[ -f "$file" ]] || continue
        wallpapers+=("$(basename "$file")")
    done
    
    # If no wallpapers found
    if [[ ${#wallpapers[@]} -eq 0 ]]; then
        log "No wallpapers found in $WALLS_DIR"
        log "Run sway/scripts/download_wallpapers.sh to download some wallpapers"
        return 1
    fi
    
    # Get screen dimensions
    local screen_width=$(swaymsg -t get_outputs | jq -r '.[0].current_mode.width')
    local screen_height=$(swaymsg -t get_outputs | jq -r '.[0].current_mode.height')
    
    # Set wofi window dimensions (30% of screen size)
    local wofi_width=$(( screen_width * 30 / 100 ))
    local wofi_height=$(( screen_height * 50 / 100 ))
    
    # Ensure minimum dimensions
    if [ "$wofi_width" -lt 600 ]; then wofi_width=600; fi
    if [ "$wofi_height" -lt 400 ]; then wofi_height=400; fi
    
    # Calculate center position
    local x_pos=$(( (screen_width - wofi_width) / 2 ))
    local y_pos=$(( (screen_height - wofi_height) / 2 ))
    
    # Use wofi to select a wallpaper with calculated center position and image preview
    selected=$(printf "%s\n" "${wallpapers[@]}" | wofi \
        --allow-images \
        --dmenu \
        --prompt="Select wallpaper:" \
        --width=$wofi_width \
        --height=$wofi_height)
    
    # Check if a wallpaper was selected
    if [[ -z "$selected" ]]; then
        log "No wallpaper selected, exiting"
        return 1
    fi
    
    # Return the full path to the selected wallpaper
    echo "$WALLS_DIR/$selected"
}

# Function to set a specific wallpaper and generate colors
set_wallpaper() {
    local wallpaper="$1"
    
    # Check if the wallpaper exists
    if [[ ! -f "$wallpaper" ]]; then
        log "ERROR: Wallpaper $wallpaper does not exist"
        return 1
    fi
    
    log "Setting wallpaper: $wallpaper"
    
    # Save the current wallpaper path
    echo "$wallpaper" > "$CURRENT_WALLPAPER_FILE"
    log "Saved current wallpaper path to $CURRENT_WALLPAPER_FILE"
    
    # Generate colors from wallpaper
    python3 "$WALLPAPER_SCRIPT" "$wallpaper"
    
    # Kill any existing swaybg instances
    pkill -f swaybg || true

    # Kill any existing waybar instances
    pkill -f waybar || true
    
    # Set the wallpaper using swaybg directly (more reliable than swaymsg)
    swaybg -i "$wallpaper" -m fill &
    
    # Also set it via swaymsg for compatibility
    swaymsg output '*' bg "$wallpaper" fill

    # Reload sway config
    log "Reloading sway config..."
    swaymsg reload
    
    log "Wallpaper and theme applied successfully!"
}

# Main function
main() {
    log "Starting manual wallpaper selection..."
    
    # Select a wallpaper
    wallpaper=$(select_wallpaper)
    
    # Check if a wallpaper was selected
    if [[ -n "$wallpaper" ]]; then
        # Set the wallpaper and generate colors
        set_wallpaper "$wallpaper"
    else
        log "No wallpaper selected, exiting"
        exit 1
    fi
}

# Run the main function
main