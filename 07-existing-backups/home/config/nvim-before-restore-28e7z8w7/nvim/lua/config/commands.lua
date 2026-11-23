local M = {}

function M.setup()
  vim.api.nvim_create_user_command("NvimGuide", function()
    local path = vim.fn.stdpath("config") .. "/README.md"
    vim.cmd.tabedit(vim.fn.fnameescape(path))
  end, { desc = "Open the local Neovim usage guide", force = true })

  vim.api.nvim_create_user_command("NvimTools", function()
    vim.cmd("checkhealth nvim_setup")
  end, { desc = "Check configured language tools", force = true })

  vim.api.nvim_create_user_command("NvimToolsInstall", function()
    require("config.tools").install()
  end, { desc = "Install or retry missing Neovim language tools", force = true })
end

return M
