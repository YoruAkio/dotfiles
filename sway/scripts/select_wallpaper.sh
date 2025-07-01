#!/bin/bash

# Script to manually select a wallpaper using swww with wofi launcher on Sway
set -e

# Define paths
SWAY_CONFIG_DIR="$HOME/.config/sway"
WALLS_DIR="$SWAY_CONFIG_DIR/walls"
WALLPAPER_SCRIPT="$SWAY_CONFIG_DIR/scripts/get_wallpaper_color.py"
CURRENT_WALLPAPER_FILE="$WALLS_DIR/.current"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SELECT: $1"
}

# Get random position on screen for wallpaper transition
get_random_position() {
    # Get screen resolution with fallback values
    local width=$(swaymsg -t get_outputs | jq -r '.[0].current_mode.width // 1920')
    local height=$(swaymsg -t get_outputs | jq -r '.[0].current_mode.height // 1080')
    
    # Use 10% margin from edges
    local margin_x=$((width / 10))
    local margin_y=$((height / 10))
    
    # Generate random coordinates
    local x=$((RANDOM % (width - 2*margin_x) + margin_x))
    local y=$((RANDOM % (height - 2*margin_y) + margin_y))
    
    echo "$x,$y"
}

# Function to select a wallpaper using wofi
select_wallpaper() {
    # Check if wofi is installed
    if ! command -v wofi >/dev/null 2>&1; then
        log "ERROR: wofi is not installed. Please install it with 'sudo pacman -S wofi'"
        return 1
    fi
    
    # Check if wallpapers exist
    shopt -s nullglob
    local wallpapers=("$WALLS_DIR"/*.{jpg,jpeg,png})
    shopt -u nullglob
    
    if [[ ${#wallpapers[@]} -eq 0 ]]; then
        log "No wallpapers found in $WALLS_DIR"
        log "Run sway/scripts/download_wallpapers.sh to download some wallpapers"
        return 1
    fi
    
    # Get screen dimensions
    local screen_width=$(swaymsg -t get_outputs | jq -r '.[0].current_mode.width // 1920')
    local screen_height=$(swaymsg -t get_outputs | jq -r '.[0].current_mode.height // 1080')
    
    # Set wofi dimensions (30% width, 50% height, with minimums)
    local wofi_width=$(( screen_width * 30 / 100 ))
    local wofi_height=$(( screen_height * 50 / 100 ))
    [[ $wofi_width -lt 600 ]] && wofi_width=600
    [[ $wofi_height -lt 400 ]] && wofi_height=400
    
    # Create formatted entries with image previews
    local entries=()
    for file in "${wallpapers[@]}"; do
        local filename=$(basename "$file")
        entries+=("img:$file:text:$filename")
    done
    
    # Select wallpaper with wofi
    local selected=$(printf "%s\n" "${entries[@]}" | wofi \
        --allow-images \
        --dmenu \
        --prompt="Select wallpaper:" \
        --width=$wofi_width \
        --height=$wofi_height)
    
    [[ -z "$selected" ]] && return 1
    
    # Extract the filename from the selected entry
    local wallpaper_name=$(echo "$selected" | sed -E 's/img:.*:text:(.*)/\1/')
    echo "$WALLS_DIR/$wallpaper_name"
}

# Function to set wallpaper and apply theme
set_wallpaper() {
    local wallpaper="$1"
    
    # Validate wallpaper
    if [[ ! -f "$wallpaper" ]]; then
        log "ERROR: Wallpaper $wallpaper does not exist"
        return 1
    fi
    
    log "Setting wallpaper: $wallpaper"
    
    # Save current wallpaper path
    echo "$wallpaper" > "$CURRENT_WALLPAPER_FILE"
    
    # Generate colors from wallpaper
    python3 "$WALLPAPER_SCRIPT" "$wallpaper"
    
    # Restart services for theme changes
    pkill -f waybar || true
    pkill -f dunst || true
    pkill -SIGUSR1 kitty || true
    
    # Apply wallpaper with transition
    local position=$(get_random_position)
    swww img "$wallpaper" \
        --transition-bezier .43,1.19,1,.4 \
        --transition-type grow \
        --transition-duration 1 \
        --transition-fps 60 \
        --transition-pos "$position"

    # Allow transition to complete
    sleep 1.2
    
    # Reload sway and restart services
    log "Reloading sway configuration..."
    swaymsg reload
    
    sleep 0.5
    dunst &
    
    log "Wallpaper and theme applied successfully!"
}

# Main execution
main() {
    log "Starting wallpaper selection..."
    
    local wallpaper=$(select_wallpaper)
    if [[ -n "$wallpaper" ]]; then
        set_wallpaper "$wallpaper"
    else
        log "No wallpaper selected, exiting"
        exit 1
    fi
}

# Run the script
main