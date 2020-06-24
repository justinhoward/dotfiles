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
" nnoremap <leader>ii :ALEHover<cr>
" nnoremap <leader>id :ALEGoToDefinition<cr>
" nnoremap <leader>it :ALEGoToTypeDefinition<cr>
" nnoremap <leader>ir :ALERename<cr>
" nnoremap <leader>if :ALEFindReferences<cr>
" nnoremap <leader>ic :ALEDocumentation<cr>

" coc GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of LS, ex: coc-tsserver
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Map function and class text objects
" Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Linting
nnoremap <leader>cj :ALENext<cr>
nnoremap <leader>ck :ALEPrevious<cr>
nnoremap <leader>cg :ALEFirst<cr>
nnoremap <leader>cG :ALELast<cr>
nnoremap <leader>cf :ALEFix<cr>
nnoremap <leader>rn <Plug>(coc-rename)

" Asterisk
map *   <Plug>(asterisk-*)
map #   <Plug>(asterisk-#)
map g*  <Plug>(asterisk-g*)
map g#  <Plug>(asterisk-g#)
map z*  <Plug>(asterisk-z*)
map gz* <Plug>(asterisk-gz*)
map z#  <Plug>(asterisk-z#)
map gz# <Plug>(asterisk-gz#)
