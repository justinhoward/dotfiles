" turn on incremental searching as you type
set incsearch

if has('nvim')
  set inccommand=split
endif

" Search case sensitively only if query contains uppercase characters
set ignorecase
set smartcase
