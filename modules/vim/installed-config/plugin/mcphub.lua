require('mcphub').setup({
  port = 37373,
  config = vim.fn.expand('~/.config/mcp-hub/servers.json'),
  extensions = {
    codecompanion = {
      show_result_in_chat = true,
      make_vars = true,
      make_slash_commands = true,
    },
    avante = {
      make_slash_commands = true,
    }
  }
})
