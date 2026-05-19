local vscode = require('vscode')

vim.g.mapleader = " "

-- file explorer (replaces netrw)
vim.keymap.set('n', '<leader>op', function()
    vscode.action('workbench.action.toggleSidebarVisibility')
end)

-- telescope replacements
vim.keymap.set('n', '<leader>ff', function()
    vscode.action('workbench.action.quickOpen')
end)
vim.keymap.set('n', '<leader>fg', function()
    vscode.action('workbench.action.findInFiles')
end)
vim.keymap.set('n', '<leader>fw', function()
    vscode.action('workbench.action.findInFiles', {
        args = { query = vim.fn.expand('<cword>') }
    })
end)

-- diagnostics
vim.keymap.set('n', '<leader>do', function()
    vscode.action('editor.action.showHover')
end)
vim.keymap.set('n', '<leader>d[', function()
    vscode.action('editor.action.marker.prev')
end)
vim.keymap.set('n', '<leader>d]', function()
    vscode.action('editor.action.marker.next')
end)
vim.keymap.set('n', '<leader>dd', function()
    vscode.action('workbench.actions.view.problems')
end)
