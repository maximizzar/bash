#!/bin/bash

#Count of times we have queried and there are tasks running
count=0
#Number of no-task intervals before we shutdown
max=40
#Interval in seconds
interval=5


#Continue until we shutdown
while true; do
    #Check if we should shutdown until we see not
    if [[ $(proxmox-backup-manager task list) ]]; then
        #Continue to wait
        count=0
    else
        #There are no tasks running, so increment counter
        count=$((count + 1))
        echo "No tasks running, time until shutdown is $(((max - count) * interval)) seconds"
        #If we reached the max count, then shutdown
        if  ((count >= max)); then
            zfs_scrub
            echo "Time to shutdown!"
            current_time=$(date +%H%M)
            if [ "$current_time" -ge 1700 ]; then
                rtcwake --utc --time "$(date --date 'TZ=UTC tomorrow 17:00' +%s)" --mode mem
            else
                rtcwake --utc --time "$(date --date 'TZ=UTC today 17:00' +%s)" --mode mem
            fi
        fi
    fi
    #Delay by interval to next check
    sleep "$interval"
done
echo "Exiting"
