require'fzf-lua'.setup({
  fzf_opts = {
    ['--layout'] = 'default',
  },
  files = {
    fd_opts = "--color=never --type f --hidden --no-ignore --exclude .git"
  }
})

vim.cmd("FzfLua register_ui_select")
