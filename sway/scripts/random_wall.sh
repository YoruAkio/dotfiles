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
    [[ "$1" == "--reload-only" ]]
}

# Get random position on screen for wallpaper transition
get_random_screen_position() {
    # Get screen resolution
    local screen_width=$(swaymsg -t get_outputs | jq -r '.[0].current_mode.width // 1920')
    local screen_height=$(swaymsg -t get_outputs | jq -r '.[0].current_mode.height // 1080')
    
    # Set margins (10% from edges)
    local margin_x=$((screen_width / 10))
    local margin_y=$((screen_height / 10))
    
    # Calculate bounds
    local min_x=$margin_x
    local max_x=$((screen_width - margin_x))
    local min_y=$margin_y
    local max_y=$((screen_height - margin_y))
    
    # Generate random coordinates
    local random_x=$((RANDOM % (max_x - min_x + 1) + min_x))
    local random_y=$((RANDOM % (max_y - min_y + 1) + min_y))
    
    echo "${random_x},${random_y}"
}

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    for cmd in swww python3 waybar jq; do
        command -v "$cmd" >/dev/null 2>&1 || missing_deps+=("$cmd")
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log "ERROR: Missing dependencies: ${missing_deps[*]}"
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
    
    # If reload only and current wallpaper exists, use it
    if [[ "$reload_only" == "true" ]] && [[ -f "$CURRENT_WALLPAPER_FILE" ]]; then
        local current_wallpaper=$(cat "$CURRENT_WALLPAPER_FILE")
        if [[ -f "$current_wallpaper" ]]; then
            log "Using existing wallpaper: $current_wallpaper"
            return 0
        fi
        log "Saved wallpaper not found, selecting new one"
    fi
    
    # Select a new wallpaper and generate color themes
    local wallpaper=$(python3 "$WALLPAPER_SCRIPT")
    if [[ $? -ne 0 || -z "$wallpaper" ]]; then
        log "Error selecting wallpaper. Using fallback."
        wallpaper="/usr/share/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png"
    fi
    
    # Save the current wallpaper path
    echo "$wallpaper" > "$CURRENT_WALLPAPER_FILE"
    log "Selected wallpaper: $wallpaper"
    
    # Wait for color configuration files
    for i in {1..10}; do
        if [[ -f "$SWAY_COLOR_CONFIG" && -f "$WAYBAR_COLOR_CONFIG" ]]; then
            log "Color configurations generated"
            break
        fi
        [[ $i -eq 10 ]] && log "WARNING: Timeout waiting for color files"
        sleep 0.2
    done
}

# Set the wallpaper
set_wallpaper() {
    local wallpaper=$(cat "$CURRENT_WALLPAPER_FILE")
    local random_pos=$(get_random_screen_position)
    
    log "Setting wallpaper: $wallpaper"
    
    # Set the wallpaper using swww with smooth transition
    swww img "$wallpaper" \
        --transition-bezier .43,1.19,1,.4 \
        --transition-type grow \
        --transition-duration 1 \
        --transition-fps 60 \
        --transition-pos "$random_pos"
}

# Reload configurations
reload_configs() {
    log "Reloading configurations..."
    
    # Reload sway
    swaymsg reload
    
    # Reload kitty if running
    pkill -SIGUSR1 kitty 2>/dev/null || true
    
    # Restart dunst
    pkill -f dunst 2>/dev/null || true
    sleep 0.5
    dunst &
}

# Main function
main() {
    local reload_only=false
    is_reload_only "$1" && reload_only=true
    
    log "$([ "$reload_only" = true ] && echo "Reloading configuration only" || echo "Changing wallpaper and theme")"
    
    check_dependencies
    get_wallpaper "$reload_only"
    set_wallpaper
    
    # Give time for wallpaper to apply
    sleep 1
    
    reload_configs
    log "Theme application complete!"
}

# Run the main function with any passed arguments
main "$@"