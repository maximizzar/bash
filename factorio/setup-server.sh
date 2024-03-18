#! /bin/bash

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
	SERVICE_NAME=${DOMAIN}.${HOSTNAME}.service
fi

mkdir -pv "${GAME_DIR}"
cd "${GAME_DIR}" || exit 1

echo "HOSTNAME: ${HOSTNAME}"
echo "DOMAIN: ${DOMAIN}"
echo "SYSTEMD_PATH: ${SYSTEMD_PATH}"
echo "GAME_BASE_DIR: ${GAME_BASE_DIR}"
echo "GAME_DIR: ${GAME_DIR}"

#wget --no-verbose --continue --show-progress --no-dns-cache --xattr --content-disposition https://raw.githubusercontent.com/maximizzar/bash/master/factorio/update.sh
#chmod +x updater.sh
#./updater.sh

read -p "Enter to create systemd service: (CTRL+C to stop)"

cat <<EOF > "${SYSTEMD_PATH}/${SERVICE_NAME}"
[Unit]
Description=k2se.factorio.maximizzar.io

[Service]
ExecStart=/srv/k2se/factorio/bin/x64/factorio --start-server-load-latest --server-settings /srv/k2se/factorio/data/server-settings.json
User=factorio
Type=simple
Restart=on-failure
RestartSec=16

[Install]
WantedBy=multi-user.target
EOF

systemctl enable "${SERVICE_NAME}"