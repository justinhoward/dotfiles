vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

require 'neo-tree'.setup({
    filesystem = {
      filtered_items = {
        -- visible = true,
        -- hide_dotfiles = false,
        -- hide_gitignored = false,
        never_show = {
          '.DS_Store',
          '.tags',
          '.tags.lock'
        }
      }
    }
})
