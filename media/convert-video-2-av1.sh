#!/bin/bash
# reencodes only the video stream to av1.

# Make sure every Program is installed for the script to run!
if ! [ "$(command -v ffmpeg)" ]; then
        echo "Install ffmpeg!"
        exit 1
fi

mkdir re-encode

# Only a single file
if [ "$1" ]; then
    file="$1"
    ffmpeg -i "$file" -map 0 -c copy -c:v libsvtav1 -crf 23 -b:v 0 "re-encode/$file"
    exit 0
fi

# Iterate through the files in the directory and re-encode
for file in *; do
    echo "$file"
    if [ -f "$file" ]; then
      if ! [ -f "re-encode/$file" ]; then
        ffmpeg -i "$file" -map 0 -c copy -c:v libsvtav1 -crf 23 -b:v 0 "re-encode/$file"
      fi
    fi
done
