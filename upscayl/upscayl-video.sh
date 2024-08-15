#!/usr/bin/env bash

usage() {
        echo "Fullpath-to-video upscayl-model [scale-factor]"
        echo "Default scale-factor is 2."
}

disk_usage() {
        THRESHOLD=90
        while 1; do
                # Get the disk usage percentage of the root filesystem
                USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')

                # Check if the usage is greater than or equal to the threshold
                if [ "$USAGE" -ge "$THRESHOLD" ]; then
                    echo "Warning: Disk usage is at ${USAGE}%, which is above the threshold of ${THRESHOLD}%."
                    sleep 10
                else
                    echo "Disk usage is at ${USAGE}%, which is below the threshold."
                    break
                fi
        done
}

video_to_frames() {(
        # split video into its frames
        source_video_length_in_frames="$(ffprobe -v error -count_frames -select_streams v:0 -show_entries stream=nb_read_frames -of default=nokey=1:noprint_wrappers=1 -i "$source_video_path")"
        if [ "$(find original -type f | wc -l)" -lt "$source_video_length_in_frames" ]; then
            ffmpeg -i "$source_video_path" original/%d.png
        fi

        # check if both frame dirs got created
        if ! [[ -e "upscale" ]]; then
                exit 1
        fi
        cd original || exit 1

        # move frames into sub-dirs and clone dir tree to the upscale dir
        # (does nothing if frames got sorted before)
        if ls *.png 1> /dev/null 2>&1; then
            for frame in *.png; do
                sub_dir=$(printf "%03d" $((10#$(basename "$frame" .png) / 100)))
                mkdir -p "$sub_dir" && mkdir -p "../upscale/$sub_dir"
                mv "$frame" "$sub_dir/"
            done
        fi
)}

upscale_frames() {(
        if ! [[ -e "upscale" ]]; then
                exit 1
        fi

        # Skip upscayl completely if it's 100% done
        if [ "$(find "original" -type f | wc -l)" -ne "$(find "upscale" -maxdepth 1 -type f | wc -l)" ]; then
                # Iterate through subdirectories and upscale frames.
                cd original || exit 1
                for sub_dir in */; do
                          if [ "$(find "$sub_dir" -maxdepth 1 -type f | wc -l)" -ne "$(find "../upscale/$sub_dir" -maxdepth 1 -type f | wc -l)" ]; then
                                  disk_usage
                                  SECONDS=0
                                  if ! upscayl -i "../original/$sub_dir" -o "../upscale/$sub_dir" -s "$scale_factor" -j 2:4:4 -m "$upscayl_models" -n "$upscayl_model" -f png > /dev/null; then
                                          exit $?
                                  fi
                                  echo "Batch ${sub_dir%%/} took $SECONDS seconds to compute!"
                          fi
                done
        fi
)}

frame_to_video() {
        echo "Produces to output video!"
        # Get Video resolution and generate output file.
        framerate="$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=noprint_wrappers=1:nokey=1 "$source_video_path")"
        resolution="$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "upscale/1.png")"
        if [[ -z $resolution ]]; then
                echo "Failed to calculate output resolution!"
                exit 1
        fi

        ffmpeg -i "$source_video_path" -framerate "$framerate" -i "upscale/%d.png" -map_metadata 0 -map 1:v:0 -map 0 -map -0:v:0 -c copy -c:v:0 libsvtav1 -crf 23 -b:v 0 -r "$framerate" -s "$resolution" -max_interleave_delta 0 "../$source_video_name"
}

# verify user-input is complete and correct
if [[ $# -lt 2 ]]; then
        usage
fi

working_dir=""
if [[ $working_dir == "" ]]; then
      echo "Open script and set working_dir var!"
      exit 1
elif ! [[ -e $working_dir ]]; then
      mkdir -p "$working_dir"
fi

source_video_path="$1"
if ! [[ -e $source_video_path ]]; then
        echo "The Video \"$source_video_path\" does not exist!"
        exit 1
fi

upscayl_models="/opt/models"
upscayl_model="$2"
if ! [[ -e $upscayl_models/$upscayl_model.bin ]]; then
        echo "Chosen model \"$upscayl_model\" is not installed under \"$upscayl_models\"!"
        exit 1
fi

if [[ -z $3 ]]; then
        scale_factor=$3
else
        scale_factor=2
fi

# initiate Video upscale in the working-dir
cd "$working_dir" || exit 1
source_video_name=$(basename "$source_video_path")
if [[ -e ../$source_video_name ]]; then
        echo "Upscale already done."
        echo "Video: ($working_dir/$source_video_name)"
        exit 0
fi

project="$source_video_name: $(echo -n "$source_video_name" | md5sum | cut -d ' ' -f 1)"
if ! [[ -e $project ]]; then
        mkdir -p "$project/original"
        mkdir -p "$project/upscale"
fi

cd "$project" || exit 1

#Begin of core logic
start_time=$(date +%s)

video_to_frames
upscale_frames
frame_to_video

end_time=$(date +%s)

execution_time=$((end_time - start_time))
echo "Execution time: $execution_time seconds"
exit 0
