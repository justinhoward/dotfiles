return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    config = function()
      require('conform').setup({
        default_format_opts = {
          -- Fall back to LSP formatting when no CLI formatter is configured.
          lsp_format = 'fallback',
        },
        formatters_by_ft = {
          -- Ruby formatting is handled by ruby-lsp (rubocop in-process). Run
          -- codespell first (via '*'), then the LSP formatter.
          ruby = { lsp_format = 'last' },
          eruby = { 'erb_format' },
          sql = { 'sqlfluff' },
          javascript = { 'prettierd' },
          javascriptreact = { 'prettierd' },
          typescript = { 'prettierd' },
          typescriptreact = { 'prettierd' },
          css = { 'prettierd' },
          scss = { 'prettierd' },
          less = { 'prettierd' },
          html = { 'prettierd' },
          json = { 'prettierd' },
          jsonc = { 'prettierd' },
          yaml = { 'prettierd' },
          markdown = { 'prettierd' },
          graphql = { 'prettierd' },
          vue = { 'prettierd' },
          lua = { 'stylua' },
          -- codespell fixes typos across all filetypes on manual format.
          ['*'] = { 'codespell' },
        },
        formatters = {
          -- erb tooling runs through the project's bundle.
          erb_format = {
            command = 'bundle',
            args = { 'exec', 'erblint', '--autocorrect', '$FILENAME' },
            stdin = false,
          },
          sqlfluff = {
            command = 'sqlfluff',
            args = { 'format', '--dialect', 'mysql', '-' },
            stdin = true,
          },
        },
      })

      -- Formatting is manual (see <leader>rf); no format-on-save.
    end,
  },
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      local lint = require('lint')

      lint.linters_by_ft = {
        -- Ruby diagnostics come from ruby-lsp (rubocop in-process), not nvim-lint.
        eruby = { 'erb_lint' },
        dockerfile = { 'hadolint' },
        markdown = { 'markdownlint' },
        sql = { 'sqlfluff' },
        yaml = { 'yamllint' },
        c = { 'cppcheck' },
        cpp = { 'cppcheck' },
      }

      -- Ruby tooling runs through the project's bundle.
      lint.linters.erb_lint.cmd = 'bundle'
      lint.linters.erb_lint.args = vim.list_extend({ 'exec', 'erblint' }, lint.linters.erb_lint.args)

      lint.linters.sqlfluff.args = vim.list_extend(lint.linters.sqlfluff.args, { '--dialect', 'mysql' })

      local function run_lint()
        lint.try_lint()
        -- codespell runs everywhere, regardless of filetype.
        lint.try_lint('codespell')
      end

      vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost', 'InsertLeave' }, {
        group = vim.api.nvim_create_augroup('config_nvim_lint', { clear = true }),
        callback = run_lint,
      })
      run_lint()
    end,
  },
}
