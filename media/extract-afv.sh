#!/usr/bin/env bash
# extract audio from video

# Make sure every Program is installed for the script to run!
if ! [ "$(command -v ffmpeg)" ]; then
        echo "Install ffmpeg!"
        exit 1
fi

if [ "$1" != "" ]; then
        filename=$(basename -- "input_video.mp4")
        ffmpeg -i "$1" -map a -c:a flac -compression_level 12 "$filename.flac"
fi

if [ "$(command -v loudgain)" ]; then
        loudgain -s e --quiet "$filename.flac"
else
        echo "Couldn't add Replay-gain to Output."
        echo "Install loudgain if you want to have Replay-gain tags!"
fi
