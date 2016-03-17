" map <leader> hjkl to move between windows
map <leader>h <C-w><C-h>
map <leader>j <C-w><C-j>
map <leader>k <C-w><C-k>
map <leader>l <C-w><C-l>
map <leader>q <C-w><C-c>
map <leader>x :bdelete<cr>

" Buffergator
map <leader>b :BuffergatorToggle<cr>
unmap <leader>t
unmap <leader>tc
unmap <leader>to

" NERD Tree
map <leader>e :NERDTreeToggle<cr>
map <leader>E :NERDTreeFind<cr>

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
map <leader>t :FZFTags<cr>

" Airline
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9
nmap <leader>- <Plug>AirlineSelectPrevTab
nmap <leader>= <Plug>AirlineSelectNextTab

" Easymotion

map <Plug>(easymotion-prefix)/ <Plug>(easymotion-sn)
omap <Plug>(easymotion-prefix)/ <Plug>(easymotion-tn)
