return {
  {
    "olimorris/codecompanion.nvim",
    version = "v20.0.1",
    lazy = true,
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    opts = {
      adapters = {
        acp = {
          codex = function()
            return require("codecompanion.adapters").extend("codex", {
              defaults = { auth_method = "chat-gpt" },
            })
          end,
        },
      },
      interactions = {
        chat = { adapter = "codex" },
      },
      display = {
        chat = {
          window = {
            layout = "vertical",
            position = "right",
            full_height = true,
            width = 0.30,
            opts = { winbar = " Ctrl-s: Send | ga: Provider | ?: Help" },
          },
          intro_message = "Type below the Me heading. Ctrl-s sends your message.",
          start_in_insert_mode = false,
        },
      },
    },
    keys = {
      {
        "<leader>aa",
        function()
          require("config.chat").toggle()
        end,
        desc = "Toggle AI Chat",
      },
      {
        "<leader>ac",
        function()
          require("config.chat").open(true, "codex")
        end,
        desc = "New ChatGPT / Codex Chat",
      },
      {
        "<leader>al",
        function()
          require("config.chat").open(true, "claude_code")
        end,
        desc = "New Claude Chat",
      },
      { "<leader>ap", "<cmd>CodeCompanionActions<cr>", mode = { "n", "x" }, desc = "AI Actions" },
      { "<leader>av", "<cmd>CodeCompanionChat Add<cr>", mode = "x", desc = "Add Selection to AI Chat" },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("personal_chat_startup", { clear = true }),
        pattern = "VeryLazy",
        once = true,
        callback = function()
          if #vim.api.nvim_list_uis() == 0 or vim.o.diff or vim.fn.index(vim.fn.argv(), "-") >= 0 then
            return
          end
          local plugin = require("lazy.core.config").plugins["codecompanion.nvim"]
          if not plugin or not plugin._.installed or vim.fn.executable("codex-acp") ~= 1 then
            return
          end
          vim.schedule(function()
            require("config.chat").open(false)
          end)
        end,
      })
    end,
  },
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        providers = {
          path = {
            enabled = function()
              return vim.bo.filetype ~= "codecompanion"
            end,
          },
        },
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = { spec = { { "<leader>a", group = "ai", mode = { "n", "x" } } } },
  },
}
