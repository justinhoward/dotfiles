set completeopt=menuone,noselect

let g:compe = {}
let g:compe.enabled = v:true
let g:compe.source = {
  \ 'vsnip': v:true,
  \ 'nvim_lsp': v:true,
  \ 'path': v:true,
  \ 'buffer': v:true,
  \ 'tags': v:true,
  \ }

highlight link CompeDocumentation NormalFloat
