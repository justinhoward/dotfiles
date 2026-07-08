return {
  {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = 'FzfLua',
    keys = {
      { '<leader>p', function() require('fzf-lua').files() end, desc = 'Find files' },
      { '<leader>ss', function() require('fzf-lua').live_grep() end, desc = 'Live grep' },
      { '<leader>ss', function() require('fzf-lua').grep_visual() end, mode = 'x', desc = 'Grep selection' },
      { '<leader>sw', function() require('fzf-lua').grep_cword() end, desc = 'Grep word' },
      { '<leader>sW', function() require('fzf-lua').grep_cWORD() end, desc = 'Grep WORD' },
      { '<leader>sl', function() require('fzf-lua').live_grep({ resume = true }) end, desc = 'Resume grep' },
      { '<leader>sk', function() require('fzf-lua').keymaps() end, desc = 'Search keymaps' },
    },
    config = function()
      local fzf = require('fzf-lua')
      local actions = fzf.actions
      fzf.setup({
        files = {
          actions = {
            ['ctrl-g'] = { actions.toggle_ignore },
          },
        },
        grep = {
          actions = {
            ['ctrl-g'] = { actions.toggle_ignore },
            ['ctrl-l'] = { actions.grep_lgrep },
          },
        },
        lsp = {
          jump1 = true,
        },
      })
      fzf.register_ui_select()
    end,
  },
}
