-- Turn on full color support in the terminal
local auto_dark_mode = require('auto-dark-mode')

vim.opt.termguicolors = true

vim.go.sonokai_enable_italic = 1
vim.go.everforest_enable_italic = 1
vim.go.everforest_background = 'hard'

-- set color scheme from colors directory
vim.cmd 'colorscheme sonokai'

if vim.o.background == 'dark' then
  vim.cmd("colorscheme sonokai")
else
  vim.cmd("colorscheme everforest")
end

vim.api.nvim_create_autocmd({"OptionSet"}, {
  pattern = {"background"},
  callback = function(ev)
    if vim.o.background == 'dark' then
      vim.cmd("colorscheme sonokai")
    else
      vim.cmd("colorscheme everforest")
    end

    -- force a full redraw:
    vim.cmd("mode")
  end
})

auto_dark_mode.setup({
	update_interval = 1000,
	set_dark_mode = function()
    vim.o.background = 'dark'
	end,
	set_light_mode = function()
    vim.o.background = 'light'
	end,
})
