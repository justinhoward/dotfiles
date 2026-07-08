return {
  {
    'sainnhe/sonokai',
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.sonokai_enable_italic = 1
    end,
  },
  {
    'sainnhe/everforest',
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.everforest_enable_italic = 1
      vim.g.everforest_background = 'hard'
    end,
  },
  {
    'f-person/auto-dark-mode.nvim',
    lazy = false,
    priority = 900,
    config = function()
      local function apply()
        vim.cmd.colorscheme(vim.o.background == 'dark' and 'sonokai' or 'everforest')
      end

      apply()

      vim.api.nvim_create_autocmd('OptionSet', {
        pattern = 'background',
        callback = function()
          apply()
          vim.cmd('mode') -- force a full redraw
        end,
      })

      require('auto-dark-mode').setup({
        update_interval = 1000,
        set_dark_mode = function() vim.o.background = 'dark' end,
        set_light_mode = function() vim.o.background = 'light' end,
      })
    end,
  },
}
