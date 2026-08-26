#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { echo "[dotfiles/install.sh] $*"; }

install_rcm() {
  if command -v rcup &>/dev/null; then
    log "rcm already installed"
    return 0
  fi

  if command -v brew &>/dev/null; then
    log "Installing rcm via Homebrew..."
    brew install rcm
  elif command -v apt-get &>/dev/null; then
    log "Installing rcm via apt-get..."
    sudo apt-get update -qq
    sudo apt-get install -y rcm
  else
    echo "[dotfiles/install.sh] ERROR: rcup not found and no supported package manager (brew, apt-get)" >&2
    exit 1
  fi
}

install_rcm

log "Applying dotfiles from $DOTFILES_DIR..."
RCRC="$DOTFILES_DIR/rcrc" rcup -d "$DOTFILES_DIR" -f

log "Done."
