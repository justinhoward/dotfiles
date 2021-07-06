set foldmethod=manual
set foldexpr=nvim_treesitter#foldexpr()
set foldenable
" Default plus jump
set foldopen=block,hor,mark,percent,quickfix,search,tag,undo,jump

" Folding
function! s:toggle_fold_method()
  if &foldmethod ==# 'manual'
    setlocal foldmethod=expr
    setlocal foldcolumn=1
  else
    setlocal foldmethod=manual
    setlocal foldcolumn=0
    normal! zE
  endif
endfunction

command! FoldToggle call <SID>toggle_fold_method()<cr>
