#!/bin/bash
export BROWSER=firefox-aurora
export DE=xfce
exec ck-launch-session dbus-launch startxfce4 # openbox-session
xset +fp /usr/share/fonts/local
xset fp rehash
