call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'mgee/lightline-bufferline'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-surround'
Plug 'scrooloose/nerdcommenter'
Plug 'embear/vim-localvimrc'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-sleuth'
Plug 'editorconfig/editorconfig-vim'
Plug 'bronson/vim-trailing-whitespace'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'mileszs/ack.vim'
Plug 'scrooloose/nerdtree'
Plug 'mbbill/undotree'
Plug 'airblade/vim-gitgutter'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'junegunn/fzf'
Plug 'w0rp/ale'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'tpope/vim-repeat'
Plug 'ludovicchabant/vim-gutentags'
Plug 'shougo/neosnippet.vim'
Plug 'shougo/neosnippet-snippets'
Plug 'andrewradev/splitjoin.vim'
Plug 'Shougo/neoyank.vim'
Plug 'justinhoward/fzf-neoyank'
Plug 'previm/previm'
Plug 'michaeljsmith/vim-indent-object'
Plug 'chrisbra/csv.vim'
Plug 'mhartington/nvim-typescript', { 'do': './install.sh' }
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-line'
Plug 'takac/vim-hardtime'
Plug 'lambdalisue/suda.vim'
Plug 'ecomba/vim-ruby-refactoring'
Plug 'autozimu/LanguageClient-neovim', {
  \ 'branch': 'next',
  \ 'do': 'bash install.sh',
  \ }

call plug#end()
