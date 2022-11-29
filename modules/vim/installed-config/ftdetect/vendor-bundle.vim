augroup VendoredFiles
  autocmd!
  autocmd BufEnter vendor/bundle/*,node_modules/* lua vim.diagnostic.disable(0)
augroup end
