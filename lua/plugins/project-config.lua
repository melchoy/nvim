return {
  name = "project-config.nvim",
  dir = vim.fn.stdpath("config"),
  config = function()
    local M = {}
    
    -- Configuration options
    local config = {
      nvimrc_files = { '.nvimrc', '.nvim/init.lua' },
      max_search_depth = 10,  -- Prevent infinite loops
      debug = false,          -- Set to true for debug messages
    }
    
    -- Debug logging
    local function debug_log(msg)
      if config.debug then
        print("[project-config] " .. msg)
      end
    end
    
    -- Find project config by walking up directories
    local function find_project_config(start_dir)
      local current_dir = start_dir or vim.fn.expand('%:p:h')
      local depth = 0
      
      debug_log("Starting search from: " .. current_dir)
      
      while current_dir ~= '/' and depth < config.max_search_depth do
        for _, config_file in ipairs(config.nvimrc_files) do
          local config_path = current_dir .. '/' .. config_file
          debug_log("Checking: " .. config_path)
          
          if vim.fn.filereadable(config_path) == 1 then
            debug_log("Found project config: " .. config_path)
            return config_path, current_dir
          end
        end
        
        -- Move up one directory
        current_dir = vim.fn.fnamemodify(current_dir, ':h')
        depth = depth + 1
      end
      
      debug_log("No project config found")
      return nil, nil
    end
    
    -- Apply global project rules
    local function apply_global_rules(project_root)
      debug_log("Applying global project rules")
      
      local ok, global_rules = pcall(require, 'config.global-project-rules')
      if not ok then
        debug_log("No global project rules found")
        return
      end
      
      -- Apply global settings
      if global_rules.settings then
        debug_log("Applying global settings")
        -- Settings are already executed when the module loads
      end
      
      -- Apply global keymaps
      if global_rules.keymaps then
        debug_log("Applying global keymaps")
        for _, keymap in ipairs(global_rules.keymaps) do
          local mode, lhs, rhs, opts = keymap[1], keymap[2], keymap[3], keymap[4] or {}
          vim.keymap.set(mode, lhs, rhs, opts)
        end
      end
      
      -- Apply global autocommands
      if global_rules.autocommands then
        debug_log("Applying global autocommands")
        local augroup = vim.api.nvim_create_augroup('GlobalProjectRules', { clear = true })
        for _, autocmd in ipairs(global_rules.autocommands) do
          vim.api.nvim_create_autocmd(autocmd.event, {
            group = augroup,
            pattern = autocmd.pattern,
            callback = autocmd.callback,
            desc = autocmd.desc,
          })
        end
      end
      
      -- Auto-detect project type and apply patterns
      if global_rules.patterns then
        debug_log("Detecting project type")
        for project_type, pattern_config in pairs(global_rules.patterns) do
          for _, file in ipairs(pattern_config.files) do
            if vim.fn.filereadable(project_root .. '/' .. file) == 1 then
              debug_log("Detected project type: " .. project_type)
              if pattern_config.settings then
                pattern_config.settings()
              end
              break
            end
          end
        end
      end
      
      -- Set environment variables
      if global_rules.environment then
        debug_log("Setting global environment variables")
        for key, value in pairs(global_rules.environment) do
          vim.env[key] = value
        end
      end
    end

    -- Load project configuration file
    local function load_project_config(config_path, project_root)
      debug_log("Loading project config: " .. config_path)
      
      -- Store project root for potential use in project config
      vim.g.project_root = project_root
      
      -- First apply global project rules
      apply_global_rules(project_root)
      
      -- Then load project-specific config (which can override global rules)
      local ok, error_msg = pcall(function()
        if config_path:match('%.lua$') then
          -- Lua file - use dofile
          dofile(config_path)
        else
          -- Assume .nvimrc (vim script or lua in vim script wrapper)
          vim.cmd('source ' .. vim.fn.fnameescape(config_path))
        end
      end)
      
      if not ok then
        vim.notify(
          "Error loading project config " .. config_path .. ": " .. error_msg, 
          vim.log.levels.ERROR
        )
      else
        debug_log("Successfully loaded project config")
        vim.notify("📁 Loaded project config from " .. vim.fn.fnamemodify(config_path, ':~:.'), vim.log.levels.INFO)
      end
    end
    
    -- Check if we should load project config for current buffer
    local function should_load_config(bufnr)
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      
      -- Skip for empty buffers, help files, etc.
      if bufname == "" then return false end
      if vim.bo[bufnr].buftype ~= "" then return false end
      if vim.bo[bufnr].filetype == "help" then return false end
      
      return true
    end
    
    -- Main function to discover and load project config
    local function setup_project_config(bufnr)
      bufnr = bufnr or vim.api.nvim_get_current_buf()
      
      if not should_load_config(bufnr) then
        debug_log("Skipping config load for buffer " .. bufnr)
        return
      end
      
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      local file_dir = vim.fn.fnamemodify(bufname, ':h')
      
      local config_path, project_root = find_project_config(file_dir)
      if config_path then
        load_project_config(config_path, project_root)
      else
        -- Even if there is no per-project config file, still apply global rules
        -- so behaviors like search/globs are consistent across all projects.
        project_root = project_root or file_dir
        -- Store project root and apply global rules
        vim.g.project_root = project_root
        apply_global_rules(project_root)
      end
    end
    
    -- Setup autocommands
    local augroup = vim.api.nvim_create_augroup('ProjectConfig', { clear = true })
    
    -- Load project config when opening files
    vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
      group = augroup,
      callback = function(ev)
        -- Small delay to let other plugins initialize first
        vim.defer_fn(function()
          setup_project_config(ev.buf)
        end, 100)
      end,
      desc = 'Load project-specific configuration'
    })
    
    -- Also check current buffer on plugin load
    vim.defer_fn(function()
      setup_project_config()
    end, 200)
    
    -- Expose API for manual triggering
    M.setup = function(opts)
      config = vim.tbl_extend('force', config, opts or {})
    end
    
    M.reload_project_config = function()
      setup_project_config()
    end
    
    M.find_project_config = find_project_config
    
    -- User command for manual reload
    vim.api.nvim_create_user_command('ProjectConfigReload', function()
      M.reload_project_config()
    end, { desc = 'Reload project configuration' })
    
    -- User command to find current project config
    vim.api.nvim_create_user_command('ProjectConfigShow', function()
      local config_path, project_root = find_project_config()
      if config_path then
        print("Project config: " .. config_path)
        print("Project root: " .. project_root)
      else
        print("No project config found")
      end
    end, { desc = 'Show current project configuration path' })
    
    -- Global access
    _G.ProjectConfig = M
  end,
}