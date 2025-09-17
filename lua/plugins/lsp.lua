return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "ts_ls" },
        automatic_installation = true,
      })
    end
  },
	{
    "neovim/nvim-lspconfig",
    dependencies = { 
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    lazy = false,
    config = function()
      local lspconfig = require("lspconfig")
      
      -- Get enhanced capabilities for nvim-cmp
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      
      -- Setup LSP servers with enhanced capabilities
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
      })
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
      })

      -- Setup keymaps only when LSP attaches to buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gh', vim.lsp.buf.hover, vim.tbl_extend('force', opts, { desc = "LSP: Hover info" }))
          vim.keymap.set('n', '<leader>ld', vim.lsp.buf.definition, vim.tbl_extend('force', opts, { desc = "LSP: Go to definition" }))
          vim.keymap.set('n', '<leader>lr', vim.lsp.buf.references, vim.tbl_extend('force', opts, { desc = "LSP: Find references" }))
          vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action, vim.tbl_extend('force', opts, { desc = "LSP: Code actions" }))
          vim.keymap.set('n', '<leader>ln', vim.lsp.buf.rename, vim.tbl_extend('force', opts, { desc = "LSP: Rename symbol" }))
          vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format, vim.tbl_extend('force', opts, { desc = "LSP: Format document" }))
        end,
      })
		end
  }
}
