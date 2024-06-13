local plugins = {
  {
    "jose-elias-alvarez/null-ls.nvim",
    ft = {"python"},
    opts = function()
      return require "custom.configs.null-ls"
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "pyright",
      }
    }
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
      -- GitHub Copilot
    {
        'github/copilot.vim',
        lazy = false,
    },
    -- FZF and FZF.vim
    {
        'junegunn/fzf',
        build = function()
            vim.fn['fzf#install']()
        end,
        lazy = false,
    },
    {
        'junegunn/fzf.vim',
        lazy = false
    },
    {
      'https://github.com/vim-python/python-syntax',
      lazy = false,
      ft= "python",
      config = function()
        vim.g.python_highlight_all = 1
    end
    }

}
return plugins
