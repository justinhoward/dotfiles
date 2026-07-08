local augroup = function(name)
  return vim.api.nvim_create_augroup('config_' .. name, { clear = true })
end

-- Absolute line numbers in insert mode, relative everywhere else.
vim.api.nvim_create_autocmd('InsertEnter', {
  group = augroup('relnr'),
  callback = function() vim.opt_local.relativenumber = false end,
})
vim.api.nvim_create_autocmd('InsertLeave', {
  group = augroup('relnr'),
  callback = function() vim.opt_local.relativenumber = true end,
})

-- Prose settings for text and markdown.
vim.api.nvim_create_autocmd('FileType', {
  group = augroup('prose'),
  pattern = { 'markdown', 'text' },
  callback = function()
    vim.opt_local.textwidth = 80
    vim.opt_local.spell = true
  end,
})

-- Vendored dependencies are not ours to lint.
vim.api.nvim_create_autocmd('BufEnter', {
  group = augroup('vendored'),
  pattern = { '*/vendor/bundle/*', '*/node_modules/*' },
  callback = function(args)
    vim.diagnostic.enable(false, { bufnr = args.buf })
  end,
})
