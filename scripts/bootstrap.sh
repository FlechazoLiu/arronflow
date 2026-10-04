#!/usr/bin/env bash
#
# The arronflow entry point — picks a phase and hands off. The phases live
# in their own scripts so each stays small and readable:
#
#   tools.sh    phase 1 — install tool binaries (automatic or manual commands)
#   install.sh  phase 2 — deploy configs, gated on the binaries being present
#   doctor.sh   read-only health report
#
#   no args + terminal → numbered menu below
#   --tools | --configs | --doctor | --everything   run that phase
#   --auto | --manual    install mode (needed by --tools/--everything when piped)
#   --all | <tool>...    which tools; --dry-run passes through
#
# Piped with no arguments = usage error: auto-install runs sudo and must
# never be a silent default.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS="$REPO_ROOT/scripts"
source "$SCRIPTS/lib/common.sh"
source "$SCRIPTS/lib/registry.sh"
prepend_paths

usage() {
  cat <<'EOF'
usage: bootstrap.sh [--tools | --configs | --doctor | --everything]
                    [--auto | --manual] [--all | <tool>...] [--dry-run]

  no args + terminal → interactive menu
  --everything       phase 1 (tools) then phase 2 (configs)
  --tools            scripts/tools.sh    (requires --auto or --manual when piped)
  --configs          scripts/install.sh  (gated on installed binaries)
  --doctor           scripts/doctor.sh   (read-only)
EOF
  exit 2
}

PHASE="" MODE="" DRY="" ALL=0
TOOLS=""                       # space-joined tool names (word-split on handoff)
while (( $# > 0 )); do
  case "$1" in
    --tools) PHASE=tools ;;
    --configs) PHASE=configs ;;
    --doctor) PHASE=doctor ;;
    --everything) PHASE=everything ;;
    --auto) MODE="--auto" ;;
    --manual) MODE="--manual" ;;
    --all) ALL=1 ;;
    --dry-run) DRY="--dry-run" ;;
    -h | --help) usage ;;
    -*) printf 'unknown flag: %s\n\n' "$1" >&2; usage ;;
    *)
      reg_has "$1" || die "unknown tool: $1 (scripts/tools.sh --list)"
      TOOLS="$TOOLS $1"
      ;;
  esac
  shift
done
TOOLS="${TOOLS# }"

if [[ -z $PHASE ]]; then
  if is_interactive; then
    printf 'arronflow — what do you want to do?\n\n'
    printf '  1) everything   install tools, then deploy configs\n'
    printf '  2) tools        install tool binaries only\n'
    printf '  3) configs      deploy configs only (gated on installed binaries)\n'
    printf '  4) doctor       read-only health report\n'
    printf '  5) quit\n\n'
    choice="1"
    ask 'choice [1]: ' choice
    case "${choice:-1}" in
      1) PHASE=everything ;;
      2) PHASE=tools ;;
      3) PHASE=configs ;;
      4) PHASE=doctor ;;
      5) exit 0 ;;
      *) die "invalid choice: $choice" ;;
    esac
  else
    usage
  fi
fi

ALLFLAG=""
if [[ $ALL == 1 ]]; then ALLFLAG="--all"; fi

case "$PHASE" in
  doctor)
    exec "$SCRIPTS/doctor.sh" $TOOLS
    ;;
  configs)
    # No forwarded flags = install.sh's own defaults (menu on a TTY,
    # everything when piped).
    exec "$SCRIPTS/install.sh" $TOOLS $ALLFLAG $DRY
    ;;
  tools | everything)
    # Phase 1 needs an install mode; ask when interactive, demand when piped.
    if [[ -z $MODE ]]; then
      if is_interactive; then
        if confirm 'install automatically? [Y/n] (n = print the manual commands) ' y; then
          MODE="--auto"
        else
          MODE="--manual"
        fi
      else
        printf 'error: --tools/--everything needs --auto or --manual when piped\n\n' >&2
        usage
      fi
    fi
    if [[ $PHASE == tools ]]; then
      exec "$SCRIPTS/tools.sh" $MODE $TOOLS $ALLFLAG $DRY
    fi
    # everything: phase 1 as a child (a missing optional tool must not stop
    # phase 2 — the config gates report exactly what deployed and what didn't),
    # then phase 2 replaces us so its exit code is the answer.
    "$SCRIPTS/tools.sh" $MODE $TOOLS $ALLFLAG $DRY || true
    exec "$SCRIPTS/install.sh" $TOOLS $ALLFLAG $DRY
    ;;
esac
