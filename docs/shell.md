# Shell — zsh + Oh My Zsh + Powerlevel10k

> **Status:** ✅ configured (2026-09-27). Canonical configs:
> [`config/zsh/zshrc`](../config/zsh/zshrc) → `~/.zshrc`,
> [`config/zsh/p10k.zsh`](../config/zsh/p10k.zsh) → `~/.p10k.zsh`.

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
Starship both work by overwriting that function. Whoever initializes *last* renders. The
pre-arronflow zshrc accidentally ran *both*: it loaded Starship only when
`TERM_PROGRAM == ghostty` — a test that is never true inside tmux, because tmux ≥ 3.4
sets `TERM_PROGRAM=tmux` in its panes. Since daily work happens in tmux, Powerlevel10k
was the de-facto prompt all along. This stack keeps exactly one engine on purpose — p10k
as the OMz theme — so the prompt is identical in Ghostty, tmux, Terminal.app, and IDE
terminals.

**Why Powerlevel10k:** it is the prompt this machine already ran for months — configured
personally with p10k's wizard on 2026-05-20 — and the wizard makes restyling a two-minute
affair. Starship, the honest alternative (a standalone Rust binary, TOML config, works in
any shell), was briefly deployed here — as its stock default and as a custom
Tokyo-Night-style design — and both were rolled back in favor of the familiar look.

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
scripts/tools.sh --auto zsh    # or: brew bundle install + the OMz clones below
scripts/install.sh zsh         # deploy ~/.zshrc + ~/.p10k.zsh
```

`tools.sh --auto zsh` also clones Oh My Zsh plus the external plugins and the
p10k theme into `~/.oh-my-zsh/custom/` (`--manual` prints every command
instead). Framework: [scripts.md](scripts.md).

## Our configuration

### `~/.zshrc` ([config/zsh/zshrc](../config/zsh/zshrc))

Ordered top to bottom:

1. **Greeting** — `fastfetch`, guarded by `command -v` so a fresh clone before `brew
   bundle` doesn't error. The old `neofetch` cost 200–300 ms per shell; fastfetch is the
   Rust successor at milliseconds. Its display list is curated in
   [config/fastfetch/config.jsonc](../config/fastfetch/config.jsonc) — see below.
2. **p10k instant prompt** — sources the cached last prompt so the prompt is on screen
   instantly while the rest of this file (and `~/.zshrc.local`, ~1 s of dev environment)
   still loads. Placement rule inherited from the pre-arronflow zshrc: it must come
   *after* anything that prints (the greeting) and *before* Oh My Zsh — console output
   between this block and the prompt triggers p10k's initialization-output warning.
3. **OMz + the p10k config loader** — `ZSH_THEME="powerlevel10k/powerlevel10k"` loads
   Powerlevel10k's *engine* as the OMz theme. The engine alone does **not** read
   `~/.p10k.zsh`; the line right after `source $ZSH/oh-my-zsh.sh` does that explicitly:
   `[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh`. That line is load-bearing — without
   it, no `POWERLEVEL9K_*` parameter is ever set, and p10k auto-runs `p10k configure`
   in every fresh shell (this failure happened once; see the FAQ). Plus the plugin
   lineup. Each plugin's job, in one line each:
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
4. **Options** — `setopt CORRECT`: zsh offers to fix command typos
   (`correct 'gti' to 'git'?`).
5. **PATH** — only the portable `$HOME/.local/bin` prefix. Machine-specific PATHs belong
   in `~/.zshrc.local`.
6. **Modern aliases** — the table above, per policy.
7. **Tool inits** — `zoxide`, then `fzf --zsh`. No prompt engine here: the prompt is the
   OMz theme from step 3.
8. **Local hook** — `[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local`. The portability
   seam: machine-specific setup lives there — present on machines that need it, absent on
   machines that don't, never in git. This Mac's `~/.zshrc.local` (created 2026-09-27,
   migrated losslessly from the pre-arronflow zshrc) carries nvm + npm-global PATH, conda,
   JDK/sdkman, the Qt CMake prefix, and the personal `top`/`fd` aliases. It costs ~1 s of
   startup; lazy-loading those tools is a known optimization, deliberately not applied
   until it hurts.

### Powerlevel10k ([config/zsh/p10k.zsh](../config/zsh/p10k.zsh))

The prompt is the user's own `p10k configure` wizard output (first configured
2026-05-20, regenerated 2026-09-27; 1745 machine-generated lines, zero machine-specific
paths), versioned in this repo. The wizard's current choices, i.e. what you see:

- **classic style, two lines, right frame — sharp heads, vertical separators** — line 1
  carries `dir` and `vcs` (git state) on the left; the right side carries signals that
  appear only when relevant: exit code of a failed command, command duration, background
  jobs, and environment segments (`anaconda` for conda, `nvm` for Node, …). Line 2 is
  the `❯` prompt character.
- **Nerd Font v3 icons, few and small** — icons only where they earn their place.
- **sparse spacing, one empty line between prompts** — each command block breathes.
- **instant prompt** — the cached prompt paints immediately while zsh initializes.

Do not hand-edit the file casually — it is machine-generated. Restyle with
`p10k configure`, which rewrites `~/.p10k.zsh`; since that is a symlink into this repo,
`git diff` shows exactly what the wizard changed — commit what you keep.

### fastfetch ([config/fastfetch/config.jsonc](../config/fastfetch/config.jsonc))

The greeting shown once per shell. Curated for a laptop where the interesting facts are
few: `os · host · uptime · packages · shell · display · theme · terminal ·
cpu · gpu · memory · swap · disk · locale`, then the color palette. Deliberately
absent: `separator` (the dashed line under the title), `kernel`, `font`, `cursor`,
`localip`, `battery`, `poweradapter`, `wm`, `wmtheme`, and modules that print nothing
on macOS anyway (`de`, `icons`, `terminalfont`).

The `modules` array is the complete display list — what is not named does not print.
Adjust by editing it; module names are the lowercase words fastfetch prints on the
left. `fastfetch --gen-config` regenerates the full default list for reference.

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
  (The prompt paints instantly regardless of startup time — that is what instant prompt
  is for.)
- **Restyle the prompt**: `p10k configure` — the interactive wizard walks through style,
  characters, colors, one vs. two lines, spacing, and transient/instant prompt, then
  shows a "show off" demo. It rewrites `~/.p10k.zsh` (a symlink into this repo); review
  with `git diff`, commit what you keep.
- **Toggle single segments** (drop `anaconda`, add `java_version`, …): edit
  `POWERLEVEL9K_LEFT/RIGHT_PROMPT_ELEMENTS` near the top of `config/zsh/p10k.zsh` —
  every available segment is listed there, mostly commented out; `exec zsh` applies.
- **OMz CLI**: `omz update`, `omz plugin enable/disable <name>`, `omz theme set <name>`
  (they edit `~/.zshrc` — i.e. this repo's file; prefer hand-editing so docs stay in
  sync).
- **Add a dev environment later**: put its init block in `~/.zshrc.local`; the repo zshrc
  picks it up automatically.

## FAQ

- **The prompt shows boxes / missing icons.** The Nerd Font must be the terminal font —
  check Ghostty's `font-family` (see [ghostty.md](ghostty.md)).
- **Every fresh shell opens the p10k configuration wizard** (diamond / font questions
  instead of the prompt). Cause: `~/.p10k.zsh` is not being loaded. Setting
  `ZSH_THEME="powerlevel10k/powerlevel10k"` only loads the theme *engine*; when p10k
  starts and finds zero `POWERLEVEL9K_*` parameters, it concludes the prompt is
  unconfigured and launches the wizard. Fix: the explicit loader line after
  `source $ZSH/oh-my-zsh.sh` — `[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh` — must
  be present (2026-09-27: it was mistaken for redundant and removed; every new tmux
  window ran the wizard until it came back). Quick check:
  `zsh -i -c 'print ${(k)#parameters[(I)POWERLEVEL9K_*]}'` — a healthy shell reports
  ~314, a broken one reports 0.
- **`command not found: fastfetch` etc. after a fresh clone.** Run `brew bundle install`
  and `scripts/bootstrap.sh` before the first shell start; the fastfetch line is guarded,
  the rest fail loudly on purpose.
- **Where did my old `~/.zshrc` and `~/.p10k.zsh` go?** `scripts/install.sh` moved each
  to `<name>.bak.<timestamp>` before symlinking; the live `~/.p10k.zsh` is a symlink to
  `config/zsh/p10k.zsh` with identical content. Old backups are safe to delete once you
  are satisfied.
- **Why doesn't `grep` mean `rg` anymore?** Copied shell snippets assume real `grep`
  semantics; aliases that silently change them cause confusing failures. Type `rg`.
- **A command behaves oddly.** First suspect: an alias. Check with `alias <name>` or
  `als`; bypass aliases with `command <name>` or a leading backslash.

## References

| When you need…                                 | Where                                                          |
| ---------------------------------------------- | -------------------------------------------------------------- |
| Powerlevel10k — README: wizard, options, FAQ   | [romkatv/powerlevel10k](https://github.com/romkatv/powerlevel10k) |
| Oh My Zsh — docs, plugins, themes              | [ohmyzsh/ohmyzsh](https://github.com/ohmyzsh/ohmyzsh)          |
| OMz plugin catalog                             | [OMz wiki — Plugins](https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins) |
| zsh-autosuggestions (keys, strategies)         | [zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) |
| zsh-syntax-highlighting                        | [zsh-users/zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) |
| zoxide                                         | [ajeetdsouza/zoxide](https://github.com/ajeetdsouza/zoxide)    |
| fzf — keys and customization                   | [junegunn/fzf](https://github.com/junegunn/fzf)                |
| eza / bat / fd / ripgrep / fastfetch           | [eza-community/eza](https://github.com/eza-community/eza) · [sharkdp/bat](https://github.com/sharkdp/bat) · [sharkdp/fd](https://github.com/sharkdp/fd) · [BurntSushi/ripgrep](https://github.com/BurntSushi/ripgrep) · [fastfetch-cli/fastfetch](https://github.com/fastfetch-cli/fastfetch) |
| fastfetch — config syntax & module catalog     | [fastfetch wiki — Configuration](https://github.com/fastfetch-cli/fastfetch/wiki/Configuration) |
| The shell itself                               | `man zsh` (and `man zshoptions`, `man zshall`)                  |
