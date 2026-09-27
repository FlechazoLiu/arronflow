#!/usr/bin/env bash
#
# Bootstrap a fresh macOS machine with the arronflow tool stack.
#   1. Homebrew + everything in the Brewfile
#   2. Oh My Zsh + custom plugins/themes (not available via Homebrew)
#   3. Deploy configs via scripts/install.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> 1/3 Homebrew + Brewfile"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
brew bundle install --file "$REPO_ROOT/Brewfile"

echo "==> 2/3 Oh My Zsh + external plugins"
# External OMz plugins live in custom/ so `omz update` never clobbers them.
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
fi

clone_if_missing() {
  local repo="$1" dest="$2"
  if [[ ! -d "$dest" ]]; then
    git clone --depth=1 "$repo" "$dest"
  else
    printf 'SKIP   %s (already present)\n' "$dest"
  fi
}

clone_if_missing https://github.com/zsh-users/zsh-autosuggestions     "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
# Prompt theme: Powerlevel10k (wizard config deployed to ~/.p10k.zsh).
clone_if_missing https://github.com/romkatv/powerlevel10k             "$ZSH_CUSTOM/themes/powerlevel10k"

echo "==> 3/3 Deploy configs"
"$REPO_ROOT/scripts/install.sh"

echo "All set. Start a new terminal to pick everything up."
