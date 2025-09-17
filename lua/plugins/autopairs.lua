return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  config = function()
    local autopairs = require("nvim-autopairs")
    
    autopairs.setup({
      check_ts = true,  -- treesitter integration
      ts_config = {
        lua = { 'string', 'source' },
        javascript = { 'string', 'template_string' },
        java = false,
      },
      disable_filetype = { "TelescopePrompt", "spectre_panel" },
      disable_in_macro = true,  -- disable when recording or executing a macro
      disable_in_visualblock = false, -- disable when insert after visual block mode
      disable_in_replace_mode = true,
      ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
      enable_moveright = true,
      enable_afterquote = true,  -- add bracket pairs after quote
      enable_check_bracket_line = true,  -- check bracket in same line
      enable_bracket_in_quote = true, --
      enable_abbr = false, -- trigger abbreviation
      break_undo = true, -- switch for basic rule break undo sequence
      check_comma = true,
      map_cr = true,
      map_bs = true,  -- map the <BS> key
      map_c_h = false,  -- Map the <C-h> key to delete a pair
      map_c_w = false, -- map <c-w> to delete a pair if possible
    })

    -- Integration with nvim-cmp
    local cmp = require('cmp')
    local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    cmp.event:on(
      'confirm_done',
      cmp_autopairs.on_confirm_done()
    )
    
    -- Custom rules
    local Rule = require('nvim-autopairs.rule')
    local cond = require('nvim-autopairs.conds')

    -- Add spaces between parentheses
    autopairs.add_rules({
      Rule(' ', ' ')
        :with_pair(function(opts)
          local pair = opts.line:sub(opts.col - 1, opts.col)
          return vim.tbl_contains({ '()', '[]', '{}' }, pair)
        end),
      Rule('( ', ' )')
        :with_pair(function() return false end)
        :with_move(function(opts)
          return opts.prev_char:match('.%)') ~= nil
        end)
        :use_key(')'),
      Rule('{ ', ' }')
        :with_pair(function() return false end)
        :with_move(function(opts)
          return opts.prev_char:match('.%}') ~= nil
        end)
        :use_key('}'),
      Rule('[ ', ' ]')
        :with_pair(function() return false end)
        :with_move(function(opts)
          return opts.prev_char:match('.%]') ~= nil
        end)
        :use_key(']')
    })

    -- Add custom rules for specific languages
    autopairs.add_rules({
      -- HTML/JSX
      Rule('<', '>')
        :with_pair(cond.before_regex('%a+:?:?$', 1))
        :with_move(function(opts) return opts.char == '>' end),
      
      -- Arrow functions in JS/TS
      Rule('%(.*%)%s*%=>$', ' {  }', { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' })
        :use_regex(true)
        :set_end_pair_length(2),
    })
  end,
}