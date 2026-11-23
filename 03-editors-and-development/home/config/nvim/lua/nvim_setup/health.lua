-- Neovim discovers this as :checkhealth nvim_setup.
local M = {}

function M.check()
  local health = vim.health
  local tools = require("config.tools")
  health.start("Personal Neovim setup")
  health.info("Config: " .. vim.fn.stdpath("config"))
  health.info("Guide: :NvimGuide | Install missing tools: :NvimToolsInstall | Progress: :Mason")
  for _, command in ipairs({ "git", "rg", "fd", "node", "npm", "python3", "gcc", "curl", "unzip", "lazygit" }) do
    local path = tools.path(command)
    if path then
      health.ok(command .. ": " .. path)
    else
      health.warn(command .. " unavailable")
    end
  end
  health.start("Language tools (Mason installs into Neovim's data directory)")
  for _, item in ipairs(tools.packages) do
    local path = tools.path(item[2])
    if path then
      health.ok(item[1] .. ": " .. path)
    else
      health.warn(item[1] .. " missing: " .. item[3], { "Run :NvimToolsInstall when online" })
    end
  end
  health.start("Required language runtimes")
  for _, command in ipairs({ "rustfmt", "cargo", "rustc" }) do
    local path = tools.path(command)
    if path then
      health.ok(command .. ": " .. path)
    else
      health.warn(command .. " unavailable; Rust needs a working toolchain")
    end
  end
  local java_home = require("config.java").home()
  if java_home then
    health.ok("Java JDK 21+: " .. java_home)
  else
    health.warn("Java LSP runtime missing", {
      "Run :NvimToolsInstall to download a JDK into Neovim's data directory",
      "Java formatting still works through clang-format until Google Java Format installs",
    })
  end
  health.start("Document viewers")
  for _, name in ipairs({ "render-markdown.nvim", "pdfreader.nvim", "telescope.nvim" }) do
    local path = vim.fn.stdpath("data") .. "/lazy/" .. name .. "/lua"
    if vim.uv.fs_stat(path) then
      health.ok(name .. " installed")
    else
      health.warn(name .. " pending installation", { "Run :Lazy install, then restart Neovim" })
    end
  end
  for _, command in ipairs({ "magick", "gs", "pdfinfo", "pdftotext", "pdftohtml" }) do
    if tools.path(command) then
      health.ok(command .. " available")
    else
      health.warn(command .. " missing for PDF reading")
    end
  end
  health.start("Clipboard")
  if vim.env.SSH_CONNECTION then
    health.info("SSH session: using Neovim's terminal clipboard support")
  elseif vim.env.WAYLAND_DISPLAY and tools.path("wl-copy") and tools.path("wl-paste") then
    health.ok("Wayland clipboard available")
  else
    health.info("Use :checkhealth vim.provider to inspect the clipboard in your terminal session")
  end
end

return M
