#!/usr/bin/env bash
# Compatibility shim — the unified entry point is scripts/arron.
# Old flags keep working during the migration; new usage: `arron help`.

set -euo pipefail
SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "${1:-}" in
  --everything) shift; exec "$SCRIPTS/arron" up "$@" ;;
  --tools) shift; exec "$SCRIPTS/arron" tools "$@" ;;
  --configs) shift; exec "$SCRIPTS/arron" config "$@" ;;
  --doctor) shift; exec "$SCRIPTS/arron" doctor "$@" ;;
esac
exec "$SCRIPTS/arron" "$@"
