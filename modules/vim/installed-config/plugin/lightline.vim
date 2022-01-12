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

lua << EOF
function _G.lightlineLspSymbol()
  if vim.tbl_isempty(vim.lsp.buf_get_clients(0)) then return '' end

  local counts = {}
  for _, diag in ipairs(vim.diagnostic.get()) do
    if not counts[diag.severity] then counts[diag.severity] = 0 end
    counts[diag.severity] = counts[diag.severity] + 1
  end

  if counts[vim.diagnostic.severity.ERROR] then
    return ' '
  end

  if counts[vim.diagnostic.severity.WARN] then
    return ' '
  end

  if counts[vim.diagnostic.severity.INFO] then
    return ' '
  end

  if counts[vim.diagnostic.severity.HINT] then
    return ' '
  end

  return ''
end
EOF

function! LightlineLspSymbol()
  if luaeval('#vim.lsp.buf_get_clients() > 0')
    return luaeval("lightlineLspSymbol()")
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
  \     ['lspstatus']
  \   ],
  \   'right': [
  \     ['lspsymbol'],
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
  \   'lspsymbol': 'LightlineLspSymbol',
  \   'gutentags_status': 'LightlineGutentagsStatus'
  \ },
  \ 'component_expand': {
  \   'buffers': 'lightline#bufferline#buffers'
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
