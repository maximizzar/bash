#!/bin/bash

usage() {
    echo "Usage: -r framerate -i path to images "
    echo "Optional: -q quality (default 50) -o outfile (loop.webp)"
}

while getopts ":r:i:o:q:" opt; do
    case $opt in
        r) FRAMERATE=$OPTARG
           ;;
        i) INPUT=$OPTARG
           ;;
        o) OUTPUT=$OPTARG
           ;;
        q) QUALITY=$OPTARG
           ;;
        \?) echo "Invalid option: -$OPTARG" >&2
            ;;
    esac
done

if [ -z "$FRAMERATE" ] || [ -z "$INPUT" ]; then
    usage
    exit 1
fi

if [ "$OUTPUT" == "" ]; then
        OUTPUT="loop.webp"
fi

if [ "$QUALITY" == "" ]; then
      QUALITY=50
fi

ffmpeg -framerate "$FRAMERATE" -i "$INPUT" -map 0 -c:v libwebp -lossless 0 -r "$FRAMERATE" -compression_level 6 -q:v "$QUALITY" -loop 0 "$OUTPUT"
