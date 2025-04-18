require('avante').setup({
  provider = 'copilot',
  auto_suggestion_provider = 'copilot',
  copilot = {
    model = 'claude-3.7-sonnet'
  },
  system_prompt = function()
    local hub = require('mcphub').get_hub_instance()
    return hub:get_active_servers_prompt()
  end,
  custom_tools = function()
    return {
      require('mcphub.extensions.avante').mcp_tool()
    }
  end,
})

require('mcphub').setup({
  port = 37373,
  config = vim.fn.expand('~/.config/mcp-hub/servers.json'),
  extensions = {
    codecompanion = {
      show_result_in_chat = true,
      make_vars = true,
    },
    avante = {
      make_slash_commands = true,
    }
  }
})
