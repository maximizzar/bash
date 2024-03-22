#! /bin/bash

echo "Importand: What you need before running this script."
echo "At best a new user. That user needs sudo privileges. Those are needed maily to deal with systemd service creation and than the start and stop process"

# Hostname
read -p "Enter the servers hostname (how the game-server gets called):" HOSTNAME
if [ "${HOSTNAME}" == "" ]; then
    exit 1
fi

# Domain
read -p "Enter the Domain under with the Server will be served (can be empty if not configured):" DOMAIN

# Systemd service config path
SYSTEMD_PATH="/etc/systemd/system"

# Factorio game-servers base path
echo -e "Don't provide sub dirs i.e. just type '/home/USER' and not '/home/USER/factorio-server-01' or something like that.\nIf you install many servers and want them in a servers dir, then you need to append that here."
read -p "Enter the game base path (if empty the script uses pwd):" GAME_BASE_DIR
if [ "${GAME_BASE_DIR}" == "" ]; then
    GAME_BASE_DIR="$(pwd)"
fi

if [ "${DOMAIN}" == "" ]; then
	GAME_DIR="${GAME_BASE_DIR}/${HOSTNAME}"
	SERVICE_NAME=${HOSTNAME}.service
else
	GAME_DIR="${GAME_BASE_DIR}/${DOMAIN}/${HOSTNAME}"
	SERVICE_NAME=${HOSTNAME}.${DOMAIN}.service
fi

# Create Directory Structure for Server installation
mkdir -pv "${GAME_DIR}"
cd "${GAME_DIR}" || exit 1
{
    echo "HOSTNAME=${HOSTNAME}"
    echo "DOMAIN=${DOMAIN}"
    echo "SYSTEMD_PATH=${SYSTEMD_PATH}"
    echo "GAME_BASE_DIR=${GAME_BASE_DIR}"
    echo "GAME_DIR=${GAME_DIR}"
    echo "SERVICE_NAME=${SERVICE_NAME}"
} >> config

# Create Systemd service
sudo cat >"${SYSTEMD_PATH}/${SERVICE_NAME}" <<EOF
[Unit]
Description=A Factorio Game-Server at: ${HOSTNAME}.${DOMAIN}.

[Service]
ExecStart=${GAME_DIR}/factorio/bin/x64/factorio --start-server-load-latest --server-settings ${GAME_DIR}/factorio/data/server-settings.json
User="$(whoami)"
Type=simple
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable ${SERVICE_NAME}

# Create world-gen script
cat >"${GAME_DIR}/world-gen.sh" <<EOF
sudo systemctl stop ${SERVICE_NAME}
${GAME_DIR}/factorio/bin/x64/factorio --create ${GAME_DIR}/factorio/saves/world.zip --map-gen-settings ${GAME_DIR}/factorio/data/map-gen-settings.json
sudo systemctl start ${SERVICE_NAME}
EOF
chmod world-gen.sh

# Download update script, make it executable and run it to install the actual server
wget --no-verbose --continue --show-progress --no-dns-cache --xattr --content-disposition https://raw.githubusercontent.com/maximizzar/bash/master/factorio/update.sh
chmod +x update.sh
./update.sh
