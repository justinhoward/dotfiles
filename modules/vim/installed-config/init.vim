call plug#begin('~/.vim/plugged')

" Lua dependencies
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
" Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" Monokai Color Scheme
Plug 'sainnhe/sonokai'
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
Plug 'b3nj5m1n/kommentary'
" Project-local vimrc files
Plug 'embear/vim-localvimrc'
" Syntax for any language
Plug 'sheerun/vim-polyglot'
" Detect indentation
Plug 'tpope/vim-sleuth'
" Read editorconfig files
Plug 'editorconfig/editorconfig-vim'
" Remove trailing whitespace with a command
Plug 'ntpeters/vim-better-whitespace'
" Show vertical indent guides
Plug 'nathanaelkane/vim-indent-guides'
" Search in vim with ripgrep
Plug 'jremmen/vim-ripgrep'
" File browser
Plug 'kyazdani42/nvim-web-devicons'
Plug 'kyazdani42/nvim-tree.lua'
" Undo tree browser
Plug 'mbbill/undotree'
" File outline
Plug 'simrat39/symbols-outline.nvim'
" Git status in the gutter and hunk editing
Plug 'lewis6991/gitsigns.nvim'
" Fuzzy finder
" Plug 'junegunn/fzf'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
" Default FZF sources
" Plug 'junegunn/fzf.vim'
" LSP FZF sources
Plug 'gfanto/fzf-lsp.nvim'
" Neoyank FZF source
Plug 'justinhoward/fzf-neoyank'
" Repeat (.) support for plugins
Plug 'tpope/vim-repeat'
" Generate tag files automatically
Plug 'ludovicchabant/vim-gutentags'
" Snippet support
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
" Snippet repository
Plug 'rafamadriz/friendly-snippets'
" Context-aware split/join
Plug 'andrewradev/splitjoin.vim'
" Save yank history
Plug 'Shougo/neoyank.vim'
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
" textobj for treesitter queries
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
" sudo workaround until https://github.com/neovim/neovim/issues/1496 is resolved
Plug 'lambdalisue/suda.vim'
" Better * navigation
Plug 'haya14busa/vim-asterisk'
" Run .http files with the dot-http command and http syntax
Plug 'bayne/vim-dot-http'
" Better buffer delete commands
Plug 'moll/vim-bbye'
" Language server setup
Plug 'neovim/nvim-lspconfig'
" Show code action light bulb
Plug 'kosayoda/nvim-lightbulb'
" External linter support for lsp
Plug 'justinhoward/null-ls.nvim', { 'branch': 'combined-filetype-support' }
" Rust LSP extras
Plug 'simrat39/rust-tools.nvim'
" Completion
Plug 'hrsh7th/nvim-compe'
" Color highlighter
Plug 'norcalli/nvim-colorizer.lua'

call plug#end()
