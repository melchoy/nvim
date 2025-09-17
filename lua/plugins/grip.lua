-- Grip integration for markdown preview
-- No plugin needed - just keymap integration with grip command

return {
  -- Empty plugin spec - just for organization
  -- Actual functionality is in the autocmd below
  name = "grip-integration",
  dir = vim.fn.stdpath("config"),
  config = function()
    -- Grip keymaps (only in markdown files)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        local opts = { buffer = true }
        
        -- Main grip preview with auto browser launch
        vim.keymap.set("n", "<leader>mp", function()
          local file = vim.fn.expand('%:p')
          if vim.fn.filereadable(file) == 1 then
            -- Use grip-preview wrapper that handles browser opening
            vim.fn.system('grip-preview ' .. vim.fn.shellescape(file) .. ' --browser > /dev/null 2>&1 &')
            print('🚀 Starting grip preview: ' .. vim.fn.expand('%:t'))
            print('📱 Opening browser automatically...')
          else
            print('❌ Current file is not readable')
          end
        end, vim.tbl_extend("force", opts, { desc = "Preview markdown with grip" }))
        
        -- Alternative: preview without auto browser
        vim.keymap.set("n", "<leader>mo", function()
          local file = vim.fn.expand('%:p')
          if vim.fn.filereadable(file) == 1 then
            -- Start grip without browser, print URL
            local output = vim.fn.system('grip ' .. vim.fn.shellescape(file) .. ' --no-browser > /dev/null 2>&1 & echo "http://localhost:6419"')
            print('🌐 Grip server started: http://localhost:6419')
            print('📋 Copy URL to browser manually')
          else
            print('❌ Current file is not readable')
          end
        end, vim.tbl_extend("force", opts, { desc = "Start grip server (no browser)" }))
        
        -- Stop all grip processes
        vim.keymap.set("n", "<leader>ms", function()
          vim.fn.system('pkill -f grip')
          print('🛑 Stopped all grip processes')
        end, vim.tbl_extend("force", opts, { desc = "Stop grip preview" }))
        
        -- Directory preview (preview entire project)
        vim.keymap.set("n", "<leader>md", function()
          local cwd = vim.fn.getcwd()
          vim.fn.system('grip-preview ' .. vim.fn.shellescape(cwd) .. ' --browser > /dev/null 2>&1 &')
          print('📁 Starting grip for entire directory')
          print('📱 Opening browser automatically...')
        end, vim.tbl_extend("force", opts, { desc = "Preview directory with grip" }))
      end,
    })
  end
}