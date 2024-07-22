#!/usr/bin/env bash
# Installer to install dependencies
# If not used scripts will tell you what they need

# Install sudo to use it in the following scripts.
# If you use something different put it into the alias

#alias sudo=''

if ! [ "$(command -v sudo)" ]; then
        apt update
        apt install sudo
fi

sudo apt update

# Install curl
if ! [ "$(command -v curl)" ]; then
        sudo apt install curl -y
fi

# Install nala for a better apt interface
if ! [ "$(command -v nala)" ]; then
        curl https://gitlab.com/volian/volian-archive/-/raw/main/install-nala.sh | bash
        # sudo apt install -t nala nala
fi

# Install loud-gain to add Replay-gain to audio-tracks
if ! [ "$(command -v loudgain)" ]; then
        sudo nala install loudgain
fi

# Install gpg to work with gpg-keys and such
if ! [ "$(command -v gpg)" ]; then
        sudo nala install gpg -y
fi

# Install eza. A modern, maintained replacement for ls
if ! [ "$(command -v eza)" ]; then
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo nala update
        sudo nala install -y eza
fi

# Install System monitoring tool
if ! [ "$(command -v btop)" ];then
        sudo nala install btop
fi

# Install GPU monitoring tool
if lspci | grep -i "VGA compatible controller" | grep -i nvidia > /dev/null; then
        sudo nala install nvtop
elif lspci | grep -i "VGA compatible controller" | grep -i amd > /dev/null; then
        sudo nala install radeontop
fi

# Install Shellcheck to get Spellcheck for bash-script syntax
if ! [ "$(command -v shellcheck)" ]; then
        sudo nala install shellcheck
fi

# Install pipx to have an easier time with python-based Apps
if ! [ "$(command -v pipx)" ]; then
        sudo nala install pipx
fi

# Install gallery-dl with pipx (apt's version is too old)
if ! [ "$(command -v gallery-dl)" ]; then
        pipx install gallery-dl
fi

# Install yt-dlp with pipx (apt's version is too old)
if ! [ "$(command -v yt-dlp)" ]; then
        pipx install yt-dlp
fi
