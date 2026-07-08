return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'theHamsta/nvim-dap-virtual-text',
      'suketa/nvim-dap-ruby',
    },
    keys = {
      { '<F8>', function() require('dap').continue() end, desc = 'Debug: continue' },
      { '<F10>', function() require('dap').step_over() end, desc = 'Debug: step over' },
      { '<F11>', function() require('dap').step_into() end, desc = 'Debug: step into' },
      { '<F12>', function() require('dap').step_out() end, desc = 'Debug: step out' },
      { '<leader>dd', function() require('dap').toggle_breakpoint() end, desc = 'Toggle breakpoint' },
      {
        '<leader>dc',
        function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end,
        desc = 'Conditional breakpoint',
      },
      {
        '<leader>dL',
        function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end,
        desc = 'Log point',
      },
      { '<leader>dr', function() require('dap').repl.open() end, desc = 'Open REPL' },
      { '<leader>dl', function() require('dap').run_last() end, desc = 'Run last' },
      { '<leader>dk', function() require('dap.ui.widgets').hover() end, desc = 'Hover value' },
    },
    config = function()
      require('nvim-dap-virtual-text').setup()
      require('dap-ruby').setup()

      local sign = vim.fn.sign_define
      sign('DapBreakpoint', { text = '' })
      sign('DapBreakpointCondition', { text = '' })
      sign('DapLogPoint', { text = '' })
      sign('DapStopped', { text = '' })
      sign('DapBreakpointRejected', { text = '' })
    end,
  },
}
