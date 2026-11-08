# ==============================================================================
# Zsh Configuration (Cross-Platform macOS + Linux)
# Managed via dotfiles: https://github.com/dexisback/dotfiles
# ==============================================================================

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment the following line to use hyphen-insensitive completion.
# HYPHEN_INSENSITIVE="true"

# Plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# Load Oh My Zsh if installed
if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# Load Powerlevel10k config
[[ ! -f "$HOME/.p10k.zsh" ]] || source "$HOME/.p10k.zsh"

# ==============================================================================
# Environment Paths & Runtime Version Managers
# ==============================================================================

# Local user binaries
export PATH="$HOME/.local/bin:$PATH"

# Node Version Manager (nvm)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
command -v nvm >/dev/null 2>&1 && nvm use default >/dev/null 2>&1

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# Golang
if command -v go >/dev/null 2>&1; then
  export PATH="$PATH:$(go env GOPATH 2>/dev/null)/bin"
fi
export PATH="$PATH:$HOME/go/bin:/usr/local/go/bin"

# Rust (Cargo)
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# Opencode CLI
export PATH="$HOME/.opencode/bin:$PATH"

# ==============================================================================
# Cross-Platform OS Adjustments (macOS vs Linux)
# ==============================================================================
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS Homebrew (Apple Silicon / Intel)
  if [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  alias clip="pbcopy"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linuxbrew (if installed)
  if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
  alias clip="xclip -selection clipboard 2>/dev/null || wl-copy 2>/dev/null"
fi

# ==============================================================================
# Personal Aliases
# ==============================================================================
alias k='kubectl'
alias terminal='ghostty'

# ==============================================================================
# Local Secrets & Machine-Specific Overrides (Never committed to Git)
# ==============================================================================
# Load ~/.env (KEY=VAL format)
if [[ -f "$HOME/.env" ]]; then
  set -a
  source "$HOME/.env"
  set +a
fi

# Load ~/.zshrc.local (Arbitrary shell overrides)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
