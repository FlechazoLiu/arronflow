# Our tmux keybindings — the live keymap

The keymap as deployed by `config/tmux/tmux.conf` (verified 2026-09-28
against the running tmux 3.7c). Our remaps are few and deliberate; most
of the keymap is still stock, and untouched defaults keep working. What
stock tmux looks like — on a vanilla server, prefix `C-b` — is recorded
separately in [tmux-keys-default.md](tmux-keys-default.md).

## The shape of it

- Prefix **`C-a`**; `prefix C-a` sends a literal Ctrl+a to the pane.
- Copy mode is **vi**; the mouse is on.
- Style: vim directions (`hjkl`) for movement, the capital letter for
  the "big" version of the same action (resize).

## What we remapped

| Action | Stock | Ours | Why |
| --- | --- | --- | --- |
| Prefix | `C-b` | `C-a` | Closer to the home row; `C-a C-a` still passes a literal Ctrl+a through to the pane. |
| Split side by side | `%` | `\` | Pairs visually with `-`; the new pane also **inherits the pane's directory** (stock splits start in the session's start directory). |
| Split stacked | `"` | `-` | Same reasoning. |
| Move between panes | arrows | `h j k l` | Vim directions, hands stay on the home row. |
| Resize pane | `C-arrow` (1) / `M-arrow` (5) | `H J K L` (5) | Same hand as movement; `-r` makes one press stretch while held. |
| Start selection (copy mode) | `Space` | `v` | The vim reflex; `Space` still works. |
| Rectangular selection | `v` | `C-v` | `v` is taken for selection; `C-v` matches vim's visual-block. |
| Copy and exit (copy mode) | `Enter` | `y` | `y` for yank; `Enter` still works. |

Two additions with no stock counterpart:

| Keys | Action |
| --- | --- |
| `prefix r` | reload `~/.config/tmux/tmux.conf` (the 30-second tuning loop) |
| `prefix t` | new window in the pane's current directory |

## Cheat sheet

The essentials — `prefix ?` lists everything. "ours" marks a remap or
addition, "stock" an untouched default.

### Meta

| Keys | Source | Action |
| --- | --- | --- |
| `prefix r` | ours | reload config, confirm on screen |
| `prefix :` | stock | command prompt — any tmux command by name |
| `prefix ?` | stock | annotated key list |
| `prefix /` | stock | search the key list |
| `prefix C` | stock | interactive options browser |
| `prefix d` | stock | detach |
| `prefix ~` | stock | tmux message log |
| `prefix C-z` | stock | suspend the client |

### Session

| Keys | Source | Action |
| --- | --- | --- |
| `prefix s` | stock | session tree |
| `prefix $` | stock | rename session |
| `prefix (` / `)` | stock | previous / next session |

### Window

| Keys | Source | Action |
| --- | --- | --- |
| `prefix t` | ours | new window, current directory |
| `prefix c` | stock | new window (no directory inheritance — prefer `t`) |
| `prefix ,` | stock | rename window |
| `prefix n` / `p` | stock | next / previous window |
| `prefix 1`–`9` | stock | window by number |
| `prefix w` | stock | window tree |
| `prefix '` | stock | jump by index (prompt) |
| `prefix &` | stock | kill window |

### Pane

| Keys | Source | Action |
| --- | --- | --- |
| `prefix \` / `prefix -` | ours | split side by side / stacked, inherit cwd |
| `prefix h j k l` | ours | move focus |
| `prefix H J K L` | ours | resize by 5, repeatable while held |
| `prefix z` | stock | zoom toggle |
| `prefix o` / `;` | stock | cycle panes / back to previous pane |
| `prefix x` | stock | kill pane |
| `prefix q` | stock | flash pane numbers |
| `prefix Space` | stock | cycle preset layouts |
| `prefix {` / `}` | stock | swap pane up / down |
| `prefix !` | stock | promote pane to its own window |

### Copy & paste

| Keys | Source | Action |
| --- | --- | --- |
| `prefix [` | stock | enter copy mode |
| `prefix ]` | stock | paste newest tmux buffer |
| `prefix =` | stock | pick from all past copies |

### Copy mode (vi)

| Keys | Source | Action |
| --- | --- | --- |
| `h j k l`, `w`/`b`, `0`/`$` | stock | move |
| `g` / `G` | stock | jump to history top / bottom (single `g`, not `gg`) |
| `H` / `M` / `L` | stock | visible screen top / middle / bottom |
| `/` / `?`, `n` / `N` | stock | search down / up, repeat |
| `v` | ours | start selection |
| `C-v` | ours | rectangular selection |
| `y` | ours | copy and exit |
| `Space` / `Enter` | stock | alternative start-selection / copy keys |
| `q` / `Esc` | stock | exit without copying |

Every copy lands in both tmux's buffers **and** the system clipboard
(`set-clipboard on`).

### Mouse

Untouched stock bindings — the full table lives in
[tmux-keys-default.md](tmux-keys-default.md). The three worth
remembering: **middle-click** pastes, **right-click** opens context
menus (pane, window, session name), and the **wheel over the status
bar** switches windows. `Shift` + drag makes a native Ghostty selection
that can cross panes and include the status line.

## Known shadows

A remap overwrites the stock binding on the same key — three cases
worth knowing:

- **`prefix l`** — stock: jump to the last-used window; ours:
  select-pane right. Last-window currently has no key; use window
  numbers, `prefix '`, or `prefix w`. A dedicated binding is a
  candidate for the upcoming keybinding-optimization pass.
- **`prefix %` / `prefix "`** — still bound (stock) but superseded:
  they work, they just don't inherit the current directory. Prefer
  `\` and `-`.
- **`prefix c`** — likewise still works; `t` is the same thing plus
  directory inheritance.

## Inspecting the live keymap

```sh
tmux list-keys -T prefix        # the exact table, ours + stock
tmux list-keys -T copy-mode-vi  # the copy-mode table
```

`prefix ?` renders the same with descriptions, and `prefix /` searches
it. After editing `config/tmux/tmux.conf`, `prefix r` reloads it into
the running server — the deploy is a symlink, so the repo file and the
live file are the same file.
