#!/bin/bash
# re-encodes only the video stream to av1.

# Make sure every Program is installed for the script to run!
if ! [ "$(command -v ffmpeg)" ]; then
        echo "Install ffmpeg!"
        exit 1
fi

check_codec() {
        local file=$1
        if echo ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$file" | grep -q "av1"; then
                return 0
        fi
        return 1
}

mkdir re-encode

# Only a single file
if [ "$1" ]; then

    file="$1"
    if check_codec "$file" -eq 0; then
            ffmpeg -i "$file" -map 0 -c copy -c:v libsvtav1 -crf 23 -b:v 0 "re-encode/$file"
            exit 0
    fi
    exit 1
fi

# Iterate through the files in the directory and re-encode

for file in *; do
        echo "$file"
        if [ -f "$file" ]; then
                if [ -f "re-encode/$file" ]; then
                        continue
                fi

                if check_codec "$file" -eq 1; then
                        continue
                fi

                ffmpeg -i "$file" -map 0 -c copy -c:v libsvtav1 -crf 23 -b:v 0 "re-encode/$file"
        fi
done
