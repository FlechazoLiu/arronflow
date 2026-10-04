#!/usr/bin/env bash
#
# Bootstrap a fresh machine with the arronflow tool stack.
#   1. Tools
#        macOS → Homebrew + Brewfile (the Brewfile is macOS-only)
#        Linux → distro packages via pacman/apt/dnf for everything the
#                distro ships, plus official GitHub release binaries into
#                ~/.local/bin for what it does not (Ubuntu's repos lack
#                lazygit/yazi/eza and ship a Neovim too old for LazyVim).
#                Supported families: Arch, Debian/Ubuntu, Fedora;
#                architectures: x86_64, aarch64.
#   2. Oh My Zsh + custom plugins/themes (plain git clones — same everywhere)
#   3. Deploy configs via scripts/install.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OS="$(uname -s)"
LOCAL_BIN="$HOME/.local/bin"   # the zshrc puts this FIRST on PATH, so
                                # GitHub-installed binaries win over distro ones

die() { printf 'bootstrap: %s\n' "$*" >&2; exit 1; }

# ===========================================================================
# Step 1 — tools (macOS)
# ===========================================================================

bootstrap_macos() {
  echo "==> 1/3 macOS: Homebrew + Brewfile"
  if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  brew bundle install --file "$REPO_ROOT/Brewfile"
}

# ===========================================================================
# Step 1 — tools (Linux)
# ===========================================================================

# Already root (e.g. inside a container)? Then no sudo needed.
as_root() { if [[ $EUID -eq 0 ]]; then "$@"; else sudo "$@"; fi; }

have() { command -v "$1" >/dev/null 2>&1; }

# Release assets are named per CPU; pick the right one.
arch_asset() { # arch_asset <asset-on-x86_64> <asset-on-aarch64>
  case "$(uname -m)" in
    x86_64)  printf '%s' "$1" ;;
    aarch64) printf '%s' "$2" ;;
    *) die "unsupported CPU $(uname -m) — x86_64/aarch64 only" ;;
  esac
}

latest_tag() { # latest_tag <owner/repo> → prints the tag, e.g. "v0.65.1"
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" \
    | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -1
}

# Download the latest release of <owner/repo> into a fresh temp dir.
# Some asset names embed the version with the leading "v" stripped (lazygit
# tags v0.65.1 but ships lazygit_0.65.1_...) — write "{ver}" for that part.
# The path is left in RELEASE_TMP; the caller unpacks and removes it.
RELEASE_TMP=""
fetch_release() { # fetch_release <owner/repo> <asset>
  local repo="$1" asset="$2" tag url
  tag=$(latest_tag "$repo")
  [[ -n "$tag" ]] || die "could not resolve the latest release of $repo"
  asset="${asset//\{ver\}/${tag#v}}"
  RELEASE_TMP=$(mktemp -d)
  url="https://github.com/$repo/releases/download/$tag/$asset"
  printf 'FETCH   %s\n' "$url"
  curl -fL --progress-bar -o "$RELEASE_TMP/$asset" "$url"
}

put_bin() { # put_bin <downloaded-path> <name> → install into ~/.local/bin
  install -Dm0755 "$1" "$LOCAL_BIN/$2"
  printf 'BIN     %s\n' "$LOCAL_BIN/$2"
}

from_tarball() { # from_tarball <repo> <asset> <binary>
  # For the common case: a flat tarball with the binary at its root.
  fetch_release "$1" "$2"
  tar -xzf "$RELEASE_TMP/"*.tar.gz -C "$RELEASE_TMP"
  put_bin "$RELEASE_TMP/$3" "$3"
  rm -rf "$RELEASE_TMP"
}

PKG=""  # pacman | apt | dnf

linux_detect() {
  local ID="" ID_LIKE=""
  . /etc/os-release   # the standard distro identity file; sets ID/ID_LIKE
  case "$ID $ID_LIKE" in
    *arch*)   PKG=pacman ;;
    *debian*) PKG=apt ;;
    *fedora*) PKG=dnf ;;
    *) die "unsupported distro '$ID' — Arch, Debian/Ubuntu and Fedora families are supported" ;;
  esac
  printf '==> 1/3 Linux (%s): packages via %s\n' "$ID" "$PKG"
}

linux_ghostty_hint() {
  cat >&2 <<'EOF'
NOTE    Ghostty (the terminal emulator) is not in this distro's standard repos.
        - Ubuntu ≥ 26.04 ships it officially; older Ubuntu: community builds
          at https://github.com/mkasberg/ghostty-ubuntu
        - Fedora: `dnf copr enable scottames/ghostty && dnf install ghostty`
        - Arch: `pacman -S ghostty` (official [extra] repo)
        Everything else in arronflow runs in any terminal — this is optional.
EOF
}

linux_base_packages() {
  case "$PKG" in
    pacman)
      # Arch [extra] carries the whole stack at current versions, so the
      # GitHub fallbacks in linux_github_tools all self-skip via `have`.
      # gcc+make: LazyVim's treesitter parsers compile C on first launch.
      as_root pacman -Sy --needed --noconfirm \
        git zsh tmux neovim fzf ripgrep fd bat eza zoxide lazygit yazi fastfetch \
        ghostty curl unzip fontconfig gcc make
      ;;
    apt)
      as_root apt-get update
      # build-essential: LazyVim's treesitter parsers compile C on first launch.
      DEBIAN_FRONTEND=noninteractive as_root apt-get install -y \
        git zsh tmux fzf ripgrep bat fd-find curl unzip fontconfig build-essential
      # Debian names the binaries batcat/fdfind; link them to the plain
      # names the aliases and docs use. ~/.local/bin precedes /usr/bin
      # on PATH (see zshrc), so the links win.
      mkdir -p "$LOCAL_BIN"
      have bat || ln -sf "$(command -v batcat)" "$LOCAL_BIN/bat"
      have fd  || ln -sf "$(command -v fdfind)" "$LOCAL_BIN/fd"
      # Ghostty entered Ubuntu's own repos with 26.04; older releases only
      # have community builds — print the hint instead of failing.
      DEBIAN_FRONTEND=noninteractive as_root apt-get install -y ghostty \
        || linux_ghostty_hint
      ;;
    dnf)
      # gcc+make: LazyVim's treesitter parsers compile C on first launch.
      as_root dnf install -y \
        git zsh tmux fzf ripgrep bat fd-find curl unzip fontconfig gcc make
      as_root dnf install -y ghostty || linux_ghostty_hint
      ;;
  esac
}

linux_github_tools() {
  # Nothing to do on Arch — pacman just installed everything (each block
  # below is `have`-guarded anyway; the early return just reads clearer).
  [[ "$PKG" == "pacman" ]] && return 0

  # Single-binary tools the Ubuntu/Fedora repos do not carry.
  have lazygit || from_tarball jesseduffield/lazygit \
    "$(arch_asset 'lazygit_{ver}_linux_x86_64.tar.gz' 'lazygit_{ver}_linux_arm64.tar.gz')" lazygit
  have eza     || from_tarball eza-community/eza \
    "$(arch_asset 'eza_x86_64-unknown-linux-gnu.tar.gz' 'eza_aarch64-unknown-linux-gnu.tar.gz')" eza
  have zoxide  || from_tarball ajeetdsouza/zoxide \
    "$(arch_asset 'zoxide-{ver}-x86_64-unknown-linux-musl.tar.gz' 'zoxide-{ver}-aarch64-unknown-linux-musl.tar.gz')" zoxide

  # yazi ships a zip holding a directory with BOTH binaries: yazi (the file
  # manager) and ya (its plugin/CLI companion).
  have yazi || {
    fetch_release sxyazi/yazi \
      "$(arch_asset 'yazi-x86_64-unknown-linux-gnu.zip' 'yazi-aarch64-unknown-linux-gnu.zip')"
    unzip -qo "$RELEASE_TMP/"*.zip -d "$RELEASE_TMP"
    local d
    for d in "$RELEASE_TMP"/yazi-*-unknown-linux-gnu; do
      put_bin "$d/yazi" yazi
      put_bin "$d/ya"   ya
    done
    rm -rf "$RELEASE_TMP"
  }

  # fastfetch's tarball mimics a /usr tree — the binary sits in usr/bin/.
  have fastfetch || {
    fetch_release fastfetch-cli/fastfetch \
      "$(arch_asset 'fastfetch-linux-amd64.tar.gz' 'fastfetch-linux-aarch64-polyfilled.tar.gz')"
    tar -xzf "$RELEASE_TMP/"*.tar.gz -C "$RELEASE_TMP"
    put_bin "$RELEASE_TMP"/fastfetch-*/usr/bin/fastfetch fastfetch
    rm -rf "$RELEASE_TMP"
  }

  # Neovim: even where apt/dnf ship one, it lags behind the Neovim ≥ 0.11
  # LazyVim target (Ubuntu 24.04 has 0.9.5). Always take the official
  # release here; it is a relocatable tree, so it goes to ~/.local/opt/nvim
  # with a symlink from ~/.local/bin.
  fetch_release neovim/neovim \
    "$(arch_asset 'nvim-linux-x86_64.tar.gz' 'nvim-linux-arm64.tar.gz')"
  tar -xzf "$RELEASE_TMP/"*.tar.gz -C "$RELEASE_TMP"
  rm -rf "$HOME/.local/opt/nvim"
  mkdir -p "$HOME/.local/opt"
  # Trailing slash: match only the extracted directory, not the tarball
  # sitting next to it (a bare glob matches both and breaks mv).
  mv "$RELEASE_TMP"/nvim-linux-*/ "$HOME/.local/opt/nvim"
  mkdir -p "$LOCAL_BIN"
  ln -sf "$HOME/.local/opt/nvim/bin/nvim" "$LOCAL_BIN/nvim"
  printf 'BIN     %s -> ~/.local/opt/nvim\n' "$LOCAL_BIN/nvim"
  rm -rf "$RELEASE_TMP"
}

linux_install_font() {
  # Maple Mono NF CN — the Nerd Font every tool's icons depend on. Not
  # packaged by the distros; install per-user and refresh the font cache.
  fetch_release subframe7536/maple-font MapleMono-NF-CN.zip
  unzip -qo "$RELEASE_TMP/"*.zip -d "$RELEASE_TMP"
  mkdir -p "$HOME/.local/share/fonts"
  find "$RELEASE_TMP" -name '*.ttf' -exec cp -f {} "$HOME/.local/share/fonts/" \;
  rm -rf "$RELEASE_TMP"
  fc-cache -f >/dev/null 2>&1 || true
  printf 'FONT    Maple Mono NF CN -> ~/.local/share/fonts\n'
}

bootstrap_linux() {
  linux_detect
  linux_base_packages
  linux_github_tools
  linux_install_font
}

# ===========================================================================
# Main
# ===========================================================================

case "$OS" in
  Darwin) bootstrap_macos ;;
  Linux)  bootstrap_linux ;;
  *) die "unsupported OS '$OS' — macOS and Linux only" ;;
esac

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
if [[ "$OS" == "Linux" && "${SHELL:-}" != */zsh ]]; then
  echo "One more step: make zsh the login shell →  chsh -s \"\$(command -v zsh)\""
fi
