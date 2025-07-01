#!/bin/bash

# Sway Wallpaper Startup Script - Sets wallpaper using swww
set -euo pipefail

# Configuration
WALLS_DIR="$HOME/.config/sway/walls"
CURRENT_WALL_FILE="$WALLS_DIR/.current"
SUPPORTED_EXTENSIONS=("jpg" "jpeg" "png" "webp" "gif")

# Transition settings
TRANSITION_TYPE="grow"
TRANSITION_DURATION="1"
TRANSITION_FPS="60"
TRANSITION_BEZIER=".43,1.19,1,.4"
MARGIN_PERCENT=10

# Simple logging functions
log() { echo "[$(date '+%H:%M:%S')] $*" >&2; }
log_info() { log "INFO: $*"; }
log_error() { log "ERROR: $*"; }

# Check required dependencies
check_dependencies() {
    local missing_deps=()
    
    for cmd in swaymsg swww jq; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        exit 1
    fi
}

# Get screen resolution with fallbacks
get_screen_resolution() {
    local width height
    
    # Try different methods to get resolution
    if width=$(swaymsg -t get_outputs 2>/dev/null | jq -r '.[] | select(.focused==true) | .current_mode.width // empty' 2>/dev/null) && 
       height=$(swaymsg -t get_outputs 2>/dev/null | jq -r '.[] | select(.focused==true) | .current_mode.height // empty' 2>/dev/null) &&
       [[ -n "$width" && -n "$height" && "$width" -gt 0 && "$height" -gt 0 ]]; then
        echo "${width}x${height}"
        return 0
    fi
    
    if width=$(swaymsg -t get_outputs 2>/dev/null | jq -r '.[] | select(.active==true) | .current_mode.width' 2>/dev/null | head -n1) && 
       height=$(swaymsg -t get_outputs 2>/dev/null | jq -r '.[] | select(.active==true) | .current_mode.height' 2>/dev/null | head -n1) &&
       [[ -n "$width" && -n "$height" && "$width" -gt 0 && "$height" -gt 0 ]]; then
        echo "${width}x${height}"
        return 0
    fi
    
    # Fallback resolution
    log_info "Using fallback resolution 1920x1080"
    echo "1920x1080"
}

# Generate random position for transition
get_random_position() {
    local resolution=$(get_screen_resolution)
    local width=${resolution%x*}
    local height=${resolution#*x}
    
    # Calculate margins
    local margin_x=$((width * MARGIN_PERCENT / 100))
    local margin_y=$((height * MARGIN_PERCENT / 100))
    
    # Define bounds
    local min_x=$margin_x
    local max_x=$((width - margin_x))
    local min_y=$margin_y
    local max_y=$((height - margin_y))
    
    # If screen is too small, use center
    if [[ $max_x -le $min_x ]] || [[ $max_y -le $min_y ]]; then
        echo "$((width / 2)),$((height / 2))"
        return 0
    fi
    
    # Generate random coordinates
    local random_x=$((RANDOM % (max_x - min_x + 1) + min_x))
    local random_y=$((RANDOM % (max_y - min_y + 1) + min_y))
    
    echo "${random_x},${random_y}"
}

# Find available wallpaper
find_wallpaper() {
    for ext in "${SUPPORTED_EXTENSIONS[@]}"; do
        local wallpaper=$(find "$WALLS_DIR" -maxdepth 1 -name "*.${ext}" -type f -print -quit 2>/dev/null || true)
        if [[ -n "$wallpaper" && -f "$wallpaper" ]]; then
            echo "$wallpaper"
            return 0
        fi
    done
    return 1
}

# Ensure wallpaper file exists and is valid
ensure_wallpaper() {
    # Create directory if needed
    if [[ ! -d "$WALLS_DIR" ]]; then
        log_info "Creating directory: $WALLS_DIR"
        mkdir -p "$WALLS_DIR" || {
            log_error "Failed to create directory: $WALLS_DIR"
            exit 1
        }
    fi
    
    # Check for current wallpaper file
    if [[ ! -f "$CURRENT_WALL_FILE" ]]; then
        log_info "Finding fallback wallpaper"
        
        if wallpaper=$(find_wallpaper); then
            log_info "Using: $(basename "$wallpaper")"
            echo "$wallpaper" > "$CURRENT_WALL_FILE" || {
                log_error "Failed to write wallpaper file"
                exit 1
            }
        else
            log_error "No wallpapers found in $WALLS_DIR"
            exit 1
        fi
    fi
}

# Validate wallpaper file
validate_wallpaper() {
    local wallpaper="$1"
    
    if [[ -z "$wallpaper" || ! -f "$wallpaper" || ! -r "$wallpaper" || ! -s "$wallpaper" ]]; then
        return 1
    fi
    
    return 0
}

# Set wallpaper with swww
set_wallpaper() {
    local wallpaper="$1"
    local position="$2"
    
    log_info "Setting wallpaper: $(basename "$wallpaper")"
    
    if ! swww img "$wallpaper" \
        --transition-bezier "$TRANSITION_BEZIER" \
        --transition-type "$TRANSITION_TYPE" \
        --transition-duration "$TRANSITION_DURATION" \
        --transition-fps "$TRANSITION_FPS" \
        --transition-pos "$position" 2>/dev/null; then
        
        log_error "Failed to set wallpaper with swww"
        return 1
    fi
    
    return 0
}

# Main function
main() {
    log_info "Starting wallpaper setup"
    
    # Check dependencies
    check_dependencies
    
    # Ensure wallpaper exists
    ensure_wallpaper
    
    # Read wallpaper path
    local wallpaper
    if ! wallpaper=$(cat "$CURRENT_WALL_FILE" 2>/dev/null); then
        log_error "Failed to read wallpaper file"
        exit 1
    fi
    
    # Validate and find fallback if needed
    if ! validate_wallpaper "$wallpaper"; then
        log_info "Invalid wallpaper, finding fallback"
        
        if wallpaper=$(find_wallpaper); then
            echo "$wallpaper" > "$CURRENT_WALL_FILE"
        else
            log_error "No valid wallpaper found"
            exit 1
        fi
        
        if ! validate_wallpaper "$wallpaper"; then
            log_error "Fallback wallpaper is also invalid"
            exit 1
        fi
    fi
    
    # Set the wallpaper with random position
    local position=$(get_random_position)
    if set_wallpaper "$wallpaper" "$position"; then
        log_info "Wallpaper set successfully"
        exit 0
    else
        log_error "Failed to set wallpaper"
        exit 1
    fi
}

# Run the script
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi