#!/bin/bash

executable_name="crunchy-cli"
executable_path="/usr/bin/$executable_name"
executable_exists=$(command -v "$executable_name" >/dev/null 2>&1 && echo true || echo false)

if [ "$executable_exists" ]; then
    executable_version=$($executable_name --version)
fi

# get latest release tag from Github
latest_release_api="https://api.github.com/repos/crunchy-labs/crunchy-cli/releases/latest"
latest_release_tag=$(curl --silent "$latest_release_api" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ "$executable_exists" ]; then
  if [[ "$executable_version//v/" == *"${latest_release_tag//v/}"* ]]; then
    echo "Latest Version is already installed."
    exit 1
  fi
  # Move old version in users home dir
  mv "/usr/bin/crunchy-cli" "$HOME/crunchy-cli-$executable_version"
fi

arch="linux-$(uname -m)"

# Get new Version from github and make it executable
wget -O "$executable_path" "https://github.com/crunchy-labs/crunchy-cli/releases/download/$latest_release_tag/$executable_name-$latest_release_tag-$arch"
chmod +x "$executable_path"

exit 0
