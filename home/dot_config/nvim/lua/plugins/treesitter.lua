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
      -- Force native .so parser builds. This Neovim (Homebrew, linked against
      -- libtree-sitter with no wasmtime) cannot load .wasm parsers, so arborist's
      -- WASM-first default just burns a doomed WASM build attempt before falling
      -- back to native. For huge generated grammars (e.g. kitty ~5 MB, zsh ~33 MB)
      -- that WASM attempt (`clang -Os`, no timeout) hangs for hours and pins a
      -- CPU core. Native builds are bounded and are the only format this Neovim
      -- can actually load.
      require('arborist').setup({
        prefer_wasm = false,
      })
    end,
  },
}
