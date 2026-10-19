#!/bin/bash

# Arch Linux Installation Script
# Installs packages using pacman and AUR helper (yay)

# --- CONFIGURATION ---
DOTFILES_DIR="$HOME/.dotfiles"
STOW_TARGET="$HOME"
STOW_PACKAGES=(tmux gitconfig nvim wezterm zprofile zshrc)

# Core packages available in official Arch repositories
PACMAN_PACKAGES=(
    "git"
    "go"
    "neovim"
    "nodejs"
    "npm"
    "python"
    "python-pip"
    "ripgrep"
    "ruby"
    "stow"
    "tmux"
    "tree"
    "wget"
    "yarn"
    "gnome-keyring"
    "zsh"
    "unbound"
    "luarocks"
    "lua"
)

# AUR packages (require AUR helper like yay)
AUR_PACKAGES=(
    "golangci-lint"
    "gotests"
    "lazygit"
    "luaver"
    "mockery"
    "ollama"
    "pass"
    "tmuxinator"
    "tree-sitter"
    "yazi"
    "zsh-theme-powerlevel10k-git"
    "oh-my-zsh-git"
    "lazydocker"
)

TMUX_PLUGIN_PATH="$HOME/.tmux/plugins/tpm"
TMUX_PLUGIN_REPO="https://github.com/tmux-plugins/tpm"

# --- HELPER FUNCTIONS ---

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_yay() {
    if ! command_exists yay; then
        echo "📦 Installing yay AUR helper..."
        cd /tmp || exit 1
        git clone https://aur.archlinux.org/yay.git
        cd yay || exit 1
        makepkg -si --noconfirm
        cd "$HOME" || exit 1
        rm -rf /tmp/yay
    else
        echo "✅ yay already installed"
    fi
}

install_pacman_packages() {
    echo "📦 Installing packages with pacman..."
    sudo pacman -Syu --noconfirm
    for package in "${PACMAN_PACKAGES[@]}"; do
        echo "Installing $package..."
        sudo pacman -S --noconfirm "$package" || echo "⚠️ Failed to install $package"
    done
}

install_aur_packages() {
    if command_exists yay; then
        echo "📦 Installing AUR packages with yay..."
        for package in "${AUR_PACKAGES[@]}"; do
            echo "Installing $package..."
            yay -S --noconfirm "$package" || echo "⚠️ Failed to install $package"
        done
    else
        echo "⚠️ yay not found. Skipping AUR packages installation."
    fi
}

clone_tmux_plugin_manager() {
    if [ ! -d "$TMUX_PLUGIN_PATH" ]; then
        echo "📥 Cloning tmux plugin manager..."
        git clone "$TMUX_PLUGIN_REPO" "$TMUX_PLUGIN_PATH"
    else
        echo "✅ tmux plugin manager already exists"
    fi
}

stow_packages() {
    if command_exists stow; then
        echo "🔗 Stowing packages..."
        cd "$DOTFILES_DIR" || exit 1
        for package in "${STOW_PACKAGES[@]}"; do
            echo "Stowing $package..."
            stow -t "$STOW_TARGET" -v "$package"
        done
    else
        echo "⚠️ stow not found. Install it first with: sudo pacman -S stow"
    fi
}

setup_python_packages() {
    echo "🐍 Installing Python packages..."
    pip install --user pipx
    
    # Add pipx to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
    fi
}

setup_node_packages() {
    echo "📦 Installing global Node.js packages..."
    npm install -g @anthropic-ai/claude-code
}

# --- MAIN SCRIPT ---

echo "🐧 Starting Arch Linux dotfiles installation..."

# Update system first
echo "🔄 Updating system..."
sudo pacman -Syu --noconfirm

# Install yay AUR helper
install_yay

# Install core packages from official repositories
install_pacman_packages

# Install AUR packages
install_aur_packages

# Set up Python environment
setup_python_packages

# Set up Node.js packages
setup_node_packages

# Clone tmux plugin manager
clone_tmux_plugin_manager

# Stow dotfiles
stow_packages

# Set up shell alias
echo "🔧 Setting up vim alias..."
if ! grep -q "alias vim='nvim'" ~/.zshrc 2>/dev/null; then
    echo "alias vim='nvim'" >> ~/.zshrc
fi

# Enable and start gnome-keyring if not already running
echo "🔐 Setting up gnome-keyring..."
systemctl --user enable gnome-keyring-daemon.service || true

echo "✅ Arch Linux installation complete!"
echo "🔄 Please restart your terminal or run 'source ~/.zshrc' to apply changes"
echo "📝 Note: Some AUR packages might require manual configuration"
