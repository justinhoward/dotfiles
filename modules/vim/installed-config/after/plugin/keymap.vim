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

" NERD Tree
nnoremap <leader>e :NERDTreeToggle<cr>
nnoremap <leader>E :NERDTreeFind<cr>

" UndoTree
nnoremap <leader>u :UndotreeToggle<cr>

" Tagbar
nnoremap <leader>t :TagbarToggle<cr>

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
nnoremap <leader>qo :copen<cr>
nnoremap <leader>qc :cclose<cr>
nnoremap <leader>qn :cnext<cr>
nnoremap <leader>qp :cprevious<cr>
nnoremap <leader>qf :cnfile<cr>
nnoremap <leader>qF :cpfile<cr>

" Find
nnoremap <leader>s :Rg<c-space>
nnoremap <leader>/ :nohlsearch<cr>

" Language Client
" nnoremap <leader>ii :ALEHover<cr>
" nnoremap <leader>id :ALEGoToDefinition<cr>
" nnoremap <leader>it :ALEGoToTypeDefinition<cr>
" nnoremap <leader>ir :ALERename<cr>
" nnoremap <leader>if :ALEFindReferences<cr>
" nnoremap <leader>ic :ALEDocumentation<cr>

" coc trigger completion
inoremap <silent><expr> <c-space> coc#refresh()

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

" Linting (f=fix)
nnoremap <leader>fn :ALENext<cr>
nnoremap <leader>fp :ALEPrevious<cr>
nnoremap <leader>fg :ALEFirst<cr>
nnoremap <leader>fG :ALELast<cr>
nnoremap <leader>ff :ALEFix<cr>

" Refactor/Reformat
nmap <leader>rn <Plug>(coc-rename)
xmap <leader>rf  <Plug>(coc-format-selected)
nmap <leader>rf  <Plug>(coc-format-selected)

" Code Action
" Apply codeAction to the current buffer
nmap <leader>a<leader> <Plug>(coc-codeaction)
" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

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

" Folding
function! s:toggle_fold_method()
  if &foldmethod ==# 'manual'
    set foldmethod=syntax
  else
    set foldmethod=manual
  endif
endfunction

nmap <silent> <leader>z :call <SID>toggle_fold_method()<cr>
