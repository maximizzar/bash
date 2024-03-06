#!/bin/bash

# set flag if crunchy-cli is installed
crunchy_cli_exists=$(command -v crunchy-cli >/dev/null 2>&1 && echo true || echo false)

# if crunchy-cli is installed save it's version
if [ "$crunchy_cli_exists" ]; then
    crunchy_cli_version=$(crunchy-cli --version);
fi

# get latest release_tag from Github
latest_release="https://api.github.com/repos/crunchy-labs/crunchy-cli/releases/latest"
latest_release_tag=$(curl --silent "$latest_release" | # Get latest release from GitHub api
  grep '"tag_name":' |                                 # Get tag line
  sed -E 's/.*"([^"]+)".*/\1/'                         # Pluck JSON value
);

if [ "$crunchy_cli_exists" ]; then
  if [[ "$crunchy_cli_version//v/" == *"${latest_release_tag//v/}"* ]]; then
    echo "Latest Version is already installed."
    exit 1
  fi
    # Move old version in users home dir
    mv "/usr/bin/crunchy-cli" "$HOME/crunchy-cli-$version"
fi

# Get new Version from github and make it executable
wget -O "/usr/bin/crunchy-cli" "https://github.com/crunchy-labs/crunchy-cli/releases/download/$latest_release_tag/crunchy-cli-$latest_release_tag-$arch"
chmod +x "/usr/bin/crunchy-cli"

exit 0
