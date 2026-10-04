# Shared helpers for the arronflow scripts.
#
# Sourced (never executed) by tools.sh, install.sh, doctor.sh and
# bootstrap.sh. Pure bash, macOS bash 3.2 compatible: no associative
# arrays, no mapfile, no ${var,,}, no sort -V (BSD sort lacks it).
#
# Sourcing order: lib/common.sh FIRST (defines die/have used below), then
# lib/registry.sh (its record lines expand $HOME-derived targets).

# --- Environment ------------------------------------------------------------

# Checks and installs must see ~/.local/bin (GitHub-release binaries and
# the Debian bat/fd rename links) and Homebrew, even in a bare non-login
# shell whose PATH is just /usr/bin:/bin. Idempotent.
prepend_paths() {
  case "$(uname -s)" in
    Darwin) PATH="/opt/homebrew/bin:/usr/local/bin:$PATH" ;;
  esac
  PATH="$HOME/.local/bin:$PATH"
}

die() { printf 'arronflow: %s\n' "$*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

# Interactive only when BOTH ends are a terminal — piped/CI runs must take
# the flag path, never the menu.
is_interactive() { [[ -t 0 && -t 1 ]]; }

# --- Prompts (EOF-safe; set -e survives closed stdin) ------------------------

ask() { # ask <prompt> <varname> — answer in $varname, "" on EOF
  # No `local` in here, on purpose. `read` assigns the variable the caller
  # NAMED, resolved dynamically up the call stack; an intermediate local
  # would shadow it and the caller would always see "" — every answer
  # silently becoming the default. (Found on the Ubuntu VM: a typed "y"
  # was declined.) `|| true` keeps partial input delivered before EOF
  # (Ctrl+D instead of Enter) and survives set -e; EOF alone still sets "".
  read -r -p "$1" "$2" || true
}

confirm() { # confirm <prompt> [default y|n] — exit 0 = yes
  local __ans="" __def="${2:-n}"
  while true; do
    ask "$1" __ans
    case "$__ans" in
      [Yy] | [Yy][Ee][Ss]) return 0 ;;
      [Nn] | [Nn][Oo]) return 1 ;;
      "")
        if [[ $__def == y ]]; then return 0; fi
        return 1
        ;;
      *)
        # Non-empty but unrecognized (typo, full-width "ｙ" from an IME):
        # echo what arrived and re-ask. An empty line or EOF exits via the
        # branch above with the default, so the loop cannot spin on a pipe.
        printf 'arronflow: please answer y or n (you typed "%s").\n' "$__ans" >&2
        ;;
    esac
  done
}

# Numbered multi-select. <varname> receives the chosen items (space
# separated, registry order). Items must be single words (tool names are).
menu_select() { # menu_select <varname> <item...>
  local __var="$1"; shift
  local __items=("$@") __sel="" __in="" __tok __i __it __on __new
  while true; do
    printf '\n'
    for __i in "${!__items[@]}"; do
      __it="${__items[$__i]}"
      __on="[ ]"; [[ " $__sel " == *" $__it "* ]] && __on="[x]"
      printf '  %2d) %s %s\n' "$((__i + 1))" "$__on" "$__it"
    done
    printf '\n  toggle: numbers ("1 3")   a: all   n: none   Enter: accept   q: quit\n'
    ask 'choice: ' __in
    case "$__in" in
      q | Q) printf -v "$__var" '%s' ""; return 0 ;;
      a | A) __sel="${__items[*]}" ;;
      n | N) __sel="" ;;
      "") break ;;
      *)
        __new=""
        for __i in "${!__items[@]}"; do
          __it="${__items[$__i]}"
          __on=0; [[ " $__sel " == *" $__it "* ]] && __on=1
          for __tok in $__in; do
            case "$__tok" in *[!0-9]*) continue ;; esac
            (( __tok == __i + 1 )) && __on=$((1 - __on))
          done
          (( __on )) && __new="$__new $__it"
        done
        __sel="${__new# }"
        ;;
    esac
  done
  printf -v "$__var" '%s' "$__sel"
  return 0
}

# --- Version handling ---------------------------------------------------------

ver_of() { # ver_of <binary> <vflag> — first x.y(.z) token, "" if unknowable
  local out
  out=$("$1" "$2" 2>&1) || true
  printf '%s\n' "$out" | grep -oE '[0-9]+(\.[0-9]+)+' | head -1
}

# Dotted-numeric compare in pure bash (BSD sort has no -V). Leading
# "name " and trailing letters ("-dev", "3.5a") are stripped by the grep.
ver_ge() { # ver_ge <got> <min> — exit 0 when got >= min
  local got min i a b
  got=$(printf '%s' "$1" | grep -oE '[0-9]+(\.[0-9]+)*' | head -1)
  min=$(printf '%s' "$2" | grep -oE '[0-9]+(\.[0-9]+)*' | head -1)
  [[ -z $min ]] && return 0   # no minimum recorded
  [[ -z $got ]] && return 1   # minimum recorded but version unknown
  local gs ms
  IFS='.' read -r -a gs <<<"$got"
  IFS='.' read -r -a ms <<<"$min"
  for i in 0 1 2 3 4 5; do
    a=${gs[$i]:-0}; b=${ms[$i]:-0}
    (( a > b )) && return 0
    (( a < b )) && return 1
  done
  return 0
}

# --- Tool / config state (single check layer for gating + doctor + menus) ----

tool_state() { # tool_state <tool> → "ok <bin> <ver>" | "old <bin> <ver> <min>" | "missing"
  local tool="$1" bins bin first ver vmin
  # bins is COMMA-separated ("yazi,ya"); word-splitting alone would treat
  # the whole list as one nonexistent command name. (Found the hard way:
  # yazi installed fine yet reported missing on the Ubuntu VM.)
  bins=$(reg_field "$tool" bins | tr ',' ' ')
  first=""
  for bin in $bins; do
    have "$bin" || { printf 'missing\n'; return 0; }
    [[ -z $first ]] && first="$bin"
  done
  [[ -z $first ]] && { printf 'missing\n'; return 0; }   # no binaries declared
  ver=$(ver_of "$first" "$(reg_field "$tool" vflag)")
  vmin=$(reg_field "$tool" min)
  if [[ -n $vmin ]] && ! ver_ge "$ver" "$vmin"; then
    printf 'old %s %s %s\n' "$first" "${ver:-unknown}" "$vmin"
  else
    printf 'ok %s %s\n' "$first" "${ver:-unknown}"
  fi
  return 0
}

# Config state aggregated over a tool's link pairs:
#   none | placeholder | linked | unlinked | foreign (target occupied by
#   something that is not our symlink)
config_state() { # config_state <tool>
  local tool="$1" pairs line src dst ready=1 linked=0 foreign=0 n=0
  pairs=$(config_pairs_for "$tool")
  [[ -z $pairs ]] && { printf 'none\n'; return 0; }
  while IFS=$'\t' read -r src dst; do
    [[ -z $src || -z $dst ]] && continue
    n=$((n + 1))
    if ! source_is_ready "$src"; then
      ready=0
      continue
    fi
    if [[ -L $dst && "$(readlink "$dst")" == "$REPO_ROOT/$src" ]]; then
      linked=$((linked + 1))
    elif [[ -e $dst || -L $dst ]]; then
      foreign=$((foreign + 1))
    fi
  done <<<"$pairs"
  (( ready == 0 )) && { printf 'placeholder\n'; return 0; }
  (( n == 0 )) && { printf 'none\n'; return 0; }
  (( foreign > 0 )) && { printf 'foreign\n'; return 0; }
  (( linked == n )) && { printf 'linked\n'; return 0; }
  printf 'unlinked\n'
  return 0
}

# A source is deployable when it is a plain file, or a directory holding
# anything beyond its README placeholder. Placeholder-only dirs are skipped
# so the skeleton stage never touches live configs (inherited behavior
# from the original install.sh).
source_is_ready() { # source_is_ready <repo-relative src>
  local src="$1" entries
  if [[ -f "$REPO_ROOT/$src" ]]; then
    return 0
  fi
  entries=$(find "$REPO_ROOT/$src" -mindepth 1 -maxdepth 1 ! -name 'README.md' -print -quit 2>/dev/null)
  [[ -n $entries ]]
}

# --- Manual-install command block (bootstrap --manual AND doctor) -------------

detect_pkgmgr() { # → brew | pacman | apt | dnf on stdout; exit 1 (printing
  # "unknown" + a hint on stderr) when nothing matches — callers decide
  # whether that is fatal (tools.sh) or just a quieter report (doctor.sh)
  local ID="" ID_LIKE=""
  case "$(uname -s)" in
    Darwin)
      if have brew; then printf 'brew\n'; return 0; fi
      printf 'unknown\n'
      printf 'arronflow: Homebrew not found — see https://brew.sh\n' >&2
      return 1
      ;;
  esac
  . /etc/os-release
  case "$ID $ID_LIKE" in
    *arch*) printf 'pacman\n'; return 0 ;;
    *debian*) printf 'apt\n'; return 0 ;;
    *fedora*) printf 'dnf\n'; return 0 ;;
  esac
  printf 'unknown\n'
  printf 'arronflow: unsupported distro %s — Arch, Debian/Ubuntu and Fedora families are supported\n' "${ID:-?}" >&2
  return 1
}

# Does this package manager currently OFFER the package? Local-cache queries
# only (pacman's sync dbs, apt's lists) — read-only and network-free, so
# doctor can call them freely. Managers without a cheap local query (brew,
# dnf) assume yes; their registry entries are curated per platform anyway.
pkg_available() { # pkg_available <pkgmgr> <pkgname>
  local cand
  case "$1" in
    pacman) have pacman && pacman -Si "$2" >/dev/null 2>&1 ;;
    apt)
      cand=$(apt-cache policy "$2" 2>/dev/null | sed -n 's/^  Candidate: //p')
      [[ -n $cand && $cand != "(none)" ]]
      ;;
    *) return 0 ;;
  esac
}

# Prints the install commands for ONE tool on the CURRENT platform, plus a
# stable GitHub link when this platform has no native package for it.
# Never calls the GitHub API and never installs anything — safe on a box
# with zero tools and zero network.
print_manual_block() { # print_manual_block <tool> [pkgmgr]
  local tool="$1" pkg="${2:-$(detect_pkgmgr)}"
  local brew pacman apt dnf gh repo native spec pkgname realbin
  brew=$(reg_field "$tool" brew)
  pacman=$(reg_field "$tool" pacman)
  apt=$(reg_field "$tool" apt)
  dnf=$(reg_field "$tool" dnf)
  gh=$(reg_field "$tool" gh)
  native=""
  case "$pkg" in
    brew) native="$brew" ;;
    pacman) native="$pacman" ;;
    apt) native="$apt" ;;
    dnf) native="$dnf" ;;
  esac
  printf '  %s:\n' "$tool"
  case "$pkg" in
    brew)
      if [[ -n $brew ]]; then
        for spec in ${brew//,/ }; do
          if [[ $spec == cask:* ]]; then
            printf '    brew install --cask %s\n' "${spec#cask:}"
          else
            printf '    brew install %s\n' "$spec"
          fi
        done
      fi
      ;;
    pacman)
      if [[ -n $pacman ]]; then
        if pkg_available pacman "$pacman"; then
          printf '    sudo pacman -S --needed %s\n' "$pacman"
        else
          printf '    # %s is not in this repo set (e.g. Ghostty on Arch Linux ARM) — optional\n' "$pacman"
        fi
      fi
      ;;
    apt)
      for spec in ${apt//,/ }; do
        pkgname="${spec%%:*}"
        if pkg_available apt "$pkgname"; then
          printf '    sudo apt update && sudo apt install -y %s\n' "$pkgname"
        else
          printf '    # no %s package on this release (e.g. Ghostty on Ubuntu < 26.04) — optional\n' "$pkgname"
        fi
        if [[ $spec == *:* ]]; then
          realbin="${spec#*:}"
          printf '    # Debian names the binary %s — arronflow links it as %s in ~/.local/bin\n' \
            "$realbin" "$(reg_field "$tool" bins | cut -d, -f1)"
        fi
      done
      ;;
    dnf)
      [[ -n $dnf ]] && printf '    sudo dnf install -y %s\n' "$dnf"
      ;;
  esac
  if [[ -n $gh && -z $native ]]; then
    repo="${gh%%:*}"
    printf '    official release: https://github.com/%s/releases/latest\n' "$repo"
  fi
  case ",$(reg_field "$tool" post)," in *,omz,*)
    printf '    Oh My Zsh + plugins: see https://ohmyz.sh (bootstrap --auto %s does the clones)\n' "$tool" ;;
  esac
}
