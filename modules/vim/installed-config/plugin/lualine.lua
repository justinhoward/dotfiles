local utils = require('lualine.utils.utils')

require('lualine').setup {
  sections = {
    lualine_a = {'mode'},
    lualine_b = {
      'branch',
      {
        'diagnostics',
        symbols = {
          error = ' ',
          warn = ' ',
          info = ' ',
          hint = ' '
        },
        diagnostics_color = {
          error = { fg = utils.extract_color_from_hllist('fg', { 'DiagnosticSignError' }, nil) },
          warn = { fg = utils.extract_color_from_hllist('fg', { 'DiagnosticSignWarn' }, nil) },
          info = { fg = utils.extract_color_from_hllist('fg', { 'DiagnosticSignInformation' }, nil) },
          hint = { fg = utils.extract_color_from_hllist('fg', { 'DiagnosticSignHint' }, nil) }
        }
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
      { 'buffers', mode = 2 }
    }
  },
  extensions = {},
}
