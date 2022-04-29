require'nvim-treesitter.configs'.setup {
  ensure_installed = "all", -- one of "all"
  -- Disabling for now since running this causes significant input lag
  highlight = {
    enable = true,              -- false will disable the whole extension
  },
  -- indent = {
  --   enable = true,
  -- },
  textobjects = {
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
  },
}
