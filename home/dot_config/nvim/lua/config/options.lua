-- Leader must be set before lazy.nvim loads.
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

local opt = vim.opt

-- UI
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.colorcolumn = '80'
opt.laststatus = 3
opt.cmdheight = 0
opt.splitkeep = 'screen'
opt.winborder = 'rounded'
opt.shortmess:append('I')

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Indentation: 2-space, expandtab, softtabstop follows shiftwidth.
opt.shiftwidth = 2
opt.softtabstop = -1
opt.expandtab = true
opt.wrap = false

-- Command-line completion
opt.wildmode = 'longest:full,full'

-- Persistent undo (swap/undo/backup live under the XDG state dir by default).
opt.undofile = true

-- Project-local config: auto-source .nvim.lua/.nvimrc/.exrc from the startup cwd,
-- gated by Neovim's built-in trust prompt (persisted to stdpath('state')/trust and
-- re-prompted if the file changes). Replaces the old vim-localvimrc plugin.
opt.exrc = true

-- Tags
opt.tags = '.tags'

-- Folding (nvim-ufo drives fold text; keep folds open by default).
opt.foldcolumn = '1'
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.foldopen = 'block,mark,percent,quickfix,search,tag,undo'
opt.fillchars = { eob = ' ', fold = ' ', foldopen = '\u{f47c}', foldsep = ' ', foldclose = '\u{f460}' }

-- Only wait briefly for terminal key codes so <Esc> is responsive.
opt.ttimeoutlen = 10

-- Built-in Ruby indent tuning.
vim.g.ruby_indent_block_style = 'do'
vim.g.ruby_indent_assignment_style = 'variable'
vim.g.ruby_indent_hanging_elements = 0
