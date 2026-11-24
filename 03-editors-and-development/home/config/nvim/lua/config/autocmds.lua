local group = vim.api.nvim_create_augroup("personal_nvim", { clear = true })

local autosave_timers = {}

local function can_autosave(buf)
  if not vim.api.nvim_buf_is_loaded(buf) or vim.api.nvim_buf_get_name(buf) == "" then
    return false
  end

  local options = vim.bo[buf]
  return options.buftype == "" and options.modified and not options.readonly
end

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "TextChangedP" }, {
  group = group,
  desc = "Save file buffers one second after the last edit",
  callback = function(event)
    local buf = event.buf
    if not can_autosave(buf) then
      return
    end

    local timer = autosave_timers[buf]
    if timer and not timer:is_closing() then
      timer:close()
    end

    local changedtick = vim.api.nvim_buf_get_changedtick(buf)
    timer = vim.defer_fn(function()
      if autosave_timers[buf] ~= timer then
        return
      end
      autosave_timers[buf] = nil

      if not can_autosave(buf) or vim.api.nvim_buf_get_changedtick(buf) ~= changedtick then
        return
      end

      local ok, err = pcall(vim.api.nvim_buf_call, buf, function()
        vim.cmd("silent update")
      end)
      if not ok then
        vim.notify("Autosave failed: " .. err, vim.log.levels.WARN)
      end
    end, 1000)
    autosave_timers[buf] = timer
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = false -- Toggle spelling with Space u s when wanted.
    -- The Markdown renderer manages concealment while switching edit/read modes.
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "python",
  callback = function()
    -- A project's EditorConfig still wins over these fallback defaults.
    if not (vim.b.editorconfig and vim.b.editorconfig.indent_size) then
      vim.opt_local.shiftwidth = 4
      vim.opt_local.tabstop = 4
    end
  end,
})
