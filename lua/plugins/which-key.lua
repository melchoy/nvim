return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  config = function()
    local wk = require("which-key")
    
    wk.setup({
      preset = "modern",
      delay = 300,
      filter = function(mapping)
        -- example to exclude mappings without a description
        return mapping.desc and mapping.desc ~= ""
      end,
      spec = {
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>d", group = "diff" },
        { "<leader>l", group = "lsp" },
        { "<leader>m", group = "markdown" },
        { "<leader>t", group = "toggle" },
      },
      keys = {
        scroll_down = "<c-d>",
        scroll_up = "<c-u>",
      },
      sort = { "local", "order", "group", "alphanum", "mod" },
      expand = 0, -- expand groups when <= n mappings
      replace = {
        key = {
          function(key)
            return require("which-key.view").format(key)
          end,
          -- { "<Space>", "SPC" },
        },
        desc = {
          { "<Plug>%(?(.*)%)?", "%1" },
          { "^%+", "" },
          { "<[cC]md>", "" },
          { "<[cC][rR]>", "" },
          { "<[sS]ilent>", "" },
          { "^lua%s+", "" },
          { "^call%s+", "" },
          { "^:%s*", "" },
        },
      },
      icons = {
        breadcrumb = "»",
        separator = "➜",
        group = "+",
        ellipsis = "…",
        mappings = false, -- set to false to disable all mapping icons
      },
      show_help = true,
      show_keys = true,
      disable = {
        -- disable WhichKey for certain buf types and file types
        bt = {},
        ft = { "TelescopePrompt" },
      },
    })
  end,
}