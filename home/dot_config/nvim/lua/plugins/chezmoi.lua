return {
  -- Makes chezmoi source files first-class: `.tmpl` buffers are gotmpl with the
  -- target language injected, plus :Chezmoi preview/apply/pick.
  -- Must load eagerly (no ft/cmd): setup() registers the filetype detection that
  -- recognizes `.tmpl` sources; the heavy work is deferred internally until a
  -- managed file opens.
  {
    'dpezto/chezmoi-template.nvim',
    version = '*',
    lazy = false,
    ---@module 'chezmoi-template'
    ---@type chezmoi-template.Config
    opts = {
      -- Apply explicitly (:Chezmoi apply / chezmoi apply), not on every write.
      apply = { on_save = false },
    },
  },
}
