" set key code delay to 10ms
" only wait a very short time for terminal key codes
" these aren't used by modern terminals
" This prevents delays when pressing ESC
set ttimeoutlen=10

" change leader key from \ to space
let mapleader=' '

" change backspace behavior to be more like a typical editor
set backspace=indent,eol,start
