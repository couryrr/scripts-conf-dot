-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd.packadd('packer.nvim')

return require('packer').startup(function(use)
-- Packer can manage itself
use 'wbthomason/packer.nvim'
-- Need a fuzzy finder
use {
	'nvim-telescope/telescope.nvim', tag = '0.1.0',
	-- or                            , branch = '0.1.x',
	requires = { {'nvim-lua/plenary.nvim'} }
}

-- Highlighting code
use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
use 'mfussenegger/nvim-jdtls'
use 'neovim/nvim-lspconfig' -- Configurations for Nvim LSP
use {
  'VonHeikemen/lsp-zero.nvim',
  requires = {
    -- LSP Support
    {'neovim/nvim-lspconfig'},
    {'williamboman/mason.nvim'},
    {'williamboman/mason-lspconfig.nvim'},

    -- Autocompletion
    {'hrsh7th/nvim-cmp'},
    {'hrsh7th/cmp-buffer'},
    {'hrsh7th/cmp-path'},
    {'saadparwaiz1/cmp_luasnip'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'hrsh7th/cmp-nvim-lua'},

    -- Snippets
    {'L3MON4D3/LuaSnip'},
    {'rafamadriz/friendly-snippets'},
  }
}

use({ "iamcco/markdown-preview.nvim",
    run = "cd app && npm install",
    setup = function()
        vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
})

-- colorscheme (keep at bottom treesitter error breaks file Highlighting).
use({
	'EdenEast/nightfox.nvim',
	config = function()
		vim.cmd('colorscheme nightfox')
	end
})

end)
