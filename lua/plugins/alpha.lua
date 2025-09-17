return {
  "goolord/alpha-nvim",
  lazy = false,
  priority = 1000,
  dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Default ASCII art (Melzz)
		local default_ascii = {
			"                                                     ",
			"  ███╗   ███╗███████╗██╗     ███████╗███████╗        ",
			"  ████╗ ████║██╔════╝██║     ╚══███╔╝╚══███╔╝        ",
			"  ██╔████╔██║█████╗  ██║       ███╔╝   ███╔╝         ",
			"  ██║╚██╔╝██║██╔══╝  ██║      ███╔╝   ███╔╝          ",
			"  ██║ ╚═╝ ██║███████╗███████╗███████╗███████╗        ",
			"  ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝╚══════╝        ",
			"                                                     ",
			"     ⚡ Powered by Neovim & Supermaven               ",
			"                                                     ",
		}

		-- Try to load local override (safe - no error if missing)
		local ok, local_config = pcall(require, "local.alpha")
		local ascii_art = ok and local_config.ascii_art or default_ascii

		dashboard.section.header.val = ascii_art

		-- Buttons with your keymaps
		dashboard.section.buttons.val = {
			dashboard.button("f", "  Find File", ":Telescope find_files <CR>"),
			dashboard.button("r", "  Recent Files", ":Telescope oldfiles <CR>"),
			dashboard.button("t", "  File Tree", ":Neotree filesystem toggle left<CR>"),
			dashboard.button("g", "  Live Grep", ":Telescope live_grep <CR>"),
			dashboard.button("c", "  Config", ":e ~/.config/nvim/init.lua<CR>"),
			dashboard.button("l", "  Lazy", ":Lazy<CR>"),
			dashboard.button("q", "  Quit", ":qa<CR>"),
		}

		-- Footer with current directory
		dashboard.section.footer.val = {
			"📁 " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":~"),
			"⚡ Neovim loaded with lazy.nvim"
		}

		-- Setup alpha
		alpha.setup(dashboard.config)

    -- Show dashboard for directory opening (alpha handles no-args case automatically)
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        local argc = vim.fn.argc()
        
        if argc == 1 then
          local arg = vim.fn.argv(0)
          
          if vim.fn.isdirectory(arg) == 1 then
            -- Change to the directory
            vim.cmd('cd ' .. vim.fn.fnameescape(arg))
            -- Show dashboard for directory
            vim.schedule(function()
              alpha.start()
            end)
          end
        end
      end,
    })
	end,
}

