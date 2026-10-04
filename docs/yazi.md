# yazi

> **Status:** pending — configured and documented in the yazi setup step.

## Role

File manager TUI. Fast directory navigation with previews (images, video, archives, PDFs),
bulk operations, and a smooth hand-off into the shell, Neovim, or lazygit.

## Why yazi

- Asynchronous and very fast, even over ssh.
- Rich previews via optional external tools (ffmpeg, sevenzip, poppler — see Brewfile).
- Plugin/theme ecosystem in Lua; `y`/`cd`-on-quit shell wrapper turns it into a directory
  teleporter.

## Installation

`scripts/tools.sh --auto yazi` (`--manual` prints the commands; on Linux that
is the official release zip providing both `yazi` and `ya`). Also `yazi` in
the [`Brewfile`](../Brewfile) (optional preview renderers listed there too).

## Configuration

Source of truth: [`config/yazi/`](../config/yazi/) → deployed to `~/.config/yazi/`
(`yazi.toml`, `keymap.toml`, `theme.toml` — created during setup).

_To be filled during the setup step: opener rules, preview setup, keymap tweaks, the shell
wrapper function for cd-on-quit._

## Key bindings

_To be documented once configured._
