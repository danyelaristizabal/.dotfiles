#!/bin/bash

# Stow all directories in the current directory except "arch", "macosx", and "stow.sh" itself

for dir in */ ; do
    dirname="${dir%/}"
    if [[ -d "$dirname" ]]; then
        echo "Stowing $dirname..."
        stow -t "$HOME" "$dirname"
    fi
done
