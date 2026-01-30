
require "core"

local custom_init_path = vim.api.nvim_get_runtime_file("lua/custom/init.lua", false)[1]

if custom_init_path then
  dofile(custom_init_path)
end

require("core.utils").load_mappings()

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

-- bootstrap lazy.nvim!
if not vim.loop.fs_stat(lazypath) then
  require("core.bootstrap").gen_chadrc_template()
  require("core.bootstrap").lazy(lazypath)
end

dofile(vim.g.base46_cache .. "defaults")
vim.opt.rtp:prepend(lazypath)
require "plugins"
vim.cmd("source ~/.config/nvim/vimrc")

local config_path = '/Users/evanthomas/.config/nvim/vim-files/'

vim.cmd('source ' .. config_path .. 'header.vim')
vim.cmd('source ' .. config_path .. 'remaps.vim')
vim.cmd('source ' .. config_path .. 'run.vim')
vim.cmd('source ' .. config_path .. 'snippets.vim')
vim.cmd('source ' .. config_path .. 'windowsAndTabs.vim')
vim.cmd('source ' .. config_path .. 'tabnames.vim')


-- Source local.lua once at startup if present
local startup_local = vim.fn.getcwd() .. "/local.lua"
if vim.fn.filereadable(startup_local) == 1 then
  vim.cmd("source " .. vim.fn.fnameescape(startup_local))
end


-- Automatically reload local.lua on save
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "local.lua",
  callback = function(args)
    local path = args.file
    if vim.fn.filereadable(path) == 1 then
      vim.cmd("source " .. vim.fn.fnameescape(path))
      vim.notify("🔁 Reloaded " .. path, vim.log.levels.INFO)
    end
  end,
})



-- Diff configuration - set diff options
vim.opt.diffopt:append("internal")
vim.opt.diffopt:append("algorithm:histogram")
vim.opt.diffopt:append("iwhiteall")

-- Load diff color scheme manager
require("custom.diff_colors")

-- Load NewZettle command
require("custom.newzettle")

-- Load window titles configuration
require("custom.window_titles")

-- Load GPG encryption/decryption commands
require("custom.gpg_crypt").setup()
