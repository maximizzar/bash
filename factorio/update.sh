#!/bin/bash
source config

if ! [ -e "config" ]; then
    echo "No config file found"
    exit 1
fi

FACTORIO_REMOTE="https://factorio.com/get-download/latest/headless/linux64"

# if first installation create dir
if ! [ -e "${GAME_DIR}" ]; then
        mkdir -pv ${GAME_DIR}
fi

cd "${GAME_DIR}" || exit 1

if [ -d "${GAME_DIR}/factorio}" ]; then
    SERVER_OLD_VERSION=$(${GAME_DIR}/factorio/bin/x64/factorio --version | grep -oP 'Version: \K\d+\.\d+\.\d+')
    SERVER_NEW_VERSION=$(wget -S --spider "${FACTORIO_REMOTE}" 2>&1 | grep 'Location' | awk '{print $2}' | grep -oP '(\d+\.\d+\.\d+)' | head -1)

    echo "local version: ${SERVER_OLD_VERSION}"
    echo "remote version: ${SERVER_NEW_VERSION}"

    if [ "${SERVER_OLD_VERSION}" == "${SERVER_NEW_VERSION}" ]; then
            echo "Server is upto Date!"
            exit 1;
    fi

    sudo systemctl stop "${SERVICE_NAME}"

    echo "Backup old (local) Server-files"
    tar -cvf "factorio-${SERVER_OLD_VERSION}.tar" factorio
fi

echo "Install new (remote) Server-files"
wget --no-verbose -O factorio.tar.xz ${FACTORIO_REMOTE}
tar --overwrite -xvf factorio.tar.xz
chmod +x factorio/bin/x64/factorio

rm factorio.tar.xz

# Deal with the json config example files
for example_file in "${GAME_DIR}/factorio/data/*.example.json"; do
    output_file="${example_file%.example.json}.json"

    if [ -e "${output_file}" ]; then
        rm "${example_file}"
    else
        mv "${example_file}" "${output_file}"
        nano "${output_file}"
    fi
done

echo "Start Server"
sudo systemctl start "${SERVICE_NAME}"
exit 0
