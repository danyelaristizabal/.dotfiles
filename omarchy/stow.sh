#!/bin/bash

# Stow all directories in the current directory except "arch", "macosx", and "stow.sh" itself

for dir in .*/ */; do
  dirname="${dir%/}"
  if [[ -d "$dirname" && "$dirname" != "." && "$dirname" != ".." ]]; then
    echo "Stowing $dirname..."
    stow -t ~ "$dirname"
  fi
done
