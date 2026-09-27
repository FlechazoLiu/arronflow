#!/usr/bin/env bash
#
# Create-or-attach tmux session helper.
#
#   session.sh                list all sessions
#   session.sh <name> [dir]   attach to session <name>; create it rooted
#                             at [dir] (default: the current directory)
#                             if it does not exist yet
#
# One session per project is the intended workflow: `session.sh arron
# ~/Work/Arron` on a fresh morning recreates nothing — it just lands you
# back in yesterday's session, processes and scrollback intact.
#
# When already inside tmux, attaching uses switch-client instead of a
# nested `tmux attach` (which tmux refuses with "sessions should be
# nested with care, unset $TMUX to override"). Targets are matched with
# "=name" for exactness — a plain name would also prefix-match a session
# called <name>-something.

set -euo pipefail

if (( $# == 0 )); then
  exec tmux ls
fi

name=$1
dir=${2:-$PWD}

if ! tmux has-session -t "=$name" 2>/dev/null; then
  tmux new-session -d -s "$name" -c "$dir"
  printf 'created session %s (rooted at %s)\n' "$name" "$dir"
fi

if [[ -n ${TMUX:-} ]]; then
  exec tmux switch-client -t "=$name"
else
  exec tmux attach-session -t "=$name"
fi
