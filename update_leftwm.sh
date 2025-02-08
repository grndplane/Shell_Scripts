#! /bin/bash
#
# Recompile and update LeftWM
# Version 0.0.1
# By Mike Edwards

cd ~/leftwm/leftwm/

git pull origin main

# With systemd logging (view with 'journalctl -f -t leftwm-worker')
cargo build --profile optimized
