# arronflow

My macOS terminal workflow: **Ghostty + tmux + Neovim + lazygit + yazi + zsh (Oh My Zsh)** —
documented, versioned, and scripted, so the whole environment can be rebuilt on a fresh Mac
in minutes.

The name: **Arron** + **workflow** = `arronflow`.

## The stack

| Tool                                                        | Role                | Config in this repo                                   | Docs                                           |
| ----------------------------------------------------------- | ------------------- | ----------------------------------------------------- | ---------------------------------------------- |
| [Ghostty](https://ghostty.org)                              | Terminal emulator   | `config/ghostty/` → `~/.config/ghostty/`              | [docs/ghostty.md](docs/ghostty.md)             |
| [tmux](https://github.com/tmux/tmux)                        | Terminal multiplexer | `config/tmux/` → `~/.config/tmux/`                   | [docs/tmux.md](docs/tmux.md)                   |
| [Neovim](https://neovim.io)                                 | Editor              | `config/nvim/` → `~/.config/nvim/`                    | [docs/neovim.md](docs/neovim.md)               |
| [lazygit](https://github.com/jesseduffield/lazygit)         | Git TUI             | `config/lazygit/` → `~/Library/Application Support/lazygit/` | [docs/lazygit.md](docs/lazygit.md)       |
| [yazi](https://github.com/sxyazi/yazi)                      | File manager TUI    | `config/yazi/` → `~/.config/yazi/`                    | [docs/yazi.md](docs/yazi.md)                   |
| [zsh](https://www.zsh.org) + [Oh My Zsh](https://ohmyz.sh)  | Shell               | `config/zsh/zshrc` → `~/.zshrc`                       | [docs/shell.md](docs/shell.md)                 |

How the tools compose: [docs/workflow.md](docs/workflow.md).

## Setup on a new Mac

```sh
git clone <this-repo> ~/arronflow && cd ~/arronflow
scripts/bootstrap.sh   # Homebrew + Brewfile, Oh My Zsh & plugins, then deploys configs
```

Or manually, in two steps:

```sh
brew bundle install    # install every tool from the Brewfile
scripts/install.sh     # symlink configs into place (idempotent, backs up existing files)
```

## Design decisions

- **Symlinks, not copies.** `scripts/install.sh` links each tool's config from this repo into
  its canonical location. Editing a config here and editing it in `~/.config/...` is the same
  act — there is exactly one source of truth, and `git diff` always tells the truth.
- **Docs live with configs.** Every tool has a page in `docs/` explaining what it does, why it
  is configured the way it is, and the key bindings worth memorizing. Config without
  explanation rots.
- **Idempotent scripts.** Re-running setup is always safe; existing files at a target location
  are moved aside as `*.bak.<timestamp>`, never silently overwritten.
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
| Neovim              | ⬜         | ⬜         |
| lazygit             | ⬜         | ⬜         |
| yazi                | ⬜         | ⬜         |
| zsh + Oh My Zsh     | ✅         | ✅         |

## License

TBD — a personal workflow repo; an OSS license will be added if it ever gets shared publicly.
