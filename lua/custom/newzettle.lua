local new_cmd = vim.api.nvim_create_user_command

-- Zettlekasten directory
local zettle_dir = "/Users/evanthomas/notes/Main/Zettlekasten"

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
