#!/bin/bash

echo "Set Vars"
FACTORIO_REMOTE='https://factorio.com/get-download/latest/headless/linux64'
FACTORIO_GAME_DIR='/home/factorio/k2se'

echo "Halt Server"
systemctl stop k2se.factorio.maximizzar.io.service

if [ -e "${FACTORIO_GAME_DIR}" ]; then
        echo "Archive Local Server"
        cd "${FACTORIO_GAME_DIR}" || exit 1
        SERVER_OLD_VERSION=$(/home/factorio/k2se/factorio/bin/x64/factorio --version | grep -oP 'Version: \K\d+\.\d+\.\d+')
        SERVER_NEW_VERSION=$(wget -S --spider "${FACTORIO_REMOTE}" 2>&1 | grep 'Location' | awk '{print $2}' | grep -oP '(\d+\.\d+\.\d+)(?=_)')

        echo "${SERVER_OLD_VERSION}" | hexdump -c
        echo "${SERVER_NEW_VERSION}" | hexdump -c

        if [ "${SERVER_OLD_VERSION}" = "${SERVER_NEW_VERSION}" ]; then
                echo 'Server is upto Date!'
                exit 1;
        fi

        # Backup old (local) Server-files
        tar -cvf "factorio: ${SERVER_OLD_VERSION}.tar" factorio
else
        mkdir -pv "${FACTORIO_GAME_DIR}"
fi

# Install new (remove) Server-files
#wget -O "factorio.tar" "${FACTORIO_REMOTE}"
#tar -xvf "factorio.tar" -C "factorio/"
#chmod +x "${FACTORIO_GAME_DIR}/factorio/bin/x64/factorio"

# Cleanup installation
#rm "factorio.tar"

if [[ -e "${FACTORIO_GAME_DIR}/factorio/data/*example.json" ]]; then
        rm "/home/factorio/k2se/factorio/data/*example.json"
fi

# Server restart
systemctl start k2se.factorio.maximizzar.io.service
