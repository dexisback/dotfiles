#!/usr/bin/env bash
# ==============================================================================
# Dotfiles 1-Click Bootstrap Script (Cross-Platform macOS & Linux)
# Repo: https://github.com/dexisback/dotfiles
# ==============================================================================

set -euo pipefail

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${RESET} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }
log_error() { echo -e "${RED}[ERROR]${RESET} $1"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

echo -e "${BOLD}======================================================${RESET}"
echo -e "${BOLD}      DEXISBACK DOTFILES BOOTSTRAPPER                 ${RESET}"
echo -e "${BOLD}======================================================${RESET}"
log_info "Detected OS: $OS"
log_info "Dotfiles directory: $DOTFILES_DIR"

# ------------------------------------------------------------------------------
# 1. Package Management & Dependencies
# ------------------------------------------------------------------------------
install_dependencies() {
    log_info "Checking system package dependencies..."

    if [ "$OS" = "Darwin" ]; then
        # macOS
        if ! xcode-select -p >/dev/null 2>&1; then
            log_info "Installing Xcode Command Line Tools..."
            xcode-select --install || true
        fi

        if ! command -v brew >/dev/null 2>&1; then
            log_info "Homebrew not found. Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"
        fi

        log_info "Running Homebrew bundle..."
        brew bundle --file="$DOTFILES_DIR/Brewfile" || {
            log_warn "Some brew packages could not be installed immediately. Continuing..."
        }

    elif [ "$OS" = "Linux" ]; then
        # Linux (Debian / Ubuntu / Linux Mint)
        if command -v apt-get >/dev/null 2>&1; then
            log_info "Debian/Ubuntu/Mint detected. Updating and installing core tools..."
            sudo apt-get update -y
            sudo apt-get install -y stow git zsh curl wget tmux ripgrep
        elif command -v pacman >/dev/null 2>&1; then
            log_info "Arch Linux detected. Installing core tools..."
            sudo pacman -Sy --noconfirm stow git zsh curl wget tmux ripgrep
        elif command -v dnf >/dev/null 2>&1; then
            log_info "Fedora/RHEL detected. Installing core tools..."
            sudo dnf install -y stow git zsh curl wget tmux ripgrep
        else
            log_warn "Unknown Linux distribution. Please ensure stow, git, zsh, and tmux are installed."
        fi
    fi
}

# ------------------------------------------------------------------------------
# 2. Oh-My-Zsh & Shell Plugins
# ------------------------------------------------------------------------------
setup_zsh_environment() {
    log_info "Setting up Zsh, Powerlevel10k & Plugins..."

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log_info "Installing Oh-My-Zsh (unattended)..."
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        log_info "Oh-My-Zsh is already installed."
    fi

    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # Powerlevel10k theme
    if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
        log_info "Cloning Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
    fi

    # zsh-autosuggestions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        log_info "Cloning zsh-autosuggestions plugin..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    fi

    # zsh-syntax-highlighting
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        log_info "Cloning zsh-syntax-highlighting plugin..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    fi
}

# ------------------------------------------------------------------------------
# 3. Safe Symlinking & Backup Mechanism
# ------------------------------------------------------------------------------
safe_link() {
    local src="$1"
    local dest="$2"

    mkdir -p "$(dirname "$dest")"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
            return 0
        fi
        mkdir -p "$BACKUP_DIR"
        log_warn "Backing up existing $dest -> $BACKUP_DIR/"
        mv "$dest" "$BACKUP_DIR/"
    fi

    ln -s "$src" "$dest"
    log_success "Linked: $dest -> $src"
}

stow_or_link_all() {
    log_info "Symlinking dotfiles into place..."

    local STOW_PACKAGES=(zsh git tmux ghostty alacritty kitty zed cursor vscode scripts neofetch)

    if command -v stow >/dev/null 2>&1; then
        log_info "Using GNU Stow to link packages..."
        for pkg in "${STOW_PACKAGES[@]}"; do
            if [ -d "$DOTFILES_DIR/$pkg" ]; then
                # Backup any existing real files that would cause stow conflict
                find "$DOTFILES_DIR/$pkg" -type f | while read -r file; do
                    rel_path="${file#$DOTFILES_DIR/$pkg/}"
                    target="$HOME/$rel_path"
                    if [ -f "$target" ] && [ ! -L "$target" ]; then
                        mkdir -p "$BACKUP_DIR"
                        mv "$target" "$BACKUP_DIR/"
                        log_warn "Moved colliding file: $target to $BACKUP_DIR"
                    fi
                done

                stow -v -R -d "$DOTFILES_DIR" -t "$HOME" "$pkg" 2>/dev/null || {
                    log_warn "Stow had non-fatal warning on $pkg. Verifying links..."
                }
            fi
        done
    else
        log_warn "GNU Stow not found. Falling back to native symbolic links..."
        safe_link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
        safe_link "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
        safe_link "$DOTFILES_DIR/zsh/.zshenv" "$HOME/.zshenv"
        safe_link "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
        safe_link "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
        safe_link "$DOTFILES_DIR/ghostty/.config/ghostty/config" "$HOME/.config/ghostty/config"
        safe_link "$DOTFILES_DIR/alacritty/.config/alacritty/alacritty.yml" "$HOME/.config/alacritty/alacritty.yml"
        safe_link "$DOTFILES_DIR/kitty/.config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
        safe_link "$DOTFILES_DIR/zed/.config/zed/settings.json" "$HOME/.config/zed/settings.json"
        safe_link "$DOTFILES_DIR/zed/.config/zed/keymap.json" "$HOME/.config/zed/keymap.json"
        safe_link "$DOTFILES_DIR/cursor/.config/Cursor/User/settings.json" "$HOME/.config/Cursor/User/settings.json"
        safe_link "$DOTFILES_DIR/cursor/.config/Cursor/User/keybindings.json" "$HOME/.config/Cursor/User/keybindings.json"
        safe_link "$DOTFILES_DIR/vscode/.config/Code/User/settings.json" "$HOME/.config/Code/User/settings.json"
        safe_link "$DOTFILES_DIR/vscode/.config/Code/User/keybindings.json" "$HOME/.config/Code/User/keybindings.json"
        safe_link "$DOTFILES_DIR/scripts/.scripts/cursor-zoom.sh" "$HOME/.scripts/cursor-zoom.sh"
        safe_link "$DOTFILES_DIR/neofetch/.config/neofetch/config.conf" "$HOME/.config/neofetch/config.conf"
    fi

    # macOS specific editor paths (Application Support)
    if [ "$OS" = "Darwin" ]; then
        log_info "Configuring macOS Application Support paths for Cursor & VS Code..."
        safe_link "$DOTFILES_DIR/cursor/.config/Cursor/User/settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json"
        safe_link "$DOTFILES_DIR/cursor/.config/Cursor/User/keybindings.json" "$HOME/Library/Application Support/Cursor/User/keybindings.json"
        safe_link "$DOTFILES_DIR/vscode/.config/Code/User/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
        safe_link "$DOTFILES_DIR/vscode/.config/Code/User/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"
    fi
}

# ------------------------------------------------------------------------------
# 4. Secrets & Local Environment Initialization
# ------------------------------------------------------------------------------
setup_secrets_environment() {
    if [ ! -f "$HOME/.env" ]; then
        log_info "Initializing local ~/.env from template..."
        cp "$DOTFILES_DIR/.env.example" "$HOME/.env"
        chmod 600 "$HOME/.env"
        log_warn "Created ~/.env — Remember to populate your private tokens (e.g. GITHUB_MCP_TOKEN)!"
    else
        log_success "Local ~/.env already exists."
    fi
}

# ------------------------------------------------------------------------------
# 5. Editor Extensions Installation
# ------------------------------------------------------------------------------
install_editor_extensions() {
    if command -v cursor >/dev/null 2>&1 && [ -f "$DOTFILES_DIR/extensions/cursor-extensions.txt" ]; then
        log_info "Installing Cursor extensions..."
        while read -r ext; do
            [ -n "$ext" ] && cursor --install-extension "$ext" --force || true
        done < "$DOTFILES_DIR/extensions/cursor-extensions.txt"
    fi

    if command -v code >/dev/null 2>&1 && [ -f "$DOTFILES_DIR/extensions/vscode-extensions.txt" ]; then
        log_info "Installing VS Code extensions..."
        while read -r ext; do
            [ -n "$ext" ] && code --install-extension "$ext" --force || true
        done < "$DOTFILES_DIR/extensions/vscode-extensions.txt"
    fi
}

# ------------------------------------------------------------------------------
# Main Flow
# ------------------------------------------------------------------------------
main() {
    install_dependencies
    setup_zsh_environment
    stow_or_link_all
    setup_secrets_environment
    install_editor_extensions

    echo ""
    echo -e "${BOLD}${GREEN}======================================================${RESET}"
    echo -e "${BOLD}${GREEN}   Dotfiles Installation & Symlinking Complete!       ${RESET}"
    echo -e "${BOLD}${GREEN}======================================================${RESET}"
    echo -e "Restart your terminal or run: ${BOLD}exec zsh${RESET}"
}

main "$@"
