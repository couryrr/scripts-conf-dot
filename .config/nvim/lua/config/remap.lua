vim.g.mapleader = " "
vim.keymap.set("n", "<leader>op", vim.cmd.Ex)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "Q", "<nop>")

-- Tab with... tab
vim.keymap.set("v", "<Tab>", ">>")
vim.keymap.set("v", "<S-Tab>", "<<")
vim.keymap.set("n", "<Tab>", ">>")
vim.keymap.set("n", "<S-Tab>", "<<")
vim.keymap.set("i", "<Tab>", "<C-i>")
vim.keymap.set("i", "<S-Tab>", "<C-d>")
