#!/bin/sh

# Reload Sway configuration
swaymsg reload

# Reload kitty configuration
pkill -SIGUSR1 kitty