set showtabline=2

function! LightlineFilename()
  return expand('%:t')
endfunction

function! LightlineFiletype()
  return &filetype
endfunction

function! LightlineFileformat()
  return &fileformat ==# 'unix' ? '' : &fileformat
endfunction

function! LightlineFileencoding()
  return &fileencoding ==# 'utf-8' ? '' : &fileencoding
endfunction

function! LightlineLspStatus()
  if luaeval('#vim.lsp.buf_get_clients() > 0')
    return luaeval("require('lsp-status').status()")
  endif

  return ''
endfunction

function! LightlineGit()
  if exists('b:gitsigns_head')
    return join([b:gitsigns_head, b:gitsigns_status], ' ')
  endif

  return ''
endfunction

let g:lightline = {
  \ 'colorscheme': 'wombat',
  \ 'active': {
  \   'left': [
  \     ['mode', 'paste'],
  \     ['gitbranch', 'filename', 'readonly'],
  \   ],
  \   'right': [
  \     ['lineinfo'],
  \     ['percent'],
  \     ['fileformat', 'fileencoding', 'filetype'],
  \     ['lspstatus']
  \   ]
  \ },
  \ 'inactive': {
  \   'left': [
  \     [ 'filename' ]
  \   ],
  \   'right': []
  \ },
  \ 'tabline': {
  \   'left': [
  \     [ 'buffers' ]
  \   ],
  \   'right': []
  \ },
  \ 'component_function': {
  \   'blame': 'LightlineGitBlame',
  \   'gitbranch': 'LightlineGit',
  \   'filename': 'LightlineFilename',
  \   'filetype': 'LightlineFiletype',
  \   'fileformat': 'LightlineFileformat',
  \   'fileencoding': 'LightlineFileencoding',
  \   'lspstatus': 'LightlineLspStatus'
  \ },
  \ 'component_expand': {
  \   'buffers': 'lightline#bufferline#buffers'
  \ },
  \ 'component_type': {
  \   'buffers': 'tabsel'
  \ },
  \ 'separator': {
  \   'left': '',
  \   'right': ''
  \ },
  \ 'subseparator': {
  \   'left': '',
  \   'right': ''
  \ }
\ }

let lightline#bufferline#show_number = 2
let lightline#bufferline#shorten_path = 1
