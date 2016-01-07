" map <leader> hjkl to move between windows
map <leader>h <C-w><C-h>
map <leader>j <C-w><C-j>
map <leader>k <C-w><C-k>
map <leader>l <C-w><C-l>
map <leader>q <C-w><C-c>

" Buffergator
map <leader>b :BuffergatorToggle<cr>
unmap <leader>tc
unmap <leader>to

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

" Save file
map <leader>w :w<cr>

" FZF
map <leader>p :FZF<cr>
