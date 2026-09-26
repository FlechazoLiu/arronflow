# Shell — zsh + Oh My Zsh

> **Status:** pending — configured and documented in the shell setup step.

## Role

The shell is the glue: prompt, completion, history, aliases, and the modern CLI replacements
that every other tool leans on.

## Why zsh + Oh My Zsh

- zsh is the macOS default shell; OMz adds sane defaults, completions, and plugin loading
  without a from-scratch framework.
- The ecosystem around it (autosuggestions, syntax highlighting, zoxide, fzf) compounds into
  the fastest possible command line.

## Installation

- zsh ships with macOS.
- Oh My Zsh and its custom plugins/themes are git-cloned by `scripts/bootstrap.sh`.
- Companion CLI tools live in the [`Brewfile`](../Brewfile) (starship/zoxide/fzf/eza/bat/
  ripgrep/fd — finalized in this step).

## Configuration

Source of truth: [`config/zsh/`](../config/zsh/) — `zshrc` deploys to `~/.zshrc`.

_To be filled during the setup step: prompt choice (Powerlevel10k vs Starship), plugin list,
modern CLI replacements and aliases, PATH setup, history tuning, machine-specific overrides
kept out of the repo._

## Key bindings & aliases

_To be documented once configured._
