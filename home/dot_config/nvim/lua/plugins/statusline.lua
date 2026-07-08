return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = 'VeryLazy',
    config = function()
      local lualine = require('lualine')
      local utils = require('lualine.utils.utils')

      local function macro_recording()
        local reg = vim.fn.reg_recording()
        if reg == '' then
          return ''
        end
        return '󰻂 @' .. reg
      end

      lualine.setup({
        sections = {
          lualine_a = { 'mode' },
          lualine_b = {
            'branch',
            {
              'diagnostics',
              symbols = {
                error = '󰅚 ',
                warn = ' ',
                info = '󰋽 ',
                hint = ' ',
              },
              diagnostics_color = {
                error = { fg = utils.extract_color_from_hllist('fg', { 'DiagnosticSignError' }, nil) },
                warn = { fg = utils.extract_color_from_hllist('fg', { 'DiagnosticSignWarn' }, nil) },
                info = { fg = utils.extract_color_from_hllist('fg', { 'DiagnosticSignInformation' }, nil) },
                hint = { fg = utils.extract_color_from_hllist('fg', { 'DiagnosticSignHint' }, nil) },
              },
              always_visible = true,
            },
            { 'macro-recording', fmt = macro_recording },
          },
          lualine_c = { 'filename' },
          lualine_x = {
            { 'encoding', cond = function() return vim.opt.fileencoding:get() ~= 'utf-8' end },
            { 'fileformat', cond = function() return vim.bo.fileformat ~= 'unix' end },
            'filetype',
          },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { 'filename' },
          lualine_x = { 'location' },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {
          lualine_a = {
            { 'buffers', mode = 2, max_length = function() return vim.o.columns end },
          },
        },
        extensions = {},
      })

      -- Refresh the statusline when macro recording starts and stops so the
      -- indicator appears/clears immediately.
      vim.api.nvim_create_autocmd('RecordingEnter', {
        callback = function()
          lualine.refresh({ place = { 'statusline' } })
        end,
      })
      vim.api.nvim_create_autocmd('RecordingLeave', {
        callback = function()
          -- reg_recording() is not yet cleared on RecordingLeave; wait a tick.
          local timer = vim.uv.new_timer()
          timer:start(50, 0, vim.schedule_wrap(function()
            lualine.refresh({ place = { 'statusline' } })
          end))
        end,
      })

      -- Jump to buffers by tabline position.
      for i = 1, 9 do
        vim.keymap.set('n', '<leader>' .. i, '<cmd>LualineBuffersJump ' .. i .. '<cr>', { silent = true, desc = 'Go to buffer ' .. i })
      end
      vim.keymap.set('n', '<leader>0', '<cmd>LualineBuffersJump 0<cr>', { silent = true, desc = 'Go to last buffer' })
    end,
  },
}
