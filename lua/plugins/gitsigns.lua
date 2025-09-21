return {
  "lewis6991/gitsigns.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("gitsigns").setup({
      signs = {
        add          = { text = '┃' },
        change       = { text = '┃' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      signs_staged = {
        add          = { text = '┃' },
        change       = { text = '┃' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      signs_staged_enable = true,
      signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
      numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
      linehl     = true,  -- Enable inline line highlighting by default
      word_diff  = true,  -- Enable word-level diff highlighting by default
      watch_gitdir = {
        follow_files = true
      },
      attach_to_untracked = true,
      current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
      word_diff = true,  -- Enable word-level diff highlighting
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil, -- Use default
      max_file_length = 40000, -- Disable if file is longer than this (in lines)
      preview_config = {
        -- Options passed to nvim_open_win
        border = 'single',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1
      },
    })

    -- Keymaps
    local gs = require('gitsigns')

    -- Inline diff features
    vim.keymap.set('n', '<leader>gp', gs.preview_hunk, { desc = "Git: Preview hunk" })
    vim.keymap.set('n', '<leader>gl', gs.toggle_linehl, { desc = "Git: Toggle line highlighting (inline diff)" })
    vim.keymap.set('n', '<leader>gw', gs.toggle_word_diff, { desc = "Git: Toggle word diff" })
    vim.keymap.set('n', '<leader>gn', gs.toggle_numhl, { desc = "Git: Toggle number column highlighting" })
    vim.keymap.set('n', '<leader>gs', gs.stage_buffer, { desc = "Git: Stage file" })
    vim.keymap.set('n', '<leader>gsh', gs.stage_hunk, { desc = "Git: Stage hunk" })
    vim.keymap.set('n', '<leader>gu', gs.undo_stage_hunk, { desc = "Git: Unstage hunk" })
    vim.keymap.set('n', '<leader>gR', gs.reset_hunk, { desc = "Git: Reset hunk" })
    vim.keymap.set('n', '<leader>gb', gs.toggle_current_line_blame, { desc = "Git: Toggle blame" })

    -- Visual mode stage/reset
    vim.keymap.set('v', '<leader>gsh', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = "Git: Stage selection" })
    vim.keymap.set('v', '<leader>gR', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, { desc = "Git: Reset selection" })

    -- Buffer operations  
    vim.keymap.set('n', '<leader>gX', gs.reset_buffer, { desc = "Git: Reset buffer" })

    -- Navigation
    vim.keymap.set('n', ']h', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, { expr = true, desc = "Git: Next hunk" })

    vim.keymap.set('n', '[h', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, { expr = true, desc = "Git: Previous hunk" })

    -- Text object
    vim.keymap.set({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = "Git: Select hunk" })
    
    -- Unified diff view (inline +/- style)
    vim.keymap.set('n', '<leader>dd', function()
      -- Create a scratch buffer with unified diff
      local current_file = vim.fn.expand('%:p')
      if current_file == '' then
        vim.notify('No file open', vim.log.levels.WARN)
        return
      end
      
      local output = vim.fn.system('git diff ' .. vim.fn.shellescape(current_file))
      if vim.v.shell_error ~= 0 or output == '' then
        vim.notify('No git diff available', vim.log.levels.WARN)
        return
      end
      
      -- Create new buffer for diff
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
      vim.api.nvim_buf_set_option(buf, 'filetype', 'diff')
      vim.api.nvim_buf_set_name(buf, 'Git Diff: ' .. vim.fn.fnamemodify(current_file, ':t'))
      
      -- Split lines and set content
      local lines = vim.split(output, '\n')
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      
      -- Open in split
      vim.cmd('botright vsplit')
      vim.api.nvim_win_set_buf(0, buf)
      vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    end, { desc = "Git: Show unified diff (+/-)" })
  end
}