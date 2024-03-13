#!/bin/bash
echo "Only when .bashrc and .bash_aliases respectively removed, the script will pull configs remotely."
read -m "Press Enter to proceed: "

echo "Set Bash config"
wget --no-clobber https://raw.githubusercontent.com/maximizzar/bash/master/.bash_aliases
wget --no-clobber https://raw.githubusercontent.com/maximizzar/bash/master/.bashrc

if [ $UID != 0 ] then; {
    echo "Please login as admin"
    exit 1;
}

echo "Install repos"
if ! [ -f "/etc/apt/sources.list.d/volian-archive-scar-unstable.list" ]; then
    echo "deb http://deb.volian.org/volian/ scar main" | tee /etc/apt/sources.list.d/volian-archive-scar-unstable.list
    wget -qO - https://deb.volian.org/volian/scar.key | tee /etc/apt/trusted.gpg.d/volian-archive-scar-unstable.gpg
fi

if ! [ -f "/etc/apt/sources.list.d/gierens.list" ]; then
    mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list
    chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
fi

echo "Install tools"
apt update
apt install -y colordiff btop nala eza fzf neofetch
