require('telescope').setup {
  defaults = {
    path_display = { 'truncate' }
  }
}

require('telescope').load_extension('fzf')
