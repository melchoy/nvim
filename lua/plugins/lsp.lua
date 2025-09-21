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
        ensure_installed = { "lua_ls", "ts_ls", "eslint" },
        automatic_installation = true,
        automatic_setup = false,
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
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Prefer the new API on Neovim 0.11+
      local has_new = vim.fn.has('nvim-0.11') == 1 and vim.lsp and vim.lsp.config and vim.lsp.enable
      if has_new then
        vim.lsp.config('lua_ls', { capabilities = capabilities })
        vim.lsp.enable('lua_ls')

        vim.lsp.config('ts_ls', { capabilities = capabilities })
        vim.lsp.enable('ts_ls')

        vim.lsp.config('eslint', {
          capabilities = capabilities,
          settings = {
            codeAction = {
              disableRuleComment = { enable = true, location = "separateLine" },
              showDocumentation = { enable = true },
            },
            codeActionOnSave = { enable = false, mode = "all" },
            format = false,
            nodePath = "",
            onIgnoredFiles = "off",
            packageManager = "npm",
            problems = { shortenToSingleLine = false },
            quiet = false,
            rulesCustomizations = {},
            run = "onType",
            useESLintClass = false,
            validate = "on",
            workingDirectory = { mode = "location" },
          },
          on_attach = function(client, bufnr)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
        })
        vim.lsp.enable('eslint')
      else
        -- Fallback for Neovim < 0.11 using the legacy lspconfig API
        local lspconfig = require('lspconfig')
        lspconfig.lua_ls.setup({ capabilities = capabilities })
        lspconfig.ts_ls.setup({ capabilities = capabilities })
        lspconfig.eslint.setup({
        capabilities = capabilities,
        settings = {
          codeAction = {
            disableRuleComment = {
              enable = true,
              location = "separateLine"
            },
            showDocumentation = {
              enable = true
            }
          },
          codeActionOnSave = {
            enable = false,  -- We handle this with conform.nvim
            mode = "all"
          },
          format = false,  -- We use conform.nvim/prettier for formatting
          nodePath = "",
          onIgnoredFiles = "off",
          packageManager = "npm",
          problems = {
            shortenToSingleLine = false
          },
          quiet = false,
          rulesCustomizations = {},
          run = "onType",  -- Show diagnostics as you type
          useESLintClass = false,
          validate = "on",
          workingDirectory = {
            mode = "location"
          }
        },
        on_attach = function(client, bufnr)
          -- Disable ESLint formatting (we use prettier via conform.nvim)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
        })
      end

      -- Setup diagnostic colors (yellow warnings) - force after colorscheme loads
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", {
            undercurl = true,
            sp = "#F9E2AF"  -- Catppuccin yellow
          })
          vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", {
            undercurl = true,
            sp = "#89B4FA"  -- Catppuccin blue
          })
          vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", {
            undercurl = true,
            sp = "#A6E3A1"  -- Catppuccin green
          })
        end,
        desc = "Set diagnostic underline colors after colorscheme loads"
      })

      -- Also set initial colors
      vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", {
        undercurl = true,
        sp = "#F9E2AF"  -- Catppuccin yellow
      })
      vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", {
        undercurl = true,
        sp = "#89B4FA"  -- Catppuccin blue
      })
      vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", {
        undercurl = true,
        sp = "#A6E3A1"  -- Catppuccin green
      })

      -- Setup keymaps only when LSP attaches to buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gh', vim.lsp.buf.hover, vim.tbl_extend('force', opts, { desc = "LSP: Hover info" }))
          vim.keymap.set('n', 'ge', vim.diagnostic.open_float, vim.tbl_extend('force', opts, { desc = "LSP: Show diagnostic" }))
          vim.keymap.set('n', '<leader>ld', vim.lsp.buf.definition, vim.tbl_extend('force', opts, { desc = "LSP: Go to definition" }))
          vim.keymap.set('n', '<leader>lr', vim.lsp.buf.references, vim.tbl_extend('force', opts, { desc = "LSP: Find references" }))
          vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action, vim.tbl_extend('force', opts, { desc = "LSP: Code actions" }))
          vim.keymap.set('n', '<leader>ln', vim.lsp.buf.rename, vim.tbl_extend('force', opts, { desc = "LSP: Rename symbol" }))
          vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format, vim.tbl_extend('force', opts, { desc = "LSP: Format document" }))

          -- Diagnostic navigation
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next, vim.tbl_extend('force', opts, { desc = "LSP: Next diagnostic" }))
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, vim.tbl_extend('force', opts, { desc = "LSP: Previous diagnostic" }))
        end,
      })
		end
  }
}
