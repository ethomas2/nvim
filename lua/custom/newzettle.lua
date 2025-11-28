local new_cmd = vim.api.nvim_create_user_command

-- Zettlekasten directory
local zettle_dir = "/Users/evanthomas/notes/Main/Zettlekasten"

-- Helper function to show floating window input
local function floating_input(prompt, callback)
  local width = math.max(50, #prompt + 20)
  local height = 1

  -- Create a scratch buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "buftype", "")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "filetype", "")

  -- Set initial content with prompt
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { prompt })

  -- Calculate window position (centered)
  local ui = vim.api.nvim_list_uis()[1]
  local win_width = ui.width
  local win_height = ui.height
  local col = math.floor((win_width - width) / 2)
  local row = math.floor((win_height - height) / 2)

  -- Create floating window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
  })

  -- Set up keymaps
  local function on_confirm()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local input = lines[1] or ""
    -- Remove prompt prefix if present
    if input:sub(1, #prompt) == prompt then
      input = input:sub(#prompt + 1)
    end
    input = input:match("^%s*(.-)%s*$") -- Trim whitespace
    -- Mark buffer as not modified before closing
    vim.api.nvim_buf_set_option(buf, "modified", false)
    vim.api.nvim_win_close(win, true)
    if input ~= "" then
      callback(input)
    end
  end

  -- Prevent deleting the prompt
  vim.api.nvim_buf_set_keymap(buf, "i", "<Home>", "", {
    callback = function()
      vim.api.nvim_win_set_cursor(win, {1, #prompt})
    end,
  })

  vim.api.nvim_buf_set_keymap(buf, "i", "<CR>", "", {
    callback = on_confirm,
  })

  vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
    callback = on_confirm,
  })

  vim.api.nvim_buf_set_keymap(buf, "i", "<Esc>", "", {
    callback = function()
      vim.api.nvim_buf_set_option(buf, "modified", false)
      vim.api.nvim_win_close(win, true)
    end,
  })

  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "", {
    callback = function()
      vim.api.nvim_buf_set_option(buf, "modified", false)
      vim.api.nvim_win_close(win, true)
    end,
  })

  -- Move cursor to end of prompt and start insert mode
  vim.api.nvim_win_set_cursor(win, {1, #prompt})
  vim.cmd("startinsert")
end

-- Function to execute NewZettle with filename
local function execute_newzettle(filename)
  local path = zettle_dir .. "/" .. filename
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end

-- NewZettle command
new_cmd("NewZettle", function(opts)
  local filename = opts.args
  if filename == "" then
    -- No arg provided, show floating window
    floating_input("", function(input)
      if input ~= "" then
        execute_newzettle(input)
      end
    end)
  else
    -- Arg provided, execute directly
    execute_newzettle(filename)
  end
end, { nargs = "?", complete = "file" })
