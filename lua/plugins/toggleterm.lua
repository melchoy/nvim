return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      size = 20,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      persist_mode = true,
      direction = 'float',
      close_on_exit = true,
      shell = vim.o.shell,
      auto_scroll = true,
      float_opts = {
        border = 'rounded',
        width = 120,
        height = 30,
        winblend = 0,
      },
      winbar = {
        enabled = false,
        name_formatter = function(term)
          return term.name
        end
      },
      highlights = {
        Normal = {
          guibg = "NONE",
        },
        NormalFloat = {
          link = 'Normal'
        },
      },
    })

    -- Custom terminal keymaps
    function _G.set_terminal_keymaps()
      local opts = {buffer = 0}
      vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
      vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
      vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
      vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
      vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
      -- Let <C-l> work normally for terminal clear (remove window navigation)
      -- If you need window navigation from terminal, use <C-w>l instead
      vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
    end

    -- Apply keymaps to terminal buffers
    vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

    -- Additional terminal keymaps
    local Terminal = require('toggleterm.terminal').Terminal
    -- Forward declare helper so it's visible before definition
    local get_project_root

    -- LazyGit (float) at project root as a dedicated terminal
    local lazygit_term

    local function toggle_lazygit()
      if not lazygit_term then
        lazygit_term = Terminal:new({
          cmd = "lazygit",
          direction = "float",
          hidden = true,
          close_on_exit = true,
          float_opts = { border = "rounded" },
          count = 99, -- keep separate from default ToggleTerm instances
        })
      end
      -- Always launch from detected project root
      lazygit_term.dir = get_project_root()
      lazygit_term:toggle()
    end

    -- Keymap: launch LazyGit
    vim.keymap.set('n', '<leader>lg', toggle_lazygit, { desc = "LazyGit (project root)" })

    

    -- Function to find project root
    function get_project_root()
      -- Try git root first
      local git_root = vim.fn.system('git rev-parse --show-toplevel 2>/dev/null'):gsub('\n', '')
      if vim.v.shell_error == 0 and git_root ~= '' then
        return git_root
      end
      
      -- Look for common project markers
      local markers = { 'package.json', 'Cargo.toml', 'pyproject.toml', 'go.mod', '.git' }
      local current_dir = vim.fn.expand('%:p:h')
      
      while current_dir ~= '/' do
        for _, marker in ipairs(markers) do
          if vim.fn.filereadable(current_dir .. '/' .. marker) == 1 or 
             vim.fn.isdirectory(current_dir .. '/' .. marker) == 1 then
            return current_dir
          end
        end
        current_dir = vim.fn.fnamemodify(current_dir, ':h')
      end
      
      -- Fallback to current working directory
      return vim.fn.getcwd()
    end

    -- Root directory terminal toggle
    vim.keymap.set('n', '<leader>tr', function()
      local root_dir = get_project_root()
      vim.cmd('ToggleTerm dir=' .. vim.fn.fnameescape(root_dir))
    end, { desc = "Toggle: Terminal at project root" })

    -- Horizontal terminal (bottom panel) - current directory
    vim.keymap.set('n', '<leader>tt', ':ToggleTerm direction=horizontal<CR>', { desc = "Toggle: Terminal (horizontal)" })
    
    -- Vertical terminal (side panel)  
    vim.keymap.set('n', '<leader>tv', ':ToggleTerm direction=vertical<CR>', { desc = "Toggle: Terminal (vertical)" })
    
    -- Floating terminal
    vim.keymap.set('n', '<leader>tf', ':ToggleTerm direction=float<CR>', { desc = "Toggle: Terminal (floating)" })
    
    -- Project-specific terminals (integrate with project config)
    local function project_terminal(cmd, name)
      local term = Terminal:new({
        cmd = cmd,
        display_name = name,
        direction = "horizontal",
        close_on_exit = false,  -- Keep open to see results
        auto_scroll = true,
      })
      return term
    end

    -- Common project commands
    vim.keymap.set('n', '<leader>pb', function()
      -- Default build command (can be overridden in project config)
      local build_cmd = vim.g.project_build_cmd or "echo 'No build command configured'"
      local build_term = project_terminal(build_cmd, "Build")
      build_term:toggle()
    end, { desc = "Project: Build" })

    vim.keymap.set('n', '<leader>pt', function()
      -- Default test command (can be overridden in project config)
      local test_cmd = vim.g.project_test_cmd or "echo 'No test command configured'"
      local test_term = project_terminal(test_cmd, "Test")
      test_term:toggle()
    end, { desc = "Project: Test" })

    vim.keymap.set('n', '<leader>pl', function()
      -- Default lint command (can be overridden in project config)
      local lint_cmd = vim.g.project_lint_cmd or "echo 'No lint command configured'"
      local lint_term = project_terminal(lint_cmd, "Lint")
      lint_term:toggle()
    end, { desc = "Project: Lint" })

    -- Multiple terminal instances
    vim.keymap.set('n', '<leader>t1', ':1ToggleTerm<CR>', { desc = "Toggle: Terminal 1" })
    vim.keymap.set('n', '<leader>t2', ':2ToggleTerm<CR>', { desc = "Toggle: Terminal 2" })
    vim.keymap.set('n', '<leader>t3', ':3ToggleTerm<CR>', { desc = "Toggle: Terminal 3" })
    
    -- Send lines to terminal
    vim.keymap.set('v', '<leader>ts', ':ToggleTermSendVisualLines<CR>', { desc = "Terminal: Send selection" })
    vim.keymap.set('n', '<leader>ts', ':ToggleTermSendCurrentLine<CR>', { desc = "Terminal: Send line" })
  end,
}