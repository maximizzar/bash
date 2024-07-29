#!/usr/bin/env bash

sudo apt update


# get_upscayl_nncc_url
api="https://api.github.com/repos/upscayl/upscayl-ncnn/releases/latest"
tag_name="$(curl --silent "$api" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')"
upscayl_nncc_url="https://github.com/upscayl/upscayl-ncnn/releases/tag/$tag_name/upscayl-bin-$tag_name-linux.zip"

if ! [ "$(command -v ffmpeg)" ]; then
        echo "Install ffmpeg!"
        sudo apt install -y ffmpeg
fi

if ! [ "$(command -v curl)" ]; then
        echo "Install curl"
        sudo apt install -y curl
fi

if ! [ "$(command -v zip)" ]; then
        echo "Install zip"
        sudo apt install -y zip
fi

if ! [ "$(command -v git)" ]; then
        echo "Install git"
        sudo apt install -y git
fi

if ! [ "$(command -v upscayl)" ]; then
        # Install upscayl dependencies
        sudo apt install -y libvulkan1 libgomp1

        echo "Install upscayl"
        (
                cd /tmp || exit 1
                wget "$upscayl_nncc_url"
                unzip "upscayl-bin-$tag_name-linux.zip"
                sudo chmod +x "upscayl-bin-$tag_name-linux/upscayl-bin"
                sudo mv "upscayl-bin-$tag_name-linux/upscayl-bin" "/usr/local/bin/upscayl"
        )

        echo "Install Default Models"
        (
                cd /tmp || exit
                git clone https://github.com/upscayl/custom-models.git
                cd custom-models || exit 1
                sudo mv "models" "/opt"
        )
fi
