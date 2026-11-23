-- LazyVim provides the baseline; keep local preferences in this file.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.lazyvim_picker = "snacks"
vim.g.lazyvim_cmp = "blink.cmp"
vim.g.autoformat = true
vim.g.snacks_animate = false
vim.g.ai_cmp = false

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.conceallevel = 0 -- Plain source by default; Markdown's viewer manages its windows.
opt.expandtab = true
opt.shiftwidth = 2 -- Project EditorConfig and language settings take precedence.
opt.tabstop = 2
opt.softtabstop = -1
opt.breakindent = true
opt.undofile = true
opt.undolevels = 10000
opt.swapfile = true
opt.autowrite = false -- Save explicitly with Ctrl-s or :w.
opt.autoread = true
opt.confirm = true
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split" -- Preview :substitute before accepting it.
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.timeoutlen = 400
opt.updatetime = 250
opt.pumblend = 0
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.diffopt:append({ "algorithm:histogram", "linematch:60" })

-- Respect LazyVim's OSC 52 clipboard behavior over SSH.
if not vim.env.SSH_CONNECTION and vim.fn.executable("wl-copy") == 1 and vim.env.WAYLAND_DISPLAY then
  opt.clipboard = "unnamedplus"
end
