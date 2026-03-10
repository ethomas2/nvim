---@type ChadrcConfig
local M = {}

M.ui = {
  theme = 'solarized_dark',
  tabufline = {
    enabled= false
  },
  statusline = {
    overriden_modules = function(modules)
      table.insert(modules, " Ln %l, Col %c")
    end,
  },
  -- Override diff highlight groups to add background colors
  hl_override = {
    DiffAdd = { bg = "#005f00" },
    DiffDelete = { bg = "#5f0000" },
    DiffChange = { bg = "#00005f" },
    DiffText = { bg = "#005faf" },
  },
}
M.plugins = "custom.plugins"



return M
