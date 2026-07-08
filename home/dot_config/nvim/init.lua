-- Entry point. Order matters: options set the leader before lazy.nvim loads so
-- plugin mappings resolve correctly.
require('config.options')
require('config.filetypes')
require('config.commands')
require('config.autocmds')
require('config.lazy')
require('config.keymaps')
