vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.g.mapleader= " "

-- Clipboard integration for macOS
vim.opt.clipboard = "unnamedplus"

-- Ensure we're using the right clipboard provider on macOS
if vim.fn.has('macunix') == 1 then
  vim.g.clipboard = {
    name = 'macOS-clipboard',
    copy = {
      ['+'] = 'pbcopy',
      ['*'] = 'pbcopy',
    },
    paste = {
      ['+'] = 'pbpaste',
      ['*'] = 'pbpaste',
    },
    cache_enabled = 0,
  }
end

-- Toggle soft wrap per-window
vim.keymap.set('n', '<leader>ww', function()
  local winopts = vim.wo
  local enable = not winopts.wrap
  winopts.wrap = enable
  winopts.linebreak = enable
  winopts.breakindent = enable
end, { desc = 'Toggle wrap (window-local)' })

-- Open the current file in the system's default browser.
vim.keymap.set('n', '<leader>ob', function()
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then
    vim.notify('Current buffer has no file to open', vim.log.levels.WARN)
    return
  end

  local uri = vim.uri_from_fname(file)

  -- On macOS, opening a local file URL uses its file-type association rather
  -- than the default browser. Resolve the registered HTTPS handler and launch
  -- that application explicitly instead.
  if vim.fn.has('mac') == 1 then
    local handlers_path = vim.fn.expand('~/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist')
    local result = vim.system({ 'plutil', '-extract', 'LSHandlers', 'json', '-o', '-', handlers_path }, { text = true }):wait()
    local decoded, handlers = pcall(vim.json.decode, result.stdout or '')
    local browser

    if result.code == 0 and decoded then
      for _, handler in ipairs(handlers) do
        if handler.LSHandlerURLScheme == 'https' then
          browser = handler.LSHandlerRoleAll
          break
        end
      end
    end

    if not browser then
      vim.notify('Could not determine the default browser', vim.log.levels.ERROR)
      return
    end

    local job = vim.fn.jobstart({ 'open', '-b', browser, file }, {
      detach = true,
      on_exit = function(_, code)
        if code ~= 0 then
          vim.schedule(function()
            vim.notify(('Could not open the current file with %s'):format(browser), vim.log.levels.ERROR)
          end)
        end
      end,
    })
    if job <= 0 then
      vim.notify('Could not open the current file in the default browser', vim.log.levels.ERROR)
    end
    return
  end

  local _, err = vim.ui.open(uri)
  if err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = 'Open current file in browser' })

-- Start Neovim server for nvr integration
if vim.v.servername == nil or vim.v.servername == "" then
  vim.fn.serverstart(vim.fn.stdpath("run") .. "/nvim")
end

-- Line numbers
vim.opt.number = true         -- Show absolute line numbers
vim.opt.relativenumber = true -- Show relative line numbers

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")

-- Test change for gitsigns demo
