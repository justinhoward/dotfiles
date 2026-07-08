-- Cycle `listchars` through minimal -> normal -> verbose so whitespace can be
-- revealed on demand. Replaces the old toggle-list.vim plugin.
local base = 'trail:-,precedes:«,extends:»'
local list_modes = {
  base .. ',tab:  ',
  base .. ',tab:▸ ,eol:¬',
  base .. ',tab:▸ ,eol:¬,space:·',
}
local list_mode = 0

local function apply_list(mode)
  list_mode = mode
  vim.opt.list = true
  vim.opt.listchars = list_modes[mode + 1]
end

apply_list(0)

vim.api.nvim_create_user_command('ToggleList', function()
  apply_list((list_mode + 1) % #list_modes)
end, { desc = 'Cycle listchars verbosity' })

-- Toggle the quickfix window open/closed. Replaces the old quickfix.vim helper.
vim.api.nvim_create_user_command('QuickfixToggle', function()
  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 and win.loclist == 0 then
      vim.cmd('cclose')
      return
    end
  end
  vim.cmd('copen')
end, { desc = 'Toggle the quickfix window' })
