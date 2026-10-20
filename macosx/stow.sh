#!/bin/bash

# Remove files/dirs that macOS or apps create on a fresh install so stow can symlink them
rm -f "$HOME/.zshrc" "$HOME/.zprofile"
rm -rf "$HOME/.config/ghostty"

for dir in */ ; do
    dirname="${dir%/}"
    if [[ -d "$dirname" ]]; then
        echo "Stowing $dirname..."
        stow -t "$HOME" "$dirname"
    fi
done
