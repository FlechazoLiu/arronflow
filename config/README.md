# config/

Canonical config files, one directory per tool. `scripts/install.sh` symlinks each entry
into its real location on the machine — this directory is the single source of truth.

| Directory  | Deploys to                                  | Notes                                        |
| ---------- | ------------------------------------------- | -------------------------------------------- |
| `zsh/`     | `~/.zshrc` (`zshrc` file)                   | May later hold sourced files (aliases, env)  |
| `ghostty/` | `~/.config/ghostty/`                        |                                              |
| `tmux/`    | `~/.config/tmux/` (tmux ≥ 3.1)              |                                              |
| `nvim/`    | `~/.config/nvim/`                           | `lazy-lock.json` is tracked to pin plugins   |
| `yazi/`    | `~/.config/yazi/`                           |                                              |
| `lazygit/` | `~/Library/Application Support/lazygit/`    | `state.yml` (runtime) is gitignored          |

Each tool's config walkthrough lives in `docs/<tool>.md`.
