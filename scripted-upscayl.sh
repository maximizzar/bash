#!/bin/bash

cd ~/test || exit

SOURCE_FULL_PATH="$1"
SOURCE_VIDEO=$(basename "$SOURCE_FULL_PATH")
SOURCE_LENGTH_IN_FRAMES=$(ffprobe -v error -select_streams v:0 -show_entries stream=nb_frames -of default=nokey=1:noprint_wrappers=1 "$SOURCE_FULL_PATH")
FRAMERATE=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=noprint_wrappers=1:nokey=1 "$SOURCE_FULL_PATH")

MODEL="uniscale_restore"
PROJECT_NAME=$(echo -n "$SOURCE_VIDEO" | md5sum | cut -d ' ' -f 1)

# init project to start the upscale process.
mkdir -p "$PROJECT_NAME" && cd "$PROJECT_NAME" || exit 1

# quit if output was generated before
if [ -f "$SOURCE_VIDEO" ]; then
    echo "bye bye" && exit 1
fi

# create dir for video frame and for the upscale output
mkdir -p original

if [ "$(find original -type f | wc -l)" -lt "$SOURCE_LENGTH_IN_FRAMES" ]; then
  # split video into its frames
    ffmpeg -i "$SOURCE_FULL_PATH" original/%d.png
fi

# move frames into sub-dirs and clone dir tree to the upscale dir (does nothing if frames got sorted before)
(
cd original || exit 1
  if ls *.png 1> /dev/null 2>&1; then
      for frame in *.png; do
          sub_dir=$(printf "%03d" $((10#$(basename "$frame" .png) / 1000)))
          mkdir -p "$sub_dir" && mkdir -p "../upscale/$MODEL/$sub_dir"
          mv "$frame" "$sub_dir/"
      done
  fi
)

# Download the upscayl custom-models if not present yet
(
  cd ..
  if ! [ -d custom-models/models ]; then
    git clone https://github.com/upscayl/custom-models
  fi
)

# Iterate through subdirectories and upscale frames.
(
    cd original || exit 1
    for sub_dir in */; do
      if ! [ "$(ls "$sub_dir" | wc -l)" == "$(ls ../upscale/$MODEL/$sub_dir | wc -l)" ]; then
        (cd ../ && upscayl -i "original/$sub_dir" -o "upscale/$MODEL/$sub_dir" -s 2 -m "../custom-models/models" -n uniscale_restore -f png -c 0)
      fi
    done
)

# Check if the Media Container has an audio stream
if [ -z "$(ffmpeg -i "$SOURCE_FULL_PATH" 2>&1 | grep Stream | grep -i audio)" ]; then
  # Encode Video with av1
  ffmpeg -framerate "$FRAMERATE" -i "upscale/$MODEL/000/%d.png" -c:v libsvtav1 -crf 28 -b:v 0 -r "$FRAMERATE" "$SOURCE_VIDEO"
else
  # Encode Video with av1 and aac
  ffmpeg -i "$SOURCE_FULL_PATH" -vn -c:a pcm_s16le -f wav pipe: | ffmpeg -framerate "$FRAMERATE" -i "upscale/$MODEL/000/%d.png" -i pipe: -c:v libsvtav1 -crf 28 -b:v 0 -r "$FRAMERATE" -c:a aac "$SOURCE_VIDEO"
fi
