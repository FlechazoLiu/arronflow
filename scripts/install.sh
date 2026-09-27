#!/usr/bin/env bash
#
# Deploys arronflow configs by symlinking them from this repo into place.
# Idempotent: safe to re-run at any time. Existing files at a target location
# are preserved as <target>.bak.<timestamp>, never silently overwritten.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ---------------------------------------------------------------------------
# Link manifest: repo-relative source -> absolute target.
# A source that does not exist yet (tool not configured so far) is skipped,
# so the script works at every stage of the step-by-step setup.
# ---------------------------------------------------------------------------
SOURCES=(
  "config/zsh/zshrc"
  "config/zsh/p10k.zsh"
  "config/fastfetch"
  "config/ghostty"
  "config/tmux"
  "config/nvim"
  "config/yazi"
  "config/lazygit"
)
TARGETS=(
  "$HOME/.zshrc"
  "$HOME/.p10k.zsh"
  "$HOME/.config/fastfetch"
  "$HOME/.config/ghostty"
  "$HOME/.config/tmux"
  "$HOME/.config/nvim"
  "$HOME/.config/yazi"
  "$HOME/Library/Application Support/lazygit"
)

timestamp() { date +%Y%m%d-%H%M%S; }

# A source is deployable when it is a plain file (e.g. zshrc), or a directory
# that holds anything beyond its README placeholder. Placeholder-only dirs are
# skipped so the skeleton stage never touches live configs on the machine.
source_is_ready() {
  local src="$1"
  if [[ -f "$REPO_ROOT/$src" ]]; then
    return 0
  fi
  local entries
  entries=$(find "$REPO_ROOT/$src" -mindepth 1 -maxdepth 1 ! -name 'README.md' -print -quit 2>/dev/null)
  [[ -n "$entries" ]]
}

link_one() {
  local src="$1" dst="$2"

  if ! source_is_ready "$src"; then
    printf 'SKIP   %-24s (not configured in this repo yet)\n' "$src"
    return 0
  fi

  if [[ -L "$dst" && "$(readlink "$dst")" == "$REPO_ROOT/$src" ]]; then
    printf 'OK     %-24s -> %s (already linked)\n' "$src" "$dst"
    return 0
  fi

  mkdir -p "$(dirname "$dst")"

  if [[ -e "$dst" || -L "$dst" ]]; then
    local backup="$dst.bak.$(timestamp)"
    mv "$dst" "$backup"
    printf 'BACKUP %s -> %s\n' "$dst" "$backup"
  fi

  ln -s "$REPO_ROOT/$src" "$dst"
  printf 'LINK   %-24s -> %s\n' "$src" "$dst"
}

printf 'Deploying arronflow configs from %s\n\n' "$REPO_ROOT"

for i in "${!SOURCES[@]}"; do
  link_one "${SOURCES[$i]}" "${TARGETS[$i]}"
done

printf '\nDone. Restart running apps (or reload their config) to pick up changes.\n'
