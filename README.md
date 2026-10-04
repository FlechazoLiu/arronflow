# arronflow

My terminal workflow: **Ghostty + tmux + LazyVim (Neovim) + lazygit + yazi + zsh (Oh My
Zsh)** — documented, versioned, and scripted, so the whole environment can be rebuilt on a
fresh Mac (Homebrew) or a fresh Linux box (Arch / Debian-Ubuntu / Fedora families) in minutes.

The name: **Arron** + **workflow** = `arronflow`.

## The stack

| Tool                                                        | Role                | Config in this repo                                   | Docs                                           |
| ----------------------------------------------------------- | ------------------- | ----------------------------------------------------- | ---------------------------------------------- |
| [Ghostty](https://ghostty.org)                              | Terminal emulator   | `config/ghostty/` → `~/.config/ghostty/`              | [docs/ghostty.md](docs/ghostty.md)             |
| [tmux](https://github.com/tmux/tmux)                        | Terminal multiplexer | `config/tmux/` → `~/.config/tmux/`                   | [docs/tmux.md](docs/tmux.md)                   |
| [Neovim](https://neovim.io) + [LazyVim](https://lazyvim.github.io) | Editor (LazyVim distro) | `config/nvim/` → `~/.config/nvim/` | [docs/lazyvim.md](docs/lazyvim.md) |
| [lazygit](https://github.com/jesseduffield/lazygit)         | Git TUI             | `config/lazygit/` → platform config dir | [docs/lazygit.md](docs/lazygit.md)       |
| [yazi](https://github.com/sxyazi/yazi)                      | File manager TUI    | `config/yazi/` → `~/.config/yazi/`                    | [docs/yazi.md](docs/yazi.md)                   |
| [zsh](https://www.zsh.org) + [Oh My Zsh](https://ohmyz.sh)  | Shell               | `config/zsh/zshrc` → `~/.zshrc`                       | [docs/shell.md](docs/shell.md)                 |

How the tools compose: [docs/workflow.md](docs/workflow.md).

## Setup on a new machine

macOS:

```sh
git clone <this-repo> ~/arronflow && cd ~/arronflow
scripts/bootstrap.sh   # Homebrew + Brewfile, Oh My Zsh & plugins, then deploys configs
```

Or manually, in two steps:

```sh
brew bundle install    # install every tool from the Brewfile
scripts/install.sh     # symlink configs into place (idempotent, backs up existing files)
```

Linux (Arch, Debian/Ubuntu, Fedora families — x86_64 and aarch64):

```sh
git clone <this-repo> ~/arronflow && cd ~/arronflow
scripts/bootstrap.sh   # distro packages + GitHub release binaries, OMz, configs
```

The same script dispatches on the OS. On Linux it uses the distro's package
manager for everything the distro ships (on Arch that is the whole stack), and
falls back to official GitHub release binaries in `~/.local/bin` for the rest
(Ubuntu's repos lack lazygit/yazi/eza and ship a Neovim older than LazyVim's
≥ 0.11 requirement — the release tarball covers it). The Maple Mono NF CN font
comes from its GitHub release into `~/.local/share/fonts`. Ghostty is packaged
on Arch and Ubuntu ≥ 26.04; elsewhere the script prints the community-repo
options (the rest of the stack runs in any terminal). The per-tool pages in
`docs/` show the macOS install commands; on Linux, `bootstrap.sh` is the path.
`scripts/session.sh` and all configs under `config/` are platform-independent.

## Design decisions

- **Symlinks, not copies.** `scripts/install.sh` links each tool's config from this repo into
  its canonical location. Editing a config here and editing it in `~/.config/...` is the same
  act — there is exactly one source of truth, and `git diff` always tells the truth.
- **Docs live with configs.** Every tool has a page in `docs/` explaining what it does, why it
  is configured the way it is, and the key bindings worth memorizing. Config without
  explanation rots.
- **Idempotent scripts.** Re-running setup is always safe; existing files at a target location
  are moved aside as `*.bak.<timestamp>`, never silently overwritten.
- **Native first on Linux.** `bootstrap.sh` prefers the distro's own packages
  (pacman/apt/dnf) and only falls back to official GitHub release binaries
  (`~/.local/bin`, which the zshrc puts first on PATH) where the distro has
  nothing current to offer. Homebrew stays macOS-only.
- **English only.** Docs, comments, and commit messages are English so the repo is shareable;
  nothing in here is private notes.
- **One tool per directory.** `config/<tool>/` mirrors the tool's real config directory, so the
  repo layout teaches you the layout of your machine.

## Status

Built tool-by-tool — each row lights up as the step-by-step setup progresses.

| Piece               | Configured | Documented |
| ------------------- | ---------- | ---------- |
| Repo skeleton, scripts, docs structure | ✅ | ✅ |
| Ghostty             | ✅         | ✅         |
| tmux                | 🔄         | 🔄         |
| [Vim foundations](docs/vim.md) (tutorial only) | — | ✅ |
| [Neovim concepts](docs/neovim.md) (tutorial only) | — | ✅ |
| [LazyVim](docs/lazyvim.md) (daily editor) | ✅ | ✅ |
| lazygit             | ⬜         | ⬜         |
| yazi                | ⬜         | ⬜         |
| zsh + Oh My Zsh     | ✅         | ✅         |
| Linux bootstrap (Arch/Debian/Fedora) | 🔄 | ✅ |

## License

TBD — a personal workflow repo; an OSS license will be added if it ever gets shared publicly.
