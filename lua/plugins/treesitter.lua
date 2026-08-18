local ensure_installed = {
  -- Core/editor
  "lua",
  "vim",
  "vimdoc",
  -- Markdown
  "markdown",
  "markdown_inline",
  -- Web/TS
  "tsx",
  "typescript",
  "javascript",
  "graphql",
  "json",
  "yaml",
  -- Other languages used in docs
  "ruby",
  "bash",
  -- Existing languages
  "go",
  "python",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local treesitter = require("nvim-treesitter")

    treesitter.setup({})
    treesitter.install(ensure_installed)

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("TreesitterConfig", { clear = true }),
      callback = function(event)
        local started = pcall(vim.treesitter.start, event.buf)
        if started then
          vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
