#!/bin/bash
# Follows the setup guild for debian from docker.io

# Comment out if you want to get asked by apt.
YES_FLAG="-y"

# is curl installed?
if ! which curl >/dev/null; then
    echo "curl is not installed."
    apt install curl "$YES_FLAG"
fi

# is gpg install?
if ! which gpg >/dev/null; then
    echo "gpg is not installed."
    apt install gpg "$YES_FLAG"
fi

# Remove current container engine installations
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
  apt-get remove $pkg;
done

# 1. Update the apt package index and install packages to allow apt to use a repository over HTTPS
if ! { apt-get update 2>&1 || echo E: update failed; } | grep -q '^[WE]:'; then
    echo "Failed to update your System!";
    exit 1;
fi

if which gnupg <>/dev/null; then
        apt-get install ca-certificates curl gnupg "$YES_FLAG"
fi

# 2. Add Docker’s official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
if ! [ -f "/etc/apt/keyrings/docker.gpg" ]; then
        echo "Failed to download docker gpg key!"
        exit 1
fi
chmod a+r /etc/apt/keyrings/docker.gpg

# 3. Use the following command to set up the repository
echo \ "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 1. Update the apt package index
if ! { apt-get update 2>&1 || echo E: update failed; } | grep -q '^[WE]:'; then
    echo "Installed docker repository correctly.";
else
    echo "Failed to correctly install docker repository!";
    exit 1;
fi

# 2. Install Docker Engine, containerd, and Docker Compose
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Verify that the Docker Engine installation is successful
# by running the hello-world image
docker run --name hello-world-test hello-world

# Check the exit status
if [ $? -eq 0 ]; then
    echo "Docker is successfully installed."
    docker rm hello-world-test
    docker rmi hello-world
else
    echo "Docker installation failed!"
    docker rm hello-world-test
    # Don't delete hello-world so user can test without re-downloading
fi
