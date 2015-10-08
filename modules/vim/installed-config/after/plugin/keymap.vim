
" map space-e to open the file explorer
"map <leader>e :Explore<cr>
"map <leader><S-E> :Rexplore<cr>

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

" Buffergator
map <leader>b :BuffergatorToggle<cr>
unmap <leader>tc
unmap <leader>to

" NERD Tree
map <leader>e :NERDTreeToggle<cr>
