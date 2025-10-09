return {
  {
    "nvim-telescope/telescope-ui-select.nvim",
  },
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.5',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require("telescope").setup({
        defaults = {
          -- Include local/ directories even if gitignored
          find_command = {
            "rg",
            "--files",
            "--no-ignore",
            "--glob", "!.git/**",
            "--glob", "!.claude/**",
            "--glob", "!node_modules/**",
            "--glob", "!dist/**",
            "--glob", "!build/**",
            "--glob", "!target/**",
            "--glob", "!.cache/**",
            "--glob", "!.next/**",
            "--glob", "!.nuxt/**",
            "--glob", "!__pycache__/**",
            "--glob", "!.venv/**",
            "--glob", "!venv/**"
          },
          -- Also update vimgrep arguments for live_grep to include local/
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--no-ignore",
            "--glob", "!.git/**",
            "--glob", "!.claude/**",
            "--glob", "!node_modules/**",
            "--glob", "!dist/**",
            "--glob", "!build/**",
            "--glob", "!target/**",
            "--glob", "!.cache/**",
            "--glob", "!.next/**",
            "--glob", "!.nuxt/**",
            "--glob", "!__pycache__/**",
            "--glob", "!.venv/**",
            "--glob", "!venv/**"
          },
        },
        extensions = {
          ['ui-select'] = {
            require("telescope.themes").get_dropdown {
            }
          }
        }
      })
      local builtin = require("telescope.builtin")
      vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = "Find: Files" })
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find: Files" })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Find: Grep" })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Find: Buffers" })
      vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = "Find: Recent files" })
      vim.keymap.set('n', '<leader>ft', function()
        builtin.git_files({ show_untracked = true })
      end, { desc = "Find: Git files (incl. untracked)" })
      -- Git pickers
      vim.keymap.set('n', '<leader>gS', builtin.git_status,   { desc = "Git: Status" })
      vim.keymap.set('n', '<leader>gC', builtin.git_commits,  { desc = "Git: Commits" })
      vim.keymap.set('n', '<leader>gB', builtin.git_bcommits, { desc = "Git: Buffer commits" })
      vim.keymap.set('n', '<leader>gbr', builtin.git_branches,{ desc = "Git: Branches" })
      vim.keymap.set('n', '<leader>gT', builtin.git_stash,    { desc = "Git: Stash" })
      vim.keymap.set('n', '<leader>fc', builtin.commands, { desc = "Find: Commands" })
      vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = "Find: Keymaps" })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "Find: Help" })

      -- Toggle hidden/ignored files in telescope
      vim.keymap.set('n', '<leader>fH', function()
        builtin.find_files({ hidden = true, no_ignore = true })
      end, { desc = "Find: All files (including hidden/ignored)" })

      -- Popover open: find files, then open selection in floating window with <C-f>
      vim.keymap.set('n', '<leader>fF', function()
        local actions = require('telescope.actions')
        local action_state = require('telescope.actions.state')

        local function open_in_float(path)
          local buf = vim.fn.bufadd(path)
          vim.fn.bufload(buf)
          local cols, lines = vim.o.columns, vim.o.lines
          local w, h = math.floor(cols * 0.9), math.floor(lines * 0.9)
          local r, c = math.floor((lines - h) / 2), math.floor((cols - w) / 2)
          local win = vim.api.nvim_open_win(buf, true, {
            relative = 'editor', row = r, col = c, width = w, height = h,
            style = 'minimal', border = 'rounded',
          })
          vim.bo[buf].bufhidden = 'wipe'
          vim.keymap.set('n', 'q', function()
            pcall(vim.api.nvim_win_close, win, true)
          end, { buffer = buf, nowait = true })
        end

        require('telescope.builtin').find_files({
          layout_strategy = 'cursor',
          previewer = false,
          attach_mappings = function(prompt_bufnr, map)
            local function open_float()
              local entry = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              open_in_float(entry.path or entry.filename)
            end
            map('i', '<C-f>', open_float)
            map('n', '<C-f>', open_float)
            return true
          end,
        })
      end, { desc = 'Find: Popover open (floating) with <C-f>' })

      vim.keymap.set('n', '<leader>fG', function()
        builtin.live_grep({ additional_args = { "--hidden", "--no-ignore" } })
      end, { desc = "Find: Grep all files (including hidden/ignored)" })

      require("telescope").load_extension("ui-select")
    end
  },
}

