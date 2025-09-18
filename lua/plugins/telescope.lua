return {
  {
    "nvim-telescope/telescope-ui-select.nvim",
  },
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.5',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require("telescope").setup({
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
      vim.keymap.set('n', '<leader>ft', builtin.git_files, { desc = "Find: Git files (tracked)" })
      vim.keymap.set('n', '<leader>fc', builtin.commands, { desc = "Find: Commands" })
      vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = "Find: Keymaps" })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "Find: Help" })
      
      -- Toggle hidden/ignored files in telescope
      vim.keymap.set('n', '<leader>fH', function()
        builtin.find_files({ hidden = true, no_ignore = true })
      end, { desc = "Find: All files (including hidden/ignored)" })
      
      vim.keymap.set('n', '<leader>fG', function()
        builtin.live_grep({ additional_args = { "--hidden", "--no-ignore" } })
      end, { desc = "Find: Grep all files (including hidden/ignored)" })

      require("telescope").load_extension("ui-select")
    end
  },
}

