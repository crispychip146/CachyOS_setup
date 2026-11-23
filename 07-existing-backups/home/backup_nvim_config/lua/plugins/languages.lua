-- Start installed servers immediately; download tools explicitly with
-- :NvimToolsInstall so opening a file works quietly even without internet.
local function server(command, opts)
  opts = opts or {}
  opts.mason = false
  opts.enabled = require("config.tools").path(command) ~= nil
  return opts
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = { spacing = 2, source = "if_many", prefix = "●" },
        float = { border = "rounded", source = true },
        update_in_insert = false,
        severity_sort = true,
      },
      inlay_hints = { enabled = false }, -- Toggle with Space u h.
      servers = {
        lua_ls = server("lua-language-server"),
        basedpyright = server("basedpyright-langserver", {
          settings = {
            basedpyright = {
              disableOrganizeImports = true, -- Ruff owns import actions.
              analysis = { typeCheckingMode = "standard", diagnosticMode = "openFilesOnly" },
            },
          },
        }),
        ruff = server("ruff"),
        ts_ls = server("typescript-language-server"),
        bashls = server("bash-language-server"),
        html = server("vscode-html-language-server"),
        cssls = server("vscode-css-language-server"),
        jsonls = server("vscode-json-language-server", { settings = { json = { validate = { enable = true } } } }),
        yamlls = server("yaml-language-server", {
          settings = {
            redhat = { telemetry = { enabled = false } },
            yaml = { keyOrdering = false, schemaStore = { enable = true } },
          },
        }),
        taplo = server("taplo"),
        marksman = server("marksman"),
        -- Reuse the installed system compiler server; no compiler/toolchain changes.
        clangd = server("clangd"),
        rust_analyzer = server("rust-analyzer", {
          cmd = { require("config.tools").path("rust-analyzer") or "rust-analyzer" },
          settings = {
            ["rust-analyzer"] = {
              check = { command = "clippy" },
              cargo = { allFeatures = false },
            },
          },
        }),
        jdtls = {
          mason = false,
          enabled = require("config.tools").path("jdtls") ~= nil and require("config.java").home() ~= nil,
          cmd = require("config.java").start,
          settings = { java = { signatureHelp = { enabled = true } } },
        },
      },
      setup = {
        ruff = function()
          Snacks.util.lsp.on({ name = "ruff" }, function(_, client)
            client.server_capabilities.hoverProvider = false
          end)
        end,
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = {}
      -- :NvimToolsInstall and :MasonUpdate explicitly refresh the registry.
      opts.registry_cache = { refresh = false }
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      -- LazyVim handles format-on-save. Do not add a second BufWritePre hook.
      default_format_opts = { timeout_ms = 3000, lsp_format = "fallback" },
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
        python = { "ruff_format" },
        rust = { "rustfmt" },
        java = { "google-java-format", "clang-format", stop_after_first = true },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        less = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        ["markdown.mdx"] = { "prettier" },
        bash = { "shfmt" },
      },
      formatters = {
        prettier = {
          -- This Neovim/Node combination returns empty output with piped stdin.
          -- Conform writes and cleans a temporary file beside the source instead.
          stdin = false,
          args = { "--write", "$FILENAME" },
          range_args = function(_, ctx)
            local first, last = require("conform.util").get_offsets_from_range(ctx.buf, ctx.range)
            return { "--write", "$FILENAME", "--range-start=" .. first, "--range-end=" .. last }
          end,
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = { sh = { "shellcheck" }, bash = { "shellcheck" } },
      linters = {
        shellcheck = {
          condition = function()
            return require("config.tools").path("shellcheck") ~= nil
          end,
        },
      },
    },
  },
}
