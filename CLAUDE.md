# arronflow

Personal macOS terminal-workflow repository: **Ghostty + tmux + Neovim + lazygit + yazi +
zsh (Oh My Zsh)**. It exists so the whole environment can be tuned here, then rebuilt on a
fresh machine or shared via `scripts/bootstrap.sh` + `scripts/install.sh`.

## Language rules

- All repo content — docs, config comments, commit messages — is written in **English**.
- Conversation with the user happens in **Chinese**.

## Documentation style

The user is learning these tools as we configure them. Every tool page in `docs/` is a
tutorial, not a reference sheet, and follows this order:

1. **Status** — configured or pending.
2. **Role** — one short paragraph: what the tool does in this stack.
3. **Background** — the concepts a newcomer needs *before* any settings (e.g. terminal
   vs. shell vs. multiplexer). Teach first, configure second.
4. **Why this tool** — honest one-line comparisons with alternatives.
5. **Installation** — exact runnable commands.
6. **Our configuration** — walk through every setting, grouped in the same sections as the
   config file; every value carries its *why*, including taste decisions.
7. **Key bindings** — cheat-sheet table.
8. **Tuning & exploring** — the 30-second adjust loop, preview/reference commands, and a
   short FAQ.
9. **References** — verified links to official documentation (docs hub, full configuration
   reference, keybind/action reference, feature deep-dives, source repo), each with a
   one-line "when to reach for it". The page is the tutorial; official docs are the depth.
   Only link canonical URLs that have been verified (fetch them, or know them cold) —
   never guessed paths.

Tone: formal but easy to read — plain English, short sentences, runnable commands. In chat,
teach the same content narratively in Chinese; the English doc is the durable version.

## Layout

- `config/<tool>/` — canonical config files. Deployed as symlinks; the link manifest lives in
  `scripts/lib/registry.sh` (one line per tool: binaries, packages, configs, docs).
- `docs/<tool>.md` — per-tool documentation (role, rationale, config walkthrough, key
  bindings). `docs/workflow.md` explains how the tools compose.
- `Brewfile` — tool dependencies (`brew bundle install`).
- `scripts/bootstrap.sh` — front door: numbered menu on a terminal, flags when piped; hands
  off to the phase scripts below.
- `scripts/tools.sh` — phase 1: tool installation, `--auto` or `--manual` (commands only).
- `scripts/install.sh` — phase 2: idempotent symlink deployment, gated on the tool's binary
  being installed; backs up existing files as `*.bak.<timestamp>`.
- `scripts/doctor.sh` — read-only health report (binary, version, config link) + manual
  install commands for the gaps.
- `scripts/session.sh` — create-or-attach helper for named tmux sessions (the daily
  "one session per project" workflow).
- `scripts/lib/` — `registry.sh` (the per-tool data every script reads) and `common.sh`
  (shared checks/prompts).

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
