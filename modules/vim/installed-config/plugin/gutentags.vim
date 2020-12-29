let g:gutentags_ctags_tagfile='.tags'

" Don't regenerate the whole tags file when reopening vim
let g:gutentags_generate_on_new=0

au FileType gitcommit,gitrebase let g:gutentags_enabled=0
