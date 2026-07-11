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
          -- erb tooling runs through the project's bundle. Only run when the
          -- project actually bundles erb_lint, so unrelated repos don't error.
          erb_format = {
            command = 'bundle',
            args = { 'exec', 'erblint', '--autocorrect', '$FILENAME' },
            stdin = false,
            condition = function(_, ctx)
              return require('config.bundle').has_gem(ctx.dirname, 'erb_lint')
            end,
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

      -- A linter is only runnable if its command actually resolves: a plain
      -- executable must be on PATH, and bundle-based linters (erb_lint) must be
      -- present in the project's Gemfile.lock. This keeps missing tooling a
      -- silent skip instead of a per-run error notification.
      local function runnable(name)
        if name == 'erb_lint' then
          return require('config.bundle').has_gem(vim.fn.expand('%:p:h'), 'erb_lint')
        end
        local linter = lint.linters[name]
        if type(linter) == 'function' then
          linter = linter()
        end
        local cmd = linter and linter.cmd
        if type(cmd) == 'function' then
          cmd = cmd()
        end
        return type(cmd) == 'string' and vim.fn.executable(cmd) == 1
      end

      local function run_lint()
        local runnable_fts = {}
        for _, name in ipairs(lint.linters_by_ft[vim.bo.filetype] or {}) do
          if runnable(name) then
            runnable_fts[#runnable_fts + 1] = name
          end
        end
        if #runnable_fts > 0 then
          lint.try_lint(runnable_fts)
        end
        -- codespell runs everywhere, regardless of filetype.
        if runnable('codespell') then
          lint.try_lint('codespell')
        end
      end

      vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost', 'InsertLeave' }, {
        group = vim.api.nvim_create_augroup('config_nvim_lint', { clear = true }),
        callback = run_lint,
      })
      run_lint()
    end,
  },
}
