# Vim Foundations

## Status

**Stage 1 of 3 — documented, intentionally unconfigured.** This page uses
the Vim already included with macOS to teach modal editing and Vim's
editing language. This repository does not manage a `.vimrc`, install Vim
plugins, or deploy a Vim configuration.

The editor curriculum is deliberately staged:

1. **Vim** — learn modes, motions, operators, text objects, and repetition.
2. **Neovim** — understand what Neovim changes and why its ecosystem exists.
3. **LazyVim** — configure and deploy the actual daily editor.

The commands learned here transfer directly to Neovim and LazyVim. Practical
editor configuration starts only in the LazyVim stage.

## Role

Vim is both an editor and an editing language. In this stack it is the
zero-configuration classroom for that language, not the final daily editor.
Learning it first separates durable concepts — modes, motions, operators,
text objects, and repeatable changes — from the plugins and interface that
LazyVim will add later. The same foundation also remains useful on remote or
recovery machines where only a basic terminal editor is available.

## Background

### Editing is not the same as typing

Most editors assume that almost every key inserts a character. Vim does not.
It treats **typing text** and **describing an edit** as different activities.
You enter Insert mode to type, then return to Normal mode to navigate and
express the next edit.

This is the first habit to build:

> Insert mode is a temporary action. Normal mode is the control center.

Vim starts in Normal mode. If the current mode is ever unclear, press
`Esc`. Pressing it more than once is harmless.

### The modes

| Mode | Purpose | Enter it | Leave it |
| --- | --- | --- | --- |
| Normal | navigate and compose editing commands | Vim starts here; or press `Esc` | choose another mode |
| Insert | type text | `i`, `a`, `o`, or `O` | `Esc` |
| Visual | select text, then operate on it | `v`, `V`, or `C-v` | `Esc` |
| Command-line | run an Ex command such as write or quit | `:` | `Enter` runs it; `Esc` cancels |
| Operator-pending | wait for the range of an operation | press `d`, `c`, or `y` in Normal mode | complete a motion/text object, or press `Esc` |

Operator-pending mode is brief but important. After `d`, Vim has not deleted
anything yet. It is asking, "delete **what**?" A following `w`, `$`, `iw`, or
other range answers that question.

### Reading Vim key notation

- `Esc` means the Escape key.
- `C-r` means hold Control and press `r`.
- `Enter` means Return.
- `dw` means press `d`, release it, then press `w` — not both together.
- Case matters: `i` and `I`, or `p` and `P`, are different commands.
- A command such as `f{char}` means press `f`, then the character to find.

### The editing grammar

Normal-mode commands form a small language rather than a flat list of
shortcuts:

```text
[count] operator [count] motion
[count] operator text-object
```

Think of operators as verbs and motions or text objects as their ranges:

| Part | Examples | Meaning |
| --- | --- | --- |
| Operator | `d`, `c`, `y` | delete, change, yank (copy) |
| Motion | `w`, `b`, `$`, `}` | next word, previous word, line end, next paragraph |
| Text object | `iw`, `aw`, `i"`, `a(` | inner/around word, quotes, parentheses |
| Count | `2`, `3`, `5` | repeat or enlarge the range |

The pieces compose:

- `dw` — delete to the next word boundary.
- `ciw` — change the word under the cursor, regardless of cursor position
  within it.
- `di"` — delete inside the surrounding double quotes but keep the quotes.
- `2dd` — delete two lines.
- `yip` — yank the paragraph contents.

This grammar is more valuable than memorizing hundreds of isolated commands.
Once one operator and one new motion are known, their combination is already
known too.

### File, buffer, window, and tab page

These names are easy to confuse:

- A **file** is data stored on disk.
- A **buffer** is Vim's in-memory copy of a file. Editing changes the buffer;
  `:w` writes it back to disk.
- A **window** is a viewport onto a buffer. Two windows can show different
  buffers, or two locations in the same buffer.
- A **tab page** is a collection of windows — a workspace layout, not simply
  one file.

For the first lesson, one buffer in one window is enough. The distinction
mainly explains why Vim can refuse `:q`: the buffer contains changes that
have not been written yet.

### Registers and the clipboard

Yanked or deleted text goes into Vim **registers**. Plain `p` pastes from the
unnamed register, so the basic workflow needs no register name. The `0`
register preserves the most recent yank, while named registers such as `"a`
can hold text deliberately.

The system clipboard is a separate register, written as `"+`. For example,
`"+y` yanks a selected range to it and `"+p` pastes from it. Clipboard
support depends on how Vim was built; `:version` shows whether `+clipboard`
is available. Advanced register management is deliberately postponed until
there is a real need for it.

### Ex commands

A leading `:` opens Vim's command line. These commands often act on files,
buffers, windows, or ranges rather than on one character under the cursor:

```vim
:w                 " write the current buffer
:q                 " close the current window
:%s/old/new/gc     " replace in the whole buffer, asking for confirmation
```

The `"` comments above explain the examples; do not type the comments.

## Why Vim

- **vs nano** — nano is easier for one urgent edit; Vim provides a
  composable editing language that scales to daily work.
- **vs a GUI editor** — a GUI makes selection and clicking immediately
  familiar; Vim makes ranges, intent, and repetition explicit.
- **vs starting directly with LazyVim** — native Vim has no leader-key menus,
  plugin pop-ups, or IDE features to hide which behavior belongs to Vim
  itself.
- **vs configuring Vim first** — a clean session exposes portable defaults.
  We can later judge LazyVim additions against a foundation we understand.

Vim's default interface is not the final goal here. It is the clearest place
to learn concepts that will survive every later configuration.

## Installation

No installation is required for this stage. macOS already provides Vim and
Vim Tutor. Inspect what the current machine has:

```sh
command -v vim
vim --version
command -v vimtutor
```

Start the guided lesson:

```sh
vimtutor
```

Or open a disposable practice file in a clean session:

```sh
vim --clean /tmp/arronflow-vim-practice.txt
```

`--clean` ignores user configuration and plugins for that launch. The file in
`/tmp` is temporary learning material, not repository state. Do not run
`brew install vim` for this stage; the point is to learn the native language,
not to introduce another managed editor.

## Our configuration

There is intentionally **no Vim configuration** in arronflow:

- no `.vimrc` or `config/vim/`;
- no Vim entry in the `Brewfile` or `scripts/install.sh`;
- no plugin manager, mappings, or persistent options;
- no symlink to deploy.

`vim --clean` is a launch option, not a configuration. The practice file in
`/tmp` is not tracked or deployed either.

This stage practices native commands: modes, motions, operators, text
objects, search, undo, repeat, and safe file handling. Leader keys, plugins,
LSP, completion, formatting, fuzzy finding, git signs, themes, and permanent
keymaps belong to the LazyVim stage.

## Key bindings

Learn these in order. The goal is not to memorize every row in one sitting;
it is to understand which category answers the current editing intent.

### 1. Safety first

| Intent | Keys | Notes |
| --- | --- | --- |
| return to Normal mode / cancel | `Esc` | the universal first response when unsure |
| undo | `u` | undo the latest change |
| redo | `C-r` | redo an undone change |
| write the buffer | `:w` `Enter` | save without exiting |
| quit | `:q` `Enter` | refuses if unsaved changes would be lost |
| write and quit | `:wq` `Enter` | save, then close the window |
| discard changes and quit | `:q!` `Enter` | intentionally loses unsaved changes |

A useful recovery sequence is: `Esc`, decide whether the changes matter,
then use `:wq` or `:q!`.

### 2. Move between Normal and Insert mode

| Intent | Keys |
| --- | --- |
| insert before cursor | `i` |
| insert at start of line | `I` |
| append after cursor | `a` |
| append at end of line | `A` |
| open a line below / above | `o` / `O` |
| replace one character | `r{char}` |
| return to Normal mode | `Esc` |

Prefer choosing the insertion point in Normal mode, inserting a short piece
of text, then returning to Normal mode.

### 3. Move by meaning

| Intent | Keys |
| --- | --- |
| left / down / up / right | `h` / `j` / `k` / `l` |
| next word start / previous word start / word end | `w` / `b` / `e` |
| line start / first non-blank / line end | `0` / `^` / `$` |
| first / last line | `gg` / `G` |
| next / previous paragraph | `}` / `{` |
| matching bracket | `%` |
| find character forward on this line | `f{char}` |
| repeat / reverse the latest `f` or `t` search | `;` / `,` |
| go to line number | `{count}G` — for example `20G` |

Counts work with motions: `3w` moves three words and `5j` moves five lines.
Arrow keys remain a valid recovery tool; the learning goal is richer motions,
not punishment for using arrows.

### 4. Operate on a range

| Operator | Meaning | Line form |
| --- | --- | --- |
| `d` | delete and save the text in a register | `dd` |
| `c` | delete the range, then enter Insert mode | `cc` |
| `y` | yank (copy) | `yy` |
| `>` / `<` | indent / unindent | `>>` / `<<` |

Add a motion to provide the range:

| Command | Result |
| --- | --- |
| `dw` | delete to the next word boundary |
| `d$` or `D` | delete to line end |
| `cw` | change through the current word boundary |
| `c$` or `C` | change to line end |
| `y}` | yank to the next paragraph |
| `3dd` | delete three lines |
| `x` | delete one character (a complete command, not an operator) |

### 5. Use text objects

Text objects describe semantic regions. `i` means **inside**; `a` includes the
surrounding delimiters or whitespace.

| Object | Inner | Around |
| --- | --- | --- |
| word | `iw` | `aw` |
| double quotes | `i"` | `a"` |
| single quotes | `i'` | `a'` |
| parentheses | `i(` | `a(` |
| brackets | `i[` | `a[` |
| paragraph | `ip` | `ap` |

Combine them with an operator:

- `ciw` — replace the current word.
- `di"` — clear quoted content, keeping the quotes.
- `ca(` — replace the parenthesized expression, including parentheses.
- `yap` — copy a paragraph including its surrounding blank line.

A text object normally follows an operator or is used in Visual mode; it is
not a standalone movement command.

### 6. Yank, paste, and registers

| Intent | Keys |
| --- | --- |
| yank line | `yy` |
| yank a range | `y{motion}` or `y{text-object}` |
| paste after / before cursor | `p` / `P` |
| paste latest yank rather than latest deletion | `"0p` |
| use named register `a` | `"ay{range}` then `"ap` |
| use system clipboard | `"+y{range}` / `"+p` |

A deletion also updates the unnamed register. If `p` unexpectedly pastes
something just deleted, `"0p` retrieves the latest yank instead.

### 7. Search, replace, and repeat

| Intent | Keys |
| --- | --- |
| search forward / backward | `/pattern` / `?pattern`, then `Enter` |
| next / previous match | `n` / `N` |
| search word under cursor forward / backward | `*` / `#` |
| repeat latest change | `.` |
| repeat latest Ex command | `@:` |
| replace all matches, confirming each | `:%s/old/new/gc` |

The dot command is central to Vim fluency: make one change precisely, move to
the next target, then press `.` instead of rebuilding the command.

### 8. Visual selection

| Mode | Keys | Range |
| --- | --- | --- |
| characterwise Visual | `v` | characters |
| linewise Visual | `V` | whole lines |
| blockwise Visual | `C-v` | rectangle/columns |

Move to extend the selection, then apply an operator such as `d`, `y`, `c`,
`>`, or `<`. Visual mode is useful when the range is easier to see than to
describe, but operator + motion/text object is often faster and easier to
repeat.

### 9. Files, buffers, windows, and tab pages

These are orientation commands, not a list to memorize immediately:

| Intent | Command |
| --- | --- |
| edit a file | `:edit path` |
| list buffers | `:ls` |
| open a listed buffer | `:buffer {number-or-name}` |
| next / previous buffer | `:bnext` / `:bprevious` |
| horizontal / vertical split | `:split` / `:vsplit` |
| move between windows | `C-w h/j/k/l` |
| close the current window | `:close` |
| new tab page | `:tabnew` |
| next / previous tab page | `gt` / `gT` |

Do not equate a tab page with a file. A tab page holds a window layout; each
window displays a buffer.

### 10. Ask Vim itself

| Intent | Command |
| --- | --- |
| open help | `:help` |
| look up a topic | `:help {topic}` |
| open the user manual | `:help user-manual` |
| learn motions / operators / text objects | `:help motion.txt`, `:help operator`, `:help text-objects` |
| jump to a help link / jump back | `C-]` / `C-t` |
| close help | `:helpclose` |

Vim's local help matches the installed version and is the authority for exact
behavior.

## Tuning & exploring

There is no configuration to tune yet. Tune the **learning loop** instead:

1. name the edit in plain language;
2. choose an operator;
3. choose a motion or text object for its range;
4. run it once;
5. use `u` if the range was wrong, or `.` to repeat if it was right.

### First practice loop

Run `vimtutor` once from beginning to end. Do not try to memorize every
command. Then open the temporary practice file:

```sh
vim --clean /tmp/arronflow-vim-practice.txt
```

Inside Vim:

1. use `i` or `o` to enter a few lines, then press `Esc`;
2. navigate with `w`, `b`, `0`, `$`, `gg`, and `G`;
3. try `dw`, `ciw`, and `2dd`, undoing with `u` after each;
4. put quoted or parenthesized text in a line and try `ci"` or `di(`;
5. search with `/`, move through matches with `n`, and repeat a change with
   `.`;
6. finish with `:wq`, or intentionally discard the exercise with `:q!`.

### When Stage 1 is complete

Move to the Neovim lesson when you can:

- explain the jobs of Normal, Insert, Visual, and Command-line modes;
- recover from uncertainty with `Esc` and safely save or quit;
- navigate by words and line structure, not only one character at a time;
- explain operator + motion/text object;
- use combinations such as `ciw` and `di"` without treating them as magic;
- undo, redo, search, and repeat a change with `.`;
- complete a short edit in `vim --clean` without changing a configuration.

### FAQ

**I am typing commands, but letters appear in the file.**

You are in Insert mode. Press `Esc`, then issue the Normal-mode command.

**Vim says `No write since last change`.**

The buffer differs from the file on disk. Use `:wq` to keep the changes or
`:q!` to discard them.

**I made a destructive change.**

Press `u`. Use `C-r` if you undo too far.

**Why did `p` paste text I deleted instead of text I copied?**

Deletes also update the unnamed register. Try `"0p` for the latest yank.

**Why does the system clipboard command not work on another server?**

That Vim build may lack `+clipboard`, or the remote terminal path may not
expose the local clipboard. Check `:version`. Plain `y` and `p` still work
inside Vim everywhere.

**Should I create a `.vimrc` to make this easier?**

Not in this curriculum. First learn what native Vim does. Persistent editor
choices will be made once, in the LazyVim configuration.

**Are registers, macros, marks, and mappings missing?**

They are deferred, not forgotten. They become useful after the basic editing
grammar is automatic and can be introduced in the context of the final
editor.

## References

- Run `:help user-manual` inside Vim — the version-matched user manual and
  the best next step after `vimtutor`.
- Run `:help tutor` or `vimtutor` — Vim's built-in guided introduction for
  practicing safely.
- [Vim documentation](https://www.vim.org/docs.php) — the official
  documentation hub; use it to find the user manual, reference help, and
  current online help.
- [Vim source repository](https://github.com/vim/vim) — the official source,
  release history, and canonical runtime documentation when implementation
  details matter.
- [Vim runtime help](https://github.com/vim/vim/tree/master/runtime/doc) —
  the source files behind `:help`; use them when local Vim is unavailable.
