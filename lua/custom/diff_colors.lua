-- Diff color scheme manager
local diff_color_schemes = {
  -- Scheme 1: Cool-tinted backgrounds (default)
  [1] = function()
    vim.cmd([[
      highlight! DiffAdd    guibg=#0a3d2a ctermbg=22 guifg=#859900 ctermfg=64
      highlight! DiffDelete guibg=#2d0a1a ctermbg=52 guifg=#dc322f ctermfg=160
      highlight! DiffChange guibg=#2d2a0a ctermbg=58 guifg=#b58900 ctermfg=136
      highlight! DiffText   guibg=#0a1a2d ctermbg=17 guifg=#268bd2 ctermfg=33
    ]])
  end,
  -- Scheme 2: Base02 backgrounds with cyan instead of yellow
  [2] = function()
    vim.cmd([[
      highlight! DiffAdd    guibg=#073642 ctermbg=235 guifg=#859900 ctermfg=64
      highlight! DiffDelete guibg=#073642 ctermbg=235 guifg=#dc322f ctermfg=160
      highlight! DiffChange guibg=#073642 ctermbg=235 guifg=#2aa198 ctermfg=37
      highlight! DiffText   guibg=#073642 ctermbg=235 guifg=#268bd2 ctermfg=33
    ]])
  end,
}

-- Current scheme (default to 1)
local current_diff_scheme = 1

-- Function to apply a diff color scheme
local function apply_diff_scheme(scheme_num)
  if diff_color_schemes[scheme_num] then
    diff_color_schemes[scheme_num]()
    current_diff_scheme = scheme_num
    vim.notify("Diff color scheme: " .. scheme_num, vim.log.levels.INFO)
  else
    vim.notify("Invalid diff color scheme: " .. scheme_num, vim.log.levels.ERROR)
  end
end

-- Function to cycle through schemes
local function cycle_diff_scheme()
  local next_scheme = (current_diff_scheme % #diff_color_schemes) + 1
  apply_diff_scheme(next_scheme)
end

-- Create command
vim.api.nvim_create_user_command("DiffColors", function(opts)
  if opts.args == "" then
    -- No argument - cycle through schemes
    cycle_diff_scheme()
  else
    -- Argument provided - set specific scheme
    local scheme_num = tonumber(opts.args)
    if scheme_num then
      apply_diff_scheme(scheme_num)
    else
      vim.notify("Invalid argument. Use :DiffColors <number> or :DiffColors to cycle", vim.log.levels.ERROR)
    end
  end
end, { nargs = "?", complete = function() return {"1", "2"} end })

-- Force diff highlights after base46 loads - run very late to override everything
vim.api.nvim_create_autocmd({"VimEnter", "UIEnter"}, {
  group = vim.api.nvim_create_augroup("ForceDiffHighlights", { clear = true }),
  callback = function()
    -- Use vim.schedule to run after all other startup code
    vim.schedule(function()
      -- Apply default scheme (scheme 1)
      apply_diff_scheme(1)
    end)
  end,
  once = true,
})

return {
  apply_diff_scheme = apply_diff_scheme,
  cycle_diff_scheme = cycle_diff_scheme,
}
