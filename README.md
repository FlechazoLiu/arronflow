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

Two independent phases behind one command ([scripts.md](docs/scripts.md)):

1. **Tools** — `arron tools --auto` installs binaries; `--manual` prints the exact commands
   for brew / pacman / apt / dnf / GitHub releases and installs nothing.
2. **Configs** — `arron config` symlinks configs, **gated** on each binary being present.

The first `./scripts/arron` run bootstraps the lightweight gum UI, then opens one menu for
setup, health checks, and tmux sessions. The config phase links the command into
`~/.local/bin`, so future shells can call `arron` from anywhere.

```sh
git clone https://github.com/FlechazoLiu/arronflow.git ~/arronflow
cd ~/arronflow
./scripts/arron                         # interactive menu
./scripts/arron up --auto --all --dry-run   # or preview the full setup
./scripts/arron up --auto --all             # then execute it
arron doctor                            # verify (after opening a new shell)
```

Platform notes — macOS: Homebrew; `--all` is one Brewfile transaction. Linux (Arch /
Debian-Ubuntu / Fedora, x86_64 & aarch64): distro packages where current, official GitHub
release binaries into `~/.local/bin` where not (Ubuntu's repos lack lazygit/yazi/eza and
ship a Neovim older than LazyVim's ≥ 0.11). The Maple Mono NF CN font installs from its
release; Ghostty is native on Arch and Ubuntu ≥ 26.04, community-built elsewhere —
optional, the rest of the stack runs in any terminal.

## Design decisions

- **Symlinks, not copies.** `scripts/install.sh` links each tool's config from this repo into
  its canonical location. Editing a config here and editing it in `~/.config/...` is the same
  act — there is exactly one source of truth, and `git diff` always tells the truth.
- **Docs live with configs.** Every tool has a page in `docs/` explaining what it does, why it
  is configured the way it is, and the key bindings worth memorizing. Config without
  explanation rots.
- **Idempotent scripts.** Re-running setup is always safe; existing files at a target location
  are moved aside as `*.bak.<timestamp>`, never silently overwritten.
- **One entrance, separate phases.** `arron` is the only command to remember; behind it,
  tools and configs remain independent. A declarative registry (`scripts/lib/registry.sh`)
  drives both, plus doctor. Gum gives the interactive UI; pure bash remains the first-run,
  offline, and CI fallback.
- **Native first on Linux.** `arron tools` prefers the distro's own packages
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
| [Script framework](docs/scripts.md) (`arron`, gum UI, registry, two phases, doctor) | ✅ | ✅ |
| Linux support (Arch/Debian/Fedora) | 🔄 | ✅ |

## License

TBD — a personal workflow repo; an OSS license will be added if it ever gets shared publicly.
