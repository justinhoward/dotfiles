local treesitter = require('nvim-treesitter')

local excluded_filetypes = {
  docker = true,
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = { '*' },
  callback = function()
    local ft = vim.bo.filetype

    if excluded_filetypes[ft] then
      return
    end

    local lang = vim.treesitter.language.get_lang(ft)
    local available = treesitter.get_available()

    if lang and vim.tbl_contains(available, lang) then
      vim.treesitter.start(0, lang)
      vim.bo.syntax = 'on'
    end
  end,
})
