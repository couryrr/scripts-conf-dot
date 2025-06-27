return {
    "supermaven-inc/supermaven-nvim",
    config = function()
        require("supermaven-nvim").setup({})
        vim.keymap.set("n", "<leader>cs", function()
            vim.cmd("SupermavenToggle")
        end, { desc = "Toggle Supermaven" })
    end,
}
