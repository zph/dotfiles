#!/bin/sh
HDID=$(which hdid)
echo "Y" | $HDID "$1"
