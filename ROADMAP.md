# Roadmap

Where arronflow is heading. Two audiences, one repo: a fast rebuild of the owner's
own environment, and a readable reference for anyone assembling a similar one.
Each milestone is a branch-sized batch — never a big-bang rewrite.

## M1 — Script framework ✅ (branch `scripts-framework`)

Installation and configuration became two independent phases driven by one
declarative registry (`scripts/lib/registry.sh`):

- `tools.sh` — phase 1: install binaries, `--auto` or `--manual` (commands only)
- `install.sh` — phase 2: symlink configs, gated on the binary being present
- `doctor.sh` — read-only health report + manual commands for the gaps
- `bootstrap.sh` — interactive menu / flag dispatcher
- ROADMAP + `docs/scripts.md` (this batch)

## M2 — Merge & validate

- Full-run validation on Ubuntu and Arch (VM or containers): `bootstrap.sh
  --everything --auto --all`, then a re-run for idempotency
- Merge `linux-support` + `scripts-framework` into `main`
- Commit the synced Neovim config drift (Oct 1 live dir → repo, incl.
  `lazyvim.json` and the pandoc plugin)
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
