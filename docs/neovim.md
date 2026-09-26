# Neovim

> **Status:** pending — configured and documented in the Neovim setup step.

## Role

The editor. Editing, LSP-powered code intelligence, fuzzy finding, git signs — all inside a
tmux pane, all on the keyboard.

## Why Neovim

- Modal editing keeps hands on the home row; the same `hjkl` grammar as tmux and yazi.
- Lua configuration is real code: composable, versioned, testable.
- LSP + Treesitter give IDE features without an IDE.

## Installation

`brew bundle install` — `neovim` in the [`Brewfile`](../Brewfile). Plugins bootstrap
themselves via lazy.nvim on first launch; `config/nvim/lazy-lock.json` pins exact versions.

## Configuration

Source of truth: [`config/nvim/`](../config/nvim/) → deployed to `~/.config/nvim/`.

_To be filled during the setup step: plugin manager and plugin set, LSP servers, keymap
conventions (leader key), completion, formatting/linting._

## Key bindings

_To be documented once configured._
