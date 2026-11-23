local map = vim.keymap.set

map("n", "<leader>?", "<cmd>NvimGuide<cr>", { desc = "Open Your Neovim Guide" })
map("n", "<leader>cT", "<cmd>NvimTools<cr>", { desc = "Check Language Tools" })
map("n", "<leader>fs", "<cmd>write<cr>", { desc = "Save File" })
map("n", "<C-p>", function()
  Snacks.picker.files({ cwd = LazyVim.root() })
end, { desc = "Find Project File" })
map("n", "<leader>sz", function()
  Snacks.picker.zoxide()
end, { desc = "Jump to Directory (zoxide)" })
map("n", "<leader>uu", function()
  Snacks.picker.undo()
end, { desc = "Browse Undo History" })

-- Keep visual selections and the clipboard useful during repeated edits.
map("x", "p", '"_dP', { desc = "Paste Without Replacing Clipboard" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half Page Down and Center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half Page Up and Center" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Leave Terminal Input Mode" })
