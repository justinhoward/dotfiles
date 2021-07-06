" Move between windows with alt hjkl from any mode
tnoremap <A-h> <C-\><C-N><C-w>h
tnoremap <A-j> <C-\><C-N><C-w>j
tnoremap <A-k> <C-\><C-N><C-w>k
tnoremap <A-l> <C-\><C-N><C-w>l
inoremap <A-h> <C-\><C-N><C-w>h
inoremap <A-j> <C-\><C-N><C-w>j
inoremap <A-k> <C-\><C-N><C-w>k
inoremap <A-l> <C-\><C-N><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

" Delete current buffer normally (removes splits)
nnoremap <A-x> :bdelete<cr>

" Delete current buffer with bbye
nnoremap <leader>x :Bdelete<cr>

" Nvim Tree
nnoremap <leader>e :NvimTreeToggle<cr>
nnoremap <leader>E :NvimTreeFindFile<cr>

" UndoTree
nnoremap <leader>u :UndotreeToggle<cr>

" Tagbar
nnoremap <leader>t :TagbarToggle<cr>

" Save file
nnoremap <leader>w :w<cr>

" FZF
nnoremap <leader>p :GFiles<cr>
nnoremap <leader>P :Files<cr>
nnoremap <leader>] :Tags<cr>
nnoremap <leader>} :BTags<cr>
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
imap <expr> <C-j>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
smap <expr> <C-j>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

" Indent Guides
unmap <leader>ig
nnoremap <leader>vi :IndentGuidesToggle<cr>

" Whitespace
nnoremap <leader>vw :ToggleList<cr>

" Markdown Preview
nnoremap <leader>vm :PrevimOpen<cr>

" Quickfix
nnoremap <silent> <leader>cc :QuickfixToggle<cr>
nnoremap <leader>co :copen<cr>
nnoremap <leader>cl :cclose<cr>
nnoremap <leader>cn :cnext<cr>
nnoremap <leader>cp :cprevious<cr>
nnoremap <leader>cf :cnfile<cr>
nnoremap <leader>cF :cpfile<cr>

" Find
nnoremap <leader>s :Rg<c-space>
nnoremap <leader>S :Rg -u<c-space>
nnoremap <leader>/ :nohlsearch<cr>

" Compe (completion)
inoremap <silent><expr> <C-Space> compe#complete()
inoremap <silent><expr> <CR>      compe#confirm('<CR>')
inoremap <silent><expr> <C-e>     compe#close('<C-e>')
inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })

" Linting (f=fix)
nnoremap <leader>fn :ALENext<cr>
nnoremap <leader>fp :ALEPrevious<cr>
nnoremap <leader>fg :ALEFirst<cr>
nnoremap <leader>fG :ALELast<cr>
nnoremap <leader>ff :ALEFix<cr>

" NERD Commenter
nmap <leader>c<leader> <Plug>NERDCommenterToggle
xmap <leader>c<leader> <Plug>NERDCommenterToggle

" Asterisk
" We reverse the mappings so that the z (stay) commands
" are the default, and we can use z to have the default
" vim behavior
map *   <Plug>(asterisk-z*)
map #   <Plug>(asterisk-z#)
map g*  <Plug>(asterisk-gz*)
map g#  <Plug>(asterisk-gz#)

map z*  <Plug>(asterisk-*)
map z#  <Plug>(asterisk-#)
map gz* <Plug>(asterisk-g*)
map gz# <Plug>(asterisk-g#)

nmap <silent> <leader>z :FoldToggle<cr>
