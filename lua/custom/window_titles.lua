-- Window titles configuration
-- Shows filename in winbar (window bar) for each split window
-- This displays the filename at the top of each window pane

-- Function to set WinBar highlights (must be called after base46 loads)
-- Use highlight! to force override, similar to diff_colors.lua
local function setup_winbar_highlights()
  vim.cmd([[
    highlight! WinBar    guibg=#073642 ctermbg=236 guifg=#eee8d5 ctermfg=230 gui=bold
    highlight! WinBarNC  guibg=#073642 ctermbg=236 guifg=#657b83 ctermfg=243
  ]])
end

local function update_winbar()
  -- Only set winbar for normal file buffers
  local buf = vim.api.nvim_get_current_buf()
  local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
  
  -- Skip winbar for special buffers like help, quickfix, terminal, etc.
  if buftype ~= "" and buftype ~= "acwrite" then
    vim.opt_local.winbar = nil
    return
  end
  
  -- Get filename
  local filename = vim.api.nvim_buf_get_name(buf)
  if filename == "" or filename == nil then
    filename = "[No Name]"
  else
    filename = vim.fn.fnamemodify(filename, ":t")
    if filename == "" then
      filename = "[No Name]"
    end
  end
  
  -- Set winbar as a cute tag/badge style
  -- Create a tag effect: filename with background, rest transparent
  -- Use statusline format with proper highlighting
  vim.opt_local.winbar = "%#WinBar#" .. " " .. filename .. " " .. "%*" .. "%#Normal#%*"
end

-- Create autocmd group
local augroup = vim.api.nvim_create_augroup("WindowTitles", { clear = true })

-- Update winbar on various events
vim.api.nvim_create_autocmd({
  "WinEnter",
  "BufEnter",
  "BufNewFile",
  "BufReadPost",
  "BufWritePost",
  "FileType",
  "BufWinEnter",
}, {
  group = augroup,
  callback = update_winbar,
})

-- Update winbar when a new window is created
vim.api.nvim_create_autocmd("WinNew", {
  group = augroup,
  callback = function()
    vim.schedule(update_winbar)
  end,
})

-- Update winbar on VimEnter to handle nvim -O and similar cases
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup,
  callback = function()
    vim.schedule(function()
      -- Update winbar for all windows
      local wins = vim.api.nvim_list_wins()
      if #wins > 0 then
        for _, win in ipairs(wins) do
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_set_current_win(win)
            update_winbar()
          end
        end
        -- Restore focus to first window
        if vim.api.nvim_win_is_valid(wins[1]) then
          vim.api.nvim_set_current_win(wins[1])
          update_winbar()
        end
      else
        update_winbar()
      end
    end)
  end,
})

-- Also handle UIEnter for GUI clients
vim.api.nvim_create_autocmd("UIEnter", {
  group = augroup,
  callback = function()
    vim.schedule(update_winbar)
  end,
  once = true,
})

-- Setup highlights after base46 loads (similar to diff_colors approach)
vim.api.nvim_create_autocmd({"VimEnter", "UIEnter"}, {
  group = vim.api.nvim_create_augroup("SetupWinBarHighlights", { clear = true }),
  callback = function()
    vim.schedule(function()
      setup_winbar_highlights()
      update_winbar()
    end)
  end,
  once = true,
})

-- Initial update after a short delay to ensure everything is loaded
vim.schedule(function()
  vim.defer_fn(function()
    setup_winbar_highlights()
    update_winbar()
  end, 100)
end)
