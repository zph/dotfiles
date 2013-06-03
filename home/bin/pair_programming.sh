#!/bin/sh
USER=$1
# Create their user
sudo adduser --disabled-password $USER
# Add their user's Github keys to their authfile || user gh-keys
tweemux hubkey $USER
# Create tmux session based on a socket in /tmp/pair
tmux -S /tmp/pair
# Chmod for world readable
chmod 777 /tmp/pair
