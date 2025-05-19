#!/bin/bash

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
wf-recorder -g "$geometry" -f "$file" -r 30 