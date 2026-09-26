# Ghostty

> **Status:** ✅ configured (2026-09-26). Canonical config:
> [`config/ghostty/config`](../config/ghostty/config) → `~/.config/ghostty/config`.

## Role

Ghostty is the **terminal emulator** — the bottom layer of the stack. tmux, the shell,
Neovim, lazygit, and yazi all render inside a Ghostty window. Ghostty owns everything about
*display*: typography, colors, window management, clipboard, and input.

## Background: terminal vs. shell vs. multiplexer

Beginners routinely conflate three pieces of software that all look like "the black window".
They are separate programs, each with its own job:

```
keyboard input
    │
    ▼
┌────────────────────────────────────────────────────┐
│ Ghostty — terminal emulator                        │  renders text, colors,
│  ┌──────────────────────────────────────────────┐  │  fonts, windows; passes
│  │ zsh — the shell                              │  │  keystrokes through
│  │  ┌────────────────────────────────────────┐  │  │
│  │  │ the programs you run                   │  │  │  parses commands,
│  │  │ (ls, nvim, lazygit, ...)               │  │  │  manages env & history
│  │  └────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────┘
```

- The **terminal emulator** never understands commands. Programs emit streams of characters
  and escape sequences; the emulator paints them. It also owns the clipboard, selection, and
  font rendering.
- The **shell** (zsh) never draws anything. It reads command lines, launches programs, and
  manages environment variables and history.
- A **multiplexer** (tmux, covered in [tmux.md](tmux.md)) is a program *inside* the terminal
  that splits one terminal into many panes and keeps sessions alive in the background.

Rule of thumb: **the emulator owns looks, the shell owns meaning, tmux owns layout.**
The name "emulator" is historical: early terminals were physical machines; modern software
*emulates* one.

## Why Ghostty

| Property        | Why it matters here                                                       |
| --------------- | ------------------------------------------------------------------------- |
| Native macOS app| Real macOS tabs and windows; feels like the rest of the system             |
| GPU rendering   | Stays smooth when scrolling huge build logs or htop                        |
| Sane defaults   | Usable out of the box; only deliberate choices end up in the config        |
| One text file   | `~/.config/ghostty/config`, plain `key = value` lines — perfect for git    |
| Fast startup    | The quick terminal must appear instantly to be worth using                 |

One-line takes on the alternatives: iTerm2 — featureful but aging and slower; kitty and
Alacritty — fast but deliberately minimal, expect more configuration; Warp — AI-first and
closed-source. Ghostty is the current sweet spot of fast + native + low-maintenance.

## Concepts you need before the config

**Nerd Font.** The icons in yazi, prompts, and statuslines are not emoji — they are
thousands of icon glyphs patched into a font ("Nerd Font"). We use
**Maple Mono NF CN**: `NF` adds the icons, `CN` adds full CJK glyphs so Chinese text stays
perfectly aligned on the terminal grid. Every other tool depends on this font being active
in the terminal, which is why it lives in the Ghostty config.

**Theme.** A theme is one palette: background, foreground, and the 16 ANSI colors that
programs use. The decision made here cascades — tmux's status bar, Neovim, yazi, and lazygit
all follow the same family so the environment looks like one product. We chose **Atom One
Dark**: dark background, gentle contrast, easy on the eyes for long sessions.

**True color.** Modern terminals offer 24-bit color (16.7M colors) instead of the classic
256. Ghostty has it by default; tmux needs one line to pass it through (see tmux.md).

**Tabs & splits vs. tmux.** Ghostty has native tabs (`Cmd+T`) and splits (`Cmd+D`). These
overlap with tmux on purpose: use Ghostty's for quick, throwaway panes; use tmux for real
work — persistent sessions, scripted layouts, ssh. Different tools for different lifetimes.

**Quick terminal.** A Quake-style dropdown terminal summoned by a global hotkey from
anywhere in macOS. It auto-hides when it loses focus. Ideal for "run one command and get
out".

**Shell integration.** Ghostty injects a tiny script into the shell at startup so the
terminal *knows* shell state — where prompts are (jump between them with `Cmd+Up` /
`Cmd+Down`) and the current directory. We disable only its cursor feature, because Neovim
manages cursor shape itself and the two would fight.

**Scrollback.** How much history you can scroll up through, in bytes. Big logs need big
scrollback.

## Installation

```sh
brew bundle install   # cask "ghostty" + cask "font-maple-mono-nf-cn"
```

Everything is in the [`Brewfile`](../Brewfile). On a fresh Mac,
`scripts/bootstrap.sh` covers this.

## Our configuration

The canonical file is [`config/ghostty/config`](../config/ghostty/config); it is symlinked
to `~/.config/ghostty/config`, so editing it here and editing it in place is the same act.
Reload after every change with `Cmd+Shift+,` — no restart needed.

### Typography

| Setting              | Value              | Why                                                    |
| -------------------- | ------------------ | ------------------------------------------------------ |
| `font-family`        | `Maple Mono NF CN` | Nerd Font icons + CJK alignment (see Concepts)         |
| `font-size`          | `14`               | Comfortable on a 14" retina display                    |
| `font-thicken`       | `true`             | macOS renders light fonts thinly; this compensates     |
| `adjust-cell-height` | `2`                | A few pixels of extra line height — less cramped       |

### Theme

`theme = Atom One Dark` — chosen for a dark background with *low* contrast: readable for
hours without the searing whites of high-contrast palettes. The cursor uses the palette's
own blue (`#61afef`) so nothing clashes.

### Window appearance

| Setting                    | Value         | Why                                                |
| -------------------------- | ------------- | -------------------------------------------------- |
| `background-opacity`       | `0.90`        | Subtle transparency — see the desktop, keep text   |
| `background-blur-radius`   | `30`          | Blurs whatever is behind, so text stays legible    |
| `macos-titlebar-style`     | `transparent` | Title bar merges into the terminal background      |
| `window-padding-x/-y`      | `10` / `8`    | Text never touches the window edge                 |
| `window-save-state`        | `always`      | Reopen with the same tabs and splits               |
| `window-theme`             | `auto`        | Window chrome follows system appearance            |
| `macos-non-native-fullscreen` | `visible-menu` | Keeps transparency working in fullscreen (see FAQ) |

The transparency pair is a taste knob: opacity toward `1.0` reads better in direct sunlight;
toward `0.8` shows more desktop. The blur radius (roughly 0–60+) is what keeps blurred
wallpapers from turning text into noise.

`macos-option-as-alt` is left commented for now — whether Option should act as Alt/Meta
gets decided together with tmux keybindings.

### Cursor

Block cursor, blinking, palette blue, 0.9 opacity. Editors override the shape per mode
anyway; this is the shape for everything else.

### Mouse & clipboard

- `copy-on-select = clipboard` — selecting text *is* copying it; `Cmd+C` becomes optional.
- `clipboard-paste-protection = true` — multi-line pastes ask for confirmation first. This
  is a real safety feature: a web page can put a whole `curl | sh` pipeline on your
  clipboard without you knowing.

### Quick terminal

`Ctrl+\`` (global) drops a terminal from the top edge of the current screen, auto-hiding on
focus loss, with a 0.15 s animation — fast enough to feel instant.

### Shell integration

`shell-integration = detect` lets Ghostty inject its helper into zsh automatically
(`no-cursor` keeps Neovim in sole control of cursor shape). Worth learning immediately:
`Cmd+Up` / `Cmd+Down` jump between your previous prompts.

### Keybindings

All explicit, even where they match defaults — a config file should tell the truth about
what the keys do.

### Performance

`scrollback-limit = 25000000` (25 MB) — scroll back through an entire test run without
losing the beginning.

## Key bindings

| Keys                 | Action                          |
| -------------------- | ------------------------------- |
| `Cmd+T` / `Cmd+W`    | New tab / close tab or split    |
| `Cmd+1`…`Cmd+9`      | Jump to tab n                   |
| `Cmd+Shift+←/→`      | Previous / next tab             |
| `Cmd+D`              | Split right                     |
| `Cmd+Shift+D`        | Split down                      |
| `Cmd+Alt+arrows`     | Move between splits             |
| `Cmd+Shift+E`        | Equalize split sizes            |
| `Cmd+Shift+F`        | Zoom (maximize/restore) a split |
| `Cmd+Enter` / `Ctrl+Cmd+F` | Toggle fullscreen (either key) |
| `Cmd+ +`/`-`/`0`     | Font bigger / smaller / reset   |
| `Cmd+Up` / `Cmd+Down`| Jump between shell prompts      |
| `Cmd+Shift+,`        | **Reload this config**          |
| `Ctrl+`` `           | Quick terminal (global)         |

## Tuning & exploring

The two self-service commands that replace most tutorials:

```sh
ghostty +list-themes                   # live-preview every built-in theme
ghostty +show-config --default --docs  # every option, default, and help text
```

Every adjustment follows the same 30-second loop:

1. Edit the file (`~/.config/ghostty/config` — the same file as `config/ghostty/config` in
   the repo).
2. Save.
3. `Cmd+Shift+,` in Ghostty — changes apply instantly.

Common tweaks:

- **More/less transparency:** `background-opacity` (0.0–1.0) and `background-blur-radius`
  (0 ≈ 60+, in pixels).
- **Switch theme:** `ghostty +list-themes`, note a name, put it in `theme = ...`, reload.
  If the new family sticks, update the other tools' palettes too (see
  [workflow.md](workflow.md) decisions) and this doc.
- **Bigger scrollback:** `scrollback-limit` is bytes; 10 MB ≈ 10,000,000.

## FAQ

- **Transparency disappears in fullscreen.** Native macOS fullscreen moves the window to
  its own Space over an opaque system backdrop, so there is nothing to see through —
  `background-opacity` and blur silently stop working. This affects every terminal, not
  just Ghostty. Fix: `macos-non-native-fullscreen` (we ship `visible-menu`) makes
  fullscreen a regular maximized window, where transparency works. Toggle fullscreen with
  `Ctrl+Cmd+F`. If you prefer the native experience (own Space, slide animation), set it
  to `false` and accept an opaque fullscreen.
- **Icons render as boxes □.** The Nerd Font isn't active. Check `font-family` spelling,
  and that `brew bundle install` installed the font; then reload.
- **A config edit does nothing.** Save the file, then press `Cmd+Shift+,`. If Ghostty shows
  a config-error dialog, the message names the exact bad line — fix and reload again.
- **Where did my old config go?** `scripts/install.sh` never deletes: the previous live
  config was moved to `~/.config/ghostty.bak.<timestamp>` before the symlink was created.

## References

This page is the tutorial; the official docs are the depth. Reach for these:

| When you need…                                                     | Where                                                                        |
| ------------------------------------------------------------------ | ---------------------------------------------------------------------------- |
| Anything else about Ghostty                                        | [Docs hub](https://ghostty.org/docs)                                         |
| Any option beyond the ones above, with official help text          | [Option reference](https://ghostty.org/docs/config/reference) — the web version of `+show-config --default --docs` |
| Keybind trigger syntax (`global:`, `performable:`, …) and every action | [Keybind docs](https://ghostty.org/docs/config/keybind)                  |
| What shell integration injects, per shell, and troubleshooting     | [Shell integration](https://ghostty.org/docs/features/shell-integration)     |
| Source code; changelog lives under Releases                        | [ghostty-org/ghostty](https://github.com/ghostty-org/ghostty)                |
