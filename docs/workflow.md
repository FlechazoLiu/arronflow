# Workflow

How the six tools compose into one environment.

## Layers

```
┌───────────────────────────────────────────────────────────┐
│ Ghostty — terminal emulator (font, colors, tabs, splits)  │
│ ┌───────────────────────────────────────────────────────┐ │
│ │ tmux — persistent sessions, windows, panes            │ │
│ │ ┌───────────────┐ ┌─────────────────────────────────┐ │ │
│ │ │ zsh + Oh My   │ │ Neovim · lazygit · yazi         │ │ │
│ │ │ Zsh (shell)   │ │ (TUI apps running in panes)     │ │ │
│ │ └───────────────┘ └─────────────────────────────────┘ │ │
│ └───────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────┘
```

| Layer       | Tool        | Responsibility                                                            |
| ----------- | ----------- | ------------------------------------------------------------------------- |
| Terminal    | Ghostty     | Rendering, typography, theme, native tabs/splits, quick dropdown terminal |
| Multiplexer | tmux        | Sessions that outlive the terminal; windows and panes; ssh survivability  |
| Shell       | zsh + OMz   | Prompt, completion, history, aliases — the glue between everything        |
| Editor      | Neovim      | Editing, LSP, git gutter; lives in a tmux pane next to runners/watchers   |
| Git         | lazygit     | Staging hunks, committing, branching, rebasing — keyboard only            |
| Files       | yazi        | Fast navigation, previews, bulk operations; hands off to shell/editor     |

## A typical session

1. **Summon the terminal** — Ghostty quick terminal on a global hotkey, or a full window.
2. **Attach to tmux** — one session per project; sessions survive terminal restarts and ssh
   drops, so context is never lost.
3. **Navigate with yazi** — find the project, quit into a shell already `cd`'d there (via the
   shell wrapper function).
4. **Edit with Neovim** — one pane for the editor, neighboring panes for runner/build/watch.
5. **Commit with lazygit** — hunk-level staging without touching the mouse.
6. **Jump around** — zoxide for directories, fzf for files and history.

## Cross-tool conventions

- **vi keys everywhere** — `hjkl` navigation in tmux panes, Neovim, and yazi.
- **One color story** — true color (`TERM` overrides in tmux, `termguicolors` in Neovim) and a
  single palette family shared by all tools.
- **Nerd Font icons** — Maple Mono NF CN in Ghostty powers icons in yazi, the prompt, and
  statuslines.
- **Mouse optional** — everything is reachable from the keyboard; the mouse is a convenience,
  never a requirement.

## Portability

The whole environment is this repo:

1. `git clone` it anywhere,
2. `scripts/bootstrap.sh` installs the tools,
3. `scripts/install.sh` symlinks the configs,
4. pick up exactly where you left off.

## Pending decisions

Filled in tool-by-tool during setup; each gets resolved in its own step.

- [ ] Shared theme family across all tools (decide in the Ghostty step)
- [ ] Shell prompt: Powerlevel10k vs Starship (decide in the shell step)
- [ ] tmux prefix key and pane-navigation style (decide in the tmux step)
- [ ] Neovim distribution: hand-rolled lazy.nvim vs distro (decide in the Neovim step)
