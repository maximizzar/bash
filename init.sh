#!/usr/bin/env bash

# Install .bashrc
if [ -f "$HOME/.bashrc" ]; then
        # Backup current .bashrc
        mv "$HOME/.bashrc" "$HOME/.bashrc.old"
fi
ln -s "$(pwd)/.bashrc" "$HOME/.bashrc"

# Install .bash_aliases
if [ -f "$HOME/.bash_aliases" ]; then
        # Backup current .bash_aliases
        mv "$HOME/.bash_aliases" "$HOME/.bash_aliases.old"
fi
ln -s "$(pwd)/.bash_aliases" "$HOME/.bash_aliases"

# Install Extract function
if ! [ -f "/usr/local/bin/extract" ]; then
        wget https://raw.githubusercontent.com/xvoland/Extract/master/extract.sh
        mv extract.sh extract
        chmod +x extract
        mv extract /usr/local/bin/
fi

# Install convert video to av1
if ! [ -f "/usr/local/bin/convert-video-2-av1" ]; then
        ln -s "$(pwd)/media/convert-video-2-av1.sh" "/usr/local/bin/convert-video-2-av1"
fi

# Install convert wav to flac
if ! [ -f "/usr/local/bin/convert-wav-2-flac" ]; then
        ln -s "$(pwd)/media/convert-wav-2-flac.sh" "/usr/local/bin/convert-wav-2-flac"
fi

# Install extract audio from video
if ! [ -f "/usr/local/bin/extract-afv" ]; then
        ln -s "$(pwd)/media/extract-afv.sh" "/usr/local/bin/extract-afv"
fi
