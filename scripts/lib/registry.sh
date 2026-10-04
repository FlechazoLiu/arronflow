# The arronflow tool registry — the single source of truth every script
# reads: tool installation (tools.sh), config deployment + gating
# (install.sh), and the health report (doctor.sh).
#
# Sourced AFTER lib/common.sh (uses die). One record per line, fields
# separated by "|", sub-lists by ",". Bash 3.2 safe.
#
# Field reference (REG_FIELDS):
#   name     registry key / CLI selector, e.g. `install.sh tmux`
#   display  human name for menus and doctor output
#   bins     binaries that must exist (comma list; FIRST is version-checked;
#            yazi needs "yazi,ya")
#   vflag    flag that prints the version ("--version", tmux "-V",
#            ghostty "+version")
#   min      minimum version, "" = presence check only
#   brew     Homebrew spec, comma list, "cask:NAME" for casks
#   pacman   Arch packages (comma list; "" = none in official repos)
#   apt      Debian packages as pkg[:real-binary] — the optional suffix is
#            the Debian binary name when it differs (bat:batcat,
#            fd-find:fdfind); tools.sh links it under the plain name
#   dnf      Fedora packages
#   gh       GitHub release fallback "repo:x86_64-asset:aarch64-asset:bins";
#            "{ver}" in an asset = tag minus leading "v"; "" = no fallback.
#            Used when the distro field for the current platform is empty
#            (Ubuntu has no lazygit/yazi/eza/... and ships a Neovim older
#            than LazyVim's >= 0.11 requirement, so nvim has no apt/dnf
#            fields by design)
#   cfg      config pairs "src::target", comma list; "" = companion tool
#            with no config in this repo
#   docs     page in docs/ for hints
#   post     post-install hook token: "omz" (Oh My Zsh clones), "font"
#            (Maple Mono NF CN via GitHub release on Linux)
#
# Adding a tool = one record below + (if it has a config) one config/
# directory + one docs/ page. The annotated tmux record:
#   "tmux|tmux|tmux|-V|3.1|tmux|tmux|tmux|tmux||config/tmux::$HOME/.config/tmux|docs/tmux.md|"
#    │    │     │     │  │   │    │     │   │   │  └ config/tmux → ~/.config/tmux
#    │    │     │     │  │   │    │     │   │   └ no GitHub fallback needed
#    │    │     │     │  │   │    │     │   └ dnf: tmux
#    │    │     │     │  │   │    │     └ apt: tmux
#    │    │     │     │  │   │    └ pacman: tmux
#    │    │     │     │  │   └ brew: tmux
#    │    │     │     │  └ minimum version 3.1
#    │    │     │     └ `tmux -V` prints the version
#    │    │     └ binary to check: tmux
#    │    └ display name
#    └ registry key

REG_FIELDS=(name display bins vflag min brew pacman apt dnf gh cfg docs post)

# lazygit reads its config from a platform-specific directory.
if [[ "$(uname -s)" == "Darwin" ]]; then
  LAZYGIT_DST="$HOME/Library/Application Support/lazygit"
else
  LAZYGIT_DST="$HOME/.config/lazygit"
fi

REGISTRY=(
  # name     |display        |bins       |vflag     |min  |brew|pacman|apt|dnf|gh|cfg|docs|post
  "git|Git|git|--version||git|git|git|git|||||"
  "zsh|zsh + Oh My Zsh|zsh|--version||zsh|zsh|zsh|zsh||config/zsh/zshrc::$HOME/.zshrc,config/zsh/p10k.zsh::$HOME/.p10k.zsh|docs/shell.md|omz"
  "tmux|tmux|tmux|-V|3.1|tmux|tmux|tmux|tmux||config/tmux::$HOME/.config/tmux|docs/tmux.md|"
  "nvim|Neovim (LazyVim)|nvim|--version|0.11|neovim|neovim|||neovim/neovim:nvim-linux-x86_64.tar.gz:nvim-linux-arm64.tar.gz:nvim|config/nvim::$HOME/.config/nvim|docs/lazyvim.md|"
  "ghostty|Ghostty|ghostty|+version||cask:ghostty,cask:font-maple-mono-nf-cn|ghostty|ghostty|ghostty||config/ghostty::$HOME/.config/ghostty|docs/ghostty.md|font"
  "lazygit|lazygit|lazygit|--version||lazygit|lazygit|||jesseduffield/lazygit:lazygit_{ver}_linux_x86_64.tar.gz:lazygit_{ver}_linux_arm64.tar.gz:lazygit|config/lazygit::$LAZYGIT_DST|docs/lazygit.md|"
  "yazi|yazi|yazi,ya|--version||yazi|yazi|||sxyazi/yazi:yazi-x86_64-unknown-linux-gnu.zip:yazi-aarch64-unknown-linux-gnu.zip:yazi,ya|config/yazi::$HOME/.config/yazi|docs/yazi.md|"
  "fastfetch|fastfetch|fastfetch|--version||fastfetch|fastfetch|||fastfetch-cli/fastfetch:fastfetch-linux-amd64.tar.gz:fastfetch-linux-aarch64-polyfilled.tar.gz:fastfetch|config/fastfetch::$HOME/.config/fastfetch|docs/shell.md|"
  "gum|gum (UI)|gum|--version||gum|gum||gum|charmbracelet/gum:gum_{ver}_Linux_x86_64.tar.gz:gum_{ver}_Linux_arm64.tar.gz:gum||||"
  "fzf|fzf|fzf|--version||fzf|fzf|fzf|fzf|||||"
  "zoxide|zoxide|zoxide|--version||zoxide|zoxide|||ajeetdsouza/zoxide:zoxide-{ver}-x86_64-unknown-linux-musl.tar.gz:zoxide-{ver}-aarch64-unknown-linux-musl.tar.gz:zoxide||||"
  "eza|eza|eza|--version||eza|eza|||eza-community/eza:eza_x86_64-unknown-linux-gnu.tar.gz:eza_aarch64-unknown-linux-gnu.tar.gz:eza||||"
  "bat|bat|bat|--version||bat|bat|bat:batcat|bat|||||"
  "ripgrep|ripgrep|rg|--version||ripgrep|ripgrep|ripgrep|ripgrep|||||"
  "fd|fd|fd|--version||fd|fd|fd-find:fdfind|fd-find|||||"
)

# --- Accessors ---------------------------------------------------------------

reg_names() { # every registry key, one per line (order = install/menu order)
  local line
  for line in "${REGISTRY[@]}"; do
    printf '%s\n' "${line%%|*}"
  done
  return 0
}

reg_has() { # reg_has <tool> — exit 0 when known (call inside if/||)
  local tool="$1" line
  for line in "${REGISTRY[@]}"; do
    if [[ "${line%%|*}" == "$tool" ]]; then return 0; fi
  done
  return 1
}

reg_field() { # reg_field <tool> <field> — prints the value; dies if unknown
  local tool="$1" field="$2" idx=-1 i line
  for i in "${!REG_FIELDS[@]}"; do
    if [[ "${REG_FIELDS[$i]}" == "$field" ]]; then idx=$i; fi
  done
  if [[ $idx -lt 0 ]]; then die "unknown registry field: $field"; fi
  for line in "${REGISTRY[@]}"; do
    local -a f=()
    IFS='|' read -r -a f <<<"$line"
    if [[ "${f[0]}" == "$tool" ]]; then
      printf '%s\n' "${f[$idx]:-}"
      return 0
    fi
  done
  die "unknown tool: $tool (see scripts/lib/registry.sh)"
}

config_pairs_for() { # config_pairs_for <tool> — "src<TAB>target" lines
  # Split on commas with IFS=read (NOT word splitting): targets may contain
  # spaces ("~/Library/Application Support/lazygit").
  local tool="$1" cfg pair src dst
  cfg=$(reg_field "$tool" cfg)
  if [[ -z $cfg ]]; then return 0; fi
  local -a pairs
  IFS=',' read -r -a pairs <<<"$cfg"
  for pair in "${pairs[@]}"; do
    src="${pair%%::*}"
    dst="${pair#*::}"
    printf '%s\t%s\n' "$src" "$dst"
  done
  return 0
}
