" Move between next/previous with ctrl jk from any mode
tnoremap <C-j> <C-\><C-N><C-w>w
tnoremap <C-k> <C-\><C-N><C-w>p
inoremap <C-j> <C-\><C-N><C-w>w
inoremap <C-k> <C-\><C-N><C-w>p
nnoremap <C-j> <C-w>w
nnoremap <C-k> <C-w>p

" Center screen after next/prev
nnoremap n nzz
nnoremap N Nzz

" Credit https://stackoverflow.com/a/39902725/4231110
function! CenterSearch()
  let cmdtype = getcmdtype()
  if cmdtype == '/' || cmdtype == '?'
    return "\<enter>zz"
  endif
  return "\<enter>"
endfunction
cnoremap <silent> <expr> <enter> CenterSearch()

" Delete current buffer with bbye
nnoremap <silent> <leader>x :Bdelete<cr>

" Nvim Tree
nnoremap <silent> <leader>e :Neotree toggle<cr>
nnoremap <silent> <leader>E :Neotree reveal<cr>
nnoremap <silent> <leader>hh :Neotree git_status float<cr>

" UndoTree
nnoremap <leader>u :UndotreeToggle<cr>

" Aerial file tree
nnoremap <silent> <leader>t :AerialToggle<cr>
nnoremap <silent> <leader>T :AerialToggle!<cr>

" Save file
nnoremap <silent> <leader>w :w<cr>

" FZF
nnoremap <silent> <leader>p <cmd>lua require('fzf-lua').git_files()<cr>
nnoremap <silent> <leader>P <cmd>lua require('fzf-lua').files()<cr>
nnoremap <leader>y :YankyRingHistory<cr>

" Find
nnoremap <silent> <leader>ss <cmd>lua require('fzf-lua').live_grep_glob()<cr>
vnoremap <silent> <leader>ss <cmd>lua require('fzf-lua').grep_visual()<cr>
nnoremap <silent> <leader>sh <cmd>lua require('fzf-lua').live_grep_glob({ rg_opts = '-u', prompt = 'Rg -u❯ ' })<cr>
vnoremap <silent> <leader>sh <cmd>lua require('fzf-lua').grep_visual({ rg_opts = '-u', prompt = 'Rg -u❯ ' })<cr>
nnoremap <silent> <leader>sw <cmd>lua require('fzf-lua').grep_cword()<cr>
nnoremap <silent> <leader>sW <cmd>lua require('fzf-lua').grep_cWORD()<cr>
nnoremap <silent> <leader>sl <cmd>lua require('fzf-lua').grep_last()<cr>

" Lualine status line
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

" Snippets
imap <silent> <C-j> <Plug>luasnip-expand-or-jump
smap <silent> <C-j> <Plug>luasnip-expand-or-jump
imap <expr> <Tab>   luasnip#jumpable(1)  ? '<Plug>luasnip-jump-next'      : '<Tab>'
smap <expr> <Tab>   luasnip#jumpable(1)  ? '<Plug>luasnip-jump-next'      : '<Tab>'
imap <expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev'      : '<S-Tab>'
smap <expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev'      : '<S-Tab>'

" Indent Guides
nnoremap <silent> <leader>vi :IndentBlanklineToggle<cr>

" Whitespace
nnoremap <silent> <leader>vw :ToggleList<cr>

" Markdown Preview
nnoremap <silent> <leader>vm :Glow<cr>

" Color Highlighter
nnoremap <silent> <leader>vc :CccHighlighterToggle<cr>

" Quickfix
nnoremap <silent> <leader>cc :QuickfixToggle<cr>
nnoremap <silent> <leader>co :copen<cr>
nnoremap <silent> <leader>cl :cclose<cr>
nnoremap <silent> <leader>cn :cnext<cr>
nnoremap <silent> <leader>cp :cprevious<cr>
nnoremap <silent> <leader>cf :cnfile<cr>
nnoremap <silent> <leader>cF :cpfile<cr>
nnoremap <silent> <leader>ch :chistory<cr>
nnoremap <silent> <leader>cs <cmd>lua require('fzf-lua').quickfix({})<cr>

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

" nvim DAP debugger
nnoremap <silent> <F8> :lua require'dap'.continue()<CR>
nnoremap <silent> <F10> :lua require'dap'.step_over()<CR>
nnoremap <silent> <F11> :lua require'dap'.step_into()<CR>
nnoremap <silent> <F12> :lua require'dap'.step_out()<CR>
nnoremap <silent> <leader>dd :lua require'dap'.toggle_breakpoint()<CR>
nnoremap <silent> <leader>dc :lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
nnoremap <silent> <leader>dr :lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
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
