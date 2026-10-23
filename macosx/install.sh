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
    CLT=$(softwareupdate -l 2>/dev/null |
        grep -E '\* Label: Command Line Tools' |
        sed 's/^.*Label: //' |
        sort -V | tail -n1)
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

    # Fonts
    "font-jetbrains-mono-nerd-font" # JetBrains Mono with Nerd Font icons (required for nvim/oil icons)

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
    "bitwarden"   # password manager
    "hammerspoon" # app-launcher keybindings; config at ~/.hammerspoon/init.lua

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

setup_zsh_framework() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing oh-my-zsh..."
        git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    else
        echo "oh-my-zsh already installed"
    fi

    # Clone into oh-my-zsh themes dir (where ZSH_THEME looks) and symlink ~/powerlevel10k for direct sources
    local p10k_theme="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    if [ ! -d "$p10k_theme" ]; then
        echo "Installing powerlevel10k..."
        git clone https://github.com/romkatv/powerlevel10k.git "$p10k_theme"
    else
        echo "powerlevel10k already installed"
    fi
    [ ! -L "$HOME/powerlevel10k" ] && ln -sf "$p10k_theme" "$HOME/powerlevel10k"

    if [ ! -d "$HOME/.tmuxifier" ]; then
        echo "Installing tmuxifier..."
        git clone https://github.com/jimeh/tmuxifier.git "$HOME/.tmuxifier"
    else
        echo "tmuxifier already installed"
    fi
}

clone_tmux_plugin_manager() {
    if [ ! -d "$TMUX_PLUGIN_PATH" ]; then
        echo "Cloning tmux plugin manager..."
        git clone "$TMUX_PLUGIN_REPO" "$TMUX_PLUGIN_PATH"
    else
        echo "tmux plugin manager already exists"
    fi
    echo "Installing tmux plugins..."
    "$TMUX_PLUGIN_PATH/bin/install_plugins"
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

setup_fzf() {
    if command_exists fzf; then
        if ! grep -q "fzf --zsh" "$HOME/.zshrc" 2>/dev/null; then
            echo 'eval "$(fzf --zsh)"' >>"$HOME/.zshrc"
        fi
    fi
}

setup_sublime() {
    # Package Control reads Packages/User/Package Control.sublime-settings (stowed)
    # on first launch and installs every listed package, NeoVintageous included
    local installed="$HOME/Library/Application Support/Sublime Text/Installed Packages"
    if [ ! -f "$installed/Package Control.sublime-package" ]; then
        echo "Installing Sublime Package Control..."
        mkdir -p "$installed"
        curl -fsSL -o "$installed/Package Control.sublime-package" \
            "https://download.sublimetext.com/Package%20Control.sublime-package"
    else
        echo "Sublime Package Control already installed"
    fi

    # Netskope re-signs HTTPS with its own CA; Package Control ships its own CA list
    # and rejects it, so hand it the Netskope certs from the system keychain
    local keychain="/Library/Keychains/System.keychain"
    if security find-certificate -c "goskope.com" "$keychain" &>/dev/null; then
        echo "Adding Netskope CA to Sublime Package Control..."
        local user_dir="$HOME/Library/Application Support/Sublime Text/Packages/User"
        mkdir -p "$user_dir"
        {
            security find-certificate -a -c "certadmin" -p "$keychain"
            security find-certificate -a -c "goskope.com" -p "$keychain"
        } >"$user_dir/Package Control.user-ca-bundle"
    fi

    # Holding hjkl repeats instead of showing the accent picker (needed for vim mode)
    defaults write com.sublimetext.4 ApplePressAndHoldEnabled -bool false
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

setup_fzf
setup_node_packages

setup_zsh_framework
stow_packages
setup_sublime

clone_tmux_plugin_manager

echo "Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Restart Ghostty fully (Cmd+Q) so it picks up FiraCode Nerd Font"
echo "  2. source ~/.zshrc"
echo "  3. Inside tmux: press Ctrl+a I to install plugins, then Ctrl+a r to reload"
