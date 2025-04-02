call plug#begin('~/.vim/plugged')

" Lua dependencies
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
" Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" textobj for treesitter queries
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
" Refactoring and highlighting with treesitter
Plug 'nvim-treesitter/nvim-treesitter-refactor'
" Sonokai Color Scheme
Plug 'sainnhe/sonokai'
" Everforest color theme
Plug 'sainnhe/everforest'
" Update color scheme in response to system light/dark mode
Plug 'f-person/auto-dark-mode.nvim'
" Git tools
Plug 'tpope/vim-fugitive'
" GitHub extension for fugitive
Plug 'tpope/vim-rhubarb'
" Automatic quoting and unquoting
Plug 'tpope/vim-surround'
" Repeat (.) support for vim-surround
Plug 'tpope/vim-repeat'
" Project-local vimrc files
Plug 'embear/vim-localvimrc'
" Syntax for any language
Plug 'sheerun/vim-polyglot'
" Show vertical indent guides
Plug 'lukas-reineke/indent-blankline.nvim'
" Search in vim with ripgrep
Plug 'jremmen/vim-ripgrep'
" File browser
Plug 'kyazdani42/nvim-web-devicons'
Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-neo-tree/neo-tree.nvim'
" Undo tree browser
Plug 'mbbill/undotree'
" File outline
Plug 'stevearc/aerial.nvim'
" Git status in the gutter and hunk editing
Plug 'lewis6991/gitsigns.nvim'
" FZF Fuzzy finder (requires fzf binary)
Plug 'ibhagwan/fzf-lua'
" Snippet support
Plug 'L3MON4D3/LuaSnip'
" Snippet repository
Plug 'rafamadriz/friendly-snippets'
" Context-aware split/join
Plug 'andrewradev/splitjoin.vim'
" Preview markdown files in browser
Plug 'ellisonleao/glow.nvim'
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
" Better buffer delete commands
Plug 'famiu/bufdelete.nvim'
" Language server setup
Plug 'neovim/nvim-lspconfig'
" Show code action light bulb
Plug 'kosayoda/nvim-lightbulb'
" External linter support for lsp
Plug 'nvimtools/none-ls.nvim'
" Rust LSP extras
Plug 'simrat39/rust-tools.nvim'
" LSP progress notifier
Plug 'j-hui/fidget.nvim'
" Completion
Plug 'saghen/blink.cmp', { 'tag': '*' }
Plug 'fang2hou/blink-copilot'
" Color highlighter
Plug 'uga-rosa/ccc.nvim'
" DAP debugger client
Plug 'mfussenegger/nvim-dap'
" DAP virtual text hints
Plug 'theHamsta/nvim-dap-virtual-text'
" Ruby DAP adapter
Plug 'suketa/nvim-dap-ruby'
" Yankring and yank history
Plug 'gbprod/yanky.nvim'
" Statusline
Plug 'nvim-lualine/lualine.nvim'
" Fun
Plug 'eandrju/cellular-automaton.nvim'
" Automatically generate swagger-ui
Plug 'vinnymeller/swagger-preview.nvim'
" Modern fold indicators
Plug 'kevinhwang91/nvim-ufo'
Plug 'kevinhwang91/promise-async'
" GitHub Copilot
Plug 'zbirenbaum/copilot.lua'
Plug 'olimorris/codecompanion.nvim'

call plug#end()
