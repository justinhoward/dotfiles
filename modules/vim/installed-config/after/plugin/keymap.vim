
" map space-e to open the file explorer
"map <leader>e :Explore<cr>
"map <leader><S-E> :Rexplore<cr>

" map <leader>b then j or k to next and previous buffers
map <leader>bj :bnext<cr>
map <leader>bk :bprevious<cr>

" map <leader> hjkl to move between windows
map <leader>h <C-w><C-h>
map <leader>j <C-w><C-j>
map <leader>k <C-w><C-k>
map <leader>l <C-w><C-l>

" Map unmapped easymotion commands
map <Plug>(easymotion-prefix)l <Plug>(easymotion-lineforward)
map <Plug>(easymotion-prefix)h <Plug>(easymotion-linebackward)
map <Plug>(easymotion-prefix)/ <Plug>(easymotion-sn)
omap <Plug>(easymotion-prefix)/ <Plug>(easymotion-tn)

" Tagbar
nmap <leader>t :TagbarToggle<cr>

" CtrlP
map <leader>pt :CtrlPTag<cr>

" Buffergator
map <leader>bb :BuffergatorToggle<cr>
unmap <leader>tc
unmap <leader>to

" NERD Tree
map <leader>e :NERDTreeToggle<cr>

" UndoTree
map <leader>u :UndotreeToggle<cr>

" Git Gutter
map <leader>g :GitGutterToggle<cr>
