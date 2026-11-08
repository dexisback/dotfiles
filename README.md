# ⚡ dexisback / dotfiles

> **Reproducible, cross-platform developer environment for Linux & macOS.**  
> Built with zero-snowflake infrastructure, automated package bootstrapping, and strict zero-plaintext secrets isolation.

---

## 🎯 Architecture & Philosophy

This repository is built like **Infrastructure as Code (IaC) for developer workstations**. Whether booting a fresh Linux Mint / Ubuntu installation or switching to an Apple Silicon MacBook, running a single bootstrap script restores the complete shell prompt, editor configurations, terminal ergonomics, and toolchains within minutes.

### Key Highlights
* **Zero Secrets in Git**: Sensitive credentials (e.g. `GITHUB_MCP_TOKEN`, Spotify secrets, API keys) are strictly isolated into an untracked, local `~/.env` file loaded dynamically on shell startup.
* **macOS & Linux Parity**: Automatically detects operating systems (`Darwin` vs `Linux`), adapts path environments (Homebrew `/opt/homebrew` vs Linux `/usr/bin`), and normalizes utilities (e.g., `pbcopy` vs `xclip`/`wl-copy`).
* **Modular GNU Stow Layout**: Configurations are organized into self-contained packages symlinked directly into `$HOME`.
* **Declarative Extensions & Packages**: Includes a `Brewfile` for macOS and automated extensions installers for Cursor and VS Code.

---

## 📂 Repository Structure

```text
dotfiles/
├── install.sh              # 1-click bootstrap script (Linux + macOS aware)
├── sync.sh                 # Fast updater script (git pull + re-link)
├── Brewfile                # Declarative Homebrew package definitions
├── .env.example            # Environment template for local secrets
├── .gitignore              # Strict ignore rules preventing credential leaks
│
├── zsh/                    # Zsh shell configuration
│   ├── .zshrc             # Cross-platform config (OMZ, p10k, bun, nvm, go)
│   ├── .p10k.zsh          # Powerlevel10k theme configuration
│   └── .zshenv            # Shell environment (Cargo, etc.)
│
├── git/                    # Git configuration
│   └── .gitconfig         # Git user info, defaults, and cross-platform gh auth helper
│
├── tmux/                   # Terminal multiplexer
│   └── .tmux.conf         # Mouse support, 256color, scrollback limits
│
├── ghostty/                # Ghostty terminal emulator
│   └── .config/ghostty/config  # Catppuccin Mocha theme, fonts, custom keybinds
│
├── alacritty/              # Alacritty terminal emulator
│   └── .config/alacritty/alacritty.yml
│
├── kitty/                  # Kitty terminal emulator
│   └── .config/kitty/kitty.conf
│
├── zed/                    # Zed high-performance editor
│   └── .config/zed/
│       ├── settings.json  # Model configs, LSP, font, and UI settings
│       └── keymap.json    # Custom keybindings
│
├── cursor/                 # Cursor AI IDE
│   └── .config/Cursor/User/
│       ├── settings.json  # Editor formatting, clippy, syntax highlighting
│       └── keybindings.json
│
├── vscode/                 # Visual Studio Code
│   └── .config/Code/User/
│       ├── settings.json
│       └── keybindings.json
│
├── scripts/                # Utility scripts
│   └── .scripts/cursor-zoom.sh
│
├── neofetch/               # System summary config
│   └── .config/neofetch/config.conf
│
└── extensions/             # IDE extensions
    ├── cursor-extensions.txt
    └── vscode-extensions.txt
```

---

## 🚀 1-Click Bootstrap (New Machine Setup)

On a fresh Linux or macOS machine, clone and run:

```bash
git clone https://github.com/dexisback/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

### What `install.sh` does automatically:
1. **Detects the OS** and installs required system packages (`stow`, `git`, `zsh`, `tmux`, `ripgrep`, etc.). On macOS, it installs Homebrew and runs `brew bundle`.
2. **Installs Oh-My-Zsh** unattended (if not present).
3. **Clones Zsh Plugins & Themes**:
   - `powerlevel10k`
   - `zsh-autosuggestions`
   - `zsh-syntax-highlighting`
4. **Safely backs up** any existing colliding files to `~/.dotfiles_backup/<timestamp>` before creating symlinks.
5. **Symlinks configs** via GNU Stow (with native symlink fallback).
6. **Configures Editor Paths**:
   - Maps Cursor and VS Code configs to `~/.config/` on Linux.
   - Maps Cursor and VS Code configs to `~/Library/Application Support/` on macOS.
7. **Initializes Secrets**: Creates a secure `~/.env` template with `chmod 600`.
8. **Installs Extensions**: Automatically installs your Cursor and VS Code extensions.

---

## 🔐 Secrets & Local Overrides

This repository is **public-safe**. No tokens, SSH keys, or private API keys are ever committed.

### How secrets work:
1. Your shell automatically loads `~/.env` and `~/.zshrc.local` on startup if they exist.
2. When setting up a new machine, copy the template:
   ```bash
   cp ~/.dotfiles/.env.example ~/.env
   chmod 600 ~/.env
   ```
3. Populate your private tokens inside `~/.env`:
   ```bash
   export GITHUB_MCP_TOKEN="ghp_xxxxxxxxxxxx"
   export SPOTIFY_CLIENT_ID="xxxxxxxx"
   export SPOTIFY_CLIENT_SECRET="xxxxxxxx"
   ```

---

## 🔄 Day-to-Day Workflow

### Updating or Adding Configurations
When you modify a tracked file (e.g., editing `~/.config/ghostty/config` or `~/.zshrc`), the changes immediately reflect in `~/.dotfiles` because they are live symlinks.

To push updates:
```bash
cd ~/.dotfiles
git status
git add .
git commit -m "feat(ghostty): update keybindings"
git push origin main
```

### Pulling Updates on Another Machine
```bash
cd ~/.dotfiles
./sync.sh
```

---

## 👤 Author
**Amaan (`dexisback`)**
* GitHub: [@dexisback](https://github.com/dexisback)
