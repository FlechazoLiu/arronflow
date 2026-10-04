#!/usr/bin/env bash
#
# Phase 2 — config deployment: symlinks this repo's configs into place.
#
#   install.sh [tool...]   deploy the selected tools' configs
#                          (no args: menu on a terminal, everything when piped)
#   install.sh --list      tool | binary gate | config state
#   install.sh --dry-run   print LINK/SKIP/BACKUP decisions, change nothing
#
# Gating: a tool's config deploys only when the tool's BINARY is installed —
# no tmux, no tmux config. Tools are independent (skipping Ghostty never
# blocks tmux). Install binaries first: `arron tools` (`--manual` prints
# the commands for your platform). What gets linked lives in
# lib/registry.sh — one record per tool.
#
# Idempotent: re-running is always safe; existing files at a target are
# preserved as <target>.bak.<timestamp>, never silently overwritten.
# Exit code: 0 = every requested config deployed (or already linked);
# 1 = at least one was gated off because its tool is not installed.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS="$REPO_ROOT/scripts"
source "$SCRIPTS/lib/common.sh"
source "$SCRIPTS/lib/registry.sh"
source "$SCRIPTS/lib/ui.sh"
prepend_paths

usage() {
  cat <<'EOF'
usage: install.sh [tool...]   deploy configs for the named tools
                               (no args: menu on a terminal, everything when piped)
       install.sh --list      tool | binary gate | config state
       install.sh --dry-run   print decisions, change nothing
Tools are registry keys with a config (install.sh --list), e.g. install.sh tmux nvim
EOF
  exit 2
}

timestamp() { date +%Y%m%d-%H%M%S; }

cfg_tools() { # registry keys that carry a config (menu/default scope)
  local t
  for t in $(reg_names); do
    if [[ -n $(reg_field "$t" cfg) ]]; then
      printf '%s\n' "$t"
    fi
  done
  return 0
}

link_one() { # link_one <src> <dst> — placeholder-skip, backup, link (unchanged
  # semantics from the original install.sh)
  local src="$1" dst="$2" backup
  if ! source_is_ready "$src"; then
    printf 'SKIP    %-24s (not configured in this repo yet)\n' "$src"
    return 0
  fi
  if [[ -L "$dst" && "$(readlink "$dst")" == "$REPO_ROOT/$src" ]]; then
    printf 'OK      %-24s -> %s (already linked)\n' "$src" "$dst"
    return 0
  fi
  if [[ -n $DRY ]]; then
    if [[ -e "$dst" || -L "$dst" ]]; then
      printf 'DRY BACKUP %s -> %s.bak.<ts>\n' "$dst" "$dst"
    fi
    printf 'DRY LINK   %s -> %s\n' "$REPO_ROOT/$src" "$dst"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" || -L "$dst" ]]; then
    backup="$dst.bak.$(timestamp)"
    mv "$dst" "$backup"
    printf 'BACKUP %s -> %s\n' "$dst" "$backup"
  fi
  ln -s "$REPO_ROOT/$src" "$dst"
  printf 'LINK   %-24s -> %s\n' "$src" "$dst"
  return 0
}

GATED=0

deploy_tool() { # deploy_tool <tool> — binary gate, then link every config pair
  local tool="$1" state src dst doc
  state=$(tool_state "$tool")
  if [[ $state == missing ]]; then
    ui_warn "$tool: binary not installed — config not deployed"
    printf '        install first:  arron tools --auto %s   (--manual shows commands)\n' "$tool"
    doc=$(reg_field "$tool" docs)
    if [[ -n $doc ]]; then
      printf '        background:     %s\n' "$doc"
    fi
    # Never offer (let alone launch) an install from inside --dry-run.
    if is_interactive && [[ -z $DRY ]] && ui_confirm "Install $tool automatically now?" n; then
      "$SCRIPTS/tools.sh" --auto "$tool" || true
      state=$(tool_state "$tool")
    fi
    if [[ $state == missing ]]; then
      GATED=$((GATED + 1))
      return 0
    fi
    ui_ok "$tool: gate cleared after install — deploying"
  fi
  if [[ $state == old* ]]; then
    ui_warn "$tool: $state — older than the recorded minimum; deploying anyway"
  fi
  while IFS=$'\t' read -r src dst; do
    if [[ -z $src || -z $dst ]]; then continue; fi
    link_one "$src" "$dst"
  done < <(config_pairs_for "$tool")
  return 0
}

list_table() { # --list
  local t state cstate
  printf '%-10s %-9s %s\n' TOOL BINARY CONFIG
  for t in $(cfg_tools); do
    state=$(tool_state "$t")
    state="${state%% *}"           # ok | old | missing
    cstate=$(config_state "$t")
    printf '%-10s %-9s %s\n' "$t" "$state" "$cstate"
  done
  return 0
}

# --- Arguments -------------------------------------------------------------------

LIST=0 DRY="" ALL=0 ENTRY_ONLY=0
WANT=()
while (( $# > 0 )); do
  case "$1" in
    --list) LIST=1 ;;
    --dry-run) DRY=1 ;;
    --all) ALL=1 ;;
    --entrypoint-only) ENTRY_ONLY=1 ;;  # internal: `arron up gum` has no tool config
    -h | --help) usage ;;
    -*) printf 'unknown flag: %s\n\n' "$1" >&2; usage ;;
    *)
      reg_has "$1" || die "unknown tool: $1 (install.sh --list)"
      if [[ -z $(reg_field "$1" cfg) ]]; then
        die "$1 has no config in this repo (companion tool — nothing to deploy)"
      fi
      WANT+=("$1")
      ;;
  esac
  shift
done

if [[ $LIST == 1 ]]; then
  list_table
  exit 0
fi

if [[ $ENTRY_ONLY == 1 ]]; then
  WANT=()
elif [[ $ALL == 1 ]]; then
  WANT=($(cfg_tools))
elif (( ${#WANT[@]} == 0 )); then
  if is_interactive; then
    menu_want=""
    ui_multiselect menu_want 'Select configs to deploy (Space toggles; Enter accepts)' $(cfg_tools)
    if [[ -z $menu_want ]]; then
      printf 'Nothing selected.\n'
      exit 0
    fi
    WANT=($menu_want)
  else
    WANT=($(cfg_tools))
  fi
fi

printf 'Deploying arronflow configs from %s\n\n' "$REPO_ROOT"

# The unified command is itself deployed as a symlink, independent of every
# tool gate. Before ~/.local/bin is on PATH, invoke it as ./scripts/arron.
link_one "scripts/arron" "$HOME/.local/bin/arron"

if [[ $ENTRY_ONLY != 1 ]]; then
  for t in "${WANT[@]}"; do
    deploy_tool "$t"
  done
fi

if (( GATED > 0 )); then
  printf '\n%d config(s) gated off — install the tool(s) first, then re-run.\n' "$GATED"
  exit 1
fi

printf '\nDone. Restart running apps (or reload their config) to pick up changes.\n'
