local group = vim.api.nvim_create_augroup("personal_nvim", { clear = true })

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
