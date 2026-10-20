#!/usr/bin/env bash
set -e
export NONINTERACTIVE=1

# macOS Installation Script
# Installs Homebrew, formulae, casks, and sets up dotfiles

# --- BOOTSTRAP ---

# Install Xcode Command Line Tools (includes git) if missing
if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    CLT=$(softwareupdate -l 2>/dev/null \
        | grep -E '\* Label: Command Line Tools' \
        | sed 's/^.*Label: //' \
        | sort -V | tail -n1)
    sudo softwareupdate -i "$CLT" --verbose
    rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
else
    echo "Xcode Command Line Tools already installed"
fi

# Clone dotfiles if not already present
if [ ! -d "$HOME/.dotfiles" ]; then
    git clone https://github.com/danyelaristizabal/.dotfiles.git "$HOME/.dotfiles"
fi

cd "$HOME/.dotfiles"

# --- CONFIGURATION ---
DOTFILES_DIR="$HOME/.dotfiles"

# Top-level formulae (deps are pulled in automatically)
BREW_PACKAGES=(
    # Dev tools
    "git"
    "gh"
    "go"
    "rust"
    "rustup"
    "yarn"   # js package manager alternative to npm
    "python" # latest stable; homebrew resolves the version

    # Neovim + LSP / tooling
    "neovim"
    "luarocks"          # Lua package manager; neovim needs it for some plugins
    "luaver"            # Lua version manager (like nvm but for Lua)
    "markdownlint-cli2" # lints .md files for style/formatting issues
    "marksman"          # markdown LSP: go-to-definition and completions in .md files
    "tree-sitter"

    # Shell / terminal utilities
    "stow"
    "tmux"
    "tmuxinator" # manages tmux sessions via YAML; define layouts, spin up with one command
    "ripgrep"    # fast grep replacement; used by neovim Telescope/fzf for file search
    "fd"         # fast and friendly replacement for find; used by neovim plugins
    "bat"
    "btop"
    "tree"
    "wget"      # download files from URLs; handles recursive downloads and resuming (curl is built-in on macOS)grep"
    "asciinema" # records terminal sessions and lets you share/replay them as text animations
    "yazi"      # terminal file manager

    # Go dev
    "golangci-lint"
    "gotests"

    # Secrets / security
    "pass"
    "gnupg"

    # Misc CLI tools
    "imagemagick" # CLI image conversion/manipulation (resize, format convert, etc.)
    "plantuml"
    "pipx" # installs Python CLI tools in isolated envs (won't pollute system Python)
    "k6"   # load testing
    "ollama"

    "fzf" # fuzzy finder: ctrl+r for history, ctrl+t for files, alt+c for dirs
    "gemini-cli"
    "lazygit"
    "clippy" # pipes files to clipboard for clean GUI pastes: cat file.txt | clippy
)

# GUI applications (casks)
BREW_CASKS=(
    # Browsers
    "firefox"
    "google-chrome"
    "vivaldi"

    # Development
    "visual-studio-code"
    "ghostty" # terminal
    "docker-desktop"
    "postman"
    "sublime-text"

    # AI tools
    "claude"
    "codex"

    # Communication
    "slack"
    "telegram"
    "whatsapp"

    # Productivity
    "raycast"      # spotlight replacement
    "bitwarden"    # password manager
    "hammerspoon"  # app-launcher keybindings; config at ~/.hammerspoon/init.lua

    # Media
    "spotify"
    "vlc"
    "obs"

    # Utilities
    "utm" # VMs on Apple Silicon

    # Other
    "anki" # flashcards
    "tradingview"


)

TMUX_PLUGIN_PATH="$HOME/.tmux/plugins/tpm"
TMUX_PLUGIN_REPO="https://github.com/tmux-plugins/tpm"

# --- HELPER FUNCTIONS ---

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_homebrew() {
    # Load brew into PATH if already installed but not in current shell PATH
    [[ -f "/opt/homebrew/bin/brew" ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    [[ -f "/usr/local/bin/brew" ]] && eval "$(/usr/local/bin/brew shellenv)"

    if ! command_exists brew; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add brew to PATH for Apple Silicon
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>"$HOME/.zprofile"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        echo "Homebrew already installed"
    fi
}

install_brew_packages() {
    echo "Installing brew formulae..."
    brew update
    for package in "${BREW_PACKAGES[@]}"; do
        if brew list --formula "$package" &>/dev/null; then
            echo "$package already installed, skipping"
        else
            echo "Installing $package..."
            yes | brew install "$package" || echo "Failed to install $package"
        fi
    done
}

install_brew_casks() {
    echo "Installing brew casks..."
    for cask in "${BREW_CASKS[@]}"; do
        if brew list --cask "$cask" &>/dev/null; then
            echo "$cask already installed, skipping"
        else
            echo "Installing $cask..."
            yes | brew install --cask "$cask" || echo "Failed to install $cask"
        fi
    done
}

clone_tmux_plugin_manager() {
    if [ ! -d "$TMUX_PLUGIN_PATH" ]; then
        echo "Cloning tmux plugin manager..."
        git clone "$TMUX_PLUGIN_REPO" "$TMUX_PLUGIN_PATH"
    else
        echo "tmux plugin manager already exists"
    fi
}

stow_packages() {
    if command_exists stow; then
        echo "Stowing dotfiles..."
        (cd "$DOTFILES_DIR" && bash stow.sh)
        (cd "$DOTFILES_DIR/macosx" && bash stow.sh)
    else
        echo "stow not found — install it first"
    fi
}

setup_mission_control() {
    echo "Enabling Mission Control switch-to-Space behavior..."
    defaults write com.apple.dock workspaces-auto-swoosh -bool YES
    killall Dock
}

setup_fzf() {
    if command_exists fzf; then
        if ! grep -q "fzf --zsh" "$HOME/.zshrc" 2>/dev/null; then
            echo 'eval "$(fzf --zsh)"' >>"$HOME/.zshrc"
        fi
    fi
}

setup_node_packages() {
    echo "Installing global Node.js packages..."
    npm install -g @anthropic-ai/claude-code
}

# --- MAIN ---

echo "Starting macOS dotfiles installation..."

install_homebrew

brew update

install_brew_packages
install_brew_casks

setup_mission_control
setup_fzf
setup_node_packages

clone_tmux_plugin_manager

stow_packages

echo "Installation complete!"
echo "Run 'source ~/.zshrc' to apply shell changes."
