return {
  {
    "saghen/blink.cmp",
    opts = {
      -- Enter only accepts an explicitly selected item; otherwise inserts a newline.
      completion = {
        list = { selection = { preselect = false, auto_insert = false } },
        documentation = { auto_show = true, auto_show_delay_ms = 250 },
        ghost_text = { enabled = false },
      },
      keymap = {
        preset = "enter",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-y>"] = { "select_and_accept" },
        ["<C-e>"] = { "cancel", "fallback" },
        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
      },
    },
  },
  {
    "folke/snacks.nvim",
    init = function()
      vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("personal_startup_explorer", { clear = true }),
        pattern = "SnacksDashboardOpened",
        once = true,
        callback = function()
          vim.schedule(function()
            -- Directory arguments already open an explorer through Snacks.
            if #Snacks.picker.get({ source = "explorer" }) == 0 then
              Snacks.explorer({ cwd = vim.fn.getcwd() })
            end
          end)
        end,
      })
    end,
    opts = {
      scroll = { enabled = false },
      picker = {
        sources = {
          files = { hidden = true, ignored = false, exclude = { ".git", "backups" } },
          grep = { hidden = true, ignored = false, exclude = { ".git", "backups" } },
          explorer = {
            hidden = true,
            ignored = false,
            exclude = { ".git", "backups" },
            layout = { preset = "sidebar", layout = { position = "left", width = 30, min_width = 24 } },
          },
        },
      },
      dashboard = {
        width = 4,
        sections = { { text = { "nvim", hl = "header", align = "center" } } },
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = { preset = "modern", delay = 300 },
    keys = {
      { "<leader>?", "<cmd>NvimGuide<cr>", desc = "Open Your Neovim Guide" },
    },
  },
}
