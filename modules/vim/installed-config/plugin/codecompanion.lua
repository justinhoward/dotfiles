require('codecompanion').setup({
  strategies = {
    chat = {
      adapter = 'copilot'
    },
    inline = {
      adapter = 'copilot'
    },
    cmd = {
      adapter = 'copilot'
    }
  },
  adapters = {
    copilot = function()
      return require('codecompanion.adapters').extend('copilot', {
          name = 'copilot-custom',
          schema = {
            model = {
              default = 'claude-3.7-sonnet-thought'
            }
          }
      })
    end
  }
})

vim.keymap.set({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<Leader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
vim.keymap.set("x", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])
