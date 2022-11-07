require'nvim-tree'.setup {
  filters = {
    custom = {
      '.tags',
      '.tags.lock'
    }
  },
  git = {
    ignore = false
  },
  live_filter = {
    prefix = ' '

  }
}
