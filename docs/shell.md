# Shell — zsh + Oh My Zsh + Starship

> **Status:** ✅ configured (2026-09-27). Canonical configs:
> [`config/zsh/zshrc`](../config/zsh/zshrc) → `~/.zshrc`,
> [`config/starship/starship.toml`](../config/starship/starship.toml) → `~/.config/starship.toml`.

## Role

The shell is the glue layer of the whole stack — the program that reads command lines,
launches programs, and remembers everything (history, directories, environment). tmux,
Neovim, lazygit, and yazi are all *programs the shell launches*; the prompt, the
suggestions, and the fuzzy finders below are what make moving between them fast.

## Background: terminal vs. shell, again

From [ghostty.md](ghostty.md): **the emulator owns looks, the shell owns meaning.** When
you press Enter, it is zsh that parses the line, expands globs and variables, finds the
program on `$PATH`, runs it, and prints the next prompt when it exits.

zsh is a Bourne-family shell (same lineage as bash) with the strongest completion system of
the family, and it has been **the default shell of macOS since Catalina (2019)** — nothing
to install.

What zsh owns, day to day:

| Responsibility      | You experience it as                     |
| ------------------- | ---------------------------------------- |
| Parsing & launching | "the command ran"                        |
| Environment / PATH  | which `python`/`nvim` gets found         |
| History             | `↑`, `Ctrl+R`                            |
| Aliases & functions | `gst`, `ls` meaning `eza`                |
| Completion          | `Tab`                                    |
| Job control         | `Ctrl+Z`, `fg`, `bg`                     |
| The prompt          | rendered by whoever last claimed it (see below) |

## Why Oh My Zsh (a framework, not another shell)

Raw zsh is powerful but its best features ship switched off. Oh My Zsh (OMz) is a
configuration bundle: sane defaults (history, completion), a library of ~370 official
plugins, ~140 themes, and an update mechanism. It is loaded by three lines in `~/.zshrc`.

The honest alternatives: a hand-rolled zshrc (educational, but you re-solve solved
problems), or a modern plugin manager like zinit/sheldon (faster startup, more machinery to
understand). OMz is the right amount of magic for this stack.

**The cost model to remember: OMz plugins load synchronously at startup. Every plugin in
`plugins=()` is paid for on every shell start — each one must earn its keep.**

### Anatomy of `~/.oh-my-zsh/`

```
~/.oh-my-zsh/
├── oh-my-zsh.sh    the engine you source
├── lib/            OMz's own sane defaults
├── plugins/        ~370 official plugins
├── themes/         ~140 official themes
├── custom/         ★ your territory — survives `omz update`
│   ├── plugins/      external plugins (autosuggestions, syntax-highlighting)
│   └── themes/       external themes
└── tools/          updater etc.
```

`custom/` is the important lesson: an OMz update resets everything *except* `custom/`, so
anything external gets cloned there (`scripts/bootstrap.sh` does this).

## Concepts

**Prompt engines — "the last initializer wins".** The prompt is a zsh hook: before each
prompt is drawn, zsh calls whatever function currently claims it. Powerlevel10k and
Starship both work by overwriting that function. Whoever initializes *last* renders. This
stack keeps exactly one engine — Starship, initialized unconditionally — so the prompt is
identical in Ghostty, tmux, Terminal.app, and IDE terminals.

**Why Starship over Powerlevel10k:** a single Rust binary (not a zsh theme), works in any
shell, configured by a short readable TOML that belongs in git, actively developed. p10k's
one real advantage — its `p10k configure` wizard — matters less when the config is written
deliberately and versioned.

**Modern CLI replacements.** Classics rebuilt in Rust/Go — faster, colorful, humane
defaults. Wired in through aliases, but with a policy: only "output for humans" tools take
the classic name; tools that scripts and tutorials call by name keep their original.

| Classic | Modern | Note                                      |
| ------- | ------ | ----------------------------------------- |
| `ls`    | `eza`  | aliased (`ls`, `ll`) — icons, git column  |
| `cat`   | `bat`  | aliased — syntax highlight, line numbers  |
| `find`  | `fd`   | **not aliased** — type `fd`              |
| `grep`  | `rg`   | **not aliased** — type `rg`              |
| `cd`    | zoxide | `z <partial>` jumps by frecency           |
| —       | `fzf`  | fuzzy layer beneath everything            |

**zsh startup files.** `~/.zshenv` (every zsh, pure env vars), `~/.zprofile` (login
shells), `~/.zshrc` (interactive shells — the only one this repo manages). One file, one
responsibility; no scattering.

## Installation

```sh
brew bundle install   # starship, zoxide, fzf, eza, bat, ripgrep, fd, fastfetch
scripts/bootstrap.sh  # on a fresh Mac: also OMz + external plugins, then install.sh
```

## Our configuration

### `~/.zshrc` ([config/zsh/zshrc](../config/zsh/zshrc))

Ordered top to bottom:

1. **Greeting** — `fastfetch`, guarded by `command -v` so a fresh clone before `brew
   bundle` doesn't error. The old `neofetch` cost 200–300 ms per shell; fastfetch is the
   Rust successor at milliseconds.
2. **OMz** — `ZSH_THEME=""` (Starship owns the prompt; an OMz theme would be overridden
   anyway), and the plugin lineup. Each plugin's job, in one line each:
   - `git` — ~100 aliases: `gst` (status), `ga`/`gcmsg` (add/commit), `gco`/`gcb`
     (checkout/branch), `gp`/`gl` (push/pull), `gd` (diff), `glog` (pretty log). Quick
     git stays at the prompt; interactive git goes to lazygit.
   - `aliases` — provides `als`: lists every active alias grouped by the plugin that
     defined it. The discovery tool while learning.
   - `extract` — `extract <anything.tar.gz|.zip|.7z|.rar|…>`: one command for every
     archive format.
   - `zsh-autosuggestions` (external) — ghost-text suggestions from history. `→` accepts
     the whole line, `Ctrl+→` (bound explicitly below the aliases) accepts one word.
   - `zsh-syntax-highlighting` (external) — valid commands green, invalid red, live. Must
     load last among plugins, which is why it ends the array.
3. **Options** — `setopt CORRECT`: zsh offers to fix command typos
   (`correct 'gti' to 'git'?`).
4. **PATH** — only the portable `$HOME/.local/bin` prefix. Machine-specific PATHs belong
   in `~/.zshrc.local`.
5. **Modern aliases** — the table above, per policy.
6. **Tool inits** — `zoxide`, then `fzf --zsh`, then `starship init zsh`. Order is
   deliberate: prompt engines last.
7. **Local hook** — `[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local`. The portability
   seam: dev environments (conda, nvm, sdkman, JAVA_HOME, Qt) will live there when the
   workflow phase is done — present on machines that need them, absent on machines that
   don't, never in git.

### Starship ([config/starship/starship.toml](../config/starship/starship.toml))

Tokyo Night *structure* wearing an Atom One Dark *palette* — the prompt matches the
terminal theme without importing a second color scheme. Two lines:

```
╭─~/Work/Arron on  main (!2)  22.4          ⏱ 3s 12:34
╰─❯
```

- Line 1 left: **directory** (blue, truncated to repo-relative), **git branch** (purple) +
  **status** (yellow), **language runtimes** (node/python/c/cpp/cmake/java — only inside
  matching projects).
- Line 1 right: **command duration** (only ≥ 2 s — silent otherwise) and **time**, pushed
  right by the `fill` module.
- Line 2: `❯` — green after success, red after failure. Input always starts at column 0,
  so deep paths never crowd your typing.

Colors are named in `[palettes.one-dark]` and referenced as `fg:blue`, `fg:green`, … —
retinting the prompt is editing one table. Config changes apply on the *next prompt line*,
no reload.

## Key bindings & aliases worth memorizing

| Keys / command   | Action                                        |
| ---------------- | --------------------------------------------- |
| `Ctrl+R`         | fzf fuzzy history search                      |
| `Ctrl+T`         | fzf fuzzy file → insert path at cursor        |
| `Alt+C`          | fzf fuzzy cd                                  |
| `→` / `Ctrl+→`   | accept ghost suggestion / one word of it      |
| `z <partial>` / `zi` | zoxide jump / interactive pick            |
| `als`            | list all active aliases by source plugin      |
| `gst` `ga` `gcmsg` `gco` `gp` `gl` `gd` `glog` | git aliases   |
| `extract <file>` | unpack any archive format                     |
| `exec zsh`       | reload config cleanly (replaces the shell)    |

## Tuning & exploring

- **Measure startup**: `time zsh -ic exit`. Adding a plugin? Measure before and after.
- **Try prompt styles live** without touching config:
  ```sh
  STARSHIP_CONFIG=~/.cache/starship-try.toml eval "$(starship init zsh)"
  starship preset pastel-powerline -o ~/.cache/starship-try.toml   # swap styles freely
  exec zsh                                                          # back to normal
  ```
- **Explain your prompt**: `starship explain` names every visible segment.
- **Preview official presets**: https://starship.rs/presets
- **Add a segment**: pick a module from the config reference, add `$module` to `format`,
  configure its section — the change lands on the next prompt line.
- **OMz CLI**: `omz update`, `omz plugin enable/disable <name>`, `omz theme set <name>`
  (they edit `~/.zshrc` — i.e. this repo's file; prefer hand-editing so docs stay in
  sync).
- **Add a dev environment later**: put its init block in `~/.zshrc.local`; the repo zshrc
  picks it up automatically.

## FAQ

- **The prompt shows boxes / missing icons.** The Nerd Font must be the terminal font —
  check Ghostty's `font-family` (see [ghostty.md](ghostty.md)).
- **`command not found: fastfetch` etc. after a fresh clone.** Run `brew bundle install`
  and `scripts/bootstrap.sh` before the first shell start; the fastfetch line is guarded,
  the rest fail loudly on purpose.
- **Where did my old `~/.zshrc` go?** `scripts/install.sh` moved it to
  `~/.zshrc.bak.<timestamp>` before symlinking. The old Powerlevel10k files
  (`~/.p10k.zsh`, `~/.oh-my-zsh/custom/themes/powerlevel10k`) are simply no longer
  referenced; delete them whenever.
- **Why doesn't `grep` mean `rg` anymore?** Copied shell snippets assume real `grep`
  semantics; aliases that silently change them cause confusing failures. Type `rg`.
- **A command behaves oddly.** First suspect: an alias. Check with `alias <name>` or
  `als`; bypass aliases with `command <name>` or a leading backslash.

## References

| When you need…                                 | Where                                                          |
| ---------------------------------------------- | -------------------------------------------------------------- |
| Starship — everything                          | [starship.rs](https://starship.rs)                             |
| Starship module & option reference             | [starship.rs/config](https://starship.rs/config/)              |
| Preset gallery with screenshots                | [starship.rs/presets](https://starship.rs/presets)             |
| Oh My Zsh — docs, plugins, themes              | [ohmyzsh/ohmyzsh](https://github.com/ohmyzsh/ohmyzsh)          |
| OMz plugin catalog                             | [OMz wiki — Plugins](https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins) |
| zsh-autosuggestions (keys, strategies)         | [zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) |
| zsh-syntax-highlighting                        | [zsh-users/zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) |
| zoxide                                         | [ajeetdsouza/zoxide](https://github.com/ajeetdsouza/zoxide)    |
| fzf — keys and customization                   | [junegunn/fzf](https://github.com/junegunn/fzf)                |
| eza / bat / fd / ripgrep / fastfetch           | [eza-community/eza](https://github.com/eza-community/eza) · [sharkdp/bat](https://github.com/sharkdp/bat) · [sharkdp/fd](https://github.com/sharkdp/fd) · [BurntSushi/ripgrep](https://github.com/BurntSushi/ripgrep) · [fastfetch-cli/fastfetch](https://github.com/fastfetch-cli/fastfetch) |
| The shell itself                               | `man zsh` (and `man zshoptions`, `man zshall`)                  |
