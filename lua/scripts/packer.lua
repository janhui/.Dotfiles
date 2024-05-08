vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Simple plugins can be specified as strings
  use 'rstacruz/vim-closer'
  
  -- fzf files
  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.2',
	  -- or                            , branch = '0.1.x',
	  requires = { {'nvim-lua/plenary.nvim'} }
}
use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
use('theprimeagen/harpoon')
use('mbbill/undotree')

-- git plugin
use('tpope/vim-fugitive')

-- lsp setup
use {
  'VonHeikemen/lsp-zero.nvim',
  branch = 'v2.x',
  requires = {
    -- LSP Support
    {'neovim/nvim-lspconfig'},             -- Required
    {'williamboman/mason.nvim'},           -- Optional
    {'williamboman/mason-lspconfig.nvim'}, -- Optional

    -- Autocompletion
    {'hrsh7th/nvim-cmp'},     -- Required
    {'hrsh7th/cmp-nvim-lsp'}, -- Required
    {'L3MON4D3/LuaSnip'},     -- Required
  }
}

  use {'kosayoda/nvim-lightbulb'}
use({
  'marcuscaisey/please.nvim',
  requires = {
    'nvim-treesitter/nvim-treesitter',
    'mfussenegger/nvim-dap',
  },
})
use {
  'nvim-lualine/lualine.nvim',
  requires = { 'nvim-tree/nvim-web-devicons', opt = true }
}
    use({
      'j-hui/fidget.nvim',
      tag = 'legacy'
    }) 
     use({
      'catppuccin/nvim',
      config = function()
        require('catppuccin')
      end
    })

end)
