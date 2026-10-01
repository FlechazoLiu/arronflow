# LazyVim

## Status

**Configured and documented** — the editor curriculum's final stage. The
daily editor is LazyVim (v16-era starter) on Neovim, deployed from
`config/nvim/` → `~/.config/nvim/` by `scripts/install.sh`. Prerequisites:
[vim.md](vim.md) (the editing language) and [neovim.md](neovim.md) (the
core and its boundaries). Deliberately lean: stock starter, **zero extras,
zero added plugins**; the theme decision (default tokyonight vs the repo's
Atom One Dark convention) is pending a dedicated pass.

## Role

The daily editor. LazyVim is a *distribution* — a curated Neovim
configuration, not a program: there is no `brew install lazyvim`. It
assembles the plugin layer on top of the core: fuzzy picking, file
explorer, completion, LSP wiring, git signs, statusline, dashboard. The
editing language underneath is unchanged — everything from
[vim.md](vim.md) still works.

## Background

### What the starter is

We started from the official [LazyVim
starter](https://github.com/LazyVim/starter) — a minimal scaffold whose
whole job is to bootstrap the rest. The chain, file by file:

- `init.lua` — two lines: `require("config.lazy")`. Nothing else.
- `lua/config/lazy.lua` — if the plugin manager `lazy.nvim` is missing,
  clone it; then call `lazy.setup` with the **spec**:
  `{ "LazyVim/LazyVim", import = "lazyvim.plugins" }` (the whole
  distribution) plus `{ import = "plugins" }` (our `lua/plugins/` dir).
- `lua/config/{options,keymaps,autocmds}.lua` — empty hooks that run at
  the right lifecycle moments; LazyVim's own defaults load first, these
  add on top.
- `lua/plugins/example.lua` — our teaching file (below).

Plugins themselves are **not stored in this repo**. They are cloned at
first launch into `~/.local/share/nvim/lazy/`; `lazy-lock.json` (in the
repo, committed) pins every plugin to an exact commit, so a fresh clone
reproduces this exact editor.

### The one mechanism worth mastering: the spec file

Every `*.lua` file under `lua/plugins/` returns a table of *specs*.
lazy.nvim deep-merges all specs by plugin name, so a small file can
adjust the distribution without forking it:

```lua
return {
  { "folke/noice.nvim", enabled = false },        -- disable a default
  { "LazyVim/LazyVim", opts = { colorscheme = "onedark" } }, -- distro opts
  { "neovim/nvim-lspconfig", opts = { servers = { pyright = {} } } }, -- +LSP
}
```

`lua/plugins/example.lua` in this repo is exactly this recipe card,
fully commented out — our current policy is "no changes to the
distribution", so it `return {}`.

### Extras, Mason, and the two JSON files

- **Extras** are opt-in feature packs (`lang.python`, `editor.telescope`,
  …). `:LazyExtras` toggles them; the choice persists in `lazyvim.json`
  (repo dir, committed when it appears). We enable none.
- **Mason** installs the *external* binaries from
  [neovim.md](neovim.md)'s boundary: LSP servers, formatters, linters.
  `:Mason` browses them. On first `.lua` file, LazyVim auto-installs
  `lua_ls` — watch it happen, then confirm with `:LspInfo`.
- `lazy-lock.json` — the pin file; the upgrade loop below.

### Why "stock and lean"

Every default here earns its place (picking, completion, LSP wiring, git
signs, which-key discovery). Bloat risk in LazyVim comes from stacking
extras and plugins speculatively. Our discipline: add things **when a
real need appears**, as a one-spec-file change, and know how to remove
them the same way.

## Why LazyVim

- **vs bare Neovim** — the core provides clients and integrations;
  LazyVim provides the assembled experience. We wanted the experience
  without hand-assembling it.
- **vs hand-rolled lazy.nvim** — maximally instructive, but front-loads
  dozens of decisions (picker, completion, statusline, LSP UI…) a
  beginner cannot yet make. The starter keeps those decisions *reversible
  overrides* instead of from-scratch choices.
- **vs other distros** (AstroNvim, kickstart.nvim, NvChad) — kickstart is
  a annotated config to read, not a base to ride; AstroNvim/NvChad are
  comparable but heavier-opinionated. LazyVim has the cleanest
  override model (spec merge) and the best docs.

## Installation

Already done — recorded here as the reproducible path:

```sh
brew bundle install   # neovim, ripgrep, fd, lazygit — nothing was added
scripts/install.sh    # backs up ~/.config/nvim, symlinks config/nvim
nvim                  # first launch: clones lazy.nvim + 32 plugins
```

First-launch expectations: the dashboard (snacks) on a bare `nvim`;
tokyonight-moon colors; a one-time pause while treesitter parsers
compile; on opening a `.lua` file, Mason installs `lua_ls` over the
network (about a minute, once). The June-2025 hand-rolled config and its
data live on as `~/.config/nvim.bak.20261001-181805` and
`~/.local/{share,state,cache}/nvim.bak.20261001-181805` — restore by
renaming back.

External requirements, all already satisfied by this repo's Brewfile or
macOS: Neovim ≥ 0.11.2, Git, a C compiler (Xcode CLT's clang, for
treesitter parsers), `rg` + `fd` (pickers), the Maple Mono NF Nerd Font.

## Our configuration

Source of truth: [`config/nvim/`](../config/nvim/) → `~/.config/nvim/`
(symlink — editing either path edits the same file).

- `init.lua`, `lua/config/*.lua`, `.gitignore`, `.neoconf.json`,
  `stylua.toml` — **stock starter**, unchanged, so diffing against
  upstream stays trivial.
- `lua/plugins/example.lua` — the one deliberate authoring: a commented
  recipe card (add / disable / restyle / add-LSP) that currently returns
  `{}`.
- `lazy-lock.json` — generated, committed: the exact 32-plugin set.
- **What we did not add (yet)**: no extras, no plugins beyond the
  distribution, no custom options/keymaps/autocmds, no theme change.
  Deferred candidates, each a one-file change when needed: Atom One Dark
  colorscheme pass, language packs via `:LazyExtras`, more LSP servers.

## Key bindings

Verified against the installed LazyVim source. The leader is **Space**;
press and release it, then pause — the which-key popup lists every
binding from there. That popup, not this table, is the authoritative
reference.

| Intent | Keys |
| --- | --- |
| Leader | `Space` (then pause for which-key) |
| Find files (root dir) | `<leader><Space>` |
| Switch buffers | `<leader>,` |
| Grep (root dir) | `<leader>/` |
| File explorer toggle | `<leader>e` |
| Lazygit (root dir) | `<leader>gg` |
| Plugin manager UI | `<leader>l` |
| Flash-jump anywhere on screen | `s` then a label |
| Flash Treesitter select | `S` |
| Diagnostics list | `<leader>xx` (Trouble) |
| Code action | `<leader>ca` |
| Rename symbol | `<leader>cr` |
| Next/previous diagnostic | `]d` / `[d` |
| Hover docs | `K` |
| Buffer next/prev/close | `<leader>bb` (`` `<leader>` ``… see which-key) |
| Quit all | `<leader>qq` |

Motions, operators, text objects, `/`, `.` — unchanged from
[vim.md](vim.md).

## Tuning & exploring

The 30-second loop: edit any spec in `lua/plugins/` → restart `nvim` (or
`:Lazy` → reload). The repo symlink means the change is already in git's
view; commit when it sticks.

Four exercises, in order (each reversible by deleting what you added):

1. **Add a plugin**: uncomment recipe #1 in `example.lua` with any
   plugin, restart, `:Lazy` → see it installed. Revert.
2. **Disable a default**: recipe #2 with `folke/noice.nvim`, restart —
   the message UI falls back to plain. Revert.
3. **Enable an extra**: `:LazyExtras`, toggle `lang.json` (or one you
   need), restart, `git status` — `lazyvim.json` changed in the repo.
   Revert by toggling off.
4. **Add an LSP**: `:Mason` → install `pyright`; or recipe #4 in
   `example.lua` (mason-lspconfig then auto-installs it on first Python
   file). Confirm with `:LspInfo` in a buffer of that filetype.

Upgrade discipline: `:Lazy update` → skim the changelog it offers →
smoke-test the editor → `git diff config/nvim/lazy-lock.json` → commit
("nvim: update plugin lockfile"). Health: `:checkhealth lazy`.

### FAQ

**First launch looks frozen.** Parser compilation is one-time and
silent-ish; wait, or check `:checkhealth` after.
**Where did my old config go?** It was moved, not deleted — see the
`.bak.20261001-181805` names in Installation.
**A plugin misbehaves after update.** `:Lazy restore` rolls back to the
committed lockfile.
**Want the distribution gone?** `config/nvim` is self-contained; remove
the directory (and its symlink) and Neovim is bare again — the stages of
this curriculum were chosen so that would never be disorienting.
**Why tokyonight and not Atom One Dark like tmux?** Decision deferred
until the editor is in daily use; one spec-file change (recipe #3) when
we make it.

## References

- [LazyVim documentation](https://lazyvim.github.io/) — the official
  hub; start at Installation, then Configuration.
- [LazyVim extras](https://lazyvim.github.io/extras) — browsable feature
  packs; what `:LazyExtras` toggles.
- [LazyVim repo](https://github.com/LazyVim/LazyVim) — source of the
  distribution; the installed copy under
  `~/.local/share/nvim/lazy/LazyVim` is grep-able truth.
- [Starter template](https://github.com/LazyVim/starter) — what
  `config/nvim/` began as; diff against it to see our deltas.
- [lazy.nvim](https://lazy.folke.io) — the plugin manager's own docs;
  spec syntax depth and `:Lazy` commands. Local: `:help lazy.nvim`.
