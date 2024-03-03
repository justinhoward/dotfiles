local fzf_lua = require('fzf-lua')
local actions = fzf_lua.actions
fzf_lua.setup({
  'default',
  grep = {
    actions = {
      ['ctrl-g'] = { actions.toggle_ignore },
      ['ctrl-l'] = { actions.grep_lgrep }
    }
  },
  lsp = {
    jump_to_single_result = true
  }
})

vim.cmd("FzfLua register_ui_select")
