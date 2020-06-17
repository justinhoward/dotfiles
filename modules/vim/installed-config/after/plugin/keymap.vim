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
nmap <leader>gg :GitGutterToggle<cr>
nmap <leader>gp :GitGutterPreviewHunk<cr>
nmap <leader>gs :GitGutterStageHunk<cr>
nmap <leader>gu :GitGutterUndoHunk<cr>
" Refresh gutter
nmap <leader>gr :GitGutterAll<cr>
nmap [g <Plug>GitGutterPrevHunk
nmap ]g <Plug>GitGutterNextHunk
omap ig <Plug>GitGutterTextObjectInnerPending
omap ag <Plug>GitGutterTextObjectOuterPending
xmap ig <Plug>GitGutterTextObjectInnerVisual
xmap ag <Plug>GitGutterTextObjectOuterVisual

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

" Markdown Preview
nnoremap <leader>vm :PrevimOpen<cr>

" Quickfix
nnoremap <leader>fo :copen<cr>
nnoremap <leader>fc :cclose<cr>
nnoremap <leader>fn :cnext<cr>
nnoremap <leader>fp :cprevious<cr>
nnoremap <leader>ff :cnfile<cr>
nnoremap <leader>fF :cpfile<cr>

" Find
nnoremap <leader>s :Ack!<c-space>
nnoremap <leader>/ :nohlsearch<cr>

" Language Client
nnoremap <leader>ii :ALEHover<cr>
nnoremap <leader>id :ALEGoToDefinition<cr>
nnoremap <leader>it :ALEGoToTypeDefinition<cr>
nnoremap <leader>ir :ALERename<cr>
nnoremap <leader>if :ALEFindReferences<cr>
nnoremap <leader>ic :ALEDocumentation<cr>

" Asterisk
map *   <Plug>(asterisk-*)
map #   <Plug>(asterisk-#)
map g*  <Plug>(asterisk-g*)
map g#  <Plug>(asterisk-g#)
map z*  <Plug>(asterisk-z*)
map gz* <Plug>(asterisk-gz*)
map z#  <Plug>(asterisk-z#)
map gz# <Plug>(asterisk-gz#)
