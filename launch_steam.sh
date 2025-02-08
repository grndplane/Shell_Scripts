#!/bin/bash

# Stop picom
pkill -x picom

# Launch Steam and wait for it to close
steam && echo "Steam has exited."

# Restart picom
picom --config $HOME/.config/leftwm/themes/current/picom.conf &> /dev/null &

exit 0
