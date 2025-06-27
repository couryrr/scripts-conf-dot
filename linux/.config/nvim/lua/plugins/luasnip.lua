return {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
    config = function()
        require("luasnip.loaders.from_lua").lazy_load({ paths = "~/.config/nvim/lua/snippets" })
        -- vim.keymap.set({ "i", "s" }, "<Tab>", function()
        --     return require("luasnip").jump(1)
        -- end, { silent = true })
        --
        -- vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
        --     return require("luasnip").jump(-1)
        -- end, { silent = true })
    end,
}
