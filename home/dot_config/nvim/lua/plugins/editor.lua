return {
  -- Surround text objects, with dot-repeat support.
  {
    'tpope/vim-surround',
    dependencies = { 'tpope/vim-repeat' },
    event = 'VeryLazy',
  },

  -- Text objects
  { 'michaeljsmith/vim-indent-object', event = 'VeryLazy' },
  {
    'kana/vim-textobj-line',
    dependencies = { 'kana/vim-textobj-user' },
    event = 'VeryLazy',
  },

  -- Context-aware split/join.
  {
    'andrewradev/splitjoin.vim',
    keys = {
      { 'gS', desc = 'Split construct onto multiple lines' },
      { 'gJ', desc = 'Join construct onto one line' },
    },
    init = function()
      vim.g.splitjoin_ruby_curly_braces = 0
      vim.g.splitjoin_ruby_hanging_args = 0
      vim.g.splitjoin_python_brackets_on_separate_lines = 1
    end,
  },

  -- Better * / # search that keeps the cursor position.
  {
    'haya14busa/vim-asterisk',
    init = function()
      vim.g['asterisk#keeppos'] = 1
    end,
    keys = {
      -- The z (stay) variants become the default; prefix with z for vim's
      -- default jump-to-next behavior.
      { '*', '<Plug>(asterisk-z*)', mode = { 'n', 'x' }, remap = true, desc = 'Search word under cursor (keep pos)' },
      { '#', '<Plug>(asterisk-z#)', mode = { 'n', 'x' }, remap = true, desc = 'Search word backward (keep pos)' },
      { 'g*', '<Plug>(asterisk-gz*)', mode = { 'n', 'x' }, remap = true, desc = 'Search partial word (keep pos)' },
      { 'g#', '<Plug>(asterisk-gz#)', mode = { 'n', 'x' }, remap = true, desc = 'Search partial word backward (keep pos)' },
      { 'z*', '<Plug>(asterisk-*)', mode = { 'n', 'x' }, remap = true, desc = 'Search word under cursor (jump)' },
      { 'z#', '<Plug>(asterisk-#)', mode = { 'n', 'x' }, remap = true, desc = 'Search word backward (jump)' },
      { 'gz*', '<Plug>(asterisk-g*)', mode = { 'n', 'x' }, remap = true, desc = 'Search partial word (jump)' },
      { 'gz#', '<Plug>(asterisk-g#)', mode = { 'n', 'x' }, remap = true, desc = 'Search partial word backward (jump)' },
    },
  },

  -- Yank ring with cycling.
  {
    'gbprod/yanky.nvim',
    keys = {
      { 'p', '<Plug>(YankyPutAfter)', mode = { 'n', 'x' }, desc = 'Put after' },
      { 'P', '<Plug>(YankyPutBefore)', mode = { 'n', 'x' }, desc = 'Put before' },
      { 'gp', '<Plug>(YankyGPutAfter)', mode = { 'n', 'x' }, desc = 'GPut after' },
      { 'gP', '<Plug>(YankyGPutBefore)', mode = { 'n', 'x' }, desc = 'GPut before' },
      { '<C-n>', '<Plug>(YankyCycleForward)', desc = 'Cycle yank forward' },
      { '<C-p>', '<Plug>(YankyCycleBackward)', desc = 'Cycle yank backward' },
      { '<leader>y', '<cmd>YankyRingHistory<cr>', desc = 'Yank history' },
    },
    opts = {},
  },

  -- Modern fold text and fold peeking.
  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    event = { 'BufReadPost', 'BufNewFile' },
    keys = {
      { 'zR', function() require('ufo').openAllFolds() end, desc = 'Open all folds' },
      { 'zM', function() require('ufo').closeAllFolds() end, desc = 'Close all folds' },
      {
        'K',
        function()
          if not require('ufo').peekFoldedLinesUnderCursor() then
            vim.lsp.buf.hover()
          end
        end,
        desc = 'Peek fold / hover',
      },
    },
    opts = {
      provider_selector = function()
        return { 'treesitter', 'indent' }
      end,
    },
  },

  -- Highlight the word under the cursor.
  {
    'nvim-mini/mini.cursorword',
    event = 'VeryLazy',
    config = function()
      require('mini.cursorword').setup()
    end,
  },

  -- Better buffer delete/wipeout that preserves window layout.
  {
    'famiu/bufdelete.nvim',
    cmd = { 'Bdelete', 'Bwipeout' },
  },

  -- Project-local .lvimrc files.
  {
    'embear/vim-localvimrc',
    event = 'BufReadPre',
    init = function()
      -- Ask before sourcing a project .lvimrc, but persist the answer so each
      -- file is only prompted once. Keep the decision file in the XDG state dir
      -- ($XDG_STATE_HOME/nvim) instead of dropping a dotfile in $HOME.
      vim.g.localvimrc_ask = 1
      vim.g.localvimrc_persistent = 2
      vim.g.localvimrc_persistence_file = vim.fn.stdpath('state') .. '/localvimrc_persistent'
      -- Sandbox disabled so approved .lvimrc files run freely; the ask prompt
      -- above is the trust gate.
      vim.g.localvimrc_sandbox = 0
    end,
  },

  -- CSV formatting/alignment.
  {
    'chrisbra/csv.vim',
    ft = 'csv',
  },

  -- Undo history browser.
  {
    'mbbill/undotree',
    cmd = { 'UndotreeToggle', 'UndotreeShow' },
    keys = {
      { '<leader>u', '<cmd>UndotreeToggle<cr>', desc = 'Toggle undo tree' },
    },
  },
}
