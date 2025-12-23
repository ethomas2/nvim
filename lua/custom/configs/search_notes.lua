-- Search notes with Telescope - VSCode-like behavior
-- Opens existing files or creates new ones in Zettlekasten

local M = {}

M.search_notes = function()
  local telescope = require("telescope.builtin")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  
  local notes_dir = vim.fn.expand("~/notes")
  local zettlekasten_dir = vim.fn.expand("~/notes/Main/Zettlekasten")

  -- Helper function to get the prompt text
  local function get_prompt_text(picker)
    if picker and picker.prompt_bufnr then
      local prompt_lines = vim.api.nvim_buf_get_lines(picker.prompt_bufnr, 0, -1, false)
      if prompt_lines and #prompt_lines > 0 then
        local input = prompt_lines[#prompt_lines] or ""
        -- Remove prompt prefix
        local prefix = picker.prompt_prefix or ""
        if prefix ~= "" and input:sub(1, #prefix) == prefix then
          input = input:sub(#prefix + 1)
        end
        input = input:gsub("^%s+", ""):gsub("%s+$", "")
        return input
      end
    end
    return ""
  end

  -- Helper function to show template selection floating window
  local function show_template_picker(filename, callback)
    local options = { "note", "idea", "none" }
    local width = 30
    local height = #options + 2
    
    -- Create a scratch buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(buf, "filetype", "")
    
    -- Set content
    local lines = { "Select template:", "" }
    for _, opt in ipairs(options) do
      table.insert(lines, "  " .. opt)
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    
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
    
    -- Set syntax highlighting
    vim.api.nvim_buf_set_option(buf, "syntax", "")
    
    local selected_index = 1
    local ns_id = vim.api.nvim_create_namespace("template_picker")
    
    -- Highlight function
    local function highlight_selection()
      -- Clear all highlights
      vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
      
      -- Highlight selected line
      vim.api.nvim_buf_add_highlight(buf, ns_id, "Visual", selected_index + 1, 0, -1)
    end
    
    -- Initial highlight
    highlight_selection()
    
    -- Key mappings
    local function close_and_callback()
      local selected_option = options[selected_index]
      vim.api.nvim_win_close(win, true)
      callback(selected_option)
    end
    
    vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
      callback = close_and_callback,
    })
    
    vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "", {
      callback = function()
        vim.api.nvim_win_close(win, true)
      end,
    })
    
    vim.api.nvim_buf_set_keymap(buf, "n", "j", "", {
      callback = function()
        if selected_index < #options then
          selected_index = selected_index + 1
          highlight_selection()
        end
      end,
    })
    
    vim.api.nvim_buf_set_keymap(buf, "n", "k", "", {
      callback = function()
        if selected_index > 1 then
          selected_index = selected_index - 1
          highlight_selection()
        end
      end,
    })
    
    vim.api.nvim_buf_set_keymap(buf, "n", "1", "", {
      callback = function()
        selected_index = 1
        highlight_selection()
      end,
    })
    
    vim.api.nvim_buf_set_keymap(buf, "n", "2", "", {
      callback = function()
        selected_index = 2
        highlight_selection()
      end,
    })
    
    vim.api.nvim_buf_set_keymap(buf, "n", "3", "", {
      callback = function()
        selected_index = 3
        highlight_selection()
      end,
    })
    
    -- Also handle insert mode
    vim.api.nvim_buf_set_keymap(buf, "i", "<CR>", "", {
      callback = close_and_callback,
    })
    
    vim.api.nvim_buf_set_keymap(buf, "i", "<Esc>", "", {
      callback = function()
        vim.api.nvim_win_close(win, true)
      end,
    })
  end

  -- Helper function to create and open a file in Zettlekasten
  local function create_zettlekasten_file(filename, template)
    if filename and filename ~= "" then
      -- Add .md extension if not present
      if not filename:match("%.md$") and not filename:match("%.markdown$") then
        filename = filename .. ".md"
      end
      
      local file_path = zettlekasten_dir .. "/" .. filename
      file_path = vim.fn.expand(file_path)
      
      -- Create file if it doesn't exist
      if vim.fn.filereadable(file_path) == 0 then
        -- Ensure Zettlekasten directory exists
        if vim.fn.isdirectory(zettlekasten_dir) == 0 then
          vim.fn.mkdir(zettlekasten_dir, "p")
        end
        vim.fn.writefile({}, file_path)
      end
      
      vim.cmd("edit " .. vim.fn.fnameescape(file_path))
      
      -- Execute template if selected
      if template and template ~= "none" then
        vim.cmd("ObsidianTemplate " .. template)
      end
    end
  end

  -- Helper function to create and open a file (for Enter key)
  local function create_and_open_file(file_path)
    if file_path and file_path ~= "" then
      file_path = vim.fn.expand(file_path)
      
      -- Create file if it doesn't exist
      if vim.fn.filereadable(file_path) == 0 then
        local dir = vim.fn.fnamemodify(file_path, ":h")
        if dir ~= "" and dir ~= "." and vim.fn.isdirectory(dir) == 0 then
          vim.fn.mkdir(dir, "p")
        end
        vim.fn.writefile({}, file_path)
      end
      
      vim.cmd("edit " .. vim.fn.fnameescape(file_path))
    end
  end

  -- Helper function to create a new file with .md extension (for Ctrl+C)
  local function create_new_file_from_prompt(prompt_text, template)
    if prompt_text and prompt_text ~= "" then
      -- Add .md extension if not present
      if not prompt_text:match("%.md$") and not prompt_text:match("%.markdown$") then
        prompt_text = prompt_text .. ".md"
      end
      
      -- Ensure zettlekasten_dir is expanded
      local expanded_zettlekasten_dir = vim.fn.expand("~/notes/Main/Zettlekasten")
      
      -- Build file path relative to zettlekasten_dir
      local file_path = expanded_zettlekasten_dir .. "/" .. prompt_text
      file_path = vim.fn.expand(file_path)
      
      -- Create file if it doesn't exist
      if vim.fn.filereadable(file_path) == 0 then
        -- Ensure Zettlekasten directory exists
        if vim.fn.isdirectory(expanded_zettlekasten_dir) == 0 then
          vim.fn.mkdir(expanded_zettlekasten_dir, "p")
        end
        vim.fn.writefile({}, file_path)
      end
      
      vim.cmd("edit " .. vim.fn.fnameescape(file_path))
      
      -- Execute template if selected and not "none"
      if template and template ~= "none" then
        vim.cmd("ObsidianTemplate " .. template)
      end
    end
  end

  telescope.find_files({
    cwd = notes_dir,
    prompt_prefix = "    ",
    results_title = "Notes Files  |  Press C-c to create new file in Zettlekasten",
    attach_mappings = function(prompt_bufnr, map)
      -- Override the default select action (Enter key)
      map("i", "<CR>", function()
        local selection = action_state.get_selected_entry()
        local current_picker = action_state.get_current_picker(prompt_bufnr)
        
        -- Get file path from selection or prompt
        local file_path = nil
        if selection then
          -- Selection gives us the full path relative to cwd (notes_dir)
          file_path = notes_dir .. "/" .. selection.value
        else
          -- Try to get input from prompt buffer
          local prompt_text = get_prompt_text(current_picker)
          if prompt_text ~= "" then
            -- If it's not an absolute path, make it relative to notes_dir
            if not vim.fn.fnamemodify(prompt_text, ":p"):match("^/") then
              file_path = notes_dir .. "/" .. prompt_text
            else
              file_path = prompt_text
            end
          end
        end
        
        -- Close the picker
        actions.close(prompt_bufnr)
        
        -- Open or create file
        if file_path and file_path ~= "" then
          create_and_open_file(file_path)
        end
      end)
      
      -- Also handle normal mode Enter
      map("n", "<CR>", function()
        local selection = action_state.get_selected_entry()
        local current_picker = action_state.get_current_picker(prompt_bufnr)
        
        local file_path = nil
        if selection then
          file_path = notes_dir .. "/" .. selection.value
        else
          local prompt_text = get_prompt_text(current_picker)
          if prompt_text ~= "" then
            if not vim.fn.fnamemodify(prompt_text, ":p"):match("^/") then
              file_path = notes_dir .. "/" .. prompt_text
            else
              file_path = prompt_text
            end
          end
        end
        
        actions.close(prompt_bufnr)
        
        if file_path and file_path ~= "" then
          create_and_open_file(file_path)
        end
      end)
      
      -- Ctrl+N: Create new file in Zettlekasten from typed text with template selection
      map("i", "<C-n>", function()
        local current_picker = action_state.get_current_picker(prompt_bufnr)
        local prompt_text = get_prompt_text(current_picker)
        
        actions.close(prompt_bufnr)
        
        if prompt_text ~= "" then
          show_template_picker(prompt_text, function(template)
            create_zettlekasten_file(prompt_text, template)
          end)
        end
      end)
      
      map("n", "<C-n>", function()
        local current_picker = action_state.get_current_picker(prompt_bufnr)
        local prompt_text = get_prompt_text(current_picker)
        
        actions.close(prompt_bufnr)
        
        if prompt_text ~= "" then
          show_template_picker(prompt_text, function(template)
            create_zettlekasten_file(prompt_text, template)
          end)
        end
      end)
      
      -- Ctrl+C: Create new file from typed text with template selection
      map("i", "<C-c>", function()
        local current_picker = action_state.get_current_picker(prompt_bufnr)
        local prompt_text = get_prompt_text(current_picker)
        
        actions.close(prompt_bufnr)
        
        if prompt_text ~= "" then
          show_template_picker(prompt_text, function(template)
            create_new_file_from_prompt(prompt_text, template)
          end)
        end
      end)
      
      map("n", "<C-c>", function()
        local current_picker = action_state.get_current_picker(prompt_bufnr)
        local prompt_text = get_prompt_text(current_picker)
        
        actions.close(prompt_bufnr)
        
        if prompt_text ~= "" then
          show_template_picker(prompt_text, function(template)
            create_new_file_from_prompt(prompt_text, template)
          end)
        end
      end)
      
      return true
    end,
  })
end

return M
