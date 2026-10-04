# lazygit

> **Status:** pending — configured and documented in the lazygit setup step.

## Role

Git TUI. Staging hunks and lines, committing, branching, interactive rebasing, cherry-picking
— the entire daily git loop without leaving the terminal or the keyboard.

## Why lazygit

- Hunk/line-level staging beats any CLI workflow for surgical commits.
- Visual interactive rebase makes history rewriting routine instead of terrifying.
- Zero setup cost: sensible defaults, instant startup, runs in a tmux pane.

## Installation

`brew bundle install` — `lazygit` in the [`Brewfile`](../Brewfile).
On Linux, `scripts/bootstrap.sh` installs it instead (distro package, or the
official release binary into `~/.local/bin` where the distro has none).

## Configuration

Source of truth: [`config/lazygit/`](../config/lazygit/) → deployed to
lazygit's platform config dir: `~/Library/Application Support/lazygit/` on
macOS, `~/.config/lazygit/` on Linux (see `scripts/install.sh`).

_To be filled during the setup step: theme matching, custom commands, confirmation
policies._

## Key bindings

_To be documented once configured._ Press `x` inside lazygit for the full keybindings menu.
