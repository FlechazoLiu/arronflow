# tmux

> **Status:** pending — configured and documented in the tmux setup step.

## Role

Terminal multiplexer. Sessions outlive the terminal window (and ssh connections), windows and
panes tile the workspace, and long-running jobs keep running while you are away.

## Why tmux

- Persistent per-project sessions — close the laptop, reopen, reattach, nothing lost.
- Panes pair naturally with terminal editors: code in one pane, runner/watcher in another.
- Runs anywhere ssh does; the same muscle memory on every machine.

## Installation

`brew bundle install` — `tmux` in the [`Brewfile`](../Brewfile).

## Configuration

Source of truth: [`config/tmux/`](../config/tmux/) → deployed to `~/.config/tmux/`
(`tmux.conf`, read by tmux ≥ 3.1). Reload inside tmux after editing: `prefix + r`
(binding defined during setup).

_To be filled during the setup step: prefix key, base options, pane management, status bar,
clipboard behavior on macOS._

## Key bindings

_To be documented once configured._
