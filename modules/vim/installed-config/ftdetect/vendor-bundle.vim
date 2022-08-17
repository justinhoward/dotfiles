augroup VendorBundle
  autocmd!
  autocmd BufEnter vendor/bundle/* lua vim.diagnostic.disable(0)
augroup end
