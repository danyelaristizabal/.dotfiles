#!/bin/bash

# Remove files/dirs that macOS or apps create on a fresh install so stow can symlink them
rm -f "$HOME/.zshrc" "$HOME/.zprofile"

mkdir -p "$HOME/.config"

rm -rf "$HOME/.config/ghostty"

for dir in */ ; do
    dirname="${dir%/}"
    # ghostty shares ~/.config with nvim (stowed from root), causing ownership conflicts — symlink directly
    if [[ "$dirname" == "ghostty" ]]; then
        echo "Symlinking ghostty..."
        ln -sfn "$HOME/.dotfiles/macosx/ghostty/.config/ghostty" "$HOME/.config/ghostty"
        continue
    fi
    if [[ -d "$dirname" ]]; then
        echo "Stowing $dirname..."
        stow --no-folding -t "$HOME" "$dirname"
    fi
done
