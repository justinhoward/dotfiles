-- Auto-enable csvview for CSV buffers. lazy.nvim loads the plugin on the `csv`
-- filetype (see lua/plugins/editor.lua) before this after/ftplugin runs.
require('csvview').enable()
