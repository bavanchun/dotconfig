#!/bin/bash

WALLPAPER="/home/vchun/Pictures/Wallpapers/a_black_computer_monitor_with_a_white_screen.jpg"

# Start awww daemon and wait for it to be ready
awww-daemon &
sleep 1

# Set the wallpaper
awww img "$WALLPAPER" --transition-type fade --transition-duration 1
