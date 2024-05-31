#!/bin/bash

MODEL="$2"
MODEL_PATH="../models"

# if in install mode, install dependencies
if [ "$1" == "install" ]; then
        apt install curl zip git || echo "apt failed to install packages. Check privileges, connection and dns!" && exit 1
        upscayl_ncnn_release_api="https://api.github.com/repos/upscayl/upscayl-ncnn/releases/latest"
        upscayl_ncnn_release_tag=$(curl --silent "$upscayl_ncnn_release_api" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

        upscayl_release_api="https://api.github.com/repos/upscayl/upscayl/releases/latest"
        upscayl_release_tag="$(curl --silent "$upscayl_release_api" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')"

        (
                # Download upscayl, upscayl-bin and custom models
                cd /tmp || exit 1
                wget "https://github.com/upscayl/upscayl-ncnn/releases/tag/$upscayl_ncnn_release_tag/upscayl-bin-$upscayl_ncnn_release_tag-linux.zip"
                wget "https://github.com/upscayl/upscayl/releases/tag/v$upscayl_release_tag/upscayl-$upscayl_release_tag-linux.zip"
                unzip "upscayl-bin-$upscayl_ncnn_release_tag-linux.zip"
                unzip "upscayl-$upscayl_release_tag-linux"

                git clone https://github.com/upscayl/custom-models.git
        )

        (
                # copy binary and models into their correct dirs
                cp "/tmp/upscayl-bin-$upscayl_ncnn_release_tag-linux/upscayl-bin" "/usr/local/bin/upscayl"
                chmod +x /usr/local/bin/upscayl

                cd "$MODEL_PATH" || exit 1
                cp /tmp/resources/models/* .
                cp /tmp/custom-models/models/* .
        )

        echo "Installation done. Have fun!"
        exit 0
fi

# check if chosen model is installed
if ! [  -d "$MODEL_PATH" ]; then
        echo "Make sure your path is correct or create a models dir."
        exit 1
fi

if ! [ -f "$MODEL_PATH/$MODEL.bin"  ]; then
        echo "Please put your chosen model into the models dir or check the provided name."
        exit 1
fi

SOURCE_FULL_PATH="$1"
SOURCE_VIDEO=$(basename "$SOURCE_FULL_PATH")
SOURCE_LENGTH_IN_FRAMES=$(ffprobe -v error -count_frames -select_streams v:0 -show_entries stream=nb_read_frames -of default=nokey=1:noprint_wrappers=1 -i "$SOURCE_FULL_PATH")
FRAMERATE=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=noprint_wrappers=1:nokey=1 "$SOURCE_FULL_PATH")

PROJECT_NAME="$SOURCE_VIDEO: $(echo -n "$SOURCE_VIDEO" | md5sum | cut -d ' ' -f 1)"

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

# Skip upscayl completly if it's 100% done
if [ "$(find "original" -type f | wc -l)" -ne "$(find "upscale/$MODEL" -maxdepth 1 -type f | wc -l)" ]; then
        (
                # Iterate through subdirectories and upscale frames.
                cd original || exit 1
                for sub_dir in */; do
                          if [ "$(find "$sub_dir" -maxdepth 1 -type f | wc -l)" -ne "$(find ../upscale/"$MODEL"/"$sub_dir" -maxdepth 1 -type f | wc -l)" ]; then
                                    (cd ../ && upscayl -i "original/$sub_dir" -o "upscale/$MODEL/$sub_dir" -s 2 -m "$MODEL_PATH" -n "$MODEL" -f png -c 0)
                          fi
                done
        )

        (
                # move frames into upscale/$MODEL dir, because idk how to deal with sub-dirs in ffmpeg
                cd "upscayl/$MODEL" || exit 1
                for sub_dir in */; do
                        mv ./*.png ../
                done
        )
fi

ffmpeg -i "$SOURCE_FULL_PATH" -vn -c copy /tmp/no_video.mp4
ffmpeg -framerate "$FRAMERATE" -i "upscale/$MODEL/%d.png" -i "/tmp/no_video.mp4" -map 0:v -map 1 -c copy -c:v libsvtav1 -crf 23 -b:v 0 -r "$FRAMERATE" "$SOURCE_VIDEO"
rm /tmp/no_video.mp4
exit 0

# Check if the Media Container has an audio stream
if [ -z "$(ffmpeg -i "$SOURCE_FULL_PATH" 2>&1 | grep Stream | grep -i audio)" ]; then
  # Encode Video with av1
  ffmpeg -framerate "$FRAMERATE" -i "upscale/$MODEL/%d.png" -c:v libsvtav1 -crf 28 -b:v 0 -r "$FRAMERATE" "$SOURCE_VIDEO"
else
  # Encode Video with av1 and aac
  ffmpeg -i "$SOURCE_FULL_PATH" -vn -c:a pcm_s16le -f wav pipe: | ffmpeg -framerate "$FRAMERATE" -i "upscale/$MODEL/%d.png" -i pipe: -c:v libsvtav1 -crf 23 -b:v 0 -r "$FRAMERATE" -c:a aac "$SOURCE_VIDEO"
fi


ffmpeg -framerate "$FRAMERATE" -i "upscale/$MODEL/%d.png" -i "$SOURCE_FULL_PATH" -map 0 -map -0:v -c copy -c:v libsvtav1 -crf 23 -b:v 0 -r "$FRAMERATE" "$SOURCE_VIDEO"


rsync --archive --xattrs --owner --group --times --atimes --open-noatime --crtimes --delete --progress --ipv6 --dry-run /local-zfs/data/videos/movies/ ssh root@proxmox-backup-server:/mnt/datastore/local-zfs/data/videos/movies

rsync --dry-run /local-zfs/data/videos/movies/ ssh root@proxmox-backup-server:/mnt/datastore/local-zfs/data/videos/movies