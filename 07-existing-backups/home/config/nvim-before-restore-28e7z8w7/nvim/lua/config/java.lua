local M = {}
local cached_home

local function supported(home)
  local executable = home and (home .. "/bin/java")
  if not executable or vim.fn.executable(executable) ~= 1 then
    return false
  end
  local result = vim.system({ executable, "-version" }, { text = true }):wait(3000)
  local major = tonumber(((result.stderr or "") .. (result.stdout or "")):match('version "(%d+)'))
  return result.code == 0 and major ~= nil and major >= 21
end

function M.home()
  if cached_home then
    return cached_home
  end
  local candidates = { vim.fn.stdpath("data") .. "/java/jdk" }
  if vim.env.JAVA_HOME then
    table.insert(candidates, vim.env.JAVA_HOME)
  end
  local executable = vim.fn.exepath("java")
  if executable ~= "" then
    table.insert(candidates, vim.fs.dirname(vim.fs.dirname(vim.uv.fs_realpath(executable) or executable)))
  end
  for _, home in ipairs(candidates) do
    if supported(home) then
      cached_home = home
      return home
    end
  end
end

-- Give each project its own JDTLS workspace, even when directory names match.
function M.start(dispatchers, config)
  local tools = require("config.tools")
  local home = assert(M.home(), "Java LSP needs JDK 21+: run :NvimToolsInstall")
  local root = config.root_dir or vim.fn.getcwd()
  local workspace = vim.fn.stdpath("data") .. "/jdtls/workspaces/" .. vim.fn.sha256(root):sub(1, 20)
  vim.fn.mkdir(workspace, "p")
  return vim.lsp.rpc.start({ assert(tools.path("jdtls")), "-data", workspace }, dispatchers, {
    cwd = root,
    env = vim.tbl_extend("force", config.cmd_env or {}, { JAVA_HOME = home }),
  })
end

function M.install()
  if M.home() then
    return
  end
  if M.installing then
    return
  end
  M.installing = true
  vim.notify("Installing a private Java JDK under Neovim data; no system Java settings will change.")
  vim.system(
    {
      "python3",
      vim.fn.stdpath("config") .. "/scripts/install-java.py",
      vim.fn.stdpath("data") .. "/java/jdk",
    },
    { text = true },
    vim.schedule_wrap(function(result)
      M.installing = false
      if result.code == 0 then
        cached_home = nil
        vim.notify("Neovim's private Java runtime is ready. Restart after Mason installations finish.")
      else
        vim.notify(
          "Java runtime download failed: " .. vim.trim(result.stderr or "") .. "\nRetry :NvimToolsInstall when online.",
          vim.log.levels.WARN
        )
      end
    end)
  )
end

return M
