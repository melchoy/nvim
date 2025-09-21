return  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        -- Map fenced code blocks in Markdown to filetypes/highlighters
        vim.g.markdown_fenced_languages = {
            'ts=typescript',
            'tsx=typescriptreact',
            'js=javascript',
            'jsx=javascriptreact',
            'graphql=graphql',
            'rb=ruby',
            'bash=sh',
            'shell=sh',
            'yaml=yaml',
            'json=json',
        }

        local config = require("nvim-treesitter.configs")
        config.setup({
            ensure_installed = {
                -- Core/editor
                "lua", "vim", "vimdoc",
                -- Markdown
                "markdown", "markdown_inline",
                -- Web/TS
                "tsx", "typescript", "javascript", "graphql", "json", "yaml",
                -- Other langs used in docs
                "ruby", "bash",
                -- Keep existing ones
                "go", "python",
            },
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = { enable = true },
        })
    end
}
