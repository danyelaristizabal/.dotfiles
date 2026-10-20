#!/bin/bash

# Remove default shell files that macOS creates on a fresh install so stow can symlink them
rm -f "$HOME/.zshrc" "$HOME/.zprofile"

for dir in */ ; do
    dirname="${dir%/}"
    if [[ -d "$dirname" ]]; then
        echo "Stowing $dirname..."
        stow -t "$HOME" "$dirname"
    fi
done
