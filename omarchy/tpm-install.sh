#!/usr/bin/env bash

# Default TPM path
TPM_DIR="$HOME/.tmux/plugins/tpm"

echo "🔍 Checking for Tmux Plugin Manager (TPM)..."

# Check if TPM is already installed
if [ -d "$TPM_DIR" ]; then
    echo "✅ TPM already installed at $TPM_DIR"
else
    echo "⚡ TPM not found. Installing..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"

    if [ $? -eq 0 ]; then
        echo "✅ TPM installed successfully at $TPM_DIR"
        echo "👉 Remember: Reload tmux config with <prefix> + I (capital i) to install plugins."
    else
        echo "❌ Failed to install TPM. Please check your git/network setup."
        exit 1
    fi
fi

