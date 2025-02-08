#!/bin/bash

# Function to convert azimuth to compass direction
get_compass_direction() {
    local azimuth=$1
    local directions=("N" "NE" "E" "SE" "S" "SW" "W" "NW")
    local index=$(( (${azimuth%.*} + 22) % 360 / 45 ))
    echo "${directions[$index]}"
}

# Function to fetch and process ISS passes
get_iss_passes() {
    local lat=$1
    local lon=$2
    local alt=$3
    local num_passes=$4
    local api_key="EDQVYF-BMEVMQ-3NXQTD-4QXV"
    local base_url="https://api.n2yo.com/rest/v1/satellite/visualpasses/25544"
    local url="${base_url}/${lat}/${lon}/${alt}/7/${num_passes}/?apiKey=${api_key}"

    # Fetch data from API using curl
    response=$(curl -s "$url")
    
    # Check if curl command was successful
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to fetch data from the API" >&2
        exit 1
    fi

    # Check if API returned an error
    if echo "$response" | jq -e '.error' > /dev/null 2>&1; then
        error_message=$(echo "$response" | jq -r '.error')
        echo "API Error: $error_message" >&2
        exit 1
    fi

    # Check if API returned any passes
    if ! echo "$response" | jq -e '.passes[0]' > /dev/null 2>&1; then
        echo "No ISS passes found for the given location and time range." >&2
        exit 0
    fi

    # Print header
    # echo "Satellite | Date & Time    | Duration | Direction & Max Elevation"
    # echo "---------+----------------+----------+--------------------------"

    # Process each pass
    echo "$response" | jq -c '.passes[]' | while read -r pass; do
        # Extract required fields from the pass data
        start_time=$(echo "$pass" | jq -r '.startUTC // empty')
        duration=$(echo "$pass" | jq -r '.duration // empty')
        max_az=$(echo "$pass" | jq -r '.maxAz // empty')
        max_el=$(echo "$pass" | jq -r '.maxEl // empty')

        # Check if all required fields are present
        if [[ -z "$start_time" || -z "$duration" || -z "$max_az" || -z "$max_el" ]]; then
            echo "Error: Missing required fields in pass data" >&2
            continue
        fi

        # Convert UTC timestamp to readable date format
        start_date=$(date -d "@$start_time" "+%d %b %I:%M %p" 2>/dev/null)
        
        # Check if date conversion was successful
        if [[ $? -ne 0 ]]; then
            echo "Error: Invalid date format for startUTC: $start_time" >&2
            continue
        fi

        # Calculate duration in minutes and seconds
        duration_min=$((duration / 60))
        duration_sec=$((duration % 60))
        
        # Get compass direction from azimuth
        direction=$(get_compass_direction "$max_az")

        # Print formatted output
        printf "%-7s | %s | %2dm%02ds | %2s %2.0f°\n" "ISS" "$start_date" "$duration_min" "$duration_sec" "$direction" "$max_el"
    done
}

# Set default parameters
latitude=34.06862
longitude=-117.93895
altitude=156
num_passes=5  # Number of passes to display

# Call the main function with the specified parameters
get_iss_passes "$latitude" "$longitude" "$altitude" "$num_passes"
