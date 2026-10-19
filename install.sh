#!/bin/bash

# OS Detection and Package Installation Script
# This script detects the operating system and runs the appropriate installation script

# --- CONFIGURATION ---
DOTFILES_DIR="$HOME/.dotfiles"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Common packages that need to be installed on all systems
COMMON_PACKAGES=(
    "git"
    "go"
    "golangci-lint"
    "gotests"
    "lazygit"
    "luaver"
    "luarocks"
    "mockery"
    "neovim"
    "node"
    "ollama"
    "pass"
    "python"
    "ripgrep"
    "stow"
    "tmux"
    "tmuxinator"
    "tree"
    "tree-sitter"
    "unbound"
    "wget"
    "yarn"
    "yazi"
)

# --- HELPER FUNCTIONS ---

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macosx"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command_exists pacman; then
            echo "arch"
        else
            echo "linux"
        fi
    else
        echo "unknown"
    fi
}

# --- MAIN SCRIPT ---

echo "🔍 Detecting operating system..."
OS=$(detect_os)

bash "stow.sh"

case $OS in
"macosx")
    echo "🍎 macOS detected - running macOS installer"
    if [[ -f "$SCRIPT_DIR/macosx/install.sh" ]]; then
        bash "$SCRIPT_DIR/macosx/install.sh"
    else
        echo "❌ macOS installer script not found at $SCRIPT_DIR/macosx/install.sh"
        exit 1
    fi
    ;;
"arch")
    echo "🐧 Arch Linux detected - running Arch installer"
    if [[ -f "$SCRIPT_DIR/arch/install.sh" ]]; then
        bash "$SCRIPT_DIR/arch/install.sh"
    else
        echo "❌ Arch Linux installer script not found at $SCRIPT_DIR/arch/install.sh"
        exit 1
    fi
    ;;
"linux")
    echo "🐧 Arch Linux detected - running Arch installer"
    if [[ -f "$SCRIPT_DIR/arch/install.sh" ]]; then
        bash "$SCRIPT_DIR/arch/install.sh"
    else
        echo "❌ Arch Linux installer script not found at $SCRIPT_DIR/arch/install.sh"
        exit 1
    fi
    ;;
*)
    echo "❌ Unsupported operating system: $OSTYPE"
    echo "Supported systems: macOS, Arch Linux"
    exit 1
    ;;
esac

echo "✅ Installation complete!"
