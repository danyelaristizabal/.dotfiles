#!/bin/bash

[[ -f "/opt/homebrew/bin/brew" ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Remove files/dirs that macOS or apps create on a fresh install so stow can symlink them
rm -f "$HOME/.zshrc" "$HOME/.zprofile"

mkdir -p "$HOME/.config"

for dir in */ ; do
    dirname="${dir%/}"
    if [[ -d "$dirname" ]]; then
        echo "Stowing $dirname..."
        stow --no-folding -t "$HOME" "$dirname"
    fi
done
