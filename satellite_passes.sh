#!/bin/bash

# Function to convert azimuth to compass direction
get_compass_direction() {
    local azimuth=$1
    local directions=("N" "NE" "E" "SE" "S" "SW" "W" "NW")
    local index=$(( (${azimuth%.*} + 22) % 360 / 45 ))
    echo "${directions[$index]}"
}

# Function to fetch and process satellite passes
get_satellite_pass() {
    local sat_id=$1
    local sat_name=$2
    local lat=$3
    local lon=$4
    local alt=$5
    local api_key="${N2YO_API_KEY:-EDQVYF-BMEVMQ-3NXQTD-4QXV}"
    local base_url="https://api.n2yo.com/rest/v1/satellite/visualpasses"
    local url="${base_url}/${sat_id}/${lat}/${lon}/${alt}/7/3/?apiKey=${api_key}"

    # Fetch data from API using curl
    response=$(curl -s "$url")
    
    # Check if curl command was successful
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to fetch data for ${sat_name} from the API" >&2
        return
    fi

    # Check if API returned any passes
    if ! echo "$response" | jq -e '.passes[0]' > /dev/null 2>&1; then
        echo "No pass found for ${sat_name} for the given location and time range." >&2
        return
    fi

    # Process each pass
    count=0  # Initialize a counter
    echo "$response" | jq -c '.passes[]' | while read -r pass; do
        if [[ $count -ge 2 ]]; then  # Limit to 2 outputs
            break
        fi

        # Extract required fields from the pass data
        start_time=$(echo "$pass" | jq -r '.startUTC // empty')
        duration=$(echo "$pass" | jq -r '.duration // empty')
        max_az=$(echo "$pass" | jq -r '.maxAz // empty')
        max_el=$(echo "$pass" | jq -r '.maxEl // empty')

        # Check if all required fields are present
        if [[ -z "$start_time" || -z "$duration" || -z "$max_az" || -z "$max_el" ]]; then
            echo "Error: Missing required fields in pass data for ${sat_name}" >&2
            continue
        fi

        # Convert UTC timestamp to readable date format
        start_date=$(date -d "@$start_time" "+%d %b %I:%M %p" 2>/dev/null)
        
        # Check if date conversion was successful
        if [[ $? -ne 0 ]]; then
            echo "Error: Invalid date format for startUTC: $start_time for ${sat_name}" >&2
            continue
        fi

        # Calculate duration in minutes and seconds
        duration_min=$((duration / 60))
        duration_sec=$((duration % 60))
        
        # Get compass direction from azimuth
        direction=$(get_compass_direction "$max_az")

        # Print formatted output
        printf "%-7s | %s | %2dm%02ds | %2s %2.0f°\n" "$sat_name" "$start_date" "$duration_min" "$duration_sec" "$direction" "$max_el"

        count=$((count + 1))  # Increment the counter
    done
}

# Set default parameters
latitude=34.06862
longitude=-117.93895
altitude=156

# Satellite IDs
noaa_15_id=25338
noaa_18_id=28654
noaa_19_id=33591
iss_id=25544

# Print header
echo "Satellite | Date & Time    | Duration | Direction & Elevation"
echo "---------+----------------+----------+--------------------------"

# Fetch and display passes for each satellite
# get_satellite_pass $noaa_15_id "NOAA-15" "$latitude" "$longitude" "$altitude"
# get_satellite_pass $noaa_18_id "NOAA-18" "$latitude" "$longitude" "$altitude"
# get_satellite_pass $noaa_19_id "NOAA-19" "$latitude" "$longitude" "$altitude"
get_satellite_pass $iss_id "ISS" "$latitude" "$longitude" "$altitude"
