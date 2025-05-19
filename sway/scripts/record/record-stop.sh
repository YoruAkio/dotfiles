#!/bin/bash

VIDEO_DIR="$(xdg-user-dir VIDEOS)/Screenrecorder"

# Check if recording is active
if ! pgrep -x "wf-recorder" > /dev/null; then
    notify-send "No active recording found!" --icon=media-record
    exit 0
fi

notify-send "Screenrecorder stopped! Saved to $VIDEO_DIR" --icon=media-record

# Gracefully stop wf-recorder (SIGINT for clean finish)
killall -INT wf-recorder

# Wait for recording to finish processing
sleep 2

# If it's still running after 2 seconds, force kill it
if pgrep -x "wf-recorder" > /dev/null; then
    killall -9 wf-recorder
fi