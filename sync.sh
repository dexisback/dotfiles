#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Sync Utility
# Pulls latest changes from GitHub and re-applies symlinks.
# ==============================================================================

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Pulling latest dotfiles from git..."
cd "$DOTFILES_DIR"
git pull --rebase origin main

echo "==> Re-running install linking..."
"$DOTFILES_DIR/install.sh"
