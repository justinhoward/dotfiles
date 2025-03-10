local fzf_lua = require('fzf-lua')
local actions = fzf_lua.actions
fzf_lua.setup({
  files = {
    actions = {
      ['ctrl-g'] = { actions.toggle_ignore }
    }
  },
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

fzf_lua.register_ui_select()
