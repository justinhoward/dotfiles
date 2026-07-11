-- Helpers for detecting whether a gem is available in a project's bundle.
--
-- Ruby tooling (erblint, sorbet, rubocop, ...) should run through the project's
-- bundle so versions match Gemfile.lock. These checks let formatters/linters
-- skip gracefully when the gem isn't bundled, instead of erroring on every
-- unrelated repo. Results are cached per (lockfile, gem) for the session.

local M = {}

local cache = {}

--- Find the nearest Gemfile.lock at or above `dir`.
---@param dir string|nil directory to search upward from (defaults to cwd)
---@return string|nil path to Gemfile.lock, or nil if none found
local function find_lock(dir)
  return vim.fs.find('Gemfile.lock', {
    upward = true,
    type = 'file',
    path = dir or vim.fn.getcwd(),
  })[1]
end

--- Return true if `gem` is listed in an already-resolved Gemfile.lock.
--- Cached per (lockfile, gem) for the session.
---@param lock string path to a Gemfile.lock
---@param gem string gem name as it appears in Gemfile.lock (e.g. 'erb_lint')
---@return boolean
local function lock_has_gem(lock, gem)
  local key = lock .. '\0' .. gem
  local hit = cache[key]
  if hit == nil then
    hit = false
    local ok, lines = pcall(vim.fn.readfile, lock)
    if ok then
      -- Gemfile.lock lists gems as "    <name> (<version>)" under specs.
      local pat = '^%s+' .. gem:gsub('([%-%.%+])', '%%%1') .. ' %('
      for _, line in ipairs(lines) do
        if line:match(pat) then
          hit = true
          break
        end
      end
    end
    cache[key] = hit
  end
  return hit
end

--- Return true if `gem` is listed in the nearest Gemfile.lock above `dir`.
---@param dir string|nil directory to search upward from (defaults to cwd)
---@param gem string gem name as it appears in Gemfile.lock (e.g. 'erb_lint')
---@return boolean
function M.has_gem(dir, gem)
  local lock = find_lock(dir)
  return lock ~= nil and lock_has_gem(lock, gem)
end

--- Build a `vim.lsp.config` `root_dir` function that activates the server only
--- when one of `gems` is present in the nearest Gemfile.lock. When none are
--- bundled it never calls `on_dir`, so Neovim doesn't start (or try to spawn)
--- the server -- the graceful-skip we want for bundle-only tools like Sorbet.
---@param gems string|string[] gem name(s) as they appear in Gemfile.lock
---@return fun(bufnr: integer, on_dir: fun(root: string?))
function M.root_if_bundled(gems)
  if type(gems) == 'string' then
    gems = { gems }
  end
  return function(bufnr, on_dir)
    local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
    local lock = find_lock(dir)
    if not lock then
      return
    end
    for _, gem in ipairs(gems) do
      if lock_has_gem(lock, gem) then
        on_dir(vim.fs.dirname(lock))
        return
      end
    end
  end
end

return M
