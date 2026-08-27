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
    -- Use the main-branch modules directly. The old master branch also
    -- provided a top-level `nvim-treesitter` module, but without install().
    -- Avoiding that shared module name prevents stale loader state from
    -- mixing the old API with this main-branch configuration.
    local config = require("nvim-treesitter.config")
    local install = require("nvim-treesitter.install")

    config.setup({})
    install.install(ensure_installed)

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("TreesitterConfig", { clear = true }),
      callback = function(event)
        local started = pcall(vim.treesitter.start, event.buf)
        if started then
          vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter.indent'.get_indent(v:lnum)"
        end
      end,
    })
  end,
}
