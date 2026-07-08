return {
  -- Surrounding pairs. Default mini mappings: sa (add), sd (delete), sr
  -- (replace), sf/sF (find), sh (highlight), with n/l suffixes for next/last.
  -- Shadows native `s` (substitute). Replaces tpope/vim-surround (+vim-repeat);
  -- mini has native dot-repeat.
  {
    'nvim-mini/mini.surround',
    event = 'VeryLazy',
    opts = {},
  },

  -- a/i text objects (brackets, quotes, function calls `f`, arguments `a`,
  -- tags `t`, ...) plus custom indent (ii/ai) and line (il/al) objects via
  -- mini.extra. Replaces michaeljsmith/vim-indent-object and kana/vim-textobj-line.
  {
    'nvim-mini/mini.ai',
    dependencies = { 'nvim-mini/mini.extra' },
    event = 'VeryLazy',
    config = function()
      local gen_ai = require('mini.extra').gen_ai_spec
      require('mini.ai').setup({
        custom_textobjects = {
          i = gen_ai.indent(), -- ii / ai — indent scope (was vim-indent-object)
          l = gen_ai.line(), -- il / al — current line (was vim-textobj-line)
        },
        mappings = {
          -- Move last-search off il/al so those free up for the line textobject
          -- above. Next-search stays on the default in/an.
          around_last = 'aL',
          inside_last = 'iL',
        },
      })
    end,
  },

  -- Treesitter-aware split/join (replaces andrewradev/splitjoin.vim). Walks the
  -- syntax tree, so Ruby do/end blocks, hashes, arrays, and args split correctly.
  -- Uses the parsers arborist installs; nvim-treesitter is intentionally NOT a
  -- dependency (that plugin conflicts with arborist — parsers alone suffice).
  {
    'Wansmer/treesj',
    keys = {
      { 'gS', function() require('treesj').split() end, desc = 'Split construct onto multiple lines' },
      { 'gJ', function() require('treesj').join() end, desc = 'Join construct onto one line' },
    },
    opts = {
      -- gS/gJ are defined above; skip treesj's <space>m/<space>j/<space>s defaults.
      use_default_keymaps = false,
    },
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

  -- CSV/TSV column alignment via virtual text (replaces chrisbra/csv.vim). Pure Lua,
  -- no treesitter dependency. Auto-enabled per buffer in after/ftplugin/{csv,tsv}.lua.
  {
    'hat0uma/csvview.nvim',
    ft = { 'csv', 'tsv' },
    opts = {
      keymaps = {
        -- Field (cell) text objects: `if` inner, `af` outer.
        textobject_field_inner = { 'if', mode = { 'o', 'x' } },
        textobject_field_outer = { 'af', mode = { 'o', 'x' } },
      },
    },
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
