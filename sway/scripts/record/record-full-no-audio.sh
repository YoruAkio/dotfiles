#!/bin/bash

notify-send "Screenrecorder started!" --icon=media-record

datetime=$(date +%F_%T)
video_folder_dir=$(xdg-user-dir VIDEOS)/Screenrecorder
mkdir -p "$video_folder_dir"

file="$video_folder_dir/Screenrecord-$datetime.mp4"

# Simpler command with standard parameters
wf-recorder -f "$file" -r 30
