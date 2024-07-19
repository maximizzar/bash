#!/bin/bash

mkdir re-encode

# Only a single file
if [ "$1" ]; then
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
