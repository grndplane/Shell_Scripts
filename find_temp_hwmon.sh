#!/bin/bash

for i in {1..9}; do
    if [ -f "/sys/class/hwmon/hwmon${i}/temp1_input" ]; then
        echo "/sys/class/hwmon/hwmon${i}/temp1_input"
        exit 0
    fi
done

echo "Error: No valid hwmon path found" >&2
exit 1
