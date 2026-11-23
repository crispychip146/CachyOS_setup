-- Keep ordinary editing usable while first-time plugin downloads are pending.
-- Restart after :Lazy install so their file handlers can be enabled.
local function installed(name)
  return vim.uv.fs_stat(vim.fn.stdpath("data") .. "/lazy/" .. name .. "/lua") ~= nil
end

return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    version = "*",
    lazy = true,
    ft = installed("render-markdown.nvim") and { "markdown", "markdown.mdx", "codecompanion" } or nil,
    cmd = { "RenderMarkdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },
    keys = {
      { "<leader>um", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Markdown Rendering" },
      {
        "<leader>cp",
        "<cmd>RenderMarkdown preview<cr>",
        ft = { "markdown", "markdown.mdx" },
        desc = "Markdown Preview Split",
      },
    },
    opts = {
      file_types = { "markdown", "markdown.mdx", "codecompanion" },
      preset = "lazy",
      heading = { sign = false },
      code = { sign = false, width = "block", right_pad = 1 },
      -- No extra Python or TeX installation is needed for normal Markdown.
      latex = { enabled = false },
      win_options = { conceallevel = { default = 0, rendered = 3 } },
    },
  },
  {
    "r-pletnev/pdfreader.nvim",
    -- Load before entering the first PDF, including one opened from the CLI.
    lazy = true,
    event = installed("pdfreader.nvim") and { "BufReadPre *.pdf", "BufNewFile *.pdf" } or nil,
    cmd = { "PDFReader" },
    dependencies = {
      "folke/snacks.nvim",
      { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
    },
    config = function()
      require("config.pdfreader").setup()
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_c, 1, {
        function()
          return require("config.pdfreader").status()
        end,
        cond = function()
          return vim.b.pdfreader_progress ~= nil
        end,
      })
    end,
  },
  {
    "folke/snacks.nvim",
    opts = {
      image = {
        enabled = true,
        -- pdfreader owns PDF buffers, avoiding two competing file handlers.
        formats = { "png", "jpg", "jpeg", "gif", "bmp", "webp", "tiff", "heic", "avif", "svg", "icns" },
        doc = { enabled = true },
        math = { enabled = false },
      },
    },
  },
}
