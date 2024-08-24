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
