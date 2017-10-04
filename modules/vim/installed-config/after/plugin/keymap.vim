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
nmap <m-l> <Plug>AirlineSelectPrevTab
nmap <m-h> <Plug>AirlineSelectNextTab

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

" Test
nnoremap <leader>tt :TestNearest<cr>
nnoremap <leader>tl :TestLast<cr>
nnoremap <leader>ts :TestSuite<cr>
nnoremap <leader>tf :TestFile<cr>
nnoremap <leader>tg :TestVisit<cr>
