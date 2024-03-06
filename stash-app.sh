#!/bin/bash

executable_name="stash-app"
executable_path="/bin/$executable_name"
executable_exists=$(command -v "$executable_name" >/dev/null 2>&1 && echo true || echo false)

service_name="$executable_name.service"
service_path="/etc/systemctl/system/$service_name"
service_exists=$(command -v "cat $executable_path" >/dev/null 2>&1 && echo true || echo false)

if [ "$executable_exists" ]; then
	executable_version=$($executable_name --version)
fi

# build service
if ! [ "$service_exists" ]; then

cat > "$service_path" <<EOF
[Unit]
Description=$executable_name Server

[Service]
ExecStart=$service_path
User=root
Type=simple
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target

EOF

	systemctl enable $service_name
else
 	systemctl stop $service_name
fi

# get latest release tag from Github
latest_release_api="https://api.github.com/repos/stashapp/stash/releases/latest"
latest_release_tag=$(curl --silent "$latest_release_api" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ "$executable_exists" ]; then
	if [[ "$executable_version//v/" == *"${latest_release_tag}"* ]]; then
		echo "Latest Version is already installed."
		exit 1
	fi
	# Move old version in service_users home dir
	mv "/bin/$executable_name" "$HOME/$executable_name:$executable_version"
fi

# Set correct architecture based on the System
case "$(uname -m)" in
x86_64)
	arch="stash-linux"
	;;
armel)
	arch="stash-linux-arm32v6"
	;;
armhf)
	arch="stash-linux-arm32v7"
	;;
arm64)
	arch="stash-linux-arm64v8"
	;;
esac

# Get new Version from github and make it executable
wget -O "$executable_path" "https://github.com/stashapp/stash/releases/tag/$latest_release_tag/$arch"
chmod +x "$executable_path"

exit 0
