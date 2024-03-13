#!/bin/bash

read -p "Enter Server:" SERVER_NAME
read -p "Enter Domainname:" DOMAIN_NAME

read -p "Enter base dir (eg. srv): " BASE_DIR
read -p "Enter a username, the server should run under." SERVER_USER

SYSTEMD_FACTORIO_SERVICES='etc/systemd/system/factorio'

if ! [ id "$SERVER_USER" &>/dev/null ]; then
    useradd $SERVER_USER
fi

if ! [ command -v "sudo" >/dev/null 2>&1 ]; then
    apt install sudo
fi

# setup systemd service
mkdir -pv "/$SYSTEMD_FACTORIO_SERVICES"
touch "/$SYSTEMD_FACTORIO_SERVICES/$SERVER_NAME.$DOMAIN_NAME.service"
cat <<EOF > "/$SYSTEMD_FACTORIO_SERVICES/$SERVER_NAME.$DOMAIN_NAME.service"
[Unit]
Description=$SERVER_NAME.$DOMAIN_NAME.service

[Service]
ExecStart=/$BASE_DIR/$SERVER_NAME/factorio/bin/x64/factorio --start-server-load-latest --server-settings /$BASE_DIR/$SERVER_NAME/factorio/data/server-settings.json
User=$SERVER_USER
Type=simple
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl enable /$SYSTEMD_FACTORIO_SERVICES/$SERVER_NAME.$DOMAIN_NAME.service

setup_server() {
    mkdir -pv /$BASE_DIR/$SERVER_NAME
    cd /$BASE_DIR/$SERVER_NAME
    wget -O "$SERVER_NAME.$DOMAIN_NAME" https://factorio.com/get-download/latest/headless/linux64
    tar -xvf "$SERVER_NAME.$DOMAIN_NAME.tar" factorio/
    chmod +x /$BASE_DIR/$SERVER_NAME.$DOMAIN_NAME/factorio/bin /x64/factorio
    rm $SERVER_NAME.$DOMAIN_NAME.tar factorio/data/*example.json
}

sudo -u $SERVER_USER setup_server

# create update script
touch "/$BASE_DIR/$SERVER_NAME/update.sh"
cat <<EOF <"/$BASE_DIR/$SERVER_NAME/update.sh"
systemctl stop $SERVER_NAME.$DOMAIN_NAME.service

cd /$BASE_DIR/$SERVER_NAME
sudo -u $SERVER_USER OLD_SERVER_VERSION=$'(./$BASE_DIR/$SERVER_NAME/factorio/bin/x64/factorio --version | grep -oP "Version: \K\d+\.\d+\.\d+")'
sudo -u $SERVER_USER tar -cvf $OLD_SERVER_VERSION factorio

setup_server() {
    mkdir -pv /$BASE_DIR/$SERVER_NAME
    cd /$BASE_DIR/$SERVER_NAME
    wget -O "$SERVER_NAME.$DOMAIN_NAME" https://factorio.com/get-download/latest/headless/linux64
    tar -xvf "$SERVER_NAME.$DOMAIN_NAME.tar" factorio/
    chmod +x /$BASE_DIR/$SERVER_NAME.$DOMAIN_NAME/factorio/bin /x64/factorio
    rm $SERVER_NAME.$DOMAIN_NAME.tar factorio/data/*example.json
}

sudo -u $SERVER_USER setup_server

systemctl start $SERVER_NAME.$DOMAIN_NAME.service
EOF