set number
set relativenumber

augroup toggle_rel_lines
    autocmd!
    autocmd InsertEnter * setlocal norelativenumber
    autocmd InsertLeave * setlocal relativenumber
augroup END
