#!/bin/sh
USER=$1
SELF=`whoami`
# Create their user
sudo adduser --disabled-password $USER
# Modify user to be part of pair group
sudo moduser -a -G pair $SELF
sudo moduser -a -G pair $USER
# Add their user's Github keys to their authfile || user gh-keys
tweemux hubkey $USER
# Create tmux session based on a socket in /tmp/pair
tmux -S /tmp/pair new
# Chown for right group
chown $SELF:pair /tmp/pair
# Chmod for world readable
chmod 770 /tmp/pair


