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

-- Zettlekasten and Obsidian Template Commands
local zettle_dir = "/Users/evanthomas/notes/Main/Zettlekasten"
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

-- NewZettle command
new_cmd("NewZettle", function(opts)
  local filename = opts.args
  if filename == "" then
    vim.notify("Usage: :NewZettle <filename>", vim.log.levels.ERROR)
    return
  end
  local path = zettle_dir .. "/" .. filename
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end, { nargs = 1, complete = "file" })

-- ObsidianTemplate command
new_cmd("ObsidianTemplate", function(opts)
  local template = opts.args
  if template == "" then
    vim.notify("Usage: :ObsidianTemplate <template>", vim.log.levels.ERROR)
    return
  end

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
end, { nargs = 1, complete = "file" })
