return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        -- Keep the existing wallpaper palette and its live SIGUSR1 updates.
        local ok, matugen = pcall(require, "matugen")
        if ok then
          matugen.setup()
        else
          vim.cmd.colorscheme("tokyonight-moon")
        end
      end,
    },
  },
}
