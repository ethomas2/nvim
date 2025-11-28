local opt = vim.opt
local g = vim.g
local config = require("core.utils").load_config()

-------------------------------------- globals -----------------------------------------
g.nvchad_theme = config.ui.theme
g.base46_cache = vim.fn.stdpath "data" .. "/nvchad/base46/"
g.toggle_theme_icon = "   "
g.transparency = config.ui.transparency

-------------------------------------- options ------------------------------------------
opt.laststatus = 3 -- global statusline
opt.showmode = false

opt.clipboard = "unnamedplus"
opt.cursorline = true

-- Indenting
opt.expandtab = true
opt.shiftwidth = 2
opt.smartindent = true
opt.tabstop = 2
opt.softtabstop = 2

opt.fillchars = { eob = " " }
opt.ignorecase = true
opt.smartcase = true
opt.mouse = "a"

-- Numbers
opt.number = true
opt.numberwidth = 2
opt.ruler = false

-- disable nvim intro
opt.shortmess:append "sI"

opt.signcolumn = "yes"
opt.splitbelow = true
opt.splitright = true
opt.termguicolors = true
opt.timeoutlen = 400
opt.undofile = true

-- interval for writing swap file to disk, also used by gitsigns
opt.updatetime = 250

-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
opt.whichwrap:append "<>[]hl"

g.mapleader = " "

-- disable some default providers
for _, provider in ipairs { "node", "perl", "python3", "ruby" } do
  vim.g["loaded_" .. provider .. "_provider"] = 0
end

-- add binaries installed by mason.nvim to path
local is_windows = vim.fn.has("win32") ~= 0
vim.env.PATH = vim.fn.stdpath "data" .. "/mason/bin" .. (is_windows and ";" or ":") .. vim.env.PATH

-------------------------------------- autocmds ------------------------------------------
local autocmd = vim.api.nvim_create_autocmd

-- dont list quickfix buffers
autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.opt_local.buflisted = false
  end,
})

-- reload some chadrc options on-save
autocmd("BufWritePost", {
  pattern = vim.tbl_map(function(path)
    return vim.fs.normalize(vim.loop.fs_realpath(path))
  end, vim.fn.glob(vim.fn.stdpath "config" .. "/lua/custom/**/*.lua", true, true, true)),
  group = vim.api.nvim_create_augroup("ReloadNvChad", {}),

  callback = function(opts)
    local fp = vim.fn.fnamemodify(vim.fs.normalize(vim.api.nvim_buf_get_name(opts.buf)), ":r") --[[@as string]]
    local app_name = vim.env.NVIM_APPNAME and vim.env.NVIM_APPNAME or "nvim"
    local module = string.gsub(fp, "^.*/" .. app_name .. "/lua/", ""):gsub("/", ".")

    require("plenary.reload").reload_module "base46"
    require("plenary.reload").reload_module(module)
    require("plenary.reload").reload_module "custom.chadrc"

    config = require("core.utils").load_config()

    vim.g.nvchad_theme = config.ui.theme
    vim.g.transparency = config.ui.transparency

    -- statusline
    require("plenary.reload").reload_module("nvchad.statusline." .. config.ui.statusline.theme)
    vim.opt.statusline = "%!v:lua.require('nvchad.statusline." .. config.ui.statusline.theme .. "').run()"

    -- tabufline
    if config.ui.tabufline.enabled then
      require("plenary.reload").reload_module "nvchad.tabufline.modules"
      vim.opt.tabline = "%!v:lua.require('nvchad.tabufline.modules').run()"
    end

    require("base46").load_all_highlights()
    -- vim.cmd("redraw!")
  end,
})

-- user event that loads after UIEnter + only if file buf is there
vim.api.nvim_create_autocmd({ "UIEnter", "BufReadPost", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("NvFilePost", { clear = true }),
  callback = function(args)
    local file = vim.api.nvim_buf_get_name(args.buf)
    local buftype = vim.api.nvim_buf_get_option(args.buf, "buftype")

    if not vim.g.ui_entered and args.event == "UIEnter" then
      vim.g.ui_entered = true
    end

    if file ~= "" and buftype ~= "nofile" and vim.g.ui_entered then
      vim.api.nvim_exec_autocmds("User", { pattern = "FilePost", modeline = false })
      vim.api.nvim_del_augroup_by_name "NvFilePost"

      vim.schedule(function()
        vim.api.nvim_exec_autocmds("FileType", {})

        if vim.g.editorconfig then
          require("editorconfig").config(args.buf)
        end
      end, 0)
    end
  end,
})

-------------------------------------- commands ------------------------------------------
local new_cmd = vim.api.nvim_create_user_command

new_cmd("NvChadUpdate", function()
  require "nvchad.updater"()
end, {})

-- Reload config command (untested
-- new_cmd("ReloadConfig", function()
--   local config_path = vim.fn.stdpath("config")

--   -- Function to find all files that need to be reloaded
--   local function find_files_to_reload()
--     local files = {}

--     -- Find all Lua modules
--     local lua_dirs = { "core", "custom", "plugins" }
--     for _, dir in ipairs(lua_dirs) do
--       local lua_files = vim.fn.glob(config_path .. "/lua/" .. dir .. "/**/*.lua", true, true)
--       for _, file in ipairs(lua_files) do
--         -- Convert file path to module name
--         local module = file:gsub(config_path .. "/lua/", ""):gsub("%.lua$", ""):gsub("/", ".")
--         if module ~= "core.init" then -- Don't reload core.init while we're in it
--           table.insert(files, { type = "lua_module", path = module })
--         end
--       end
--     end

--     -- Add vimrc
--     table.insert(files, { type = "vimrc", path = "~/.config/nvim/vimrc" })

--     -- Add vim-files
--     local vim_files = { "header.vim", "remaps.vim", "run.vim", "snippets.vim", "windowsAndTabs.vim", "tabnames.vim" }
--     for _, vim_file in ipairs(vim_files) do
--       table.insert(files, { type = "vim_file", path = config_path .. "/vim-files/" .. vim_file })
--     end

--     -- Add custom init if it exists
--     local custom_init_path = vim.api.nvim_get_runtime_file("lua/custom/init.lua", false)[1]
--     if custom_init_path then
--       table.insert(files, { type = "custom_init", path = custom_init_path })
--     end

--     return files
--   end

--   -- Function to process each file
--   local function process_file(file_info)
--     if file_info.type == "lua_module" then
--       local reload = require("plenary.reload").reload_module
--       pcall(reload, file_info.path)
--       pcall(require, file_info.path)
--     elseif file_info.type == "vimrc" or file_info.type == "vim_file" then
--       vim.cmd("source " .. vim.fn.fnameescape(file_info.path))
--     elseif file_info.type == "custom_init" then
--       local reload = require("plenary.reload").reload_module
--       pcall(reload, "custom.init")
--       dofile(file_info.path)
--     end
--   end

--   -- Find and process all files
--   local files = find_files_to_reload()
--   for _, file_info in ipairs(files) do
--     process_file(file_info)
--   end

--   -- Reload mappings after all modules are reloaded
--   require("core.utils").load_mappings()

--   vim.notify("Config reloaded!", vim.log.levels.INFO)
-- end, {})

-- Obsidian Template Commands
local templates_dir = "/Users/evanthomas/notes/Main/Templates"

-- Helper functions for template rendering
local function str_split_lines(s)
  local t = {}
  for line in (s.."\n"):gmatch("([^\n]*)\n") do
    table.insert(t, line)
  end
  return t
end

local function obsidian_to_strftime(fmt)
  -- Convert Obsidian-like tokens to Lua os.date codes
  -- Supports: YYYY, MM, DD, HH, mm, ss
  local map = { YYYY = "%%Y", MM = "%%m", DD = "%%d", HH = "%%H", mm = "%%M", ss = "%%S" }
  -- Replace longest first to avoid overlaps
  fmt = fmt:gsub("YYYY", map.YYYY)
           :gsub("HH",   map.HH)
           :gsub("MM",   map.MM)
           :gsub("DD",   map.DD)
           :gsub("mm",   map.mm)
           :gsub("ss",   map.ss)
  return fmt
end

local function render_template_text(text)
  -- {{title}} => current buffer file stem
  local title = vim.fn.expand("%:t:r")
  if title == "" then
    -- fallback to buffer name or "Untitled"
    title = vim.fn.bufname("%"):match("([^/]+)%.%w+$") or "Untitled"
  end
  text = text:gsub("{{title}}", title)

  -- {{date:...}} => format with os.date
  -- e.g. {{date:YYYY-MM-DD}} or {{date:HH:mm}}
  text = text:gsub("{{date:([^}]+)}}", function(fmt)
    local lf = obsidian_to_strftime(fmt)
    return os.date(lf)
  end)

  return text
end

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

-- Function to execute ObsidianTemplate with template name
local function execute_obsidian_template(template)
  local template_path = templates_dir .. "/" .. template
  if not template_path:match("%.md$") then
    template_path = template_path .. ".md"
  end

  if vim.fn.filereadable(template_path) == 0 then
    vim.notify("Template not found: " .. template_path, vim.log.levels.ERROR)
    return
  end

  local raw = table.concat(vim.fn.readfile(template_path), "\n")
  local rendered = render_template_text(raw)

  -- Append to end of current buffer (preserve a separating newline if needed)
  local bufnr = 0
  local last = vim.api.nvim_buf_line_count(bufnr)
  local existing = vim.api.nvim_buf_get_lines(bufnr, last-1, last, false)[1] or ""
  local lines = str_split_lines(((existing ~= "" and not existing:match("^%s*$")) and ("\n"..rendered) or rendered))

  vim.api.nvim_buf_set_lines(bufnr, last, last, false, lines)
  vim.notify("Inserted rendered template: " .. template, vim.log.levels.INFO)
end

-- ObsidianTemplate command
new_cmd("ObsidianTemplate", function(opts)
  local template = opts.args
  if template == "" then
    -- No arg provided, show floating window
    floating_input("", function(input)
      if input ~= "" then
        execute_obsidian_template(input)
      end
    end)
  else
    -- Arg provided, execute directly
    execute_obsidian_template(template)
  end
end, { nargs = "?", complete = "file" })
