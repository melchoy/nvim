local M = {}
local uv = vim.uv or vim.loop
local scheduled = false
local last_refresh_ms = 0

-- Neo-tree refreshes Git at state.path, which may be a non-repository folder
-- containing worktrees. Its nested-repo discovery skips already known repos,
-- so explicitly update their caches before refreshing the filesystem view.
M.refresh = function()
  if scheduled then
    return
  end
  scheduled = true
  local delay = math.max(120, 1200 - (uv.now() - last_refresh_ms))
  vim.defer_fn(function()
    scheduled = false
    last_refresh_ms = uv.now()
    local manager = require("neo-tree.sources.manager")
    local renderer = require("neo-tree.ui.renderer")
    local utils = require("neo-tree.utils")
    local git = require("neo-tree.git")
    local config = require("neo-tree").config
    local roots = {}

    if config.enable_git_status then
      manager._for_each_state("filesystem", function(state)
        if not state.path or not renderer.window_exists(state) then
          return
        end
        for root in pairs(git.worktrees) do
          if utils.is_subpath(state.path, root, true)
            or utils.is_subpath(root, state.path, true) then
            roots[root] = state.git_base_by_worktree or {}
          end
        end
      end)
      for root, bases in pairs(roots) do
        if config.git_status_async then
          git.status_async(root, bases, config.git_status_async_options or {})
        else
          git.status(root, bases, false)
        end
      end
    end
    manager.refresh("filesystem")
  end, delay)
end

M.setup = function()
  local events = require("neo-tree.events")
  local handler = {
    event = events.GIT_EVENT,
    id = "config_neotree_worktree_git_refresh",
    handler = M.refresh,
  }
  events.unsubscribe(handler)
  events.subscribe(handler)
  vim.api.nvim_create_autocmd({ "FocusGained", "TermClose" }, {
    group = vim.api.nvim_create_augroup("NeotreeGitRefresh", { clear = true }),
    callback = M.refresh,
  })
end

return M
