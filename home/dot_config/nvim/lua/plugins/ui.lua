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
    'MeanderingProgrammer/render-markdown.nvim',
    -- In-buffer markdown rendering (replaces glow.nvim's terminal popup; no `glow`
    -- binary needed). Parsers (markdown/markdown_inline) come from arborist, which
    -- installs them eagerly via install_popular and explicitly supports this plugin.
    -- Deliberately NOT depending on nvim-treesitter, which would conflict with arborist.
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    ft = { 'markdown', 'codecompanion' },
    keys = {
      { '<leader>vm', '<cmd>RenderMarkdown toggle<cr>', desc = 'Toggle markdown render' },
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
