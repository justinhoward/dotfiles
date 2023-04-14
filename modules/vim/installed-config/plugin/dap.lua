local dap = require('dap')
require("nvim-dap-virtual-text").setup()
require('dap-ruby').setup()

vim.fn.sign_define("DapBreakpoint", { text = '' })
vim.fn.sign_define("DapBreakpointCondition", { text = '' })
vim.fn.sign_define("DapLogPoint", { text = '' })
vim.fn.sign_define("DapStopped", { text = '' })
vim.fn.sign_define("DapBreakpointRejected", { text = '' })
