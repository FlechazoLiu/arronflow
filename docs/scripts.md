# Scripts — one command, two phases

> **Status:** configured — `arron` is the unified entry point; gum powers
> the interactive UI; bash 3.2 remains the portable engine underneath.

## Role

`arron` turns a fresh machine into the arronflow environment and keeps it
healthy afterward. It covers installation, config deployment, diagnosis,
and tmux sessions without making you remember individual script names.

## Background: one entrance, two separate jobs

"Set up my terminal" hides two decisions:

1. **Tools** — which binaries exist? This belongs to a package manager or
   an official GitHub release. `arron tools --auto` performs the install;
   `--manual` only prints the exact commands so downloads stay under your
   control.
2. **Configs** — which live settings come from this repo? `arron config`
   creates symlinks only after that tool's binary is present. No tmux
   means no tmux config; skipping Ghostty never blocks tmux.

`arron up` runs both phases in that order. `arron doctor` reads their
results without changing anything.

## Why gum over a larger application

A Go/TUI rewrite would give the highest visual ceiling, but it would add a
build matrix and hide the setup logic behind compiled binaries. Gum is one
small executable that gives shell scripts polished menus, confirmations,
and spinners while leaving every operation readable.

There is one bootstrap rule: **installing gum cannot require gum**. The
first interactive run therefore asks one plain-bash question, installs gum
from brew/pacman/dnf or its official release, then upgrades the UI for the
rest of the run. If the machine is offline or you decline, the same command
continues with the pure-bash fallback. Pipes and CI never need gum.

## Installation

From the repo on a fresh machine:

```sh
./scripts/arron                 # first run: bootstrap gum, then open the menu
```

During the config phase it links itself to `~/.local/bin/arron`. The repo
zshrc already puts that directory first on PATH, so after opening a new
shell the shorter command works everywhere:

```sh
arron
```

`scripts/bootstrap.sh` is a temporary compatibility shim; old commands
such as `bootstrap.sh --everything --auto --all` still dispatch to `arron`.

## Commands

| Command | Role |
| --- | --- |
| `arron` | Interactive gum menu |
| `arron up --auto --all` | Install every tool, then deploy every ready config |
| `arron up --manual --all` | Print install commands, then show config gates |
| `arron tools --auto tmux nvim` | Install selected binaries |
| `arron tools --manual lazygit` | Print native/release instructions only |
| `arron config tmux nvim` | Deploy selected configs (binary-gated) |
| `arron doctor` | Read-only binary/version/link report |
| `arron session work ~/Work/project` | Create or attach a tmux session |
| `arron list` | Compact view of every registry tool |
| `arron help` | Full usage |

Add `--dry-run` to `up`, `tools`, or `config` to print decisions without
changing the machine. No arguments on an interactive terminal open menus;
no arguments through a pipe produce a usage error rather than silently
running sudo.

## Our configuration: the registry

Every operation reads one data source: `scripts/lib/registry.sh`. One
record declares a tool's binaries, minimum version, packages on four
platform families, release fallback, config paths, and docs page:

```text
"tmux|tmux|tmux|-V|3.1|tmux|tmux|tmux|tmux||config/tmux::$HOME/.config/tmux|docs/tmux.md|"
```

Special syntax: apt records can name Debian's real binary
(`bat:batcat`, `fd-find:fdfind`), and multi-binary tools use commas
(`yazi,ya`). `gum` is a companion entry with no config; brew and Arch/Fedora
install it natively, while apt uses the official release tarball.

The executable layers stay small:

| File | Responsibility |
| --- | --- |
| `scripts/arron` | Unified command and subcommand dispatcher |
| `scripts/lib/ui.sh` | gum controls + pure-bash fallback + TTY/NO_COLOR safety |
| `scripts/tools.sh` | Tool-install engine |
| `scripts/install.sh` | Gated symlink engine + `~/.local/bin/arron` deployment |
| `scripts/doctor.sh` | Read-only health matrix and actionable hints |
| `scripts/session.sh` | tmux create-or-attach helper |
| `scripts/lib/common.sh` | Checks, prompts, version comparison, platform detection |

## Safety

- **Idempotent** — installed tools and correct links are skipped.
- **Backups, never clobber** — a target is moved to
  `<target>.bak.<timestamp>` before linking.
- **Placeholder-aware** — README-only config directories are not deployed.
- **Binary-gated** — configs cannot get ahead of their applications.
- **True dry-run** — never opens a hidden install prompt.
- **Arch-safe** — always `pacman -Syu`, never unsupported partial upgrades.
- **Pipe-safe** — no ANSI color or interactive prompt leaks into CI/output.
- **Bash 3.2-compatible** — the engine works with macOS's system bash.

## Tuning & exploring

```sh
arron list
arron doctor
NO_COLOR=1 arron doctor       # disable color explicitly
arron config --dry-run tmux   # inspect one deployment
```

To add a tool: add one registry record; add `config/<tool>/` if needed;
write `docs/<tool>.md`; and keep the Brewfile's macOS entries in sync.

## FAQ

- **What if gum cannot install?** `arron` warns and falls back to the
  numbered bash interface. No core operation depends on the UI layer.
- **Why are lazygit/yazi configs "placeholder"?** Their setup lessons have
  not happened yet. The framework distinguishes "tool installed" from
  "repo config authored".
- **Why does Ubuntu use release binaries for some tools?** Its snapshots
  lack lazygit/yazi/eza or ship Neovim older than LazyVim's ≥0.11 target.
- **Why not use fzf for menus?** fzf is part of the environment being
  installed. Gum has an explicit bootstrap path; fzf remains a shell tool.

## References

- [Gum](https://github.com/charmbracelet/gum) — UI commands and install options.
- [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle) — macOS all-at-once install.
- [Roadmap](../ROADMAP.md) · [workflow decisions](workflow.md)
