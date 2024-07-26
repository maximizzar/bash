#!/usr/bin/env bash

if ! [ "$(command -v git)" ]; then
        echo "Install git!"
        exit 1
fi

cd "$HOME/bash" || exit 1
git pull
