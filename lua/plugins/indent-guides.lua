return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local ibl = require("ibl")
    
    ibl.setup({
      indent = {
        char = "┊",      -- Character for indent line
        tab_char = "┊",  -- Character for tab indent line
        highlight = "IblIndent",
        smart_indent_cap = true,
        priority = 2,
      },
      whitespace = {
        highlight = "IblWhitespace",
        remove_blankline_trail = true,
      },
      scope = {
        enabled = true,
        char = "┃",      -- Character for scope line (current block)
        highlight = "IblScope",
        priority = 1024,
        include = {
          node_type = {
            ["*"] = { "return_statement", "table_constructor", "dictionary", "element", "json_object" }
          }
        },
      },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard", 
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
        buftypes = {
          "terminal",
          "nofile",
          "quickfix",
          "prompt",
        },
      },
    })

    -- Custom highlight groups for better visibility
    vim.api.nvim_set_hl(0, "IblIndent", { fg = "#3B4252", nocombine = true })
    vim.api.nvim_set_hl(0, "IblScope", { fg = "#5E81AC", nocombine = true })
    vim.api.nvim_set_hl(0, "IblWhitespace", { fg = "#2E3440", nocombine = true })

    -- Toggle indent guides keymap
    vim.keymap.set("n", "<leader>ti", function()
      local enabled = require("ibl.config").get_config(0).enabled
      if enabled then
        require("ibl").setup_buffer(0, { enabled = false })
        print("🚫 Indent guides disabled")
      else
        require("ibl").setup_buffer(0, { enabled = true })
        print("✅ Indent guides enabled") 
      end
    end, { desc = "Toggle indent guides" })
  end,
}