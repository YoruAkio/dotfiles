#!/bin/bash

# Screen Recording Runner Script
# This script manages screen recording options using wofi

# Ensure videos directory exists
VIDEO_DIR="$(xdg-user-dir VIDEOS)/Screenrecorder"
mkdir -p "$VIDEO_DIR"

# Script directories
SCRIPT_DIR="$HOME/.config/sway/scripts/record"

# Helper function for notifications
notify() {
    notify-send "Screen Recorder" "$1" --icon=media-record
}

# Get monitor resolution for centering wofi
get_monitor_resolution() {
    # Get primary monitor resolution using swaymsg
    local resolution=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused==true) | .current_mode | "\(.width)x\(.height)"')
    
    # If we couldn't get it from swaymsg, try a fallback
    if [[ -z "$resolution" ]]; then
        resolution="1920x1080"  # Default fallback
    fi
    
    echo "$resolution"
}

# Calculate wofi position for centering
calculate_wofi_position() {
    local width=$1
    local height=$2
    local resolution=$(get_monitor_resolution)
    
    # Parse resolution
    local screen_width=$(echo "$resolution" | cut -d'x' -f1)
    local screen_height=$(echo "$resolution" | cut -d'x' -f2)
    
    # Calculate center position
    local x_pos=$(( (screen_width - width) / 2 ))
    local y_pos=$(( (screen_height - height) / 2 ))
    
    echo "$x_pos $y_pos"
}

# Calculate dialog size based on screen resolution
calculate_dialog_size() {
    local resolution=$(get_monitor_resolution)
    local screen_width=$(echo "$resolution" | cut -d'x' -f1)
    local screen_height=$(echo "$resolution" | cut -d'x' -f2)
    
    # Calculate appropriate dialog size (roughly 40% of screen width and height)
    local width=$(( screen_width * 40 / 100 ))
    local height=$(( screen_height * 40 / 100 ))
    
    # Set minimum sizes
    if [ "$width" -lt 400 ]; then
        width=400
    fi
    
    if [ "$height" -lt 300 ]; then
        height=300
    fi
    
    echo "$width $height"
}

# Check if wf-recorder is already running
check_recording_status() {
    if pgrep -x "wf-recorder" > /dev/null; then
        return 0 # Recording is active
    else
        return 1 # Not recording
    fi
}

# Show stop dialog when recording is in progress
show_stop_dialog() {
    # Set dimensions for the wofi dialog
    local dialog_size=$(calculate_dialog_size)
    local width=$(echo "$dialog_size" | cut -d' ' -f1)
    local height=$(echo "$dialog_size" | cut -d' ' -f2)
    
    # Calculate center position
    local position=$(calculate_wofi_position $width $height)
    local x_pos=$(echo "$position" | cut -d' ' -f1)
    local y_pos=$(echo "$position" | cut -d' ' -f2)
    
    # Use a temporary file to store wofi options
    local tmp_file=$(mktemp)
    printf "Stop\nContinue\nCancel" > "$tmp_file"
    
    local choice=$(wofi \
        --dmenu \
        --width=$width \
        --height=$height \
        --x=$x_pos \
        --y=$y_pos \
        --prompt="Recording Options:" \
        --cache-file=/dev/null \
        --insensitive < "$tmp_file")
    
    # Clean up temporary file
    rm -f "$tmp_file"
    
    case "$choice" in
        "Stop")
            # Run the stop script
            bash "$SCRIPT_DIR/record-stop.sh"
            ;;
        "Cancel")
            # Run the stop script but indicate cancellation
            killall -INT wf-recorder
            notify "Recording cancelled!"
            ;;
        "Continue"|*)
            # Do nothing, just continue recording
            notify "Recording continues..."
            ;;
    esac
}

# Show recording options dialog
show_recording_options() {
    # Set dimensions for the wofi dialog
    local dialog_size=$(calculate_dialog_size)
    local width=$(echo "$dialog_size" | cut -d' ' -f1)
    local height=$(echo "$dialog_size" | cut -d' ' -f2)
    
    # Calculate center position
    local position=$(calculate_wofi_position $width $height)
    local x_pos=$(echo "$position" | cut -d' ' -f1)
    local y_pos=$(echo "$position" | cut -d' ' -f2)
    
    # Use a temporary file to store wofi options
    local tmp_file=$(mktemp)
    printf "Record Fullscreen\nRecord Fullscreen - No Audio\nRecord Selection\nRecord Selection - No Audio" > "$tmp_file"
    
    local choice=$(wofi \
        --dmenu \
        --width=$width \
        --height=$height \
        --x=$x_pos \
        --y=$y_pos \
        --prompt="Screen Recording:" \
        --cache-file=/dev/null \
        --insensitive < "$tmp_file")
    
    # Clean up temporary file
    rm -f "$tmp_file"
    
    case "$choice" in
        "Record Fullscreen")
            bash "$SCRIPT_DIR/record-full-with-audio.sh"
            ;;
        "Record Fullscreen - No Audio")
            bash "$SCRIPT_DIR/record-full-no-audio.sh"
            ;;
        "Record Selection")
            bash "$SCRIPT_DIR/record-selection-with-audio.sh"
            ;;
        "Record Selection - No Audio")
            bash "$SCRIPT_DIR/record-selection-no-audio.sh"
            ;;
        *)
            # User closed the dialog or no selection was made
            notify "Recording cancelled!"
            ;;
    esac
}

# Main function
main() {
    # Ensure we're in a graphical environment by checking for WAYLAND_DISPLAY
    if [[ -z "$WAYLAND_DISPLAY" ]]; then
        echo "Error: No Wayland display detected."
        exit 1
    fi

    # Check if already recording
    if check_recording_status; then
        # If recording is active, show stop dialog
        show_stop_dialog
    else
        # If not recording, show recording options
        show_recording_options
    fi
}

# Run the main function
main