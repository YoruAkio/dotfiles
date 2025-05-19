#!/bin/bash

# Check if audio system is available
if ! pactl info &>/dev/null; then
    notify-send "Warning: Audio system not available!" --icon=media-record
    exit 1
fi

# Get default audio monitor source
DEFAULT_SOURCE=$(pactl info | grep "Default Source" | cut -d: -f2 | xargs)
    
if [[ -z "$DEFAULT_SOURCE" ]]; then
    # Fallback to first available monitor source
    DEFAULT_SOURCE=$(pactl list sources short | grep monitor | head -n 1 | awk '{print $2}')
else
    # Get the monitor of the default source
    DEFAULT_SOURCE="${DEFAULT_SOURCE}.monitor"
fi

notify-send "Select an area to record..." --icon=media-record

# Prompt user to select an area
geometry=$(slurp)
if [[ -z "$geometry" ]]; then
    notify-send "Recording cancelled!" --icon=media-record
    exit 1
fi

notify-send "Screenrecorder started!" --icon=media-record

datetime=$(date +%F_%T)
video_folder_dir=$(xdg-user-dir VIDEOS)/Screenrecorder
mkdir -p "$video_folder_dir"

file="$video_folder_dir/Screenrecord-$datetime.mp4"

# Simpler command with standard parameters
wf-recorder -g "$geometry" --audio "$DEFAULT_SOURCE" -f "$file" -r 30
