#!/bin/bash

# get latest release tag from Github
latest_release_api="https://api.github.com/repos/stashapp/stash/releases/latest"
latest_release_tag=$(wget -qO- "${latest_release_api}" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

# you may want to change some vars to fit your environment better
EXECUTABLE="stash-app"
EXECUTABLE_EXISTS=$(command -v "${EXECUTABLE}" >/dev/null 2>&1 && echo true || echo false)
if [ "${EXECUTABLE_EXISTS}" ]; then
        EXECUTABLE_VERSION=$(${EXECUTABLE} --version | grep -oP 'v\d+\.\d+\.\d+')
        if [[ "${EXECUTABLE_VERSION}//v/" == *"${latest_release_tag}"* ]]; then
                echo "Latest Version is already installed."
                exit 1
        fi
fi
SERVICE="/etc/systemd/system/${EXECUTABLE}.service"

echo "latest_release_api: ${latest_release_api}"
echo "latest_release_tag: ${latest_release_tag}"

echo "EXECUTABLE: ${EXECUTABLE}"
echo "EXECUTABLE_EXISTS: ${EXECUTABLE_EXISTS}"
echo "EXECUTABLE_VERSION: ${EXECUTABLE_VERSION}"
echo "SERVICE: ${SERVICE}"

read -n 1 -s -r -p "If you're okay with those settings, press any key to continue..."

if  [ -e "${SERVICE}" ]; then
    systemctl stop ${EXECUTABLE}.service
fi

if [ "${EXECUTABLE_EXISTS}" ]; then
        # Move old version
        mv "/bin/${EXECUTABLE}" "./${EXECUTABLE}-${EXECUTABLE_VERSION}"
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
wget --no-verbose --continue --show-progress --no-dns-cache --xattr --content-disposition -O "/bin/${EXECUTABLE}" "https://github.com/stashapp/stash/releases/download/${latest_release_tag}/${arch}"
chmod +x "/bin/${EXECUTABLE}"

if  [ -e "${SERVICE}" ]; then
    systemctl start ${EXECUTABLE}.service
    exit 0
fi

# build service
cat >"/etc/systemd/system/${EXECUTABLE}.service" <<EOF
[Unit]
Description=Stash-app service

[Service]
ExecStart=/bin/${EXECUTABLE}
User=root
Type=simple
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl enable "${EXECUTABLE}.service"
systemctl start "${EXECUTABLE}.service"
