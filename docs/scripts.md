# Scripts — install vs. configure

> **Status:** configured — bash 3.2+ (the macOS default), macOS and
> Arch/Debian/Fedora Linux, x86_64 and aarch64.

## Role

Four small scripts stand between a fresh machine and the full arronflow
environment. Their one design rule: **installing tools and configuring them
are different jobs**, done by different commands, gated on each other.

## Background: why two phases

"Set up my terminal" hides two decisions that deserve to be made
separately:

1. *Which binaries exist on this machine?* — a package-manager question
   (Homebrew, pacman, apt, dnf, or a GitHub release). Some people want a
   script to do it; others want the commands printed so they stay in
   control of their system packages.
2. *Which configs come from this repo?* — a symlinking question. A config
   for a tool that is not installed is dead weight, so deployment is
   **gated**: no tmux binary, no tmux config. Tools are independent —
   skipping Ghostty never blocks tmux.

The phases meet in a **registry** (`scripts/lib/registry.sh`): one line per
tool declaring its binaries, version minimum, per-platform packages, GitHub
release fallback, config paths, and docs page. Every script reads the same
lines, so "add a tool" is a one-line change.

## The pieces

| File                     | Job                                                             |
| ------------------------ | --------------------------------------------------------------- |
| `scripts/bootstrap.sh`   | Front door: numbered menu on a terminal, flags when piped       |
| `scripts/tools.sh`       | Phase 1: install binaries — `--auto` or `--manual` (print only) |
| `scripts/install.sh`     | Phase 2: symlink configs, gated on installed binaries           |
| `scripts/doctor.sh`      | Read-only report: binary? version? config linked? + commands    |
| `scripts/session.sh`     | tmux create-or-attach helper (unrelated to setup)               |
| `scripts/lib/registry.sh`| The data — one line per tool                                    |
| `scripts/lib/common.sh`  | Shared logic: checks, prompts, menus, version compares          |

## Everyday commands

```sh
scripts/bootstrap.sh                          # menu (on a terminal)
scripts/bootstrap.sh --everything --auto --all --dry-run   # see the plan first
scripts/bootstrap.sh --everything --auto --all             # do everything
scripts/tools.sh --auto tmux nvim             # install two tools
scripts/tools.sh --manual lazygit             # print the commands for this OS
scripts/install.sh                            # deploy all ready configs (piped)
scripts/install.sh tmux                       # deploy one tool's config
scripts/doctor.sh                             # health report
scripts/tools.sh --list / install.sh --list   # registry views
```

## Interactive vs. scripted

No arguments **on a terminal** → numbered menus (pure bash — no fzf/gum,
because those may not exist yet on a fresh machine). No arguments **piped**
→ sensible defaults (`install.sh` deploys everything it can) or a usage
error (`tools.sh`, `bootstrap.sh` — auto-install runs sudo and must never
be a silent default). Every menu has a flag equivalent, so CI and pipes
always work.

## The registry, annotated

```
"tmux|tmux|tmux|-V|3.1|tmux|tmux|tmux|tmux||config/tmux::$HOME/.config/tmux|docs/tmux.md|"
   │    │     │     │  │   │    │     │   │   └─ config source → link target
   │    │     │     │  │   │    │     │   └─ no GitHub fallback needed
   │    │     │     │  │   │    │     └─ dnf / apt / pacman / brew package names
   │    │     │     │  │   └─ minimum version ("" = presence check only)
   │    │     │     └─ flag that prints the version
   │    │     └─ binaries that must exist (yazi needs "yazi,ya")
   │    └─ display name
   └─ registry key = CLI selector (`install.sh tmux`)
```

Special syntax worth knowing: `apt` entries may carry the real Debian
binary name (`fd-find:fdfind`, `bat:batcat`) — the scripts link it under
the plain name in `~/.local/bin`. The `gh` field names the release assets
for both architectures; it is used only where the current platform has no
native package (Ubuntu's repos lack lazygit/yazi/eza and ship a Neovim
older than LazyVim's ≥ 0.11 requirement).

## Safety model

- **Idempotent** — re-running anything is safe; targets already linked are
  reported `OK` and skipped.
- **Backups, never clobber** — a foreign file or link at a target is moved
  to `<target>.bak.<timestamp>` before linking.
- **Placeholder-aware** — a config directory holding only a README (yazi,
  lazygit today) is skipped, so the step-by-step build never touches live
  configs.
- **Gated configs** — `install.sh` refuses to deploy a tool whose binary is
  missing, and says exactly how to fix that.
- **Read-only doctor** — reports and prints commands; installs nothing.
- **bash 3.2 compatible** — no associative arrays, no `mapfile`, no
  `sort -V`; prompts survive closed stdin.

## Adding a new tool

1. One record line in `scripts/lib/registry.sh`.
2. (If it has a config) `config/<tool>/` mirroring its real config layout.
3. A `docs/<tool>.md` page; the registry's `docs` field points to it.

## FAQ

- **Brewfile vs. registry?** On macOS, `--all` uses the Brewfile as one
  transaction; per-tool installs use the registry's `brew` field. Keep the
  two in sync when editing either (this is the one hand-maintained
  invariant).
- **Why does `--manual` print links instead of exact download URLs?**
  Stable `releases/latest` URLs never hit the GitHub API — no rate limit,
  no curl dependency, correct on a box with nothing installed.
- **Why is my distro's Neovim ignored?** LazyVim needs ≥ 0.11; apt/dnf
  snapshots lag. The registry leaves those fields empty on purpose so the
  release fallback wins.

## References

- Repo decisions log: [workflow.md](workflow.md) · Roadmap: [../ROADMAP.md](../ROADMAP.md)
- Bash 3.2 pitfalls: https://tldp.org/LDP/abs/html/ (guide; treat critically)
- Homebrew bundle: https://github.com/Homebrew/homebrew-bundle
