# Neovim config — LazyVim distribution

Deployed to `~/.config/nvim/` as a directory symlink by `scripts/install.sh`.

Contents are the stock [LazyVim starter](https://github.com/LazyVim/starter)
(`init.lua`, `lua/config/*`, `.gitignore`, `.neoconf.json`, `stylua.toml`)
plus our teaching-oriented `lua/plugins/example.lua`. Deliberately kept
lean: no extras, no added plugins. Walkthrough and exercises:
[docs/lazyvim.md](../../docs/lazyvim.md).

`lazy-lock.json` (plugin version pins) is generated on first launch and
committed, so a fresh clone reproduces the exact plugin set. After
`:Lazy update`, commit the lockfile diff.
