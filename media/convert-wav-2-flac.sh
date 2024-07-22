#!/bin/bash

if ! command -v ffmpeg &> /dev/null; then
        echo "Install ffmpeg"
        exit 1;
fi

if [ -f "$1" ]; then
        FILENAME="${1%.*}"
        ffmpeg -i "$1" -c:a flac -compression_level 12 "$FILENAME.flac"

        if command -v loudgain &> /dev/null; then
                loudgain -s e "$FILENAME.flac"
        fi

        if [ "$2" == "d" ]; then
                rm "$1"
        fi
fi
