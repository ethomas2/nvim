--- Shared helper: open a Telescope picker over filenames from a git command.
local M = {}

function M.pick(cmd, title)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values

  local output = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("git command failed: " .. table.concat(output, "\n"), vim.log.levels.ERROR)
    return
  end

  output = vim.tbl_filter(function(line) return line ~= "" end, output)

  if #output == 0 then
    vim.notify("No changed files", vim.log.levels.INFO)
    return
  end

  pickers.new({}, {
    prompt_title = title,
    finder = finders.new_table({ results = output }),
    sorter = conf.generic_sorter({}),
    previewer = conf.file_previewer({}),
  }):find()
end

-- :DiffFiles <commit> — convenience command with positional arg
vim.api.nvim_create_user_command("DiffFiles", function(opts)
  local commit = opts.args
  if not commit or commit == "" then
    vim.notify("Usage: :DiffFiles HEAD~1", vim.log.levels.ERROR)
    return
  end
  M.pick("git diff " .. vim.fn.shellescape(commit) .. " --name-only", "diff " .. commit)
end, { nargs = 1 })

return M
