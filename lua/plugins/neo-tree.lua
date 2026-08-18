return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("neo-tree").setup({
      close_if_last_window = false, -- Don't auto-close when last window
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
      default_component_configs = {
        container = {
          enable_character_fade = true
        },
      },
      filesystem = {
        hijack_netrw_behavior = "disabled", -- Don't hijack directory opening
        filtered_items = {
          visible = false,              -- Show filtered items dimmed instead of hidden
          show_hidden_count = true,
          hide_dotfiles = false,
          hide_gitignored = true,           -- Hide git-ignored files
          -- Always show local workspace directories and their contents,
          -- even if they are gitignored by the project.
          always_show = { 'local', 'scratch' },
          always_show_by_pattern = {
            "**/local/**",             -- show the folder and all nested content
            "**/scratch/**",
            "**/local/*.md",
            "**/local/**/*.md",
            "**/TODO.md",
            "**/*-TODO.md",
          },
          hide_by_name = {
            -- Project tooling/config dirs
            '.nvim', '.cursor', '.claude', '.coderabbit', '.github',
            'xtra',
            -- System files
            '.DS_Store',
            'thumbs.db',
            'desktop.ini',

            -- Dependencies
            'node_modules',
            'node-compile-cache',
            '.pnpm-store',
            '.npm',
            '.yarn',
            'bower_components',
            'vendor',
            '__pycache__',
            '.venv',
            'venv',

            -- Build outputs
            'dist',
            'build',
            '.next',
            '.nuxt',
            'out',
            'target',
            '.cache',
            'tmp',
            'temp',
            'log',
            'logs',

            -- IDE/Editor
            '.vscode',
            '.idea',
            '.vs',
            '*.swp',
            '*.swo',
            '*~',
          },
          hide_by_pattern = {
            -- Hide any directory named xtra anywhere
            "**/xtra/**",
            -- Patterns
            "*.tmp",
            "*.log",
            "*.pyc",
            "*.class",
            "*.o",
            "*.so",
            "*.dll",
            "*.exe",
          },
          never_show = {
            -- Never show these even if forced
            '.git',
            '.hg',
            '.svn',
          },
        },
        -- Toggle showing hidden files
        follow_current_file = {
          enabled = true,
        },
        use_libuv_file_watcher = true, -- Keep filesystem auto-refresh enabled
      },
    })

    -- Extra git-state refresh for external git actions, throttled to avoid churn.
    local uv = vim.uv or vim.loop
    local last_refresh_ms = 0
    local refresh_scheduled = false
    local refresh_cooldown_ms = 1200
    local refresh_debounce_ms = 120

    local refresh_filesystem_debounced = function()
      if refresh_scheduled then
        return
      end
      refresh_scheduled = true

      local now = uv.now()
      local since_last = now - last_refresh_ms
      local delay = refresh_debounce_ms
      if since_last < refresh_cooldown_ms then
        delay = refresh_cooldown_ms - since_last
      end

      vim.defer_fn(function()
        refresh_scheduled = false
        local ok, manager = pcall(require, "neo-tree.sources.manager")
        if ok then
          manager.refresh("filesystem")
          last_refresh_ms = uv.now()
        end
      end, delay)
    end

    vim.api.nvim_create_autocmd({ "FocusGained", "TermClose" }, {
      group = vim.api.nvim_create_augroup("NeotreeGitRefresh", { clear = true }),
      callback = refresh_filesystem_debounced,
    })

    vim.keymap.set('n', '<C-t>', ':Neotree filesystem toggle left<CR>', { desc = "Toggle file tree" })
  end
}
