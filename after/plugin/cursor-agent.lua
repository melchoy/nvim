--[[
Cursor Agent Plugin for Neovim

Integrates Cursor's AI capabilities directly into Neovim.

ENVIRONMENT VARIABLES:
  NVIM_CURSOR_AGENT_ENABLED     - Set to "false" to disable the plugin (default: true)
  NVIM_CURSOR_AGENT_PATH        - Path to cursor-agent executable (default: "cursor-agent")
  NVIM_CURSOR_AGENT_SPLIT_SIZE  - Terminal height in lines (default: 15)
  NVIM_CURSOR_AGENT_SPLIT_DIR   - Terminal position: "botright split" or "botright vsplit" (default: "botright split")

EXAMPLES:
  # Disable plugin completely
  export NVIM_CURSOR_AGENT_ENABLED=false

  # Use custom cursor-agent path
  export NVIM_CURSOR_AGENT_PATH=/opt/homebrew/bin/cursor-agent

  # Larger terminal window
  export NVIM_CURSOR_AGENT_SPLIT_SIZE=25

  # Vertical split instead of horizontal
  export NVIM_CURSOR_AGENT_SPLIT_DIR="botright vsplit"

  # Per-session disable
  NVIM_CURSOR_AGENT_ENABLED=false nvim

COMMANDS:
  :CursorAgent           - Opens cursor-agent in terminal
  :CursorResume          - Resumes cursor-agent session
  :CursorAsk <prompt>    - Ask Cursor AI directly
  :CursorAskSelection    - Ask about selected text

KEYMAPS:
  <leader>ca             - Open Cursor Agent terminal
  <leader>cr             - Resume Cursor Agent session
  <leader>cq             - Ask Cursor AI (prompts for input)
  <leader>cq (visual)    - Ask about selected text

REQUIREMENTS:
  - cursor-agent must be available in PATH (or set NVIM_CURSOR_AGENT_PATH)
  - Plugin auto-disables if cursor-agent not found
--]]

-- Load configuration from environment variables
local config = {
  enabled = os.getenv("NVIM_CURSOR_AGENT_ENABLED") ~= "false",
  cursor_agent_path = os.getenv("NVIM_CURSOR_AGENT_PATH") or "cursor-agent",
  split_size = tonumber(os.getenv("NVIM_CURSOR_AGENT_SPLIT_SIZE")) or 15,
  split_direction = os.getenv("NVIM_CURSOR_AGENT_SPLIT_DIR") or "botright split",
}

-- Check if cursor-agent is available
local function have_cursor()
  return vim.fn.executable(config.cursor_agent_path) == 1
end

-- Early return if disabled or cursor-agent missing
if not config.enabled or not have_cursor() then
  return
end

local uv = vim.uv or vim.loop

local function project_root()
  local cwd = uv.cwd()
  local markers = { ".git", ".cursor", "package.json", "go.mod", "Cargo.toml" }
  local found = vim.fs.find(markers, { upward = true })[1]
  return found and vim.fs.dirname(found) or cwd
end

local function open_terminal(cmd, name)
  -- Create a new buffer for the terminal
  local buf = vim.api.nvim_create_buf(false, true)

  -- Open the split and set it to use our new buffer
  vim.cmd(config.split_direction)
  vim.api.nvim_win_set_buf(0, buf)
  vim.cmd("resize " .. config.split_size)

  -- Now open the terminal in the clean buffer
  vim.fn.termopen(cmd, { cwd = project_root() })

  if name then
    pcall(vim.api.nvim_buf_set_name, buf, name)
  end
  vim.cmd("startinsert")
end

local function notify_missing()
  vim.notify("cursor-agent not found in PATH. Install and/or ensure it's available.", vim.log.levels.ERROR)
end

local function open_agent()
  if not have_cursor() then return notify_missing() end
  open_terminal(config.cursor_agent_path, "cursor-agent")
end

local function resume_agent()
  if not have_cursor() then return notify_missing() end
  open_terminal(config.cursor_agent_path .. " resume", "cursor-agent-resume")
end

local function get_visual_selection_text()
  local s = vim.fn.getpos("'<")
  local e = vim.fn.getpos("'>")
  local sr, sc = s[2] - 1, s[3] - 1
  local er, ec = e[2] - 1, e[3]
  local lines = vim.api.nvim_buf_get_text(0, sr, sc, er, ec, {})
  return table.concat(lines, "\n")
end

local function show_scratch(title, lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  pcall(vim.api.nvim_buf_set_name, buf, title)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.cmd("botright vsplit")
  vim.api.nvim_win_set_buf(0, buf)
end

local function ask(prompt)
  if not have_cursor() then return notify_missing() end
  if not prompt or prompt == "" then
    return vim.ui.input({ prompt = "Cursor prompt: " }, function(input)
      if input then ask(input) end
    end)
  end
  local root = project_root()
  vim.system({ config.cursor_agent_path, "-p", prompt }, { cwd = root, text = true }, function(res)
    if res.code ~= 0 then
      vim.schedule(function()
        show_scratch("Cursor Error", vim.split(res.stderr or "Unknown error", "\n", { plain = true }))
      end)
      return
    end
    vim.schedule(function()
      show_scratch("Cursor Output", vim.split(res.stdout or "", "\n", { plain = true }))
    end)
  end)
end

local function ask_selection()
  local ok, sel = pcall(get_visual_selection_text)
  if not ok or not sel or sel == "" then
    return vim.notify("No visual selection", vim.log.levels.WARN)
  end
  ask("Context:\n" .. sel .. "\n\nInstruction: ")
end

-- Commands
vim.api.nvim_create_user_command("CursorAgent", open_agent, {})
vim.api.nvim_create_user_command("CursorResume", resume_agent, {})
vim.api.nvim_create_user_command("CursorAsk", function(opts) ask(opts.args) end, { nargs = "*" })
vim.api.nvim_create_user_command("CursorAskSelection", ask_selection, {})

-- Keymaps
vim.keymap.set("n", "<leader>ca", open_agent, { desc = "Cursor: Agent (terminal)" })
vim.keymap.set("n", "<leader>cr", resume_agent, { desc = "Cursor: Resume (terminal)" })
vim.keymap.set("n", "<leader>cq", function() ask() end, { desc = "Cursor: Ask (prompt)" })
vim.keymap.set("x", "<leader>cq", ask_selection, { desc = "Cursor: Ask (visual selection)" })
