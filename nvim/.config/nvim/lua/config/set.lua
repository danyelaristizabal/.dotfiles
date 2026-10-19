-- absolute and relative numbers
vim.opt.nu = true -- show absolute line numbers
vim.opt.relativenumber = true -- show relative line numbers (distance from current line)

-- keep taps consistent
vim.opt.tabstop = 4 -- a tab character displays as 4 spaces wide
vim.opt.softtabstop = 4 -- pressing Tab inserts 4 spaces
vim.opt.shiftwidth = 4 -- indentation width for >>, <<, and autoindent
vim.opt.expandtab = true -- convert tabs to spaces on insert

vim.opt.smartindent = true -- auto-indent new lines based on syntax

-- useful wrapping
vim.opt.wrap = true -- wrap long lines visually (does not modify the buffer)

-- Neovim by default creates .swp and ~ backup files alongside your actual files as crash recovery. Most people disable them
--  because:
--  - They clutter your directories and show up in git status
--  - Modern version control (git) already handles recovery better
--  - They cause false "file already open" warnings when reopening after a crash

vim.opt.swapfile = false -- disable swap files
vim.opt.backup = false -- disable backup files

-- This is the replacement for swap/backup. Instead of per-file swap files, Neovim stores your undo history in a central
-- directory (~/.vim/undodir).
--
-- The key benefit: undo persists across sessions. Close a file, reopen it tomorrow, and you can still u to undo changes you
-- made yesterday. Without this, undo history is lost the moment you close the buffer.
--
-- The combination — disabling swap/backup but enabling persistent undo — is a cleaner approach to the same goal of not
-- losing work.

vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir" -- directory for persistent undo history
vim.opt.undofile = true -- enable persistent undo across sessions

vim.opt.termguicolors = true -- enable 24-bit RGB colors in the terminal

-- highlighting preferences
vim.opt.hlsearch = false -- do not highlight all search matches
vim.opt.incsearch = true -- highlight matches incrementally as you type

-- useful for better scrolling
vim.opt.scrolloff = 8 -- keep 8 lines visible above/below cursor when scrolling

-- ⏺ The sign column is the narrow gutter to the left of line numbers. Plugins use it to place small icons/symbols on lines,
--   for example:
--
--   - Git signs (gitsigns.nvim) — shows +, ~, - to indicate added, changed, or removed lines
--   - Diagnostics — shows error/warning icons from the LSP
--   - Debugger — shows breakpoint markers (which you have set up with DAP)
--
--   Setting it to "yes" means it's always visible even when there are no signs. The alternative is "auto", which makes it
--   appear and disappear as signs come and go — that causes the text to shift left/right which can be jarring while editing.
-- vim.opt.signcolumn = "yes" -- always show sign column (git signs, diagnostics, etc.)
--

-- allow @filename
vim.opt.isfname:append("@-@") -- treat @ as a valid filename character (e.g. for @scope/package paths)

-- speed for cursor hold, used for diagnostics
vim.opt.updatetime = 50 -- ms before CursorHold fires (affects diagnostic and git sign refresh speed)
