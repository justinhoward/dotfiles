return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
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
          -- Rename / code action under the <leader>r "refactor" group (also on
          -- the built-in grn/gra Neovim 0.11 defaults; these make them
          -- discoverable in which-key alongside format/inlay-hints).
          nmap('<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
          vim.keymap.set(
            { 'n', 'x' },
            '<leader>ra',
            vim.lsp.buf.code_action,
            { buffer = bufnr, silent = true, desc = 'Code action' }
          )
          nmap('<leader>ri', function()
            vim.lsp.inlay_hint.enable(
              not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
              { bufnr = bufnr }
            )
          end, 'Toggle inlay hints')

          vim.keymap.set({ 'n', 'v' }, '<leader>rf', function()
            -- lsp_format is set globally via conform's default_format_opts (and
            -- per-filetype, e.g. Ruby uses 'last' to format via ruby-lsp).
            require('conform').format({ async = true })
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
        -- ruby-lsp is a global (per-Ruby) install; not every project's Ruby has
        -- it. Only start when `ruby-lsp` actually resolves on PATH, so projects
        -- missing it just have no Ruby LSP instead of a loud spawn error. (The
        -- default cmd is a function, which bypasses Neovim's executable check,
        -- so we gate on activation here -- mirrors the Sorbet gate.)
        root_dir = function(bufnr, on_dir)
          if vim.fn.executable('ruby-lsp') == 1 then
            on_dir(vim.fs.root(bufnr, { 'Gemfile', '.git' }) or vim.fn.getcwd())
          end
        end,
      })

      -- Sorbet: prefer the project's bundled `srb` so type diagnostics honor
      -- Gemfile.lock; fall back to a global `srb` outside a bundle. Only start
      -- in real Sorbet projects (sorbet/config): the default Gemfile/.git
      -- markers would make Neovim try to spawn `srb` on every Ruby buffer and
      -- error loudly when Sorbet isn't installed. (A function cmd bypasses
      -- Neovim's executable check, so gating on start is what keeps it quiet.)
      -- Sorbet is bundle-only: it starts only when the project bundles Sorbet
      -- (checked via Gemfile.lock in root_dir), and runs through `bundle exec`
      -- so type diagnostics match the bundled version. Gating on activation --
      -- rather than inside cmd -- is what keeps it quiet in non-Sorbet projects:
      -- a function cmd bypasses Neovim's executable check, so if we let it start
      -- without Sorbet it would try to spawn `srb` and error loudly.
      vim.lsp.config('sorbet', {
        cmd = function(dispatchers, config)
          return vim.lsp.rpc.start(
            { 'bundle', 'exec', 'srb', 'tc', '--lsp' },
            dispatchers,
            { cwd = config.root_dir or vim.fn.getcwd() }
          )
        end,
        root_dir = require('config.bundle').root_if_bundled({ 'sorbet', 'sorbet-static-and-runtime' }),
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
          },
        },
      })

      -- Tooling (LSP servers, formatters, linters) is provided by the
      -- environment -- brew for global binaries, bundle exec for Ruby, and
      -- node_modules / self-resolving servers for JS -- not auto-installed by
      -- Neovim. Check availability with :checkhealth vim.lsp (servers) and
      -- :checkhealth conform (formatters); nvim-lint has no healthcheck, so a
      -- missing linter binary just skips silently (see plugins/lint-format.lua).
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
