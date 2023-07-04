local home = os.getenv('HOME')
local jdtls = require('jdtls')

-- File types that signify a Java project's root directory. This will be
-- used by eclipse to determine what constitutes a workspace
local root_markers = {'gradlew', 'mvnw', '.git'}
local root_dir = require('jdtls.setup').find_root(root_markers)

-- eclipse.jdt.ls stores project specific data within a folder. If you are working
-- with multiple different projects, each project must use a dedicated data directory.
-- This variable is used to configure eclipse to use the directory name of the
-- current project found using the root_marker as the folder for project specific data.
local workspace_folder = home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")

local on_attach = function(client, bufopts)
    vim.api.nvim_set_keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", { noremap = true })
    vim.api.nvim_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover", { noremap = true })
    vim.api.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition", { noremap = true })
    vim.api.nvim_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation", { noremap = true })
    --vim.api.nvim_set_keymap("i", "C-CR", "<cmd>lua vim.lsp.defaults.cmp_mappings.mapping.confirm", { noremap = true })
    vim.api.nvim_set_keymap("n", "<C-o>", "jdtls.organize_imports", { noremap = true })
end

-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local config = {
    on_attach = on_attach,
  -- The command that starts the language server
  -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  cmd = {
    home..'/.sdkman/candidates/java/17.0.5-tem/bin/java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xms1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    -- Make jar and config use XDG_CONFIG_HOME
    '-jar', home..'/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar',
    '-configuration', home..'/.local/share/nvim/mason/packages/jdtls/config_mac',
    -- The full path for this should be easily configured
    '-data', workspace_folder
  },

  root_dir = root_dir,

  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options
  settings = {
    java = {
    }
  },

  -- Language server `initializationOptions`
  -- You need to extend the `bundles` with paths to jar files
  -- if you want to use additional eclipse.jdt.ls plugins.
  --
  -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
  --
  -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
  init_options = {
    bundles = {}
  },
}
-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
jdtls.start_or_attach(config)
