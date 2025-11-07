---@type ChadrcConfig
local M = {}

M.ui = {
  theme = 'solarized_dark',
  tabufline = {
    enabled= false
  },
  -- Override diff highlight groups to add background colors
  hl_override = {
    DiffAdd = {
      guibg = "#005f00",
      ctermbg = 22,
    },
    DiffDelete = {
      guibg = "#5f0000",
      ctermbg = 52,
    },
    DiffChange = {
      guibg = "#00005f",
      ctermbg = 17,
    },
    DiffText = {
      guibg = "#005faf",
      ctermbg = 25,
    },
  },
}
M.plugins = "custom.plugins"



return M
