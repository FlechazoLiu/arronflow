# Ghostty

> **Status:** pending — configured and documented in the Ghostty setup step.

## Role

Terminal emulator. The bottom layer of the stack: tmux, the shell, Neovim, lazygit, and yazi
all render inside a Ghostty window.

## Why Ghostty

- Native macOS app with GPU-rendered output.
- Batteries-included defaults; configuration is a single plain-text file.
- Native tabs, splits, and a Quake-style quick terminal with a global hotkey.

## Installation

`brew bundle install` — cask `ghostty` in the [`Brewfile`](../Brewfile), plus the
`font-maple-mono-nf-cn` cask for the Nerd Font.

## Configuration

Source of truth: [`config/ghostty/`](../config/ghostty/) → deployed to `~/.config/ghostty/`.
Reload at runtime: `Cmd+Shift+,`. Full option reference:
`ghostty +show-config --default --docs`.

_To be filled during the setup step: typography, theme, window appearance, quick terminal,
keybindings, security._

## Key bindings

_To be documented once configured._
