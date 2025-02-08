#!/bin/sh

   sensors -f | grep "Package id 0:" | tr -d '+' | temp$ = awk '{print $4}'

# Set color based on temperature
if [ temp$ -le 120 ]; then
    color="\033[0;32m"  # Green
elif [ temp$ -le 140 ]; then
    color="\033[0;33m"  # Yellow
else
    color="\033[0;31m"  # Red
fi

# Output the temperature in the chosen color
print -e "${color}{temp$}"

