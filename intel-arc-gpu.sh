#!/bin/bash

# Dynamically find the correct hwmon directory for Intel Arc GPU
for i in {1..8}; do
    if [ -d "/sys/class/hwmon/hwmon$i" ] && [ -f "/sys/class/hwmon/hwmon$i/energy1_input" ]; then
        HWMON="/sys/class/hwmon/hwmon$i"
        break
    fi
done

# Check if HWMON is set, exit with error if not found
if [ -z "$HWMON" ]; then
    echo "Error" >&2
    exit 1
fi

# Read initial power value
POWER1=$(cat "$HWMON/energy1_input")

# Wait for a short interval
sleep 0.25

# Read second power value
POWER2=$(cat "$HWMON/energy1_input")

# Calculate power consumption
# Subtracting POWER1 from POWER2 gives energy used in the interval
# Dividing by 252525 converts to watts (adjust this value if needed for your specific GPU)
POWER=$(echo "scale=0; ($POWER2 - $POWER1) / 252525" | bc)

# Get GPU information from glxinfo
# grep finds the line with "OpenGL renderer", awk extracts the GPU name
gpu=$(glxinfo | grep -E "OpenGL renderer" | awk '{ print $7 }')

# Output result: GPU name followed by power consumption in watts
echo " $gpu ${POWER}W"
