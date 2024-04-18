#!/bin/bash

# Get the timestamp in seconds since epoch of the last ZFS scrub task
last_scrub_date=$(zpool status -T u local-zfs | head -n 1)

# Get the current time in seconds since epoch
current_time=$(date +"%s")

# Calculate the time difference in days
days_since_last_scrub=$(( (current_time - last_scrub_date) / (60*60*24) ))

# Check if it's been 35 days since the last scrub task
if [ $days_since_last_scrub -ge 35 ]; then
    zpool scrub "local-zfs"

    # Loop to check if the scrub is still in progress
    while true; do
        if zpool status -x "local-zfs" | grep -q "scrub in progress"; then
            sleep 600  # Wait for 10 minutes before checking again
        else
            break  # Exit the loop once the scrub is completed
        fi
    done
fi
