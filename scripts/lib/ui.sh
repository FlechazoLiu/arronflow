# Presentation layer for arronflow's scripts.
#
# Interactive + gum installed → gum controls. Otherwise → the pure-bash
# baseline from common.sh. The baseline is not optional dead code: it is
# how the FIRST run asks permission to install gum, how pipes/CI run, and
# how an offline machine stays usable.
#
# Sourced after common.sh. Bash 3.2 compatible.

# Capture terminal capabilities at source time. `ui_choose` is normally called
# inside command substitution (`pick=$(...)`), where fd 1 becomes a pipe; a
# live `-t 1` check there would falsely disable gum and color. Gum renders its
# controls on the terminal via stderr while reserving stdout for the choice.
UI_INTERACTIVE=0
UI_COLOR=0
[[ -t 0 && -t 2 ]] && UI_INTERACTIVE=1
[[ -t 1 && -z ${NO_COLOR:-} ]] && UI_COLOR=1

ui_has_gum() { [[ $UI_INTERACTIVE == 1 ]] && have gum; }

ui_color() { # ui_color <ANSI code> <text...> — color only on a TTY, honoring NO_COLOR
  local code="$1"; shift
  if [[ $UI_COLOR == 1 ]]; then
    printf '\033[%sm%s\033[0m' "$code" "$*"
  else
    printf '%s' "$*"
  fi
}

ui_title() {
  if ui_has_gum; then
    gum style --bold --foreground 99 --padding "0 1" "$*"
  else
    printf '\n'; ui_color '1;35' "$*"; printf '\n'
  fi
}

ui_section() {
  if ui_has_gum; then
    gum style --bold --foreground 99 "$*"
  else
    printf '\n'; ui_color '1;35' "==> $*"; printf '\n'
  fi
}

ui_ok()   { ui_color '32' '✓'; printf ' %s\n' "$*"; }
ui_warn() { ui_color '33' '⚠'; printf ' %s\n' "$*"; }
ui_err()  { ui_color '31' '✗'; printf ' %s\n' "$*"; }
ui_info() { ui_color '36' '•'; printf ' %s\n' "$*"; }
ui_dim()  { ui_color '2' "$*"; }

ui_confirm() { # ui_confirm <prompt> [default y|n] — exit 0=yes
  local prompt="$1" default="${2:-n}"
  if ui_has_gum; then
    if [[ $default == y ]]; then
      gum confirm --default=true "$prompt"
    else
      gum confirm --default=false "$prompt"
    fi
  else
    local marker='[y/N] '
    [[ $default == y ]] && marker='[Y/n] '
    confirm "$prompt $marker" "$default"
  fi
}

ui_choose() { # ui_choose <header> <option...> — chosen option on stdout; empty on cancel
  local header="$1"; shift
  local answer=""
  if ui_has_gum; then
    answer=$(gum choose --header "$header" "$@") || answer=""
    printf '%s\n' "$answer"
    return 0
  fi
  # Single-select baseline: numbered list, default first item.
  local i input="1"
  printf '\n%s\n\n' "$header" >&2
  i=1
  for answer in "$@"; do printf '  %d) %s\n' "$i" "$answer" >&2; i=$((i + 1)); done
  ask "choice [1]: " input
  input="${input:-1}"
  case "$input" in *[!0-9]* | 0) printf '\n'; return 0 ;; esac
  i=1
  for answer in "$@"; do
    if (( i == input )); then printf '%s\n' "$answer"; return 0; fi
    i=$((i + 1))
  done
  printf '\n'
  return 0
}

ui_multiselect() { # ui_multiselect <varname> <header> <item...>
  local var="$1" header="$2"; shift 2
  local answer=""
  if ui_has_gum; then
    # gum prints selected values newline-separated; registry keys contain no spaces.
    answer=$(gum choose --no-limit --header "$header" "$@") || answer=""
    answer=$(printf '%s\n' "$answer" | tr '\n' ' ')
    answer="${answer% }"
    printf -v "$var" '%s' "$answer"
  else
    printf '%s\n' "$header"
    menu_select "$var" "$@"
  fi
  return 0
}

ui_input() { # ui_input <prompt> <varname> — empty on cancel/EOF
  local prompt="$1" var="$2" answer=""
  if ui_has_gum; then
    answer=$(gum input --prompt "$prompt " 2>/dev/null) || answer=""
  else
    ask "$prompt " answer
  fi
  printf -v "$var" '%s' "$answer"
  return 0
}

ui_spin() { # ui_spin <title> <command> [args...] — preserves child exit status
  local title="$1"; shift
  if ui_has_gum; then
    gum spin --spinner dot --title "$title" --show-error -- "$@"
  else
    "$@"
  fi
}

# First-run bootstrap. Deliberately pure bash until gum exists: an installer
# cannot require the UI dependency it is trying to install. Refusal/offline
# failure degrades gracefully; every operation remains available in baseline UI.
ui_ensure_gum() { # ui_ensure_gum <scripts-dir>
  local scripts="$1"
  if ! is_interactive || have gum; then return 0; fi
  printf '\narronflow uses gum for its interactive UI.\n'
  printf 'It is not installed yet; the first prompt stays intentionally plain.\n\n'
  if confirm 'Install the lightweight gum UI now? [y/N] ' n; then
    "$scripts/tools.sh" --auto gum || {
      ui_warn 'gum install failed; continuing with the pure-bash interface.'
      return 0
    }
  else
    ui_info 'Continuing with the pure-bash interface (gum can be installed later).'
  fi
  return 0
}
