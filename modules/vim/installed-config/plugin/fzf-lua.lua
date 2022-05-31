require'fzf-lua'.setup({
  fzf_opts = {
    ['--layout'] = 'default',
  }
})

vim.cmd("FzfLua register_ui_select")
