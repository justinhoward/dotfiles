-- Auto-enable csvview for TSV buffers. lazy.nvim loads the plugin on the `tsv`
-- filetype (see lua/plugins/editor.lua) before this after/ftplugin runs.
require('csvview').enable()
