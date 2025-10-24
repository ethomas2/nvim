local plugins = {
  {
    "nvimtools/none-ls.nvim",
    ft = {"python", "typescriptreact", "javascriptreact", "typescript", "javascript"},
    opts = function()
      return require "custom.configs.none-ls"
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

  -- Translated plugins from vim-plug
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
  },
  -- Syntax highlighting
  {
   'https://github.com/altercation/vim-colors-solarized',
   lazy = false,
  },
  {
    'lifepillar/pgsql.vim',
    lazy = false,
    config = function()
      vim.g.sql_type_default = 'pgsql'
    end,
  },
  {
    'hashivim/vim-terraform',
    lazy = false,
    config = function()
      vim.g.terraform_fmt_on_save = 1
    end,
  },
  -- Verbs
  {
    'tpope/vim-surround',
    lazy = false,
  },
  {
    'tpope/vim-commentary',
    lazy = false,
  },
  {
    'tommcdo/vim-lion',
    lazy = false,
  },
  {
    'machakann/vim-swap',
    lazy = false,
  },
  -- Text objects
  {
    'kana/vim-textobj-user',
    lazy = false,
  },
  {
    -- TODO: if there are problems with this load ethomas2/vim-indent-object
    -- 'michaeljsmith/vim-indent-object',
    -- Consider the thing you put in my-files (copypasted vindent)
    'jessekelighine/vindent.vim',
    lazy = false,
  },
  -- {
  --   'glts/vim-textobj-comment',
  --   lazy = false,
  -- },

  -- I think targets.vim might intervere with indent-object?
  -- {
  --   'wellle/targets.vim',
  --   lazy = false,
  -- },
  {
    'coderifous/textobj-word-column.vim',
    lazy = false,
  },
  -- Other
  {
    'jgdavey/tslime.vim',
    lazy = false,
  },
  {
    'tpope/vim-dispatch',
    lazy = false,
  },
  {
    'jceb/vim-editqf',
    lazy = false,
  },
  {
    'ethomas2/vim-unstack',
    lazy = false,
  },
  {
    'mattboehm/vim-accordion',
    lazy = false,
  },
  {
    'tpope/vim-fugitive',
    lazy = false,
  },
  {
    'tpope/vim-rhubarb',
    lazy = false,
  },
  {
    'kshenoy/vim-signature',
    lazy = false,
  }, {
    'jrop/jq.nvim',
    lazy = false,
  }
}


return plugins
