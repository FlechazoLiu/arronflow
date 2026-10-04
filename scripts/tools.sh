#!/usr/bin/env bash
#
# Phase 1 — tool installation.
#
#   tools.sh --auto   [--all | <tool>...]   install automatically (sudo where needed)
#   tools.sh --manual [--all | <tool>...]   print the exact commands, install nothing
#   tools.sh --list                        registry tools + current state
#   add --dry-run                          print what --auto would do, execute nothing
#
# Auto vs manual is a per-machine choice; the WHAT and WHERE come from the
# registry (lib/registry.sh). Configs are NOT deployed here — that is
# install.sh, gated on the binaries this script provides. On Linux a small
# prerequisite set is installed first (curl/unzip/fontconfig, plus a C
# toolchain with nvim for treesitter parsers); macOS needs none of that.
#
# No args + terminal → interactive tool picker; no args + no terminal →
# usage error (auto-install runs sudo; it must never be a silent default).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS="$REPO_ROOT/scripts"
source "$SCRIPTS/lib/common.sh"
source "$SCRIPTS/lib/registry.sh"
prepend_paths

LOCAL_BIN="$HOME/.local/bin"   # release binaries + Debian rename links land here

usage() {
  cat <<'EOF'
usage: tools.sh --auto   [--all | <tool>...]   install automatically
       tools.sh --manual [--all | <tool>...]   print commands, install nothing
       tools.sh --list                        registry tools + current state

options: --dry-run   print what --auto would do, execute nothing
Tools are registry keys (tools.sh --list); e.g. tools.sh --auto tmux nvim
EOF
  exit 2
}

# --- Execution wrappers -------------------------------------------------------

run_root() { # privileged command, dry-run aware
  if [[ -n $DRY ]]; then printf 'DRY     sudo %s\n' "$*"; return 0; fi
  if [[ $EUID -eq 0 ]]; then "$@"; else sudo "$@"; fi
}

run() { # plain command, dry-run aware
  if [[ -n $DRY ]]; then printf 'DRY     %s\n' "$*"; return 0; fi
  "$@"
}

# --- GitHub release fallback (auto mode only; asset layouts verified) ----------

arch_asset() { # arch_asset <asset-on-x86_64> <asset-on-aarch64>
  case "$(uname -m)" in
    x86_64) printf '%s' "$1" ;;
    aarch64) printf '%s' "$2" ;;
    *) die "unsupported CPU $(uname -m) — x86_64/aarch64 only" ;;
  esac
}

latest_tag() { # latest_tag <owner/repo> → prints e.g. "v0.65.1"
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" \
    | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -1
}

RELEASE_TMP=""
fetch_release() { # fetch_release <owner/repo> <asset> → path in $RELEASE_TMP
  local repo="$1" asset="$2" tag url
  if [[ -n $DRY ]]; then
    printf 'DRY     fetch latest release of %s (%s) into %s\n' "$repo" "$asset" "$LOCAL_BIN"
    RELEASE_TMP="(dry-run)"
    return 0
  fi
  tag=$(latest_tag "$repo")
  [[ -n $tag ]] || die "could not resolve the latest release of $repo"
  asset="${asset//\{ver\}/${tag#v}}"
  RELEASE_TMP=$(mktemp -d)
  url="https://github.com/$repo/releases/download/$tag/$asset"
  printf 'FETCH   %s\n' "$url"
  curl -fL --progress-bar -o "$RELEASE_TMP/$asset" "$url"
}

put_bin() { # put_bin <downloaded-path> <name> — GNU install -D; Linux path only
  install -Dm0755 "$1" "$LOCAL_BIN/$2"
  printf 'BIN     %s\n' "$LOCAL_BIN/$2"
}

from_tarball() { # from_tarball <repo> <asset> <binary> — flat tarball, binary at root
  fetch_release "$1" "$2"
  if [[ -n $DRY ]]; then return 0; fi
  tar -xzf "$RELEASE_TMP/"*.tar.gz -C "$RELEASE_TMP"
  put_bin "$RELEASE_TMP/$3" "$3"
  rm -rf "$RELEASE_TMP"
}

gh_install() { # gh_install <tool> — registry-driven release-binary install
  local tool="$1" gh rest repo a64 aarm bins asset
  gh=$(reg_field "$tool" gh)
  repo="${gh%%:*}"; rest="${gh#*:}"
  a64="${rest%%:*}"; rest="${rest#*:}"
  aarm="${rest%%:*}"; bins="${rest#*:}"
  asset=$(arch_asset "$a64" "$aarm")
  case "$tool" in
    yazi)
      # zip holding a directory with BOTH binaries: yazi and its companion ya.
      fetch_release "$repo" "$asset"
      if [[ -z $DRY ]]; then
        local d
        unzip -qo "$RELEASE_TMP/"*.zip -d "$RELEASE_TMP"
        for d in "$RELEASE_TMP"/yazi-*-unknown-linux-gnu; do
          put_bin "$d/yazi" yazi
          put_bin "$d/ya" ya
        done
        rm -rf "$RELEASE_TMP"
      fi
      ;;
    fastfetch)
      # tarball that mimics a /usr tree — the binary sits in usr/bin/.
      fetch_release "$repo" "$asset"
      if [[ -z $DRY ]]; then
        tar -xzf "$RELEASE_TMP/"*.tar.gz -C "$RELEASE_TMP"
        put_bin "$RELEASE_TMP"/fastfetch-*/usr/bin/fastfetch fastfetch
        rm -rf "$RELEASE_TMP"
      fi
      ;;
    nvim)
      # relocatable tree → ~/.local/opt/nvim with a symlink from LOCAL_BIN
      # (distro packages lag the >= 0.11 LazyVim target on apt/dnf).
      fetch_release "$repo" "$asset"
      if [[ -z $DRY ]]; then
        local root="$HOME/.local/opt/nvim"
        tar -xzf "$RELEASE_TMP/"*.tar.gz -C "$RELEASE_TMP"
        rm -rf "$root"
        mkdir -p "$HOME/.local/opt"
        # Trailing slash: match only the extracted directory, not the
        # tarball sitting next to it (a bare glob matches both, breaking mv).
        mv "$RELEASE_TMP"/nvim-linux-*/ "$root"
        mkdir -p "$LOCAL_BIN"
        ln -sf "$root/bin/nvim" "$LOCAL_BIN/nvim"
        printf 'BIN     %s -> %s\n' "$LOCAL_BIN/nvim" "$root"
        rm -rf "$RELEASE_TMP"
      fi
      ;;
    *)
      from_tarball "$repo" "$asset" "$bins"
      ;;
  esac
}

# --- Post-install hooks --------------------------------------------------------

ghostty_hint() {
  cat >&2 <<'EOF'
NOTE    Ghostty is not in this distro's standard repos.
        - Ubuntu >= 26.04 ships it officially; older Ubuntu: community builds
          at https://github.com/mkasberg/ghostty-ubuntu
        - Fedora: `dnf copr enable scottames/ghostty && dnf install ghostty`
        Everything else in arronflow runs in any terminal — this is optional.
EOF
}

ensure_omz() { # Oh My Zsh + external plugins (custom/ so `omz update` is safe)
  local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  local -a urls dests
  local i
  urls=(zsh-users/zsh-autosuggestions zsh-users/zsh-syntax-highlighting romkatv/powerlevel10k)
  dests=(plugins/zsh-autosuggestions plugins/zsh-syntax-highlighting themes/powerlevel10k)
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    run git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
  fi
  for i in 0 1 2; do
    if [[ -d "$custom/${dests[$i]}" ]]; then
      printf 'SKIP    %s (already present)\n' "$custom/${dests[$i]}"
    else
      run git clone --depth=1 "https://github.com/${urls[$i]}.git" "$custom/${dests[$i]}"
    fi
  done
}

install_maple_font() { # Maple Mono NF CN — the Nerd Font the icons depend on
  fetch_release subframe7536/maple-font MapleMono-NF-CN.zip
  if [[ -z $DRY ]]; then
    unzip -qo "$RELEASE_TMP/"*.zip -d "$RELEASE_TMP"
    mkdir -p "$HOME/.local/share/fonts"
    find "$RELEASE_TMP" -name '*.ttf' -exec cp -f {} "$HOME/.local/share/fonts/" \;
    rm -rf "$RELEASE_TMP"
    fc-cache -f >/dev/null 2>&1 || true
    printf 'FONT    Maple Mono NF CN -> ~/.local/share/fonts\n'
  fi
}

post_hook() { # post_hook <tool>
  local post; post=$(reg_field "$1" post)
  case ",$post," in
    *,omz,*) ensure_omz ;;
    *,font,*)
      if [[ $(uname -s) == Linux ]]; then install_maple_font; fi
      # On macOS the font arrives as a cask listed in the brew field.
      ;;
  esac
  return 0
}

# --- Auto mode -------------------------------------------------------------------

install_tool() { # install_tool <tool> via package manager / release fallback
  local tool="$1" brew pacman apt dnf gh spec pkgname firstbin
  brew=$(reg_field "$tool" brew)
  pacman=$(reg_field "$tool" pacman)
  apt=$(reg_field "$tool" apt)
  dnf=$(reg_field "$tool" dnf)
  gh=$(reg_field "$tool" gh)
  firstbin=$(reg_field "$tool" bins | cut -d, -f1)
  case "$PKG" in
    brew)
      local spec
      for spec in ${brew//,/ }; do
        if [[ $spec == cask:* ]]; then
          run brew install --cask "${spec#cask:}"
        else
          run brew install "$spec"
        fi
      done
      ;;
    pacman)
      if [[ -n $pacman ]]; then
        run_root pacman -S --needed --noconfirm $pacman
      else
        gh_install "$tool"
      fi
      ;;
    apt)
      local spec
      if [[ -n $apt ]]; then
        for spec in ${apt//,/ }; do
          pkgname="${spec%%:*}"
          DEBIAN_FRONTEND=noninteractive run_root apt-get install -y "$pkgname" \
            || ghostty_hint_when "$tool"
          # Debian renames bat->batcat, fd-find->fdfind; link the plain name.
          if [[ $spec == *:* && -z $DRY ]]; then
            mkdir -p "$LOCAL_BIN"
            have "$firstbin" || ln -sf "$(command -v "${spec#*:}")" "$LOCAL_BIN/$firstbin"
          fi
        done
      else
        gh_install "$tool"
      fi
      ;;
    dnf)
      if [[ -n $dnf ]]; then
        run_root dnf install -y $dnf || ghostty_hint_when "$tool"
      else
        gh_install "$tool"
      fi
      ;;
  esac
  return 0
}

ghostty_hint_when() {
  if [[ $1 == ghostty ]]; then ghostty_hint; fi
  return 0
}

ensure_prereqs() { # small plumbing set for the selected tools (Linux only)
  [[ $PKG == brew ]] && return 0
  local -a base
  local t
  base=(curl unzip fontconfig)
  for t in "${WANT[@]}"; do
    if [[ $t == nvim ]]; then
      if [[ $PKG == apt ]]; then base+=(build-essential); else base+=(gcc make); fi
    fi
    if [[ $t == zsh ]] && ! have git; then
      install_tool git   # the Oh My Zsh clones need git
    fi
  done
  printf 'PREREQ  %s\n' "${base[*]}"
  case "$PKG" in
    # Arch: -Syu, NEVER bare -Sy — a partial upgrade can leave mismatched
    # libraries (e.g. a new curl against an old ngtcp2) that crash pacman
    # itself. Rolling distros must converge fully; --needed keeps it quiet.
    pacman) run_root pacman -Syu --needed --noconfirm "${base[@]}" ;;
    apt)
      run_root apt-get update
      DEBIAN_FRONTEND=noninteractive run_root apt-get install -y "${base[@]}"
      ;;
    dnf) run_root dnf install -y "${base[@]}" ;;
  esac
  return 0
}

auto_mode() {
  ensure_prereqs
  if [[ $PKG == brew && $ALL == 1 ]]; then
    # Whole stack on macOS = one Brewfile transaction (it stays canonical).
    run brew bundle install --file "$REPO_ROOT/Brewfile"
  fi
  local t state
  for t in "${WANT[@]}"; do
    if [[ $PKG != brew || $ALL != 1 ]]; then
      state=$(tool_state "$t")
      if [[ $state == ok* ]]; then
        printf 'SKIP    %s (already installed: %s)\n' "$t" "${state#* }"
      else
        if [[ $state == old* ]]; then
          printf 'UPGRADE %s (%s)\n' "$t" "${state#* }"
        fi
        install_tool "$t"
      fi
    fi
    post_hook "$t"
  done
  summary
}

# --- Manual mode ------------------------------------------------------------------

manual_mode() {
  local t
  printf 'Manual install commands (%s):\n' "$PKG"
  for t in "${WANT[@]}"; do
    print_manual_block "$t" "$PKG"
  done
  printf '\nAfter installing, re-check with: scripts/doctor.sh\n'
}

# --- Shared output ------------------------------------------------------------------

summary() { # final state of the wanted tools (ghostty-missing stays a warning:
  #          it needs a desktop and a distro package; optional on Linux)
  local t state issues=0
  printf '\n'
  for t in "${WANT[@]}"; do
    state=$(tool_state "$t")
    if [[ $state == ok* ]]; then
      printf 'OK      %-8s %s\n' "$t" "${state#* }"
    elif [[ $t == ghostty && $(uname -s) == Linux ]]; then
      printf 'WARN    %-8s %s (optional on Linux — see the note above)\n' "$t" "${state#* }"
    else
      printf 'MISSING %-8s %s\n' "$t" "${state#* }"
      issues=$((issues + 1))
    fi
  done
  if [[ $(uname -s) == Linux && ${SHELL:-} != */zsh ]] && have zsh; then
    if printf '%s\n' "${WANT[@]}" | grep -qx zsh; then
      printf '\nOne more step: make zsh the login shell →  chsh -s "$(command -v zsh)"\n'
    fi
  fi
  if (( issues > 0 )); then
    die "$issues tool(s) still missing — see the commands above or scripts/doctor.sh"
  fi
  return 0
}

state_table() { # --list
  local t state cfg
  printf '%-10s %-34s %s\n' TOOL STATE CONFIG
  for t in $(reg_names); do
    state=$(tool_state "$t")
    cfg=$(reg_field "$t" cfg)
    if [[ -n $cfg ]]; then cfg="yes"; else cfg="-"; fi
    printf '%-10s %-34s %s\n' "$t" "$state" "$cfg"
  done
}

# --- Argument parsing ------------------------------------------------------------------

MODE="" ALL=0 LIST=0 DRY=""
WANT=()
while (( $# > 0 )); do
  case "$1" in
    --auto) MODE=auto ;;
    --manual) MODE=manual ;;
    --all) ALL=1 ;;
    --list) LIST=1 ;;
    --dry-run) DRY=1 ;;
    -h | --help) usage ;;
    -*) printf 'unknown flag: %s\n\n' "$1" >&2; usage ;;
    *)
      reg_has "$1" || die "unknown tool: $1 (tools.sh --list)"
      WANT+=("$1")
      ;;
  esac
  shift
done

if [[ $LIST == 1 ]]; then
  state_table
  exit 0
fi

[[ -n $MODE ]] || usage

if [[ $ALL == 1 ]]; then
  WANT=($(reg_names))
elif (( ${#WANT[@]} == 0 )); then
  if is_interactive; then
    menu_want=""
    menu_select menu_want $(reg_names)
    if [[ -z $menu_want ]]; then
      printf 'Nothing selected.\n'
      exit 0
    fi
    WANT=($menu_want)
  else
    usage
  fi
fi

PKG=$(detect_pkgmgr) || die "no supported package manager found (brew, pacman, apt, dnf)"

if [[ $MODE == auto ]]; then
  auto_mode
else
  manual_mode
fi
