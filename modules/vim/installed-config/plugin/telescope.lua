require('telescope').setup {
  defaults = {
    path_display = { 'truncate' },
    file_ignore_patterns = { '.git' }
  }
}

require('telescope').load_extension('fzf')
