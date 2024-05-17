#!/bin/bash

# Check if a directory is provided as an argument
if [ -z "$1" ]; then
    #echo "Please provide a directory or a file as an argument."
    #exit 1
    1="$(pwd)"
fi

cd "$1" || exit 1
mkdir re-encode

if [ -f $1 ]; then
    ffmpeg -i "$1" -map 0 -c copy -c:v libsvtav1 -crf 24 -b:v 0 "re-encode/$1"
    exit 0
fi

cd "$1" || exit 1

# Iterate through the files in the directory and re-encode
for file in "$1"/*; do
    if [ -f "$file" ]; then
      if ! [ -f "re-encode/$file"  ]; then
        ffmpeg -i "$file" -map 0 -c:v libsvtav1 -crf 23 -b:v 0 "re-encode/$file"
      fi
    fi
done
