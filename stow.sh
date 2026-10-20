#!/bin/bash

# Stow all directories in the current directory except "arch", "macosx", and "stow.sh" itself

# Remove dirs that apps create on a fresh install so stow can symlink them
mkdir -p "$HOME/.config"
rm -rf "$HOME/.config/ghostty"

for dir in */; do
  dirname="${dir%/}"
  # Skip unwanted directories and the script itself
  if [[ "$dirname" == "arch" ]] || [[ "$dirname" == "macosx" ]] || [[ "$dirname" == "omarchy" ]] || [[ "$dirname" == "stow.sh" ]]; then
    continue
  fi
  if [[ -d "$dirname" ]]; then
    echo "Stowing $dirname..."
    stow --no-folding "$dirname"
  fi
done
