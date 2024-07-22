#!/usr/bin/env bash
# extracts frames from a given video steam and saves then in a directory

# Make sure every Program is installed for the script to run!
if ! [ "$(command -v ffmpeg)" ]; then
        echo "Install ffmpeg!"
        exit 1
fi

if ! [ -f "$1" ]; then
        echo "file '$1' does not exist"
        exit 1
fi

# Provide a dir name as 2nd Argument.
# No trailing Slash please!
if [ "$2" == "" ]; then
        frames="frames"
else
        frames="$2"
fi

# Total number of frames
total_frames=$(ffprobe -v error -count_frames -select_streams v:0 -show_entries stream=nb_read_frames -of default=nokey=1:noprint_wrappers=1 -i "$1")

# Calculate the number of digits required
num_digits=$(echo -n "$total_frames" | wc -c)

# Create format string for FFmpeg
format_string=$(printf "%%0%dd.png" "$num_digits")

mkdir "$frames"
ffmpeg -i "$1" "$frames/${format_string}"
