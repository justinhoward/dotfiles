" turn on syntax highlighting
syntax on

" Turn on full color support in the terminal
set termguicolors
set t_Co=256

let g:monokai_gui_italic=1
let g:monokai_term_italic=1

" set color scheme from colors directory
colorscheme monokai

" Background darkblack, foreground warmgrey
highlight Blamer guifg=#75715E guibg=#211F1C ctermfg=59 ctermbg=233 gui=italic

highlight IndentGuidesOdd ctermfg=none ctermbg=235 cterm=none guifg=none guibg=#2d2e27 gui=none
highlight IndentGuidesEven ctermfg=none ctermbg=236 cterm=none guifg=none guibg=#383a3e gui=none
