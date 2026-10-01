-- Teaching spec file — everything here is commented out on purpose.
--
-- Every *.lua file under lua/plugins/ must return a TABLE of plugin specs;
-- lazy.nvim merges all of them with LazyVim's own specs. An empty table
-- means "no changes to the distribution" — which is our current policy:
-- stock LazyVim, zero extras, zero additions.
return {}

-- ---------------------------------------------------------------------
-- Recipe card: the four edits you will actually make some day.
-- Uncomment, adapt, restart nvim (or run :Lazy reload). Re-comment to
-- revert. Nothing here is active right now.
-- ---------------------------------------------------------------------

-- 1. ADD a plugin (this is all a spec needs — opts/keys/events optional):
-- return {
--   { "ellisonleao/gruvbox.nvim" },
-- }

-- 2. DISABLE a default you do not want (find names via :Lazy):
-- return {
--   { "folke/noice.nvim", enabled = false },
-- }

-- 3. CHANGE the distribution's own options — the future theme pass will
--    need exactly this (after adding a colorscheme plugin as in #1):
-- return {
--   { "LazyVim/LazyVim", opts = { colorscheme = "onedark" } },
-- }

-- 4. ADD an LSP server — mason then installs the external binary for you:
-- return {
--   { "neovim/nvim-lspconfig", opts = { servers = { pyright = {} } } },
-- }
--
-- Prefer whole feature packs over hand-picking? Browse :LazyExtras —
-- enabling an extra there writes lazyvim.json, not this file.
