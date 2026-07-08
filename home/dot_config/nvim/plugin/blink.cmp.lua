require('blink.cmp').setup({
  keymap = {
    preset = 'default',
    ['<C-j>'] = { 'snippet_forward', 'fallback' },
  },
  signature = { enabled = true },
  completion = {
    documentation = { auto_show = true },
    ghost_text = { enabled = false },
  },
  snippets = { preset = 'luasnip' },
  sources = {
    default = { 'lsp', 'copilot', 'snippets', 'buffer' },
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

require('blink-copilot').setup({
  max_completions = 2
})
