return {
  "supermaven-inc/supermaven-nvim",
  event = "InsertEnter",
  config = function()
    require("supermaven-nvim").setup({
      keymaps = {
        accept_suggestion = "<C-l>",
        clear_suggestion = "<C-]>",
        accept_word = "<C-j>",
      },
      ignore_filetypes = { "cpp" },
      color = {
        suggestion_color = "#808080",
        cterm = 244,
      },
      log_level = "info", -- set to "off" to disable logging completely
      disable_inline_completion = true, -- use cmp source instead of inline
      disable_keymaps = true, -- let cmp handle keymaps
      condition = function()
        return true
      end
    })
  end,
}