#!/bin/bash
FACTORIO_REMOTE="https://factorio.com/get-download/latest/headless/linux64"
FACTORIO_GAME_DIR="/home/factorio/k2se"

# if first installation create dir
if ! [ -e "${FACTORIO_GAME_DIR}" ]; then
        echo "Start to init Server"
        mkdir -pv ${FACTORIO_GAME_DIR}
fi

cd "${FACTORIO_GAME_DIR}" || exit 1
SERVER_OLD_VERSION=$(/home/factorio/k2se/factorio/bin/x64/factorio --version | grep -oP 'Version: \K\d+\.\d+\.\d+')
SERVER_NEW_VERSION=$(wget -S --spider "${FACTORIO_REMOTE}" 2>&1 | grep 'Location' | awk '{print $2}' | grep -oP '(\d+\.\d+\.\d+)' | head -1)

echo "local version: ${SERVER_OLD_VERSION}"
echo "remote version: ${SERVER_NEW_VERSION}"

if [ "${SERVER_OLD_VERSION}" == "${SERVER_NEW_VERSION}" ]; then
        echo "Server is upto Date!"
        exit 1;
fi

echo "Start updating process"

echo "Stop Server"
sudo systemctl stop k2se.factorio.maximizzar.io.service

echo "Backup old (local) Server-files"
tar -cvf "factorio_${SERVER_OLD_VERSION}.tar" factorio

echo "Install new (remove) Server-files"
wget --no-verbose -O factorio.tar.xz ${FACTORIO_REMOTE}
tar --overwrite -xvf factorio.tar.xz .
chmod +x factorio/bin/x64/factorio

echo "Cleanup installation"
rm factorio.tar.xz

if [[ -e factorio/data/*example.json ]]; then
        rm factorio/data/*example.json
fi

echo "Start Server"
sudo systemctl start k2se.factorio.maximizzar.io.service
exit 0
