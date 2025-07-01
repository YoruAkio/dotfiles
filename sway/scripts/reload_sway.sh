#!/bin/sh

# Reload Sway configuration
swaymsg reload

# Reload kitty configuration
pkill -SIGUSR1 kitty

# Restart dunst to apply new colors
pkill dunst
pkill swaync
dunst &