#!/bin/bash

echo "Set Bash config"
wget https://raw.githubusercontent.com/maximizzar/bash/master/.bash_aliases
wget https://raw.githubusercontent.com/maximizzar/bash/master/.bashrc

echo "Install repos"
if ! [ -f "/etc/apt/sources.list.d/volian-archive-scar-unstable.list" ]; then
    echo "deb http://deb.volian.org/volian/ scar main" | sudo tee /etc/apt/sources.list.d/volian-archive-scar-unstable.list
    wget -qO - https://deb.volian.org/volian/scar.key | sudo tee /etc/apt/trusted.gpg.d/volian-archive-scar-unstable.gpg
fi

if ! [ -f "/etc/apt/sources.list.d/gierens.list" ]; then
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
fi

echo "Install tools"
sudo apt update
sudo apt install -y colordiff btop nala eza fzf neofetch
