return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      panel = { enabled = false },
      suggestion = {
        auto_trigger = true,
        -- Show ghost text even while the blink menu is open; the two surfaces are
        -- used for different things and have distinct accept keys.
        hide_during_completion = false,
        -- Shell parity with zsh-autosuggestions (bindkey -e): end-of-line/<C-e>
        -- accepts the whole suggestion, forward-word/<M-f> accepts one word. blink's
        -- <C-e> is released and its menu-dismiss moved to <Esc> (see completion.lua)
        -- so <C-e> can own ghost accept here. copilot's accept keys have no fallback,
        -- so both keys are ones with no needed insert-mode default.
        keymap = {
          accept = '<C-e>',
          accept_word = '<M-f>',
          -- Alt-based suggestion cycling unbound; ghost text is accept-or-ignore.
          next = false,
          prev = false,
        },
      },
    },
  },
  {
    'olimorris/codecompanion.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = { 'CodeCompanion', 'CodeCompanionChat', 'CodeCompanionActions', 'CodeCompanionCmd' },
    keys = {
      { '<leader>aa', '<cmd>CodeCompanionChat Toggle<cr>', mode = { 'n', 'v' }, desc = 'Toggle AI chat' },
      { '<leader>ac', '<cmd>CodeCompanionActions<cr>', mode = { 'n', 'v' }, desc = 'AI actions' },
      { 'ga', '<cmd>CodeCompanionChat Add<cr>', mode = 'v', desc = 'Add selection to AI chat' },
    },
    opts = {
      interactions = {
        chat = {
          adapter = { name = 'cursor_cli' },
        },
      },
    },
  },
}
