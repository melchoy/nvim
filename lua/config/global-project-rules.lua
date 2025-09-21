-- Global project rules that apply to ALL projects
-- This file contains common overrides/settings that should apply
-- whenever ANY project config is loaded

-- Ensure project pickers (Telescope) and greps include Markdown files under any
-- "local/" directory even when those paths are gitignored by the project.
-- We do this here so it applies to every project loaded via project-config.
pcall(function()
  local ok_telescope, telescope = pcall(require, 'telescope')
  if ok_telescope then
    local ok_cfg, telescope_config = pcall(require, 'telescope.config')
    if ok_cfg then
      local vimgrep_arguments = vim.deepcopy(telescope_config.values.vimgrep_arguments)
      -- Search hidden files and do not respect VCS ignore so that
      -- local/**/*.md shows up even if gitignored. Then re-exclude heavy dirs.
      table.insert(vimgrep_arguments, '--hidden')
      table.insert(vimgrep_arguments, '--no-ignore-vcs')

      local exclude_globs = {
        '**/.git/*',
        '**/node_modules/*',
        '**/bower_components/*',
        '**/vendor/*',
        '**/dist/*',
        '**/build/*',
        '**/.next/*',
        '**/.nuxt/*',
        '**/out/*',
        '**/target/*',
        '**/.cache/*',
        '**/.venv/*',
        '**/venv/*',
        '**/__pycache__/*',
        '**/tmp/*',
        '**/temp/*',
        '**/log/*',
        '**/logs/*',
        -- Hide any folder named "xtra" globally
        '**/xtra/**',
        -- Hide common tool/config directories globally
        '**/.nvim/**',
        '**/.cursor/**',
        '**/.coderabbit/**',
      }
      for _, g in ipairs(exclude_globs) do
        table.insert(vimgrep_arguments, '-g'); table.insert(vimgrep_arguments, '!' .. g)
      end

      -- For find_files, force rg so we can apply the same behavior
      local find_command = { 'rg', '--files', '--color', 'never', '--hidden', '--no-ignore-vcs' }
      for _, g in ipairs(exclude_globs) do
        table.insert(find_command, '-g'); table.insert(find_command, '!' .. g)
      end

      -- Do not add positive include globs for `local/**` here, since that would
      -- restrict results to only those paths. We rely on --no-ignore-vcs so
      -- gitignored `local/` still shows up, and Neo-tree's always_show handles
      -- the file tree visibility.

      local defaults = { vimgrep_arguments = vimgrep_arguments }
      -- Merge with existing defaults if telescope was set up already
      defaults = vim.tbl_deep_extend('force', telescope_config.values or {}, defaults)

      -- Ensure file_ignore_patterns contains robust xtra patterns (POSIX/Windows)
      defaults.file_ignore_patterns = defaults.file_ignore_patterns or {}
      local ignore_patterns = {
        -- Any path segment named xtra
        '[\\/]xtra[\\/]', '^xtra[\\/]', '[\\/]xtra$',
        -- Dot-directories
        '[\\/]\.nvim[\\/]', '[\\/]\.cursor[\\/]', '[\\/]\.coderabbit[\\/]',
      }
      for _, p in ipairs(ignore_patterns) do table.insert(defaults.file_ignore_patterns, p) end

      telescope.setup({
        defaults = defaults,
        pickers = { find_files = { find_command = find_command } },
      })
    end
  end
end)

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