# arronflow — tool dependencies (macOS).
# Install everything:  brew bundle install
#
# macOS-only: `cask` is a Homebrew-macOS concept. On Linux, scripts/tools.sh
# installs the same stack via distro packages (pacman/apt/dnf) plus official
# GitHub release binaries in ~/.local/bin. Keep in sync with the registry
# (scripts/lib/registry.sh) — see docs/scripts.md.

# Core terminal emulator (the app itself)
cask "ghostty"

# Terminal multiplexer (reads ~/.config/tmux/tmux.conf, tmux >= 3.1)
brew "tmux"

# Editor
brew "neovim"

# Git TUI
brew "lazygit"

# File manager TUI
brew "yazi"

# Terminal font: Nerd Font with CJK glyphs (icons everywhere depend on it)
cask "font-maple-mono-nf-cn"

# --- Companion CLI tools (decided in the shell setup step) ---
brew "zoxide"      # frecency directory jumping (z / zi)
brew "fzf"         # universal fuzzy finder (Ctrl+R / Ctrl+T / Alt+C)
brew "eza"         # ls replacement (aliased as ls / ll)
brew "bat"         # cat replacement (aliased as cat)
brew "ripgrep"     # fast grep — used by its own name (rg)
brew "fd"          # fast find — used by its own name (fd)
brew "fastfetch"   # system info greeting (fast neofetch successor)

# --- Optional yazi preview renderers ---
# brew "ffmpeg"    # video previews
# brew "sevenzip"  # archive previews
# brew "poppler"   # PDF previews
