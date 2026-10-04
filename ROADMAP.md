# Roadmap

Where arronflow is heading. Two audiences, one repo: a fast rebuild of the owner's
own environment, and a readable reference for anyone assembling a similar one.
Each milestone is a branch-sized batch — never a big-bang rewrite.

## M1 — Script framework ✅ (branch `scripts-framework`)

Installation and configuration became two independent phases driven by one
declarative registry (`scripts/lib/registry.sh`):

- `tools.sh` — internal phase 1: install binaries, `--auto` or `--manual`
- `install.sh` — internal phase 2: symlink configs, binary-gated
- `doctor.sh` — internal read-only health report + commands for the gaps
- ROADMAP + `docs/scripts.md`

## M1.5 — One entrance + UI ✅ (branch `scripts-framework`)

- `arron` is the only command to remember: up/tools/config/doctor/session/list
- gum powers interactive menus, confirmations, and release-download spinners
- first-run bootstrap remains plain bash until gum exists; offline/CI fallback
  keeps every operation usable
- config deployment links `arron` into `~/.local/bin`
- `bootstrap.sh` remains a compatibility shim until M2 merges

## M2 — Merge & validate

- Ubuntu 26.04 arm64: real full install covered native apt, six GitHub fallbacks,
  Debian bat/fd rename links, native Ghostty, and config gates; rerun after the
  yazi comma-split fix + gum UI remains
- Arch ARM: rerun from a healthy/full-upgrade state after the `-Sy` → `-Syu`
  correction, then idempotency pass
- Merge `scripts-framework` into `main` (it already contains `linux-support`)
- Fix the Ghostty transparency drift: `docs/workflow.md` says 0.9, the config
  ships 0.75

## M3 — CI

- GitHub Actions: `bash -n` + shellcheck on every script
- Container smoke test: bare Ubuntu → `install.sh` gates everything,
  `doctor.sh` exits 1 with the right manual commands

## M4 — Reference polish

- README quickstart for both audiences (rebuild mine / borrow yours)
- LICENSE decision (MIT suggested)
- `uninstall.sh` — reverse the symlinks, keep the backups
- Optional `update.sh` — pull, relink, `omz update`

## M5 — Curriculum continues

Tool-by-tool, one at a time (the repo's working rule):

1. tmux keybinding final pass (audit base: `docs/tmux-keys-ours.md`)
2. yazi configuration step (opener rules, previews, cd-on-quit wrapper)
3. lazygit configuration step

Each step lights up its registry entry, its doctor checks, and its docs page.
Known content-level gaps to fold in along the way: Ghostty keybinds are
macOS-flavored (`cmd+…` — inert on Linux), and the fastfetch module list is
tuned for a macOS laptop.
