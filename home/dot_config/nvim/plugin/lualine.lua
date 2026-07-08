local lualine = require('lualine')
local utils = require('lualine.utils.utils')

local function macro_recording()
    local recording_register = vim.fn.reg_recording()
    if recording_register == "" then
        return ""
    else
        return "󰻂 @" .. recording_register
    end
end

lualine.setup {
  sections = {
    lualine_a = {'mode'},
    lualine_b = {
      'branch',
      {
        'diagnostics',
        symbols = {
          error = '󰅚 ',
          warn = ' ',
          info = '󰋽 ',
          hint = ' '
        },
        diagnostics_color = {
          error = { fg = utils.extract_color_from_hllist('fg', { 'DiagnosticSignError' }, nil) },
          warn = { fg = utils.extract_color_from_hllist('fg', { 'DiagnosticSignWarn' }, nil) },
          info = { fg = utils.extract_color_from_hllist('fg', { 'DiagnosticSignInformation' }, nil) },
          hint = { fg = utils.extract_color_from_hllist('fg', { 'DiagnosticSignHint' }, nil) }
        },
        always_visible = true,
        -- cond = function() return vim.lsp.buf.server_ready() end
      },
      {
        'macro-recording',
        fmt = macro_recording

      }
    },
    lualine_c = {'filename'},
    lualine_x = {
      { 'encoding', cond = function () return vim.opt.fileencoding:get() ~= 'utf-8' end },
      { 'fileformat', cond = function () return vim.bo.fileformat ~= 'unix' end },
      'filetype',
    },
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {
    lualine_a = {
      { 'buffers', mode = 2, max_length = function() return vim.o.columns end }
    }
  },
  extensions = {},
}

-- Credit https://www.reddit.com/r/neovim/comments/xy0tu1/comment/irfegvd/?utm_source=reddit&utm_medium=web2x&context=3
-- Macro recording enter and exit handlers
vim.api.nvim_create_autocmd("RecordingEnter", {
    callback = function()
        lualine.refresh({
            place = { "statusline" },
        })
    end,
})

vim.api.nvim_create_autocmd("RecordingLeave", {
    callback = function()
        -- Instead of just calling refresh we need to wait a moment because of
        -- the nature of `vim.fn.reg_recording`. If we tell lualine to refresh
        -- right now it actually will still show a recording occurring because
        -- `vim.fn.reg_recording` hasn't emptied yet. So what we need to do is
        -- wait a tiny amount of time (in this instance 50 ms) to ensure
        -- `vim.fn.reg_recording` is purged before asking lualine to refresh.
        local timer = vim.loop.new_timer()
        timer:start(
            50,
            0,
            vim.schedule_wrap(function()
                lualine.refresh({
                    place = { "statusline" },
                })
            end)
        )
    end,
})
