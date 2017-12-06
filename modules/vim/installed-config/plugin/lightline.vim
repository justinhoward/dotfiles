set showtabline=2

function! LightlineFileformat()
	return &fileformat == 'unix' ? '' : &fileformat
endfunction

function! LightlineFileencoding()
	return &fileencoding == 'utf-8' ? '' : &fileencoding
endfunction

let g:lightline = {
  \ 'colorscheme': 'wombat',
  \ 'active': {
  \   'left': [
  \     ['mode', 'paste'],
  \     ['gitbranch', 'filename', 'readonly']
  \   ],
  \   'right': [
  \     ['lineinfo'],
  \     ['percent'],
  \     ['fileformat', 'fileencoding', 'filetype']
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
  \   'gitbranch': 'fugitive#head',
  \   'fileformat': 'LightlineFileformat',
  \   'fileencoding': 'LightlineFileencoding'
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
