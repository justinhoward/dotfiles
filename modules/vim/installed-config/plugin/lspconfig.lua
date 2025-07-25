local nvim_lsp = require('lspconfig')
local null_ls = require('null-ls')

vim.o.winborder = 'rounded'

vim.fn.sign_define("DiagnosticSignError", { text = '󰅚 ', texthl = 'DiagnosticSignError' })
vim.fn.sign_define("DiagnosticSignWarn", { text = ' ', texthl = 'DiagnosticSignWarn' })
vim.fn.sign_define("DiagnosticSignInfo", { text = '󰋽 ', texthl = 'DiagnosticSignInfo' })
vim.fn.sign_define("DiagnosticSignHint", { text = ' ', texthl = 'DiagnosticSignHint' })

vim.diagnostic.config {
  severity_sort = true,
  virtual_text = true
}

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Mappings.
  local opts = { buffer = bufnr, noremap = true, silent = true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.keymap.set('n', 'gD', "<cmd>lua require('fzf-lua').lsp_declarations()<cr>", opts)
  vim.keymap.set('n', 'gd', "<cmd>lua require('fzf-lua').lsp_definitions()<cr>", opts)
  vim.keymap.set('n', 'gy', "<cmd>lua require('fzf-lua').lsp_typedefs()<cr>", opts)
  vim.keymap.set('n', 'grr', "<cmd>lua require('fzf-lua').lsp_references()<cr>", opts)
  vim.keymap.set('n', 'gri', "<cmd>lua require('fzf-lua').lsp_implementations()<cr>", opts)
  vim.keymap.set('n', '<leader>fn', '<cmd>lua vim.diagnostic.goto_next()<cr>', opts)
  vim.keymap.set('n', '<leader>fp', '<cmd>lua vim.diagnostic.goto_prev()<cr>', opts)
  vim.keymap.set('n', '<leader>ff', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
  vim.keymap.set('n', '<leader>fa', "<cmd>lua require('fzf-lua').lsp_document_diagnostics()<cr>", opts)
  vim.keymap.set('n', '<leader>fA', "<cmd>lua require('fzf-lua').lsp_workspace_diagnostics()<cr>", opts)
  vim.keymap.set('n', '<leader>]', "<cmd>lua require('fzf-lua').lsp_document_symbols()<cr>", opts)
  vim.keymap.set('n', '<leader>}', "<cmd>lua require('fzf-lua').lsp_workspace_symbols()<cr>", opts)
  vim.keymap.set('n', '<leader>rf', '<cmd>lua vim.lsp.buf.format { async = true }<cr>', opts)
  vim.keymap.set('v', '<leader>rf', '<cmd>lua vim.lsp.buf.format { async = true }<cr>', opts)
 --- toggle inlay hints
	local function toggle_inlay_hints()
		vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
	end

  vim.keymap.set('n', '<leader>ri', toggle_inlay_hints, { buffer = bufnr, noremap = true, silent = true })

  vim.keymap.set('n', 'K', function()
      local winid = require('ufo').peekFoldedLinesUnderCursor()
      if not winid then
          vim.lsp.buf.hover()
      end
  end)

  -- Disable setting formatexpr from lsp
  -- https://github.com/jose-elias-alvarez/null-ls.nvim/issues/1131
  vim.api.nvim_buf_set_option(bufnr, "formatexpr", "")
end

local flags = {
  debounce_text_changes = 150,
}

-- Add cmp completion capabilities
-- local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Default configs
local servers = {
  'ccls',
  'eslint',
  'ts_ls',
  'bashls',
  'marksman',
  'jsonls',
  'ruff',
  'terraformls',
-- Swift
  'sourcekit'
}
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    -- capabilities = capabilities,
    on_attach = on_attach,
    flags = flags
  }
end

nvim_lsp.pylsp.setup {
  -- capabilities = capabilities,
  on_attach = on_attach,
  flags = flags,
  settings = {
    pylsp = {
      plugins = {
        autopep8 = { enabled = true },
        pylint = { enabled = true }
      }
    }
  }
}

nvim_lsp.sorbet.setup {
  -- capabilities = capabilities,
  on_attach = on_attach,
  flags = flags,
  cmd = { 'srb', 'tc', '--lsp' },
}

-- Individual configs
-- nvim_lsp.solargraph.setup {
--   capabilities = capabilities,
--   on_attach = on_attach,
--   flags = flags,
--   init_options = {
--     formatting = false
--   },
--   settings = {
--     solargraph = {
--       diagnostics = false
--     }
--   }
-- }

-- This should work in theory, but isn't at the moment May 24
-- nvim_lsp.rubocop.setup {
--   capabilities = capabilities,
--   on_attach = on_attach,
--   cmd = { 'bundle', 'exec', 'rubocop', '--lsp' },
--   flags = flags
-- }

nvim_lsp.yamlls.setup {
  -- capabilities = capabilities,
  on_attach = on_attach,
  flags = flags,
  settings = {
    yaml = {
      schemaStore = {
        url = "https://www.schemastore.org/api/json/catalog.json",
        enable = true,
      },
      customTags = {
        "!And scalar",
        "!And mapping",
        "!And sequence",
        "!If scalar",
        "!If mapping",
        "!If sequence",
        "!Not scalar",
        "!Not mapping",
        "!Not sequence",
        "!Equals scalar",
        "!Equals mapping",
        "!Equals sequence",
        "!Or scalar",
        "!Or mapping",
        "!Or sequence",
        "!FindInMap scalar",
        "!FindInMap mapping",
        "!FindInMap sequence",
        "!Base64 scalar",
        "!Base64 mapping",
        "!Base64 sequence",
        "!Cidr scalar",
        "!Cidr mapping",
        "!Cidr sequence",
        "!Ref scalar",
        "!Ref mapping",
        "!Ref sequence",
        "!Sub scalar",
        "!Sub mapping",
        "!Sub sequence",
        "!GetAtt scalar",
        "!GetAtt mapping",
        "!GetAtt sequence",
        "!GetAZs scalar",
        "!GetAZs mapping",
        "!GetAZs sequence",
        "!ImportValue scalar",
        "!ImportValue mapping",
        "!ImportValue sequence",
        "!Select scalar",
        "!Select mapping",
        "!Select sequence",
        "!Split scalar",
        "!Split mapping",
        "!Split sequence",
        "!Join scalar",
        "!Join mapping",
        "!Join sequence"
      }
    }
  }
}

-- Null-ls
null_ls.setup({
  debug = false,
  on_attach = on_attach,
  diagnostics_format = '[#{c}] #{m} (#{s})',
  sources = {
    null_ls.builtins.diagnostics.codespell,
    null_ls.builtins.diagnostics.cppcheck,
    null_ls.builtins.diagnostics.cfn_lint,
    null_ls.builtins.diagnostics.erb_lint.with({
      command = 'bundle',
      ignore_stderr = true,
      args = vim.list_extend(
        { "exec", "erblint" },
        null_ls.builtins.diagnostics.erb_lint._opts.args
      )
    }),
    null_ls.builtins.diagnostics.hadolint,
    null_ls.builtins.diagnostics.markdownlint,
    null_ls.builtins.formatting.rubocop.with({
      command = 'bundle',
      args = vim.list_extend(
        { "exec", "rubocop" },
        null_ls.builtins.formatting.rubocop._opts.args
      )
    }),
    null_ls.builtins.diagnostics.sqlfluff.with({ extra_args = {"--dialect", "mysql"}}),
    null_ls.builtins.diagnostics.yamllint.with({ filetypes = {'yaml'} }),
    null_ls.builtins.formatting.erb_lint.with({
      command = 'bundle',
      ignore_stderr = true,
      args = vim.list_extend(
        { "exec", "erblint" },
        null_ls.builtins.formatting.erb_lint._opts.args
      )
    }),
    null_ls.builtins.formatting.codespell,
    null_ls.builtins.formatting.prettierd,
    null_ls.builtins.diagnostics.rubocop.with({
      command = 'bundle',
      args = vim.list_extend(
        { "exec", "rubocop" },
        null_ls.builtins.diagnostics.rubocop._opts.args
      )
    }),
    null_ls.builtins.formatting.sqlfluff.with({ extra_args = {"--dialect", "mysql"}}),
  }
})
