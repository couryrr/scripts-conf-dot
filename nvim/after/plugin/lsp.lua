local lsp = require('lsp-zero')

lsp.preset('recommended')

lsp.ensure_installed({
  'tsserver',
  'eslint',
  'emmet_ls',
  'lua_ls',
  'gopls',
  'jdtls',
})
-- Fix Undefined global 'vim'
lsp.configure('lua_ls', {
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' }
            }
        }
    }
})
-- This skips jdtls so we can configure nvim-jdtls
lsp.build_options('jdtls', {})

lsp.setup()

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = false,
  float = true,
})


-- vim.lsp.set_log_level('debug')
