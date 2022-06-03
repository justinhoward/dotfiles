local fzf_lua = require('fzf-lua')
fzf_lua.setup({
  fzf_bin = 'sk',
  fzf_opts = {
    ['--layout'] = 'default',
  },
  files = {
    fd_opts = "--color=never --type f --hidden --no-ignore --exclude .git"
  },
  git = {
    files = {
      cmd = 'git ls-files --exclude-standard --others --cached'
    }
  },
  lsp = {
    jump_to_single_result = true
  }
})

vim.cmd("FzfLua register_ui_select")
