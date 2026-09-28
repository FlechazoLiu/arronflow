# Neovim

## Status

**Stage 2 of 3 — documented, configuration deferred to the LazyVim step.**
This page explains Neovim as a concept: what it inherits from Vim, what its
core adds, and where external tools and distributions begin. It is the
companion to the Stage 1 prerequisite [vim.md](vim.md). The repository
manages no Neovim configuration yet; when the editor is actually configured,
it will be configured as LazyVim, in the final stage.

The curriculum so far:

1. **Vim** — the editing language: modes, operators, motions, text objects.
2. **Neovim** — this page: the modern core that language runs on.
3. **LazyVim** — the daily editor: a full configuration assembled on top.

## Role

Neovim is the editor binary this stack standardizes on. It is not a
different editing language from Vim — everything learned in
[vim.md](vim.md) works unchanged — and it is not the finished editing
environment either. It is the **core and runtime**: the engine that provides
the editing language, plus modern infrastructure (Lua, a built-in terminal,
an LSP client, Tree-sitter integration) that plugins and the future LazyVim
setup build upon.

## Background

### A Vim descendant, not a rival

Neovim began as a Vim fork focused on extensibility and usability. Editing
behavior is deliberately compatible: modes, motions, operators, text
objects, registers, and the `:` command language all behave as taught in
Stage 1. Even the tutorial transfers — Neovim ships its own guided lesson,
launched with `:Tutor` inside Neovim.

The differences are underneath: a rewritten internal architecture, Lua as a
first-class configuration language, and a set of built-in capabilities
described below.

### The editor and its interface are separate

Neovim's core exposes its functionality through a documented RPC (remote
procedure call) API. The terminal interface you normally see is one client
of that API; a GUI is another. External programs can drive the same editing
session over the same channel, and the core communicates with clients and
events asynchronously — it can run jobs and never blocks the UI on a slow
process.

Two everyday consequences:

- the built-in terminal (below) is the same machinery turned inward — the
  editor can host a shell because the shell's UI discipline and the
  editor's are the same kind of plumbing;
- headless operation (`nvim --headless`) drives Neovim from scripts —
  how tooling runs it without any UI at all.

### What the core adds over classic Vim

- **Lua as the configuration language.** Instead of `~/.vimrc` in Vimscript,
  Neovim reads `init.lua` from its config directory (`~/.config/nvim/` on
  macOS, discovered via XDG conventions). Lua is a real programming
  language, and Neovim exposes its internals to it: `vim.opt` sets options,
  `vim.keymap.set` defines mappings, `vim.api` calls the editor's C-level
  API, and `vim.fn` calls classic Vimscript functions. Larger configs
  become Lua modules, loaded with `require` like any other code.
- **A built-in terminal emulator.** `:terminal` opens a real shell inside a
  Neovim buffer. The program inside runs as an asynchronous job; its output
  is buffer text you can scroll, search, and copy with normal Vim commands.
- **A built-in LSP client.** See the boundary section below.
- **Tree-sitter integration.** See the boundary section below.
- **Modern defaults.** Sensible settings — mouse support among them — are
  on without asking, where stock Vim leaves them off.

One recent addition deserves a version note: Neovim 0.12 introduced
`vim.pack`, an experimental built-in manager for installing plugins. This
repository targets Neovim >= 0.11, so whether the final setup uses
`vim.pack` or the third-party `lazy.nvim` is a decision for the actual
configuration stage — documented then, from the real setup.

### The four layers

Keeping these separate is the point of this stage:

| Layer | What it is | Examples | Stage |
| --- | --- | --- | --- |
| Editing language | modes, operators, motions, text objects | `ciw`, `d$`, `.` | 1 — Vim |
| Core / runtime | the editor binary and its built-ins | Lua config, terminal, LSP client, Tree-sitter integration | 2 — this page |
| Plugins & external tools | code and programs outside the binary | plugin managers, language servers, parsers, formatters, fuzzy finders | used in 3 |
| Distribution | a curated configuration assembled from the layers above | LazyVim | 3 |

### The most important boundary: client vs. component

Several advertised "Neovim features" are really **integrations in the core
plus external components**. The core provides the client side; the
capability itself comes from outside:

- **LSP.** Neovim has a built-in client for the Language Server Protocol.
  The **servers** — the programs that actually analyze code and produce
  completions, definitions, diagnostics — are third-party executables,
  installed separately per language. Without a server attached, the client
  has nothing to talk to.
- **Tree-sitter.** Neovim integrates the Tree-sitter parsing library for
  syntax-aware features. The **parsers** — compiled grammar files per
  language — are separate artifacts it loads; some ship alongside, most are
  installed deliberately.
- **Plugin managers** (including `vim.pack`) install and update plugins.
  They provide **no features themselves** — the plugins do.

The same discipline explains what a distribution is. **LazyVim is not
another editor and not a binary** — there is no `brew install lazyvim`. It
is a well-regarded Neovim configuration: a chosen plugin manager, a curated
plugin set, and conventions, maintained as a starting point. Installing
Neovim does not give you LazyVim's interface; conversely, LazyVim is
powerless without the Neovim core.

A clean `nvim --clean` session therefore looks plain: no completion pop-ups,
no file tree, no fuzzy finder, no statusline theme. Those are plugin-layer
features, assembled in the final stage. What the clean session still has:
the entire editing language, the terminal, Lua, and the client frameworks.

## Why Neovim

- **vs classic Vim** — the editing language is the same; Neovim adds the
  Lua configuration model, the built-in terminal, LSP, and Tree-sitter as
  core infrastructure, with an active modern ecosystem on top.
- **vs a GUI IDE** — an IDE hands you a finished product; this stack keeps
  the keyboard-first modal grammar and composes IDE features from layers
  you understand and control.
- **vs hand-rolling a config** — assembling plugins yourself teaches the
  most but costs the most; it also front-loads decisions a beginner cannot
  yet make.
- **vs starting at LazyVim** — skipping straight to the distribution works,
  but you could not say which behavior is Vim, which is core, and which is
  a plugin choice. This stage exists so that you can.

Honest limitation: a bare Neovim is deliberately austere. Judging it as a
product in a clean session would undersell it — the ecosystem is the point,
and the ecosystem arrives with configuration.

## Installation

Neovim is already in the [`Brewfile`](../Brewfile):

```sh
brew bundle install   # brew "neovim"
nvim --version        # repository targets Neovim >= 0.11
```

There is nothing to install beyond the binary at this stage. LazyVim, being
a configuration rather than a program, has no Homebrew formula; it arrives
with the final stage's files, not with `brew`.

Inspect a pristine session (ignores all configuration, like Vim's
`--clean`):

```sh
nvim --clean /tmp/arronflow-nvim-practice.txt
```

## Our configuration

There is **no Neovim configuration in this repository yet**, by design:

- `config/nvim/` contains only its `README.md` placeholder;
- `scripts/install.sh` skips placeholder-only directories, so nothing is
  deployed to `~/.config/nvim/`;
- no `init.lua`, no plugin manager or lockfile, no mappings, no LSP
  servers, no Tree-sitter parsers.

When configuration begins, it begins once, as the LazyVim setup, under
`config/nvim/` — deployed by the same symlink mechanism as every other
tool in this repo. This page changes then.

## Key bindings

The editing keys are exactly the Stage 1 set — modes, motions, operators,
text objects, search, `.`. See [vim.md](vim.md) rather than this page.
Leader-key mappings and plugin bindings (find files, buffers, diagnostics,
code actions) belong to the LazyVim layer and are documented there.

What this page adds is the small set of Neovim-native commands worth
knowing in a clean session:

| Intent | Keys / command |
| --- | --- |
| guided tutorial (Neovim's vimtutor) | `:Tutor` |
| version and build info | `:version` (or `nvim --version` in the shell) |
| health check of the installation | `:checkhealth` |
| show a config/data directory | `:echo stdpath('config')` — also `'data'`, `'state'` |
| run a Lua expression | `:lua print(vim.version().major)` |
| inspect node under cursor (Treesitter) | `:Inspect` |
| show the syntax tree of the buffer | `:InspectTree` |
| open a shell inside Neovim | `:terminal` |
| leave terminal mode back to Normal | `C-\` then `C-n` |
| built-in help | `:help lua-guide`, `:help lsp`, `:help treesitter` |

Inside a `:terminal` buffer, the shell owns the keyboard (insert-style);
`C-\ C-n` returns control to Normal mode, after which Vim motions, search,
and yank work on the terminal output like any buffer.

## Tuning & exploring

Nothing is configured, so there is nothing to tune. The exploration loop
runs entirely in a clean session and creates no state:

```sh
nvim --clean /tmp/arronflow-nvim-practice.txt
```

Inside it:

1. confirm the layer separation — try any Stage 1 command (`ciw`, `d$`,
   `/search`, `.`) and note that nothing needs configuring;
2. run `:version`, then `:checkhealth` — read what the health report
   checks (providers, runtime, external tools) and note which warnings are
   about **external** components rather than the core;
3. `:echo stdpath('config')` and `:echo stdpath('data')` — see where a
   future configuration and its data would live, without creating them;
4. `:lua print(vim.version())` — Lua is reachable even with no config;
5. `:terminal`, run a command, then `C-\ C-n` and scroll/search the output
   with Vim keys;
6. `:InspectTree` on any file — the Tree-sitter integration is present in
   the core even though no extra parsers are installed;
7. quit with `:q!` — the scratch file in `/tmp` was never worth saving.

### Readiness for the final stage

Move on to the LazyVim setup when these feel true:

- you can name the four layers and place a feature in the right one
  (e.g. "completion pop-ups: plugin layer; the terminal: core");
- you can say what an LSP **server** is and why Neovim alone provides no
  completions without one;
- you know LazyVim is a configuration, not an editor;
- `nvim --clean` holds no surprises: same editing language, plain
  interface.

### FAQ

**I opened `nvim` and it looks bare — isn't it supposed to be an IDE?**
Not by itself. Everything beyond the editing language and the core
integrations comes from plugins, which come with configuration. That is the
next stage.

**Does Neovim replace everything in vim.md?**
No. It runs the same editing language. Stage 1 carries over wholesale;
`:Tutor` is even Neovim's own copy of the lesson.

**Is my Vim muscle memory safe inside LazyVim later?**
Yes — distributions keep the core grammar and add mappings around it.

**Why `--clean` instead of just running `nvim`?**
Today there is no config, so they are identical. `--clean` keeps it that
way even after the LazyVim configuration exists — a way to see the core
without the layers.

**What is the difference between `vim.pack` and `lazy.nvim`?**
Both manage plugins (install, update, lock versions). `vim.pack` ships with
Neovim 0.12 and is still experimental; `lazy.nvim` is a third-party manager
and the one LazyVim is built around. The choice only becomes real with the
actual configuration.

## References

- Run `:help` inside Neovim — the complete, version-matched manual; prefer
  it over web copies whenever the local version could differ.
- [Neovim user documentation](https://neovim.io/doc/user/) — the official
  rendered `:help`; the hub for every topic below.
- [Lua guide](https://neovim.io/doc/user/lua-guide/) — the official
  introduction to configuring Neovim in Lua (`vim.opt`, `vim.keymap.set`,
  `vim.api`, `vim.fn`, modules).
- [LSP](https://neovim.io/doc/user/lsp/) — the built-in client framework;
  states plainly that servers are third-party programs.
- [Tree-sitter](https://neovim.io/doc/user/treesitter/) — the parsing
  integration and where parser files come from.
- [Terminal](https://neovim.io/doc/user/terminal/) — the embedded terminal
  and `C-\ C-n`.
- [API](https://neovim.io/doc/user/api/) — the RPC contract that separates
  core from interface; background for why GUIs and headless mode exist.
- [Differences from Vim](https://neovim.io/doc/user/vim_diff/) — the
  official, exhaustive list; read after this page, not instead of it.
- [neovim/neovim](https://github.com/neovim/neovim) — the source
  repository: releases, changelogs, and roadmap.
