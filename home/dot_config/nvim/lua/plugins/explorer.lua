return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    cmd = 'Neotree',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    keys = {
      { '<leader>e', '<cmd>Neotree toggle<cr>', desc = 'Toggle file tree' },
      { '<leader>E', '<cmd>Neotree reveal<cr>', desc = 'Reveal file in tree' },
      { '<leader>hh', '<cmd>Neotree git_status float<cr>', desc = 'Git status tree' },
    },
    opts = {
      filesystem = {
        filtered_items = {
          never_show = {
            '.DS_Store',
            '.tags',
            '.tags.lock',
          },
        },
      },
    },
  },
  {
    'stevearc/aerial.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    cmd = { 'AerialToggle', 'AerialOpen', 'AerialNavToggle' },
    keys = {
      { '<leader>o', '<cmd>AerialToggle<cr>', desc = 'Toggle symbol outline' },
      { '<leader>O', '<cmd>AerialToggle!<cr>', desc = 'Toggle symbol outline (focus)' },
    },
    -- Use the LSP backend; this config uses arborist instead of nvim-treesitter.
    opts = {
      backends = { 'lsp', 'markdown', 'man' },
    },
  },
}
