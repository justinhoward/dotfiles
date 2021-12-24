local dap = require('dap')
require("nvim-dap-virtual-text").setup()

-- From https://github.com/suketa/nvim-dap-ruby
dap.adapters.ruby = function(callback, config)
  local stdout = vim.loop.new_pipe(false)
  local waiting = config.waiting or 1000
  local port = config.port or 38698
  local server = config.server or '127.0.0.1'
  local handle
  local pid_or_err
  local args
  local script

  if config.input_port then
    port = vim.fn.input('Port (' .. port .. '):')
    if port == '' then port = 38698 end
  end

  args = { '--open', '--port', port }

  if config.is_command then
    table.insert(args, '-c')
  end

  table.insert(args, '--')

  if config.args then
    for _, arg in ipairs(config.args) do
      table.insert(args, arg)
    end
  end

  if config.input_args then
    local input_args = vim.split(vim.fn.input('Run: '), ' ', { plain = true, trimempty = true })
    for _, arg in ipairs(config.args) do
      table.insert(args, arg)
    end
  end

  if config.file then
    table.insert(args, config.file)
  end

  if config.args or config.input_args or config.file then
    local opts = {
      stdio = {nil, stdout},
      args = args,
      detached = false
    }

    handle, pid_or_err = vim.loop.spawn("rdbg", opts, function(code)
      handle:close()
      if code ~= 0 then
        print('rdbg exited with code', code)
      end
    end)

    assert(handle, 'Error running rdbg: ' .. tostring(pid_or_err))

    stdout:read_start(function(err, chunk)
      assert(not err, err)
      if chunk then
        vim.schedule(function()
          require('dap.repl').append(chunk)
        end)
      end
    end)
  end

  -- Wait for rdbg to start
  vim.defer_fn(
    function()
      callback({type = "server", host = server, port = port})
    end,
  waiting)
end

dap.configurations.ruby = {
  {
    type = 'ruby',
    name = 'current file',
    request = 'attach',
    is_command = true,
    args = { 'ruby' },
    file = '${file}',
  },
  {
    type = 'ruby',
    name = 'current rspec file',
    request = 'attach',
    is_command = true,
    args = { 'bundle', 'exec', 'rspec' },
    file = '${file}',
  },
  {
    type = 'ruby',
    name = 'input ruby script',
    request = 'attach',
    is_command = true,
    args = { 'ruby' },
    input_args = true,
  },
  {
    type = 'ruby',
    name = 'input bundle exec',
    request = 'attach',
    args = { 'bundle', 'exec' },
    input_args = true,
  },
  {
    type = 'ruby',
    name = 'attach to port',
    request = 'attach',
    input_port = true,
    waiting = 0,
  }
}
