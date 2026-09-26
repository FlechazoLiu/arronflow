# arronflow

Personal macOS terminal-workflow repository: **Ghostty + tmux + Neovim + lazygit + yazi +
zsh (Oh My Zsh)**. It exists so the whole environment can be tuned here, then rebuilt on a
fresh machine or shared via `scripts/bootstrap.sh` + `scripts/install.sh`.

## Language rules

- All repo content — docs, config comments, commit messages — is written in **English**.
- Conversation with the user happens in **Chinese**.

## Layout

- `config/<tool>/` — canonical config files. Deployed as symlinks; the link manifest lives in
  `scripts/install.sh`.
- `docs/<tool>.md` — per-tool documentation (role, rationale, config walkthrough, key
  bindings). `docs/workflow.md` explains how the tools compose.
- `Brewfile` — tool dependencies (`brew bundle install`).
- `scripts/bootstrap.sh` — full setup on a new Mac (Homebrew + Brewfile, Oh My Zsh & plugins,
  then `install.sh`).
- `scripts/install.sh` — idempotent symlink deployment; backs up existing files as
  `*.bak.<timestamp>`.

## Working rules

- The user configures tools **one at a time**. For each tool:
  1. Write the config under `config/<tool>/`.
  2. Deploy/refresh it with `scripts/install.sh`.
  3. Update `docs/<tool>.md` **and** the Status table in `README.md` in the same change —
     docs and config must never drift apart.
  4. Add new dependencies to `Brewfile` (and to `bootstrap.sh` if they need a git clone).
- Configs are **symlinked**: an edit in `~/.config/...` is an edit in this repo. Check
  `git status` before assuming the working tree is clean.
- Never commit secrets, machine-specific absolute paths, or runtime state (see `.gitignore`).
- Target platform: macOS (arm64), Homebrew, tmux ≥ 3.4, Neovim ≥ 0.11.
- Keep conventions consistent across tools: vi-style `hjkl` navigation, true color end to
  end, Nerd Font icons.
