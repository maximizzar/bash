#!/usr/bin/env bash
# This script fills the environment variables from the .env into the json.
# The final config will be saved under "~/.config/gallery-dl/config.json"

# Make sure the config directory exists
mkdir -p "$HOME/.config/gallery-dl"

# Check if .env file exists
if ! [ -f "$HOME/.config/gallery.dl/.env" ]; then
        echo "Go to ~/.config/gallery.dl/.env and fill all keys you need!"
        cp "$(pwd)/.env" "$HOME/.config/gallery-dl/"
        exit 0
fi

# Force a Image Directory
IMAGE_DIR=""

if [ "$IMAGE_DIR"  == "" ]; then
        # Get the user's pictures directory
        IMAGE_DIR=$(xdg-user-dir PICTURES)
fi
mkdir "$IMAGE_DIR"

# Check if jq is installed
if ! [ "$(command -v jq)" ]; then
        echo "Please install jq!"
        exit 1
fi

# Use jq to update the base-directory key in the JSON
jq --arg baseDir "$IMAGE_DIR" '.["base-directory"] = $baseDir' config.json > /tmp/config.json

# Source the configuration file
source "$HOME/.config/gallery-dl/.env"

# Use envsubst to substitute variables in the template JSON
envsubst < "/tmp/config.json" > "$HOME/.config/gallery-dl/config.json"
