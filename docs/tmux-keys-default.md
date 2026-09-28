# tmux default keybindings — stock tmux

The keymap a **vanilla tmux** gives you — what you will meet on any server
you ssh into. Verified against tmux 3.7c (`tmux list-keys`); behaviour is
stable across recent 3.x. Our own machines diverge in a handful of places
(prefix, splits, hjkl, copy keys) — the deltas are listed in
[tmux-keys-ours.md](tmux-keys-ours.md).

On stock tmux the prefix is `C-b`; `C-b C-b` sends a literal Ctrl-b to the
pane. The authoritative list on any machine is `tmux list-keys`, or
`prefix ?` for the annotated version.

## Meta

| Keys | Action |
| --- | --- |
| `C-b` | prefix |
| `prefix :` | command prompt — any tmux command by name |
| `prefix ?` | all keys, annotated |
| `prefix /` | search keys by name (3.7) |
| `prefix C` | interactive options browser (customize-mode) |
| `prefix d` | detach |
| `prefix ~` | tmux message log |
| `prefix C-z` | suspend the client |

## Session

| Keys | Action |
| --- | --- |
| `prefix s` | session/window tree (navigate, Enter to jump) |
| `prefix $` | rename session |
| `prefix (` / `)` | previous / next session |
| `prefix D` | choose a client to detach |

## Window

| Keys | Action |
| --- | --- |
| `prefix c` | new window |
| `prefix &` | kill window (confirm) |
| `prefix ,` | rename window |
| `prefix n` / `p` | next / previous window |
| `prefix 0`–`9` | window by number |
| `prefix w` | window tree |
| `prefix '` | jump to window by number (prompt) |
| `prefix l` | last (previously used) window |
| `prefix .` | move window to another index/session (prompt) |
| `prefix <` | window menu (rename, swap, kill, respawn…) |

## Pane

| Keys | Action |
| --- | --- |
| `prefix %` / `"` | split side-by-side / stacked |
| prefix arrows | move focus (repeatable) |
| `prefix C-arrow` / `M-arrow` | resize by 1 / 5 (repeatable) |
| `prefix o` | cycle focus to next pane |
| `prefix ;` | back to previous pane |
| `prefix {` / `}` | swap pane up / down |
| `prefix x` | kill pane (confirm) |
| `prefix z` | zoom toggle |
| `prefix q` | show pane numbers |
| `prefix Space` | cycle preset layouts |
| `prefix M-1`…`M-5` | even-horizontal, even-vertical, main-horizontal, main-vertical, tiled |
| `prefix !` | promote pane to its own window |
| `prefix >` | pane menu (split, swap, kill, zoom, mark…) |
| `prefix m` / `M` | mark pane / clear mark |
| `prefix E` | spread panes evenly |

## Copy & paste

| Keys | Action |
| --- | --- |
| `prefix [` | enter copy mode |
| `prefix PPage` | enter copy mode scrolled up one page |
| `prefix ]` | paste newest tmux buffer |
| `prefix =` | buffer list (paste any previous copy) |
| `prefix #` | list buffers |

## Copy mode

Stock tmux defaults to **emacs**-flavoured copy mode:

| Keys | Action |
| --- | --- |
| `C-n` / `C-p` / `C-f` / `C-b` | cursor down / up / right / left |
| `C-a` / `C-e` | line start / end |
| `C-s` / `C-r` | incremental search down / up |
| `C-Space` | begin selection |
| `M-w` | copy and exit |
| `q` | exit without copying |

If the machine is set to vi keys (`set -g mode-keys vi`), the vi table
applies instead — motion is `h j k l`, `w`/`b`, `0`/`$`, `g` (history
top) / `G` (history bottom), `H`/`M`/`L` (screen top/middle/bottom),
`{`/`}` (paragraph), search `/` and `?` with `n`/`N`. Note two traps for
vim users: **`Space` begins a selection (not `v`)** — plain `v` is
rectangle-toggle — and **there is no `y`**; `Enter` copies and exits.

## Mouse (with `mouse on`)

| Action | Result |
| --- | --- |
| click a pane | focus it |
| click a window name in the status bar | switch to that window |
| **middle-click** a pane | paste the tmux buffer |
| **right-click** a pane | pane menu (split, swap, kill, zoom, mark…) |
| **right-click** a window in the status bar | window menu (rename, swap, kill…) |
| **right-click** the session name | session menu (rename, renumber, new…) |
| drag in a pane | select; copies on release |
| double / triple click | select word / line |
| drag a border | resize |
| wheel over a pane | scroll history (enters copy mode) |
| wheel over the status bar | previous / next window |
