#!/usr/bin/env bash
# extract audio from video

if [ "$1" != "" ]; then
        filename=$(basename -- "input_video.mp4")
        ffmpeg -i "$1" -map a -c:a flac -compression_level 12 "$filename.flac"
fi

if [ "$(command -v loudgain)" ]; then
        loudgain -s e --quiet "$filename.flac"
fi
