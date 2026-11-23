local M = {}

local function editor_window()
  local wins = { vim.api.nvim_get_current_win() }
  vim.list_extend(wins, vim.api.nvim_tabpage_list_wins(0))
  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_win_get_config(win).relative == ""
      and (vim.bo[buf].buftype == "" or vim.bo[buf].filetype == "snacks_dashboard") then
      return win
    end
  end
  vim.cmd("botright vnew")
  return vim.api.nvim_get_current_win()
end

function M.open(focus_chat, provider)
  local companion = require("codecompanion")
  local editor = editor_window()
  vim.api.nvim_set_current_win(editor)

  local function open_chat()
    if not vim.api.nvim_win_is_valid(editor) then
      return
    end
    vim.api.nvim_set_current_win(editor)
    local chat = companion.last_chat()
    if provider then
      companion.chat({ params = { adapter = provider }, auto_submit = false })
    elseif chat then
      companion.restore(chat.bufnr)
    else
      companion.chat({ auto_submit = false })
    end
    if focus_chat == false then
      vim.api.nvim_set_current_win(editor)
    else
      local active = companion.last_chat()
      if active and active.ui:is_visible() then
        vim.api.nvim_set_current_win(active.ui.winnr)
        if vim.bo[active.bufnr].modifiable then
          local last = vim.api.nvim_buf_line_count(active.bufnr)
          local line = vim.api.nvim_buf_get_lines(active.bufnr, last - 1, last, false)[1] or ""
          vim.api.nvim_win_set_cursor(active.ui.winnr, { last, #line })
          vim.cmd("startinsert!")
        end
      end
    end
  end

  if #Snacks.picker.get({ source = "explorer" }) == 0 then
    Snacks.explorer({ cwd = LazyVim.root(), on_show = open_chat })
  else
    open_chat()
  end
end

function M.toggle()
  local companion = require("codecompanion")
  local chat = companion.last_chat()
  if chat and chat.ui:is_visible() then
    companion.toggle_chat()
  else
    M.open(true)
  end
end

return M
