#!/usr/bin/env bash
# extract audio from video

# Make sure every Program is installed for the script to run!
if ! [ "$(command -v ffmpeg)" ]; then
        echo "Install ffmpeg!"
        exit 1
fi

if [ "$1" != "" ]; then
        # Extract audio codec from the input file
        audio_codec=$(ffmpeg -i "$1" 2>&1 | grep -oP 'Audio: \K[^,]+' | awk '{print $1}')

        # Determine the output container format based on the audio codec
        case "$audio_codec" in
            aac)
                output_container="m4a"
                ;;
            mp3)
                output_container="mp3"
                ;;
            flac)
                output_container="flac"
                ;;
            ogg)
                output_container="ogg"
                ;;
            *)
                echo "Unsupported audio codec: $audio_codec"
                exit 1
                ;;
        esac

        filename=$(basename "${1%.*}")
        ffmpeg -i "$1" -vn -c:a copy "$filename.$output_container"
        echo "Audio extracted to: $filename.$output_container"
fi

if [ "$(command -v loudgain)" ]; then
        loudgain -s e --quiet "$filename.$output_container"
else
        echo "Couldn't add Replay-gain to Output."
        echo "Install loudgain if you want to have Replay-gain tags!"
fi
