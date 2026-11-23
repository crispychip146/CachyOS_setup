-- Tools and their optional Java runtime stay in Neovim's own directories.
local M = {}
M.packages = {
  { "clangd", "clangd", "C / C++ completion and diagnostics" },
  { "clang-format", "clang-format", "C / C++ formatting and Java fallback" },
  { "rust-analyzer", "rust-analyzer", "Rust completion and diagnostics" },
  { "jdtls", "jdtls", "Java completion and diagnostics (requires a JDK)" },
  { "google-java-format", "google-java-format", "Java formatting" },
  { "lua-language-server", "lua-language-server", "Lua completion and diagnostics" },
  { "basedpyright", "basedpyright-langserver", "Python types and navigation" },
  { "ruff", "ruff", "Python linting, imports and formatting" },
  { "typescript-language-server", "typescript-language-server", "JavaScript / TypeScript" },
  { "bash-language-server", "bash-language-server", "Shell completion and diagnostics" },
  { "html-lsp", "vscode-html-language-server", "HTML" },
  { "css-lsp", "vscode-css-language-server", "CSS / SCSS / Less" },
  { "json-lsp", "vscode-json-language-server", "JSON / JSONC" },
  { "yaml-language-server", "yaml-language-server", "YAML and schema validation" },
  { "taplo", "taplo", "TOML" },
  { "marksman", "marksman", "Markdown links and navigation" },
  { "prettier", "prettier", "Web, JSON, YAML and Markdown formatting" },
  { "stylua", "stylua", "Lua formatting" },
  { "shfmt", "shfmt", "Shell formatting" },
  { "shellcheck", "shellcheck", "Shell linting" },
  { "tree-sitter-cli", "tree-sitter", "Parser installation" },
}
M.parsers = { "c", "cpp", "python", "rust", "java", "javascript", "typescript", "tsx", "css", "scss", "html" }

function M.path(command)
  -- Prefer Mason over a system rustup shim which might have no component.
  local mason_path = vim.fn.stdpath("data") .. "/mason/bin/" .. command
  if vim.fn.executable(mason_path) == 1 then
    return mason_path
  end
  local path = vim.fn.exepath(command)
  if path ~= "" then
    if command == "rust-analyzer" then
      local result = vim.system({ path, "--version" }, { text = true }):wait(2000)
      if result.code ~= 0 then
        return nil
      end
    end
    return path
  end
  return nil
end

function M.install()
  require("lazy").load({ plugins = { "mason.nvim" } })
  local registry = require("mason-registry")
  -- Keep npm's download cache within Neovim too.
  vim.env.npm_config_cache = vim.fn.stdpath("cache") .. "/npm"
  require("config.java").install()
  require("lazy").load({ plugins = { "nvim-treesitter" } })
  local ts = require("nvim-treesitter")
  local installed = ts.get_installed()
  local missing = vim.tbl_filter(function(parser)
    return not vim.tbl_contains(installed, parser)
  end, M.parsers)
  if #missing > 0 then
    ts.install(missing, { summary = true })
  end
  vim.notify("Refreshing Mason registry; inspect progress with :Mason")
  registry.update(vim.schedule_wrap(function(success)
    if not success then
      vim.notify(
        "Registry refresh failed; trying cached package metadata. Inspect :MasonLog if downloads fail.",
        vim.log.levels.WARN
      )
    end
    for _, item in ipairs(M.packages) do
      local ok, package = pcall(registry.get_package, item[1])
      if ok and not M.path(item[2]) and not package:is_installed() and not package:is_installing() then
        package:install()
      elseif not ok then
        vim.notify("Mason package unavailable: " .. item[1], vim.log.levels.WARN)
      end
    end
  end))
end

return M
