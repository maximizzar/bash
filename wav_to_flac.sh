#!/bin/bash

if ! command -v ffmpeg &> /dev/null; then
        echo "Install ffmpeg"
        exit 1;
fi

if [ -f "$1" ]; then
        FILENAME="${1%.*}"
        ffmpeg -i "$1" -c:a flac -compression_level 8 "$FILENAME.flac"

        if [ "$1" == "d" ]; then
                rm "$1"
        fi
fi
