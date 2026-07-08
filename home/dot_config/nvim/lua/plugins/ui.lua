return {
  {
    'j-hui/fidget.nvim',
    event = 'VeryLazy',
    opts = {},
  },
  {
    'kosayoda/nvim-lightbulb',
    event = 'LspAttach',
    opts = {
      autocmd = { enabled = true },
    },
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    cmd = { 'IBLToggle', 'IBLEnable', 'IBLDisable' },
    keys = {
      { '<leader>vi', '<cmd>IBLToggle<cr>', desc = 'Toggle indent guides' },
    },
    opts = {
      enabled = false,
      indent = { char = '┊' },
    },
  },
  {
    'uga-rosa/ccc.nvim',
    cmd = { 'CccPick', 'CccHighlighterToggle', 'CccConvert' },
    keys = {
      { '<leader>vc', '<cmd>CccHighlighterToggle<cr>', desc = 'Toggle color highlighter' },
    },
    opts = {},
  },
  {
    'ellisonleao/glow.nvim',
    cmd = 'Glow',
    keys = {
      { '<leader>vm', '<cmd>Glow<cr>', desc = 'Markdown preview' },
    },
    opts = {},
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      spec = {
        { '<leader>c', group = 'quickfix' },
        { '<leader>d', group = 'debug' },
        { '<leader>f', group = 'lsp/diagnostics' },
        { '<leader>h', group = 'git hunks' },
        { '<leader>r', group = 'refactor' },
        { '<leader>s', group = 'search' },
        { '<leader>v', group = 'toggles/view' },
        { '<leader>a', group = 'ai' },
      },
    },
  },
}
