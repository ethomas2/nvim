local plugins = {
  -- Disable colorizer plugin (prevents color names like "red", "blue", "green" from being highlighted)
  {
    "NvChad/nvim-colorizer.lua",
    enabled = false,
  },
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

  -- Treesitter override for markdown code block highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function()
      local default_opts = require "plugins.configs.treesitter"
      -- Create a copy to avoid mutating the original
      local opts = vim.deepcopy(default_opts)

      -- Merge ensure_installed with markdown parsers and other common languages
      local base_langs = opts.ensure_installed or {}
      local additional_langs = { "markdown", "markdown_inline", "python", "javascript", "typescript", "bash", "json", "yaml", "lua", "vim", "vimdoc" }
      -- Create a set to avoid duplicates
      local lang_set = {}
      for _, lang in ipairs(base_langs) do
        lang_set[lang] = true
      end
      for _, lang in ipairs(additional_langs) do
        lang_set[lang] = true
      end
      -- Convert back to list
      local merged_langs = {}
      for lang, _ in pairs(lang_set) do
        table.insert(merged_langs, lang)
      end
      opts.ensure_installed = merged_langs

      -- Ensure highlight is enabled with proper settings
      opts.highlight = opts.highlight or {}
      opts.highlight.enable = true
      opts.highlight.use_languagetree = true
      opts.highlight.additional_vim_regex_highlighting = false

      return opts
    end,
  },

  -- Translated plugins from vim-plug
   -- GitHub Copilot
  -- {
  --     'github/copilot.vim',
  --     lazy = false,
  -- },
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
  },
  {
    'alduraibi/telescope-glyph.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    lazy = false,
    config = function()
      require('telescope').load_extension('glyph')
    end,
  },
  {
    'xiyaowong/telescope-emoji.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    lazy = false,
    config = function()
      require('telescope').load_extension('emoji')
    end,
  },
  -- Markdown preview with LaTeX support
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
    build = 'cd app && npm install',
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_command_for_global = 0
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_open_ip = ''
      vim.g.mkdp_port = ''
      vim.g.mkdp_browser = ''
      vim.g.mkdp_echo_preview_url = 1
      vim.g.mkdp_browserfunc = ''
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {},
        disable_sync_scroll = 0,
        sync_scroll_type = 'middle',
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,
        disable_filename = 0,
        toc = {}
      }
      vim.g.mkdp_markdown_css = ''
      vim.g.mkdp_highlight_css = vim.fn.expand('~/.config/nvim/markdown-preview/highlight.css')
      vim.g.mkdp_port = ''
      vim.g.mkdp_page_title = '「${name}」'
      vim.g.mkdp_filetypes = { 'markdown' }
      vim.g.mkdp_theme = 'light'
    end,
  },
  {
    'Myzel394/easytables.nvim',
    lazy = false,
  },
  -- attempt to add image support. Not working right now
  {
    "https://github.com/3rd/image.nvim",
    opts = {},
  },
}


return plugins
