#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

# Use the user local configs (recommended)
mkdir -p /home/$1/.config/pulse/
cp /app/default.pa /home/$1/.config/pulse/
cp /app/client.conf /home/$1/.config/pulse/

pulseaudio --start
