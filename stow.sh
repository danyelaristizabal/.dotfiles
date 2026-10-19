#!/bin/bash

# Stow all directories in the current directory except "arch", "macosx", and "stow.sh" itself

for dir in */; do
  dirname="${dir%/}"
  # Skip unwanted directories and the script itself
  if [[ "$dirname" == "arch" ]] || [[ "$dirname" == "macosx" ]] || [[ "$dirname" == "omarchy" ]] || [[ "$dirname" == "stow.sh" ]]; then
    continue
  fi
  if [[ -d "$dirname" ]]; then
    echo "Stowing $dirname..."
    stow "$dirname"
  fi
done
