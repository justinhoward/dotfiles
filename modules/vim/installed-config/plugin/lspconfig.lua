local nvim_lsp = require('lspconfig')
local null_ls = require('null-ls')
local cmp_nvim_lsp = require('cmp_nvim_lsp')

vim.fn.sign_define("DiagnosticSignError", { text = ' ', texthl = 'DiagnosticSignError' })
vim.fn.sign_define("DiagnosticSignWarn", { text = ' ', texthl = 'DiagnosticSignWarn' })
vim.fn.sign_define("DiagnosticSignInfo", { text = ' ', texthl = 'DiagnosticSignInfo' })
vim.fn.sign_define("DiagnosticSignHint", { text = ' ', texthl = 'DiagnosticSignHint' })

vim.diagnostic.config {
  severity_sort = true
}

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', "<cmd>lua require('fzf-lua').lsp_declarations()<cr>", opts)
  buf_set_keymap('n', 'gd', "<cmd>lua require('fzf-lua').lsp_definitions()<cr>", opts)
  buf_set_keymap('n', 'gy', "<cmd>lua require('fzf-lua').lsp_typedefs()<cr>", opts)
  buf_set_keymap('n', 'gr', "<cmd>lua require('fzf-lua').lsp_references()<cr>", opts)
  buf_set_keymap('n', 'gi', "<cmd>lua require('fzf-lua').lsp_implementations()<cr>", opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
  buf_set_keymap('n', '<leader>fn', '<cmd>lua vim.diagnostic.goto_next()<cr>', opts)
  buf_set_keymap('n', '<leader>fp', '<cmd>lua vim.diagnostic.goto_prev()<cr>', opts)
  buf_set_keymap('n', '<leader>ff', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
  buf_set_keymap('n', '<leader>fa', "<cmd>lua require('fzf-lua').lsp_document_diagnostics()<cr>", opts)
  buf_set_keymap('n', '<leader>fA', "<cmd>lua require('fzf-lua').lsp_workspace_diagnostics()<cr>", opts)
  buf_set_keymap('n', '<leader>]', "<cmd>lua require('fzf-lua').lsp_document_symbols()<cr>", opts)
  buf_set_keymap('n', '<leader>}', "<cmd>lua require('fzf-lua').lsp_workspace_symbols()<cr>", opts)
  buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
  buf_set_keymap('n', '<leader>ra', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
  buf_set_keymap('n', '<leader>rf', '<cmd>lua vim.lsp.buf.format { async = true }<cr>', opts)
  buf_set_keymap('v', '<leader>rf', '<cmd>lua vim.lsp.buf.format { async = true }<cr>', opts)
end

local flags = {
  debounce_text_changes = 150,
}

-- Add cmp completion capabilities
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Default configs
local servers = { 'ccls', 'tsserver', 'bashls', 'pylsp', 'marksman' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = flags
  }
end

-- Individual configs
nvim_lsp.solargraph.setup {
  capabilities = capabilities,
  on_attach = on_attach,
  flags = flags,
  init_options = {
    formatting = false
  },
  settings = {
    solargraph = {
      diagnostics = false
    }
  }
}

nvim_lsp.yamlls.setup {
  capabilities = capabilities,
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
        "!FindInMap mappping",
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
    null_ls.builtins.code_actions.eslint_d,
    null_ls.builtins.code_actions.shellcheck,
    null_ls.builtins.diagnostics.codespell,
    null_ls.builtins.diagnostics.cppcheck,
    null_ls.builtins.diagnostics.cfn_lint,
    null_ls.builtins.diagnostics.erb_lint.with({
      command = 'bundle',
      ignore_stderr = true,
      args = vim.list_extend(
        { "exec", "erblint" },
        require("null-ls").builtins.diagnostics.erb_lint._opts.args
      )
    }),
    null_ls.builtins.diagnostics.eslint_d,
    null_ls.builtins.diagnostics.flake8,
    null_ls.builtins.diagnostics.hadolint,
    null_ls.builtins.diagnostics.markdownlint,
    null_ls.builtins.formatting.rubocop.with({
      command = 'bundle',
      args = vim.list_extend(
        { "exec", "rubocop" },
        require("null-ls").builtins.formatting.rubocop._opts.args
      )
    }),
    null_ls.builtins.diagnostics.sqlfluff.with({ extra_args = {"--dialect", "mysql"}}),
    null_ls.builtins.diagnostics.yamllint.with({ filetypes = {'yaml'} }),
    null_ls.builtins.formatting.erb_lint.with({
      command = 'bundle',
      ignore_stderr = true,
      args = vim.list_extend(
        { "exec", "erblint" },
        require("null-ls").builtins.formatting.erb_lint._opts.args
      )
    }),
    null_ls.builtins.formatting.codespell,
    null_ls.builtins.formatting.eslint_d,
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.diagnostics.rubocop.with({
      command = 'bundle',
      args = vim.list_extend(
        { "exec", "rubocop" },
        require("null-ls").builtins.diagnostics.rubocop._opts.args
      )
    }),
    null_ls.builtins.formatting.sqlfluff.with({ extra_args = {"--dialect", "mysql"}}),
  }
})

-- Additional tools
require('rust-tools').setup {
    tools = { -- rust-tools options
        hover_with_actions = false,
        inlay_hints = {
            parameter_hints_prefix = "◀ ",
            other_hints_prefix  = "▶ ",
        }
    },
    server = {
      on_attach = on_attach,
    }
}
