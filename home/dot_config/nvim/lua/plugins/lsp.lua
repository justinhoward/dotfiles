return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'mason-org/mason.nvim',
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'saghen/blink.cmp',
    },
    config = function()
      vim.diagnostic.config({
        severity_sort = true,
        virtual_text = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = ' ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = ' ',
          },
        },
      })

      -- Buffer-local LSP keymaps, applied when any server attaches.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('config_lsp_attach', { clear = true }),
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          -- Work around a terraform-ls semantic token bug that freezes Neovim.
          -- Remove after https://github.com/hashicorp/terraform-ls/pull/2122 ships.
          if client and client.name == 'terraformls' then
            client.server_capabilities.semanticTokensProvider = nil
          end

          local fzf = require('fzf-lua')
          local function nmap(lhs, rhs, desc)
            vim.keymap.set('n', lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
          end

          nmap('gD', fzf.lsp_declarations, 'Go to declaration')
          nmap('gd', fzf.lsp_definitions, 'Go to definition')
          nmap('gy', fzf.lsp_typedefs, 'Go to type definition')
          nmap('grr', fzf.lsp_references, 'References')
          nmap('gri', fzf.lsp_implementations, 'Implementations')
          nmap('<leader>fn', function() vim.diagnostic.jump({ count = 1, float = true }) end, 'Next diagnostic')
          nmap('<leader>fp', function() vim.diagnostic.jump({ count = -1, float = true }) end, 'Previous diagnostic')
          nmap('<leader>ff', vim.diagnostic.open_float, 'Show diagnostic float')
          nmap('<leader>fa', fzf.lsp_document_diagnostics, 'Document diagnostics')
          nmap('<leader>fA', fzf.lsp_workspace_diagnostics, 'Workspace diagnostics')
          nmap('<leader>]', fzf.lsp_document_symbols, 'Document symbols')
          nmap('<leader>}', fzf.lsp_workspace_symbols, 'Workspace symbols')
          nmap('<leader>ri', function()
            vim.lsp.inlay_hint.enable(
              not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
              { bufnr = bufnr }
            )
          end, 'Toggle inlay hints')

          vim.keymap.set({ 'n', 'v' }, '<leader>rf', function()
            require('conform').format({ async = true, lsp_format = 'fallback' })
          end, { buffer = bufnr, silent = true, desc = 'Format buffer' })

          nmap('K', function()
            if not require('ufo').peekFoldedLinesUnderCursor() then
              vim.lsp.buf.hover()
            end
          end, 'Peek fold / hover')

          -- Let conform own formatting; don't inherit formatexpr from the LSP.
          vim.bo[bufnr].formatexpr = ''
        end,
      })

      -- Advertise blink.cmp's completion capabilities to every server.
      vim.lsp.config('*', {
        capabilities = require('blink.cmp').get_lsp_capabilities(),
      })

      vim.lsp.config('pylsp', {
        settings = {
          pylsp = {
            plugins = {
              autopep8 = { enabled = true },
              pylint = { enabled = true },
            },
          },
        },
      })

      -- https://shopify.github.io/ruby-lsp/rails-add-on.html
      vim.lsp.config('ruby_lsp', {
        init_options = {
          addonSettings = {
            ['Ruby LSP Rails'] = {
              enablePendingMigrationsPrompt = false,
            },
          },
        },
      })

      vim.lsp.config('sorbet', {
        cmd = { 'srb', 'tc', '--lsp' },
      })

      local terraform_capabilities = vim.lsp.protocol.make_client_capabilities()
      terraform_capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false
      vim.lsp.config('terraformls', {
        capabilities = terraform_capabilities,
      })

      vim.lsp.config('powershell_es', {
        bundle_path = vim.fn.expand('$HOME/.local/share/powershell_editor_services'),
      })

      vim.lsp.config('yamlls', {
        settings = {
          yaml = {
            schemaStore = {
              url = 'https://www.schemastore.org/api/json/catalog.json',
              enable = true,
            },
            customTags = {
              '!And scalar', '!And mapping', '!And sequence',
              '!If scalar', '!If mapping', '!If sequence',
              '!Not scalar', '!Not mapping', '!Not sequence',
              '!Equals scalar', '!Equals mapping', '!Equals sequence',
              '!Or scalar', '!Or mapping', '!Or sequence',
              '!FindInMap scalar', '!FindInMap mapping', '!FindInMap sequence',
              '!Base64 scalar', '!Base64 mapping', '!Base64 sequence',
              '!Cidr scalar', '!Cidr mapping', '!Cidr sequence',
              '!Ref scalar', '!Ref mapping', '!Ref sequence',
              '!Sub scalar', '!Sub mapping', '!Sub sequence',
              '!GetAtt scalar', '!GetAtt mapping', '!GetAtt sequence',
              '!GetAZs scalar', '!GetAZs mapping', '!GetAZs sequence',
              '!ImportValue scalar', '!ImportValue mapping', '!ImportValue sequence',
              '!Select scalar', '!Select mapping', '!Select sequence',
              '!Split scalar', '!Split mapping', '!Split sequence',
              '!Join scalar', '!Join mapping', '!Join sequence',
            },
          },
        },
      })

      require('mason').setup()
      require('mason-lspconfig').setup({
        -- Servers Mason can install cleanly. Ruby (ruby_lsp/sorbet via bundle),
        -- ccls, sourcekit, and powershell_es are provided by the system toolchain.
        ensure_installed = {
          'bashls',
          'eslint',
          'jsonls',
          'marksman',
          'pylsp',
          'ruff',
          'terraformls',
          'ts_ls',
          'yamlls',
        },
        -- Enablement is driven explicitly below for full control.
        automatic_enable = false,
      })
      require('mason-tool-installer').setup({
        -- cfn-lint and cppcheck are intentionally omitted: they are still wired
        -- up in nvim-lint but only run if present on PATH, so they don't lint
        -- every YAML/C file by surprise. Add them here to have Mason manage them.
        ensure_installed = {
          'codespell',
          'hadolint',
          'markdownlint',
          'prettierd',
          'sqlfluff',
          'stylua',
        },
      })

      vim.lsp.enable({
        'ccls',
        'eslint',
        'ts_ls',
        'bashls',
        'marksman',
        'jsonls',
        'ruff',
        'sourcekit',
        'terraformls',
        'ruby_lsp',
        'pylsp',
        'sorbet',
        'yamlls',
        'powershell_es',
      })
    end,
  },
}
