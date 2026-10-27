-- Run from this checkout: nvim --headless -u NONE -i NONE -l tests/neotree-git-refresh.lua
local repo = vim.fn.getcwd()
vim.opt.rtp:prepend(repo)
for _, plugin in ipairs({ "plenary.nvim", "nui.nvim", "nvim-web-devicons", "neo-tree.nvim" }) do
  vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/" .. plugin)
end
local temp = vim.fn.tempname()
temp = (vim.uv or vim.loop).fs_realpath(vim.fn.fnamemodify(temp, ":h"))
  .. "/" .. vim.fn.fnamemodify(temp, ":t")
local main = temp .. "/main"
local linked = temp .. "/linked"
local function git(path, ...)
  local args = { "git", "-c", "core.hooksPath=/dev/null", "-c", "user.name=Neotree test",
    "-c", "user.email=neotree-test@example.invalid", "-C", path, ... }
  local output = vim.fn.system(args)
  assert(vim.v.shell_error == 0, output)
  return output
end
local function write(path, text)
  vim.fn.writefile({ text }, path .. "/tracked.txt")
end
local function wait_for(label, predicate)
  assert(vim.wait(10000, predicate, 20), "Timed out: " .. label)
end
local ok, err = xpcall(function()
  vim.fn.mkdir(main, "p")
  git(main, "init", "-b", "main")
  write(main, "initial")
  git(main, "add", ".")
  git(main, "commit", "-m", "initial")
  git(main, "worktree", "add", "-b", "linked", linked)
  require("neo-tree").setup({
    enable_git_status = true,
    filesystem = { use_libuv_file_watcher = true, filtered_items = { never_show = { ".git" } } },
  })
  require("neo-tree").ensure_config()
  write(linked, "before external commit")
  local g = require("neo-tree.git")
  g.status(linked)
  require("neo-tree.command").execute({ source = "filesystem", position = "left", dir = temp,
    reveal_file = linked .. "/tracked.txt" })
  local function modified(path)
    local w = g.worktrees[path]
    local status = w and w.status and w.status[path .. "/tracked.txt"]
    return status ~= nil
  end
  wait_for("initial modified cache", function() return modified(linked) end)
  vim.wait(1500, function() return false end, 20)
  git(linked, "add", ".")
  git(linked, "commit", "-m", "external commit reproduces stale cache")
  vim.wait(1800, function() return false end, 20)
  assert(modified(linked), "Baseline did not reproduce the stale nested-worktree cache")
  print("PASS: reproduced stale cache after external commit without workaround")

  local refresh = require("config.neotree-git-refresh")
  refresh.setup()
  refresh.setup() -- Reloading must replace the subscription and autocmds.
  assert(#vim.api.nvim_get_autocmds({ group = "NeotreeGitRefresh" }) == 2)
  refresh.refresh()
  wait_for("clear stale worktree cache", function() return not modified(linked) end)
  assert(require("neo-tree.sources.manager").get_state("filesystem").path == temp)
  print("PASS: repaired cached status while retaining the parent tree root")

  write(linked, "second change")
  wait_for("filesystem modification", function() return modified(linked) end)
  git(linked, "add", ".")
  git(linked, "commit", "-m", "second external commit")
  wait_for("automatic Git event refresh", function() return not modified(linked) end)
  print("PASS: external commit clears markers automatically through the Git watcher")

  write(linked, "discard on branch switch")
  wait_for("modified before branch switch", function() return modified(linked) end)
  git(linked, "checkout", "-f", "-b", "switched")
  wait_for("external branch switch", function() return not modified(linked) end)
  print("PASS: external branch switch clears cached modifications")

  write(main, "main worktree change")
  g.status(main)
  write(linked, "linked worktree change")
  g.status(linked)
  git(main, "add", ".")
  git(main, "commit", "-m", "main external commit")
  git(linked, "add", ".")
  git(linked, "commit", "-m", "linked external commit")
  vim.api.nvim_exec_autocmds("FocusGained", {})
  wait_for("multiple worktrees", function() return not modified(main) and not modified(linked) end)
  print("PASS: focus refresh updates multiple cached worktrees beneath the parent")

  -- The synchronous mode must update nested repositories too.
  require("neo-tree").config.git_status_async = false
  write(linked, "synchronous refresh")
  g.status(linked)
  git(linked, "add", ".")
  git(linked, "commit", "-m", "synchronous mode")
  refresh.refresh()
  wait_for("synchronous refresh", function() return not modified(linked) end)
  print("PASS: synchronous Git status mode")
end, debug.traceback)
require("neo-tree.sources.filesystem.lib.fs_watch").stop_watching()
vim.fn.delete(temp, "rf")
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
end
print("All Neo-tree worktree refresh regression checks passed")
vim.cmd("qa!")
