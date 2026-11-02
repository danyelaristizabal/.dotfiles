# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## How it works

```mermaid
flowchart TD
    CLONE["git clone → ~/.dotfiles"] --> OS{OS?}

    OS -->|macOS| MAC["macosx/install.sh"]
    OS -->|Arch Linux| ARCH["install.sh"]

    MAC --> BREW["install_homebrew\nHomebrew + PATH"]
    BREW --> PKGS["install_brew_packages\nformulae: neovim, tmux, go, fzf…"]
    PKGS --> CASKS["install_brew_casks\nGUI apps: ghostty, claude, docker…"]
    CASKS --> FZF["setup_fzf\neval fzf --zsh → .zshrc"]
    FZF --> NPM["setup_node_packages\nnpm install -g claude-code"]
    NPM --> TPM["clone_tmux_plugin_manager\n~/.tmux/plugins/tpm"]
    TPM --> STOW_MAC["stow_packages"]

    ARCH --> PACMAN["install pacman packages\ngit, neovim, tmux, go…"]
    PACMAN --> YAY["install yay AUR helper"]
    YAY --> AUR["install AUR packages\nlazygit, yazi, tmuxinator…"]
    AUR --> STOW_ARCH["stow_packages"]

    STOW_MAC --> STOW["GNU Stow\nsymlinks ~/.dotfiles/* → $HOME"]
    STOW_ARCH --> STOW

    STOW --> HOME["$HOME\n~/.config/nvim\n~/.tmux.conf\n~/.zshrc\n~/.gitconfig\n…"]
```

## Structure

```
.dotfiles/
├── arch/          # Arch Linux install script
├── macosx/        # macOS install script
│   └── system/
│       ├── always-on/         # keep the Mac awake + reachable while charging
│       └── process-snapshot/  # minute-by-minute process/memory snapshot
├── gitconfig/     # Git configuration
├── gnupg/         # GPG configuration
├── nvim/          # Neovim configuration
├── tmux/          # Tmux configuration
├── zshrc/         # Zsh configuration
├── zprofile/      # Zsh profile
├── wezterm/       # WezTerm configuration
├── ghostty/       # Ghostty configuration (macOS + Linux)
└── stow.sh        # Stow all packages at once
```

## Fresh Mac bootstrap

On a brand new Mac you can't `git clone` before installing the CLT. Use `curl` instead — it's always available:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/danyelaristizabal/.dotfiles/refs/heads/master/macosx/install.sh)"

```

The script will install Xcode Command Line Tools, clone this repo, and set everything up automatically.

## Setup (macOS)

1. Clone the repository:

   ```bash
   git clone git@github.com:danyelaristizabal/.dotfiles.git ~/.dotfiles
   ```

2. Enter the directory:

   ```bash
   cd ~/.dotfiles
   ```

3. Run the install script (installs Homebrew, packages, casks, and stows dotfiles):

   ```bash
   ./macosx/install.sh
   ```

4. Restart your terminal or reload the shell:

   ```bash
   source ~/.zshrc
   ```

## Setup (Arch Linux)

1. Clone the repository:

   ```bash
   git clone git@github.com:danyelaristizabal/.dotfiles.git ~/.dotfiles
   ```

2. Enter the directory:

   ```bash
   cd ~/.dotfiles
   ```

3. Run the install script:

   ```bash
   ./install.sh
   ```

4. Restart your terminal or reload the shell:

   ```bash
   source ~/.zshrc
   ```

## Post-install manual steps

### Mission Control (required for Hammerspoon Space-switching)

Enable "When switching to an application, switch to a Space with open windows" in System Settings → Desktop & Dock → Mission Control, or run:

```bash
defaults write com.apple.dock workspaces-auto-swoosh -bool YES && killall Dock
```

### Hammerspoon

1. **Grant Accessibility permission** — on first launch, macOS will prompt you; approve it in System Settings → Privacy & Security → Accessibility
2. **Remove conflicting Raycast hotkeys** — any binding that collides (⌥C, ⌥V, ⌥S, ⌥B, ⌥↩, ⌥⇧C, ⌥/) will be swallowed by Raycast before Hammerspoon sees it
3. **Press ⌥/** to show a cheatsheet of all configured bindings on screen

## Stow only

To symlink dotfiles without reinstalling packages:

```bash
cd ~/.dotfiles
./stow.sh
```

## Always-on while charging (macOS)

`install.sh` runs `setup_always_on`, configured from `macosx/system/always-on/`:

- `pmset-charger.conf`: charger-only power settings (no system sleep, wake for network, auto-restart after a power cut). Battery settings are untouched.
- `dotfiles-always-on.sh` + LaunchDaemon: every 30 s, disables sleep (lid closed too) while on the charger and restores it on battery. Unplugged with the lid shut, it puts the Mac to sleep. Log: `/var/log/dotfiles-always-on.log`.
- Claude LaunchAgent: opens the Claude app in the background at login.

While on the charger, Apple menu → Sleep does nothing. Unplug or run `sudo pmset -a disablesleep 0` to sleep manually.

## Process snapshot (macOS)

`setup_process_snapshot` installs a LaunchAgent that runs `macosx/system/process-snapshot/process-snapshot.sh` every minute. It writes `~/.dotfiles/.snapshots/processes.txt` (git-ignored) with memory totals, swap, memory pressure, the top processes by memory and CPU, and memory per app with its helper processes added up. You can check it while the screen is off or locked: `cat ~/.dotfiles/.snapshots/processes.txt`.

