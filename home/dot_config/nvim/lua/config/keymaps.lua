local map = vim.keymap.set

-- Keep search matches centered.
map('n', 'n', 'nzz', { desc = 'Next search match (centered)' })
map('n', 'N', 'Nzz', { desc = 'Previous search match (centered)' })

-- Center the screen after accepting a / or ? search.
map('c', '<CR>', function()
  local t = vim.fn.getcmdtype()
  if t == '/' or t == '?' then
    return '<CR>zz'
  end
  return '<CR>'
end, { expr = true, desc = 'Center after search' })

-- Save
map('n', '<leader>w', '<cmd>w<cr>', { silent = true, desc = 'Save file' })

-- Delete the current buffer without closing its window.
map('n', '<leader>x', '<cmd>Bdelete<cr>', { silent = true, desc = 'Delete buffer' })

-- Reveal whitespace verbosity levels.
map('n', '<leader>vw', '<cmd>ToggleList<cr>', { silent = true, desc = 'Cycle whitespace display' })

-- Toggle the "fancy" in-buffer view for this filetype (markdown/codecompanion
-- render, csv/tsv alignment). Add an entry to extend it to more views.
local fancy_toggle = {
  markdown = function() require('render-markdown').buf_toggle() end,
  codecompanion = function() require('render-markdown').buf_toggle() end,
  csv = function() require('csvview').toggle() end,
  tsv = function() require('csvview').toggle() end,
}
map('n', '<leader>vf', function()
  local ft = vim.bo.filetype
  local fn = fancy_toggle[ft]
  if fn then
    fn()
  else
    vim.notify('No fancy view for filetype: ' .. (ft == '' and '(none)' or ft), vim.log.levels.INFO)
  end
end, { desc = 'Toggle fancy view' })

-- Quickfix
map('n', '<leader>cc', '<cmd>QuickfixToggle<cr>', { silent = true, desc = 'Toggle quickfix' })
map('n', '<leader>co', '<cmd>copen<cr>', { silent = true, desc = 'Open quickfix' })
map('n', '<leader>cl', '<cmd>cclose<cr>', { silent = true, desc = 'Close quickfix' })
map('n', '<leader>cn', '<cmd>cnext<cr>', { silent = true, desc = 'Next quickfix item' })
map('n', '<leader>cp', '<cmd>cprevious<cr>', { silent = true, desc = 'Previous quickfix item' })
map('n', '<leader>cf', '<cmd>cnfile<cr>', { silent = true, desc = 'Next quickfix file' })
map('n', '<leader>cF', '<cmd>cpfile<cr>', { silent = true, desc = 'Previous quickfix file' })
map('n', '<leader>ch', '<cmd>chistory<cr>', { silent = true, desc = 'Quickfix history' })
map('n', '<leader>cs', function() require('fzf-lua').quickfix() end, { silent = true, desc = 'Search quickfix (fzf)' })
