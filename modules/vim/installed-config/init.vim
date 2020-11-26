call plug#begin('~/.vim/plugged')

" Git tools
Plug 'tpope/vim-fugitive'
" GitHub extension for fugitive
Plug 'tpope/vim-rhubarb'
" Buffer tabs for lightline
Plug 'mgee/lightline-bufferline'
" Status line formatting
Plug 'itchyny/lightline.vim'
" Automatic quoting and unquoting
Plug 'tpope/vim-surround'
" Commment/uncomment
Plug 'scrooloose/nerdcommenter'
" Project-local vimrc files
Plug 'embear/vim-localvimrc'
" Syntax for any language
Plug 'sheerun/vim-polyglot'
" Detect indentation
Plug 'tpope/vim-sleuth'
" Read editorconfig files
Plug 'editorconfig/editorconfig-vim'
" Remove trailing whitespace with a command
Plug 'bronson/vim-trailing-whitespace'
" Show vertical indent guides
Plug 'nathanaelkane/vim-indent-guides'
" Search in vim with ack/ag
Plug 'mileszs/ack.vim'
" File browser
Plug 'scrooloose/nerdtree'
" Show git status in nerdtree
Plug 'Xuyuanp/nerdtree-git-plugin'
" Undo tree browser
Plug 'mbbill/undotree'
" Tag browser
Plug 'majutsushi/tagbar'
" Git status in the gutter and hunk editing
Plug 'airblade/vim-gitgutter'
" Fuzzy search for files and more
Plug 'junegunn/fzf'
" FZF sources for vim
Plug 'junegunn/fzf.vim'
" Linting etc.
Plug 'w0rp/ale'
" Autocomplete
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Repeat (.) support for plugins
Plug 'tpope/vim-repeat'
" Generate tag files automatically
Plug 'ludovicchabant/vim-gutentags'
" Snippet support
Plug 'shougo/neosnippet.vim'
" Common snippets
Plug 'shougo/neosnippet-snippets'
" Context-aware split/join
Plug 'andrewradev/splitjoin.vim'
" Save yank history
Plug 'Shougo/neoyank.vim'
" Search neoyank with FZF
Plug 'justinhoward/fzf-neoyank'
" Preview markdown files in browser
Plug 'previm/previm'
" textobj for indentation
Plug 'michaeljsmith/vim-indent-object'
" Fancy CSV formatting
Plug 'chrisbra/csv.vim'
" Define your own textobj
Plug 'kana/vim-textobj-user'
" textobj for current line
Plug 'kana/vim-textobj-line'
" sudo workaround until https://github.com/neovim/neovim/issues/1496 is resolved
Plug 'lambdalisue/suda.vim'
" Better * navigation
Plug 'haya14busa/vim-asterisk'
" Run .http files with the dot-http command and http syntax
Plug 'bayne/vim-dot-http'

call plug#end()
