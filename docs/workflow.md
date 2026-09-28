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

## Decisions

Resolved tool-by-tool; each decision is made in its own setup step.

- [x] **Theme family: Atom One Dark** (Ghostty step, 2026-09-26) — dark background, gentle
      contrast, easy on the eyes for long sessions. tmux, Neovim, yazi, and lazygit all
      follow this palette.
- [x] **Transparency: subtle** (Ghostty step) — `background-opacity = 0.9` +
      `background-blur-radius = 30`: see the desktop without hurting readability.
- [x] **Prompt: Powerlevel10k, everywhere** (shell step, finalized 2026-09-27) — the
      user's own wizard config (2026-05-20: classic, two lines, right frame, 24 h time,
      transient + instant prompt), restored verbatim and versioned at
      `config/zsh/p10k.zsh`. The pre-arronflow zshrc only loaded Starship outside tmux —
      and its `TERM_PROGRAM == ghostty` test never matches inside tmux (tmux ≥ 3.4 sets
      `TERM_PROGRAM=tmux` there), so p10k was the de-facto prompt all along. Starship's
      stock default and a custom Tokyo-Night-style design were both tried and rolled
      back the same day.
- [x] **Plugin lineup** (shell step) — OMz: `git`, `aliases`, `extract`, plus external
      `zsh-autosuggestions` and `zsh-syntax-highlighting`. Dropped: `z` (replaced by
      zoxide), `web-search` (Raycast covers it), Powerlevel10k theme. `neofetch` greeting
      replaced by `fastfetch`.
- [x] **Dev environments stay out of the repo** (shell step) — migrated to
      `~/.zshrc.local` on 2026-09-27, losslessly from the pre-arronflow setup (nvm,
      npm-global, conda, JDK/sdkman, Qt prefix, `top`/`fd` aliases). The repo zshrc loads
      that file when present; nothing machine-specific is versioned.
- [x] **tmux prefix and navigation** (tmux step, 2026-09-27) — the user's pre-repo habits
      became canonical: prefix `C-a`; `\` / `-` splits that inherit the pane's directory;
      `h j k l` pane traversal with repeatable `H J K L` resize; vi copy mode with
      `v` / `C-v` / `y`. A final keybinding-optimization pass is deferred (see Pending).

## Pending decisions

- [ ] tmux keybinding-optimization pass — deferred 2026-09-28, after the core
      setup settled; resume against the audit base in
      [tmux-keys-ours.md](tmux-keys-ours.md).
- [ ] Neovim distribution: hand-rolled lazy.nvim vs distro (decide in the Neovim step)
- [ ] `macos-option-as-alt` in Ghostty — decides together with the deferred tmux
      keybinding pass
