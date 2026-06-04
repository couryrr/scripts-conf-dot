if vim.g.vscode then
    require("config.vscode")
else
    require("config.set")
    require("config.remap")
    require("config.lazy")
end
