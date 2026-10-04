#!/usr/bin/env bash
#
# Read-only health report: for every registry tool — is the binary present,
# is the version adequate, is the config linked? — followed by the manual
# install commands for whatever is missing. Writes nothing, installs
# nothing; it is the "downloads are my job" companion to install.sh.
#
#   doctor.sh [tool...]   default: every tool in the registry
#
# Exit codes: 0 = healthy (placeholder configs are pending, not failures);
# 1 = something needs attention; 2 = usage.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS="$REPO_ROOT/scripts"
source "$SCRIPTS/lib/common.sh"
source "$SCRIPTS/lib/registry.sh"
source "$SCRIPTS/lib/ui.sh"
prepend_paths

usage() {
  cat <<'EOF'
usage: doctor.sh [tool...]   health report for every registry tool (or a subset)

Read-only: binary present? version >= minimum? config linked?
Prints manual install commands for anything missing. Exit 1 needs attention.
EOF
  exit 2
}

# --- Arguments -------------------------------------------------------------------

WANT=()
while (( $# > 0 )); do
  case "$1" in
    -h | --help) usage ;;
    -*) printf 'unknown flag: %s\n\n' "$1" >&2; usage ;;
    *)
      reg_has "$1" || die "unknown tool: $1"
      WANT+=("$1")
      ;;
  esac
  shift
done

if (( ${#WANT[@]} == 0 )); then
  WANT=($(reg_names))
fi

PKG=$(detect_pkgmgr) || PKG=unknown

# --- Report ----------------------------------------------------------------------

ISSUES=0
MISSING_TOOLS=""

note_for() { # note_for <tool> <state> <cstate> — the actionable hint (prints)
  local tool="$1" st="$2" cstate="$3"
  if [[ $st == missing ]]; then
    printf 'install: arron tools --auto %s' "$tool"
  elif [[ $st == old ]]; then
    printf 'upgrade to >= %s' "$(reg_field "$tool" min)"
  elif [[ $cstate == foreign ]]; then
    printf 'target occupied — deploy will back it up'
  elif [[ $cstate == placeholder ]]; then
    printf 'config pending in repo'
  elif [[ $cstate == unlinked ]]; then
    printf 'deploy: arron config %s' "$tool"
  else
    printf '-'
  fi
  return 0
}

printf '%-3s %-10s %-26s %-19s %-12s %s\n' '' TOOL BINARY VERSION CONFIG NOTE
for t in "${WANT[@]}"; do
  state=$(tool_state "$t")            # ok <bin> <ver> | old <bin> <ver> <min> | missing
  cstate=$(config_state "$t")
  st="${state%% *}"
  bin="" ver=""
  if [[ $st != missing ]]; then
    bin=$(printf '%s\n' "$state" | awk '{print $2}')
    ver=$(printf '%s\n' "$state" | awk '{print $3}')
  fi
  bin="${bin/#$HOME/~}"
  if [[ -z $bin ]]; then bin="-"; fi
  vmin=$(reg_field "$t" min)
  if [[ -n $ver && -n $vmin ]]; then
    ver="$ver (min $vmin)"
  elif [[ -z $ver ]]; then
    ver="-"
  fi
  if [[ $st == missing ]]; then
    MISSING_TOOLS="$MISSING_TOOLS $t"
  fi
  marker="✓"
  color=32
  if [[ $st != ok || $cstate == foreign || $cstate == unlinked ]]; then
    ISSUES=$((ISSUES + 1))
    marker="✗"; color=31
  elif [[ $cstate == placeholder ]]; then
    marker="⚠"; color=33
  fi
  note=$(note_for "$t" "$st" "$cstate")
  marker=$(ui_color "$color" "$marker")
  printf '%-3s %-10s %-26s %-19s %-12s %s\n' "$marker" "$t" "$(printf %.24s "$bin")" \
    "$(printf %.17s "$ver")" "$cstate" "$note"
done

# --- Manual commands for the gaps ---------------------------------------------------

if [[ -n ${MISSING_TOOLS# } && $PKG != unknown ]]; then
  printf '\nManual install commands (%s):\n' "$PKG"
  for t in ${MISSING_TOOLS# }; do
    print_manual_block "$t" "$PKG"
  done
  printf '\nor let arron do it: arron tools --auto %s\n' "${MISSING_TOOLS# }"
fi

if (( ISSUES > 0 )); then
  printf '\n%d item(s) need attention.\n' "$ISSUES"
  exit 1
fi
printf '\nAll healthy.\n'
