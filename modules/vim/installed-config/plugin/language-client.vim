" LanguageClient-neovim
let g:LanguageClient_serverCommands = {
	\ 'ruby': ['solargraph', 'stdio']
  \ }

" vim-lsc
let g:lsc_server_commands = {
  \ 'ruby': {
  \   'command': 'solargraph stdio',
  \   'suppress_stderr': v:true
  \ },
  \ 'rust': {
  \   'command': 'rls'
  \ }
\ }
