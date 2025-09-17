-- Global project rules that apply to ALL projects
-- This file contains common overrides/settings that should apply
-- whenever ANY project config is loaded

return {
  -- Global settings applied to all projects
  settings = {
    -- Common project-wide vim options
    vim.opt.backup = false,        -- Don't create backup files in projects
    vim.opt.writebackup = false,   -- Don't create backup on write
    vim.opt.swapfile = false,      -- Don't use swap files in projects
    vim.opt.undofile = true,       -- Enable persistent undo for projects
  },
  
  -- Global keymaps for ALL projects (in addition to your main config)
  keymaps = {
    -- Project navigation (available in any project)
    { 'n', '<leader>pr', ':ProjectConfigReload<CR>', { desc = 'Project: Reload config' } },
    { 'n', '<leader>ps', ':ProjectConfigShow<CR>', { desc = 'Project: Show config path' } },
    { 'n', '<leader>pp', function() 
        local root = vim.g.project_root or vim.fn.getcwd()
        vim.cmd('Telescope find_files cwd=' .. root)
      end, { desc = 'Project: Find files' } 
    },
    { 'n', '<leader>pg', function() 
        local root = vim.g.project_root or vim.fn.getcwd()
        vim.cmd('Telescope live_grep cwd=' .. root)
      end, { desc = 'Project: Live grep' }
    },
    
    -- Common project commands (can be overridden by specific projects)
    { 'n', '<leader>pb', function() 
        vim.notify('No project-specific build command defined', vim.log.levels.WARN)
      end, { desc = 'Project: Build (default)' }
    },
    { 'n', '<leader>pt', function()
        vim.notify('No project-specific test command defined', vim.log.levels.WARN) 
      end, { desc = 'Project: Test (default)' }
    },
    { 'n', '<leader>pl', function()
        vim.notify('No project-specific lint command defined', vim.log.levels.WARN)
      end, { desc = 'Project: Lint (default)' }
    },
  },
  
  -- Global autocommands for projects
  autocommands = {
    {
      event = 'BufEnter',
      pattern = '*',
      callback = function()
        -- Set project root when entering buffers in projects
        if vim.g.project_root then
          vim.cmd('lcd ' .. vim.g.project_root)
        end
      end,
      desc = 'Set working directory to project root'
    },
  },
  
  -- Common project file patterns and behaviors
  patterns = {
    -- Auto-detect project types and set basic configs
    javascript = {
      files = { 'package.json', 'yarn.lock', 'pnpm-lock.yaml' },
      settings = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
      end,
    },
    rust = {
      files = { 'Cargo.toml', 'Cargo.lock' },
      settings = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
      end,
    },
    python = {
      files = { 'pyproject.toml', 'setup.py', 'requirements.txt' },
      settings = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
      end,
    },
  },
  
  -- Global project environment variables
  environment = {
    -- These get set for all projects
    EDITOR = 'nvim',
    GIT_EDITOR = 'nvim',
  },
}