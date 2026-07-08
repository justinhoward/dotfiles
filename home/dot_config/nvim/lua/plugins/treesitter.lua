return {
  {
    'arborist-ts/arborist.nvim',
    -- Load eagerly. arborist.setup() registers custom tree-sitter query
    -- predicates (is?/is-not?/kind-eq?) that grammar highlight queries rely on
    -- (e.g. ruby's `#is-not? local`). Lazy-loading on BufReadPost races the
    -- built-in highlighter, which can evaluate the query before the predicate
    -- is registered and throw "No handler for is-not?". Eager load matches
    -- arborist's intended vim.pack usage and guarantees predicates exist first.
    lazy = false,
    config = function()
      require('arborist').setup()
    end,
  },
}
