return {
  {
    'tpope/vim-fugitive',
    dependencies = { 'tpope/vim-rhubarb' },
    cmd = { 'G', 'Git', 'Gdiffsplit', 'Gread', 'Gwrite', 'Gedit', 'GBrowse', 'Gclog', 'Glog' },
    -- Installed but previously keyless. gitsigns owns per-hunk ops (<leader>h*); this adds
    -- the one entry point gitsigns lacks: the status porcelain for staging, committing,
    -- and rebasing across the whole worktree.
    keys = {
      { '<leader>gs', '<cmd>Git<cr>', desc = 'Git status (fugitive)' },
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      current_line_blame = true,
      on_attach = function(bufnr)
        local gs = require('gitsigns')

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation. Prefer gitsigns nav wherever gitsigns tracks the buffer (incl.
        -- the diffview working-tree window) so the cursor lands on gitsigns' own hunk
        -- anchor and <leader>hs/hr stay reliable — native ]c and gitsigns disagree on
        -- where a deletion hunk sits (a deletion's anchor is the single surviving line
        -- above the gap; the built-in diff motion lands at/below it). Fall back to the
        -- built-in diff motion only in diff buffers gitsigns isn't attached to (the
        -- nvimdiff mergetool on temp files), detected via the status-dict buffer var.
        map('n', ']c', function()
          if vim.wo.diff and not vim.b.gitsigns_status_dict then return ']c' end
          vim.schedule(function() gs.nav_hunk('next') end)
          return '<Ignore>'
        end, { expr = true, desc = 'Next git hunk' })

        map('n', '[c', function()
          if vim.wo.diff and not vim.b.gitsigns_status_dict then return '[c' end
          vim.schedule(function() gs.nav_hunk('prev') end)
          return '<Ignore>'
        end, { expr = true, desc = 'Previous git hunk' })

        -- Actions
        map('n', '<leader>hs', gs.stage_hunk, { desc = 'Stage hunk' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = 'Reset hunk' })
        map('v', '<leader>hs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, { desc = 'Stage selected lines' })
        map('v', '<leader>hr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, { desc = 'Reset selected lines' })
        map('n', '<leader>hS', gs.stage_buffer, { desc = 'Stage buffer' })
        -- undo_stage_hunk was removed in newer gitsigns (stage_hunk now toggles).
        map('n', '<leader>hu', gs.undo_stage_hunk or gs.stage_hunk, { desc = 'Undo stage hunk' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = 'Reset buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = 'Preview hunk' })
        map('n', '<leader>hb', function() gs.blame_line({ full = true }) end, { desc = 'Blame line (full)' })
        map('n', '<leader>vb', gs.toggle_current_line_blame, { desc = 'Toggle line blame' })
        map('n', '<leader>hd', gs.diffthis, { desc = 'Diff against index' })
        map('n', '<leader>hD', function() gs.diffthis('~') end, { desc = 'Diff against last commit' })
        map('n', '<leader>vd', gs.toggle_deleted, { desc = 'Toggle deleted lines' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Inner git hunk' })
      end,
    },
  },
  {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons' },
    -- Changeset-level review surface. gitsigns handles per-hunk review inside a single
    -- buffer; diffview shows the whole diff at once with a file panel — the piece that was
    -- being outsourced to `git diff | delta` on the CLI. Primary use: review everything an
    -- agent changed, jump into any file to refine it with LSP, then stage with the gitsigns
    -- maps above. `:DiffviewOpen` alone shows uncommitted changes; pass a range (e.g.
    -- `:DiffviewOpen main...HEAD` or `HEAD~2`) to review committed work.
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory', 'DiffviewToggleFiles' },
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Diff view (uncommitted changes)' },
      { '<leader>gc', '<cmd>DiffviewClose<cr>', desc = 'Close diff view' },
      { '<leader>gl', '<cmd>DiffviewFileHistory %<cr>', desc = 'File history (current file)' },
      { '<leader>gL', '<cmd>DiffviewFileHistory<cr>', desc = 'File history (repo)' },
    },
    opts = {},
  },
}
