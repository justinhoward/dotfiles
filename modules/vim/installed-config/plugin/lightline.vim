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

let g:lightline#ale#indicator_checking = ' '
let g:lightline#ale#indicator_ok = ' '
let g:lightline#ale#indicator_warnings = ' '
let g:lightline#ale#indicator_errors = ' '

let g:lightline = {
  \ 'colorscheme': 'wombat',
  \ 'active': {
  \   'left': [
  \     ['mode', 'paste'],
  \     ['gitbranch', 'filename', 'readonly'],
  \     ['lspstatus']
  \   ],
  \   'right': [
  \     [
  \       'linter_checking',
  \       'linter_errors',
  \       'linter_warnings',
  \       'linter_infos',
  \       'linter_ok'
  \     ],
  \     ['lineinfo', 'percent'],
  \     ['fileformat', 'fileencoding', 'filetype'],
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
  \   'lspstatus': 'LightlineLspStatus',
  \   'gutentags_status': 'LightlineGutentagsStatus'
  \ },
  \ 'component_expand': {
  \   'buffers': 'lightline#bufferline#buffers',
  \   'linter_checking': 'lightline#ale#checking',
  \   'linter_infos': 'lightline#ale#infos',
  \   'linter_warnings': 'lightline#ale#warnings',
  \   'linter_errors': 'lightline#ale#errors',
  \   'linter_ok': 'lightline#ale#ok',
  \ },
  \ 'component_type': {
  \   'buffers': 'tabsel',
  \   'linter_checking': 'right',
  \   'linter_infos': 'right',
  \   'linter_warnings': 'warning',
  \   'linter_errors': 'error',
  \   'linter_ok': 'right',
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
