# Bash

It's all about the bash config and scripts


## scripted-upscayl
With scripted-upscayl you can use upscayl in the cli to upscale videos.
To do that the script uses ffmpeg and scales every video frame up.

### scripted-upscayl: Installation
Apart from the script you need:
- git to clone the custom-models repo (can be done manuly w/o git)
- ffmpeg to Extract the video frames and encode the output video-stream
- upscayl it-self

Now you're not quiet done. You need to put the upscayl into and bin dir.
I recommend /usr/local/bin.
If you don't want to move the file, create a symlink.
```
ln -s /opt/Upscayl/upscayl-bin /usr/local/bin/upscayl
```
Please check if you're upscayl is in the same dir. 
If not you need to change the first path.

### scripted-upscayl: Usage
When using the script, you need to provide a source Video.

Imported, you should create an cache dir e.g. /mnt/cache where you put the script and execute it from.
The working-dir is a very imported, because models and frames will be saved in here.

If you process multiple videos, you only need to worry about disk-usage.
The videos will be processed in separate sub-dirs.
