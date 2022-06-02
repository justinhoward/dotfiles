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

" Symbols outline
nnoremap <leader>o :SymbolsOutline<cr>

" Save file
nnoremap <leader>w :w<cr>

" FZF
nnoremap <silent> <leader>p <cmd>lua require('fzf-lua').git_files()<cr>
nnoremap <silent> <leader>P <cmd>lua require('fzf-lua').files()<cr>
nnoremap <leader>y :YankyRingHistory<cr>

" Lightline
nmap <silent> <Leader>1 :LualineBuffersJump 1<cr>
nmap <silent> <Leader>2 :LualineBuffersJump 2<cr>
nmap <silent> <Leader>3 :LualineBuffersJump 3<cr>
nmap <silent> <Leader>4 :LualineBuffersJump 4<cr>
nmap <silent> <Leader>5 :LualineBuffersJump 5<cr>
nmap <silent> <Leader>6 :LualineBuffersJump 6<cr>
nmap <silent> <Leader>7 :LualineBuffersJump 7<cr>
nmap <silent> <Leader>8 :LualineBuffersJump 8<cr>
nmap <silent> <Leader>9 :LualineBuffersJump 9<cr>
nmap <silent> <Leader>0 :LualineBuffersJump 0<cr>

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
nnoremap <silent> <leader>co :copen<cr>
nnoremap <silent> <leader>cl :cclose<cr>
nnoremap <silent> <leader>cn :cnext<cr>
nnoremap <silent> <leader>cp :cprevious<cr>
nnoremap <silent> <leader>cf :cnfile<cr>
nnoremap <silent> <leader>cF :cpfile<cr>
nnoremap <silent> <leader>ch :chistory<cr>

" Find
nnoremap <leader>s :Rg<c-space>
nnoremap <leader>S :Rg -u<c-space>
nnoremap <leader>/ :nohlsearch<cr>

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

" nvim DAP debugger
nnoremap <silent> <F8> :lua require'dap'.continue()<CR>
nnoremap <silent> <F10> :lua require'dap'.step_over()<CR>
nnoremap <silent> <F11> :lua require'dap'.step_into()<CR>
nnoremap <silent> <F12> :lua require'dap'.step_out()<CR>
nnoremap <silent> <leader>dd :lua require'dap'.toggle_breakpoint()<CR>
nnoremap <silent> <leader>dc :lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
nnoremap <silent> <leader>dl :lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
nnoremap <silent> <leader>dr :lua require'dap'.repl.open()<CR>
nnoremap <silent> <leader>dl :lua require'dap'.run_last()<CR>

" Yanky yank ring
nnoremap p <Plug>(YankyPutAfter)
nnoremap P <Plug>(YankyPutBefore)
xnoremap p <Plug>(YankyPutBefore)
xnoremap P <Plug>(YankyPutBefore)
nnoremap gp <Plug>(YankyGPutAfter)
nnoremap gP <Plug>(YankyGPutBefore)
xnoremap gp <Plug>(YankyGPutAfter)
xnoremap gP <Plug>(YankyGPutBefore)

" Cycle through yank ring
nnoremap <c-n> <Plug>(YankyCycleForward)
nnoremap <c-p> <Plug>(YankyCycleBackward)
