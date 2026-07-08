return {
  {
    'saghen/blink.cmp',
    version = '*',
    event = { 'InsertEnter', 'CmdlineEnter' },
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = 'v2.*',
        dependencies = { 'rafamadriz/friendly-snippets' },
      },
    },
    opts = {
      keymap = {
        preset = 'default',
        -- Release <C-e> so Copilot can use it for shell-parity ghost accept (ai.lua).
        ['<C-e>'] = false,
        -- <C-space> toggles the menu: 'show' fires when it's hidden and returns falsy
        -- when already open, so it falls through to 'hide'. Skips blink's default
        -- docs-toggle. This is the stay-in-insert dismiss.
        ['<C-space>'] = { 'show', 'hide' },
        -- No <Esc> override on purpose: Esc stays native so it exits insert immediately
        -- even with the popup open (blink auto-hides the menu on InsertLeave). Menu
        -- accept remains <C-y>.
      },
      signature = { enabled = true },
      completion = {
        documentation = { auto_show = true },
        -- No blink ghost text; Copilot owns inline suggestions (see ai.lua).
        ghost_text = { enabled = false },
      },
      snippets = { preset = 'luasnip' },
      sources = {
        -- Copilot is intentionally NOT a blink source. It lives as inline ghost
        -- text (copilot.lua) so the menu stays code-intelligence only: accept a menu
        -- item with <C-y>; accept ghost text with <C-e> (whole) / <M-f> (word).
        default = { 'lsp', 'snippets', 'buffer' },
        per_filetype = {
          codecompanion = { 'codecompanion' },
        },
      },
    },
    config = function(_, opts)
      require('blink.cmp').setup(opts)
      require('luasnip.loaders.from_vscode').lazy_load()

      -- blink owns snippet jumping in insert mode via <Tab>/<S-Tab>; add the
      -- select-mode equivalents so placeholder navigation works there too.
      local ls = require('luasnip')
      vim.keymap.set('s', '<Tab>', function() ls.jump(1) end)
      vim.keymap.set('s', '<S-Tab>', function() ls.jump(-1) end)
    end,
  },
}
