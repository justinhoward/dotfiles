" map <leader> hjkl to move between windows
nnoremap <leader>h <C-w><C-h>
nnoremap <leader>j <C-w><C-j>
nnoremap <leader>k <C-w><C-k>
nnoremap <leader>l <C-w><C-l>
nnoremap <leader>x :bdelete<cr>

" NERD Tree
nnoremap <leader>e :NERDTreeToggle<cr>
nnoremap <leader>E :NERDTreeFind<cr>

" UndoTree
nnoremap <leader>u :UndotreeToggle<cr>

" Git Gutter
nnoremap <leader>gg :GitGutterToggle<cr>
nnoremap <leader>gp :GitGutterPreviewHunk<cr>
nnoremap <leader>gr :GitGutterUndoHunk<cr>
nnoremap <leader>gs :GitGutterStageHunk<cr>
nnoremap <leader>gu :GitGutterUndoHunk<cr>
unmap <leader>hp
unmap <leader>hr
unmap <leader>hs
unmap <leader>hu

" Save file
nnoremap <leader>w :w<cr>

" FZF
nnoremap <leader>p :FZF<cr>
nnoremap <leader>] :FZFTags<cr>
nnoremap <leader>y :FZFNeoyank<cr>
nnoremap <leader>Y :FZFNeoyank " P<cr>
vnoremap <leader>y :FZFNeoyankSelection<cr>

" Lightline
nmap <Leader>1 <Plug>lightline#bufferline#go(1)
nmap <Leader>2 <Plug>lightline#bufferline#go(2)
nmap <Leader>3 <Plug>lightline#bufferline#go(3)
nmap <Leader>4 <Plug>lightline#bufferline#go(4)
nmap <Leader>5 <Plug>lightline#bufferline#go(5)
nmap <Leader>6 <Plug>lightline#bufferline#go(6)
nmap <Leader>7 <Plug>lightline#bufferline#go(7)
nmap <Leader>8 <Plug>lightline#bufferline#go(8)
nmap <Leader>9 <Plug>lightline#bufferline#go(9)
nmap <Leader>0 <Plug>lightline#bufferline#go(10)

" Neosnippet
imap <C-j> <Plug>(neosnippet_expand_or_jump)
smap <C-j> <Plug>(neosnippet_expand_or_jump)
xmap <C-j> <Plug>(neosnippet_expand_target)

" Indent Guides
unmap <leader>ig
nnoremap <leader>vi :IndentGuidesToggle<cr>

" Whitespace
nnoremap <leader>vw :ToggleList<cr>

" Instant Markdown
nnoremap <leader>vm :InstantMarkdownPreview<cr>

" Quickfix
nnoremap <leader>fo :copen<cr>
nnoremap <leader>fc :cclose<cr>
nnoremap <leader>fn :cnext<cr>
nnoremap <leader>fp :cprevious<cr>
nnoremap <leader>ff :cnfile<cr>
nnoremap <leader>fF :cpfile<cr>

" Find
nnoremap <leader>s :Ack!<c-space>
