" set key code delay to 10ms
" only wait a very short time for terminal key codes
" these aren't used by modern terminals
" This prevents delays when pressing ESC
set ttimeoutlen=10

" change leader key from \ to space
let mapleader=' '

" change backspace behavior to be more like a typical editor
set backspace=indent,eol,start

" map space-e to open the file explorer
map <leader>e :Explore<cr>
map <leader><S-E> :Rexplore<cr>

" map space-j and space-k to next and previous buffers
map <leader>j :bnext<cr>
map <leader>k :bprevious<cr>

" Map unmapped easymotion commands
map <Plug>(easymotion-prefix)l <Plug>(easymotion-lineforward)
map <Plug>(easymotion-prefix)h <Plug>(easymotion-linebackward)
map <Plug>(easymotion-prefix)/ <Plug>(easymotion-sn)
omap <Plug>(easymotion-prefix)/ <Plug>(easymotion-tn)

" Tagbar
nmap <leader>t :TagbarToggle<cr>

" CtrlP
map <leader>p :CtrlPTag<cr>
