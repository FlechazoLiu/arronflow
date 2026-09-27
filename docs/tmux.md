# tmux

## Status

**In progress** — the configuration lives in this repo and is deployed
(`config/tmux/tmux.conf` → `~/.config/tmux/tmux.conf`, symlinked by
`scripts/install.sh`). Done so far: migration of the pre-repo config, base
options, pane/window key bindings, the complete copy-and-paste layer
(mouse selection, system clipboard, copy mode), and the Atom One Dark
theme pass. Pending: `escape-time` tuning, the sessions/scripting lesson,
and a final keybinding-optimization pass. Last updated 2026-09-27.

## Role

tmux is the layer between the terminal emulator and the shells. One tmux
**server** owns **sessions**; each session holds **windows** (think tabs),
and each window holds **panes** (splits). Sessions live in the server, not
in the terminal window: close Ghostty, walk away, ssh back in from another
machine — `tmux attach` and everything is still running where you left it.
On this Mac it is also simply the way one terminal becomes several,
side by side.

## Background

### Terminal, shell, multiplexer — who owns what

Recap from [ghostty.md](ghostty.md): the terminal emulator draws pixels
and reads keys; the shell inside it runs commands. tmux inserts itself
between the two: programs now run inside tmux panes, tmux composes all
panes into one screen, and Ghostty displays that screen. Almost everything
surprising about tmux — the mouse included — comes from this arrangement.

### Client and server

`tmux new` starts a background server plus a first session; every later
`tmux attach` is merely a client looking at it. The server survives
closing the terminal, dropping the network, logging out; only
`tmux kill-server` (or a reboot) ends it. That is why sessions persist.

### Windows and panes

session → windows (numbered; ours start at 1) → panes (splits of a
window). Numbering and traversal are covered in the key-bindings table
below.

### Why the mouse behaves differently inside tmux

Ghostty sees one big screen drawn by tmux. With `mouse on`, tmux asks the
terminal to hand over mouse events, so clicks/drags/wheel become tmux's
to interpret: a click focuses the pane under the pointer, a drag selects
text *within one pane*, the wheel scrolls that pane's history, borders
drag-resize. The terminal's own selection still exists but must be
summoned explicitly: **hold Shift while dragging** (Ghostty's
`mouse-shift-capture = false` default reserves Shift for exactly this).
Use it when a selection must cross pane borders or include the status
line.

### Copy mode

`prefix + [` opens tmux's pager over the pane's scrollback: a cursor
moved by keys (vi-style here), marking a selection, then copying. Mouse
drags secretly use copy mode too — a drag starts a selection and
releasing the button copies it.

### Two clipboards, one escape sequence

A copy inside tmux lands in tmux's **paste buffers** (`prefix + ]` pastes
the newest). To reach the *system* clipboard as well, tmux tells the
terminal "set your clipboard to this" using the **OSC 52** escape
sequence. Ghostty accepts it (`clipboard-write = allow`), and the same
path works over ssh — a tmux running on a remote server still sets the
clipboard of the Mac in front of you. The older alternative, piping to
`pbcopy`, only works where pbcopy exists, i.e. not on remote machines.

With our settings every copy — mouse release, double-click, `y` in copy
mode — goes to both places. No Cmd+C is needed; like Ghostty's
`copy-on-select = clipboard` outside tmux, the copy happens on release.

## Why tmux

- **vs GNU screen** — the previous generation. tmux is its modern
  successor: saner config format, scriptable, actively maintained.
- **vs zellij** — friendlier defaults, but a younger ecosystem. tmux is
  installed on nearly every server you will ever ssh into; learn it once,
  find it everywhere.
- **vs Ghostty's built-in splits** — terminal splits vanish with their
  window and never leave this Mac. tmux sessions persist and reattach
  from anywhere. Ghostty splits for throwaway side-by-side, tmux for
  anything worth keeping.

## Installation

```sh
brew bundle install        # or: brew install tmux
tmux -V                    # 3.7c at the time of writing; repo targets >= 3.4
```

tmux ≥ 3.1 reads `~/.config/tmux/tmux.conf` (XDG) — the path this repo
deploys. Caveat: tmux still prefers `~/.tmux.conf` when that file exists,
so the migration moved the pre-repo file aside
(`~/.tmux.conf.bak.20260927-191347`). Keep the home directory clean of a
`~/.tmux.conf`, or the repo file silently stops loading.

## Our configuration

Walkthrough of `config/tmux/tmux.conf`, grouped as the file is.

### Base options

- `set -g prefix C-a` + `unbind C-b` + `bind C-a send-prefix` — Ctrl+a is
  easier to reach than Ctrl+b; pressing the prefix twice sends a literal
  Ctrl+a to the pane (needed by shell line-editing).
- `set -g default-terminal "tmux-256color"` — the terminal type programs
  inside panes see; the standard companion to tmux.
- `set -as terminal-overrides ",*:RGB"` — 24-bit color passthrough, so
  true color survives inside tmux (Ghostty speaks it; this keeps the
  stack true-color end to end).
- `set -g history-limit 50000` — scrollback per pane, in lines.
- `set -g base-index 1` / `setw -g pane-base-index 1` — windows and panes
  number from 1, matching the number row.
- `set -g mouse on` — everything in the mouse section above.
- `set -g renumber-windows on` — window numbers stay gapless as windows
  close.
- `set -g focus-events on` — panes report focus changes, so editors like
  Neovim can refresh on activation.
- `bell-action none` + `visual-activity/bell/silence off` — no audible or
  visual bells.

### Copy & paste

- `set -g set-clipboard on` — the OSC 52 bridge to the system clipboard.
  The three states: `off` disables it; `external` (the default) pushes
  tmux's own copies out but ignores OSC 52 coming *from* applications;
  `on` accepts both directions — an ssh'd tmux or a TUI app can hand its
  selection up to the local clipboard too. We want both directions.
- `set -g mode-keys vi` — copy mode speaks vi (hjkl motion), matching the
  rest of this stack. Defaults worth knowing stay in place: `Space`
  starts a selection, `Enter` copies and quits, `q`/`Esc` quit.
- `v` begins a selection, `y` copies and quits — the vim-style reflexes.
  Plain `v` used to be rectangle-toggle; that moved to `C-v`.
- Double-click (word) and triple-click (line) selection are **defaults in
  tmux ≥ 3.7** — listed here because they look configured but are not;
  no lines in the file for them.

### Key bindings

- `prefix \ ` and `prefix -` split side by side / stacked, with
  `-c "#{pane_current_path}"` so new panes inherit the current directory.
- `prefix h/j/k/l` traverse panes in vim directions; `prefix H/J/K/L`
  resize by 5 columns/rows — `-r` makes them repeat while held.
- `prefix r` reloads the config from the deployed path — the 30-second
  tuning loop.
- `prefix t` opens a new window in the current directory.

### Theme (status bar, panes, prompts)

The status line is three segments — `status-left`, the window list,
`status-right` — rendered from *format strings* that mix three kinds of
markup: plain text, `#{variable}` interpolations, and `#[style]` ranges.
Colors may be named (`red`), 256-index (`colour117`), or true-color hex
(`#61afef`; tmux ≥ 3.2). The bar repaints every `status-interval` seconds
(default 15) — only relevant once `#()` shell commands appear in the
string; ours has none.

The theme anchors to Atom One Dark — the same palette as Ghostty — with
each color chosen by role, not by taste alone:

- `status-style` — bar background `#21252b` is Atom's *gutter* tone, one
  step darker than the editor background `#282c34`, so the bar reads as
  furniture, not content.
- `status-left` — session name on Atom's selection tone `#3e4451` in the
  palette blue `#61afef` (the same blue as the Ghostty cursor), closed by
  a sharp Powerline triangle — the separator family the p10k prompt
  uses. `status-left-length` must cover the whole block or tmux
  truncates it (the default is only 10).
- window list — inactive windows keep a dim number (`#5c6370`) and a
  quiet name (`#abb2bf`); the current window is the only blue block on
  the bar, so the eye always knows the focus. `#F` appends window flags
  (`Z` zoomed, `M` marked, `#` activity, `-` last window) — the pre-repo
  format dropped them, which hid the zoom indicator.
- `status-right` — dim clock in the same block shape as the session
  name, mirror triangle on its left edge.
- Pane borders — deliberately left at tmux **defaults** (tried themed
  and reverted). The default is not a plain color but a condition:
  green focus border, yellow while the pane is in copy mode, red under
  `synchronize-panes` — pane borders double as a mode indicator.
- `mode-style` — the copy-mode selection highlight, exactly Atom's
  selection tone; `message-style` — the `prefix :` prompt, same
  treatment.

No decorative icons — the prompt style is sparse and the theme follows;
adding one later is a one-line change to a format string.

## Key bindings

| Action                              | Keys                    |
| ----------------------------------- | ----------------------- |
| Prefix                              | `Ctrl+a`                |
| Split side by side / stacked        | `prefix \` , `prefix -` |
| Move between panes                  | `prefix h/j/k/l`        |
| Resize pane                         | `prefix H/J/K/L` (held) |
| New window (in cwd)                 | `prefix t`              |
| Reload config                       | `prefix r`              |
| Enter copy mode                     | `prefix [`              |
| Copy mode: move                     | `h j k l`, `w`/`b`, `g g`/`G` |
| Copy mode: start selection          | `v` (or `Space`)        |
| Copy mode: rectangular selection    | `C-v` then move         |
| Copy mode: copy + exit              | `y` (or `Enter`)        |
| Copy mode: exit without copying     | `q` / `Esc`             |
| Paste tmux buffer                   | `prefix ]`              |
| Mouse: focus / select / scroll      | click / drag / wheel    |
| Mouse: select word / line           | double-click / triple-click |
| Native Ghostty selection (across panes, status line) | `Shift` + drag |

Defaults worth knowing already (lesson pending): `prefix d` detach,
`prefix s` session list, `prefix w` window tree, `prefix z` zoom pane,
`prefix x` kill pane, `prefix ,` rename window.

## Tuning & exploring

- **The 30-second loop**: edit `config/tmux/tmux.conf` → `prefix r` →
  feel the change. No restart, no re-login; running panes are untouched.
- **Toggle the mouse** to feel what it does: `tmux toggle-mouse`.
- **Inspect live state**: `tmux show -g | grep -i mouse`,
  `tmux list-keys`, `tmux list-keys -T copy-mode-vi`.
- **Theme levers**: center the window list (`set -g status-justify
  centre`), put an icon in the session block (any Nerd Font glyph —
  Maple Mono NF CN carries them), or show live info like a git branch
  via `#(...)` — remember it re-runs every `status-interval` seconds.
- **Clipboard end-to-end test**: drag-select text in a pane → release →
  Cmd+V anywhere. The same test through a remote tmux (over ssh) is the
  reason `set-clipboard` beats pbcopy piping.
- FAQ:
  - *I selected, pressed Cmd+C, and pasted something old.* Inside tmux
    the copy already happened when the mouse was released; Cmd+C has no
    native selection to act on. Want the Ghostty flow after all?
    Shift+drag, then Cmd+C as usual.
  - *My selection grabbed text from two panes.* You Shift-dragged —
    native selection spans the whole screen. A plain drag stays inside
    one pane.
  - *How do I copy a rectangle (column)?* `prefix [`, move, `C-v`,
    adjust, `y`.
  - *Why didn't the config change apply after `prefix r`?* Most likely a
    `~/.tmux.conf` exists again and shadows the repo file — check
    `ls ~/.tmux.conf`.

## References

- `man tmux` — the complete reference for every option, command, and
  binding; installed locally, always at hand.
- [github.com/tmux/tmux](https://github.com/tmux/tmux) — the source
  repository; releases and changelogs when a new version lands in
  Homebrew.
- [tmux wiki](https://github.com/tmux/tmux/wiki) — the official wiki;
  recipes and FAQ when the man page is too terse.
