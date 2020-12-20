let g:coc_global_extensions = [
  \ 'coc-tag',
  \ 'coc-neosnippet',
  \ 'coc-git',
  \ 'coc-emoji',
  \ 'coc-dictionary',
  \ 'coc-tsserver',
  \ 'coc-solargraph',
  \ 'coc-rust-analyzer',
  \ 'coc-json'
  \ ]

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')
