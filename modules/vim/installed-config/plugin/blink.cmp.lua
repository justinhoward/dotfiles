require('blink.cmp').setup({
  keymap = { preset = 'default' },
  completion = {
    documentation = { auto_show = true },
    ghost_text = {
      enabled = true,
    },
  },
  sources = {
    default = { 'copilot', 'lsp', 'path', 'snippets', 'buffer' },
    providers = {
      copilot = {
        name = 'copilot',
        module = 'blink-copilot',
        score_offset = 100,
        async = true,
      }
    },
    per_filetype = {
      codecompanion = { 'codecompanion', 'copilot' }
    }
  }
})
