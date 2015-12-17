
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
map <leader>q <C-w><C-c>

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
unmap <leader>b

" NERD Tree
map <leader>e :NERDTreeToggle<cr>

" UndoTree
map <leader>u :UndotreeToggle<cr>

" Git Gutter
map <leader>gg :GitGutterToggle<cr>
map <leader>gp :GitGutterPreviewHunk<cr>
map <leader>gr :GitGutterRevertHunk<cr>
map <leader>gs :GitGutterStageHunk<cr>
unmap <leader>hp
unmap <leader>hr
unmap <leader>hs

" Text wrapping
map <leader>w :set wrap!<cr>

" Toggle list
map <leader>s :ToggleList<cr>

" FZF
map <leader>pp :FZF<cr>
