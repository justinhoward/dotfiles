local nvim_lsp = require('lspconfig')
local null_ls = require('null-ls')
local cmp_nvim_lsp = require('cmp_nvim_lsp')

vim.fn.sign_define("DiagnosticSignError", { text = ' ', texthl = 'DiagnosticSignError' })
vim.fn.sign_define("DiagnosticSignWarn", { text = ' ', texthl = 'DiagnosticSignWarn' })
vim.fn.sign_define("DiagnosticSignInformation", { text = ' ', texthl = 'DiagnosticSignInfo' })
vim.fn.sign_define("DiagnosticSignHint", { text = ' ', texthl = 'DiagnosticSignHint' })

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gy', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>fn', '<cmd>lua vim.diagnostic.goto_next()<cr>', opts)
  buf_set_keymap('n', '<space>fp', '<cmd>lua vim.diagnostic.goto_prev()<cr>', opts)
  buf_set_keymap('n', '<space>ff', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ra', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', '<space>rf', '<cmd>lua vim.lsp.buf.formatting()<cr>', opts)
  buf_set_keymap('v', '<space>rf', '<cmd>lua vim.lsp.buf.range_formatting()<cr>', opts)
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'ccls', 'tsserver', 'solargraph', 'bashls', 'pylsp' }
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end

null_ls.setup({
  debug = true,
  on_attach = on_attach,
  sources = {
    null_ls.builtins.formatting.rubocop.with({
      command = 'bundle',
      args = vim.list_extend(
        { "exec", "rubocop" },
        require("null-ls").builtins.diagnostics.rubocop._opts.args
      )
    }),
    null_ls.builtins.diagnostics.rubocop.with({
      command = 'bundle',
      args = vim.list_extend(
        { "exec", "rubocop" },
        require("null-ls").builtins.diagnostics.rubocop._opts.args
      )
    }),
    null_ls.builtins.diagnostics.shellcheck,
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.diagnostics.cppcheck,
    null_ls.builtins.diagnostics.markdownlint,
    null_ls.builtins.diagnostics.yamllint.with({ filetypes = {'yaml'} }),
    null_ls.builtins.code_actions.shellcheck,
    null_ls.builtins.diagnostics.eslint,
    null_ls.builtins.diagnostics.hadolint,
    null_ls.builtins.diagnostics.flake8,
  }
})

require('rust-tools').setup {
    tools = { -- rust-tools options
        hover_with_actions = false,
        inlay_hints = {
            parameter_hints_prefix = "◀ ",
            other_hints_prefix  = "▶ ",
        },
        runnables = { use_telescope = false },
    },
    server = {
      on_attach = on_attach,
    }
}
