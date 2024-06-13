
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
