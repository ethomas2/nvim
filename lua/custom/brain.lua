--- Brain: Telescope picker mirroring `brain fzf <query>` (mgrep over ~/notes/Main).
--- On <CR> opens the selected file at the matched line in nvim.
local M = {}

local NOTES_DIR = vim.fn.expand("~/notes/Main")

--- Run mgrep in NOTES_DIR and return list of result lines.
local function run_mgrep(query)
  local shell = string.format(
    "cd %s && mgrep -m 50 %s",
    vim.fn.shellescape(NOTES_DIR),
    vim.fn.shellescape(query)
  )
  local out = vim.fn.systemlist(shell)
  if vim.v.shell_error ~= 0 then
    return nil, table.concat(out, "\n")
  end
  return vim.tbl_filter(function(l) return l ~= "" end, out)
end

--- Parse a result line of form `<file>:<start>-<end> (...)` into {file, line}.
local function parse_line(line)
  local file, start = line:match("^([^:]+):(%d+)%-%d+")
  if not file then
    file = line:match("^([^:]+):") or line
  end
  -- mgrep prints paths relative to NOTES_DIR (e.g. "./foo.md")
  if file:sub(1, 2) == "./" then
    file = NOTES_DIR .. "/" .. file:sub(3)
  elseif not file:match("^/") then
    file = NOTES_DIR .. "/" .. file
  end
  return file, tonumber(start)
end

--- Open Telescope picker with mgrep results for `query`.
function M.fzf(query)
  if not query or query == "" then
    vim.notify("Brain: query required", vim.log.levels.ERROR)
    return
  end

  local results, err = run_mgrep(query)
  if not results then
    vim.notify("mgrep failed: " .. (err or ""), vim.log.levels.ERROR)
    return
  end
  if #results == 0 then
    vim.notify("Brain: no results", vim.log.levels.INFO)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers.new({}, {
    prompt_title = "brain: " .. query,
    finder = finders.new_table({
      results = results,
      entry_maker = function(line)
        local file, lnum = parse_line(line)
        return {
          value = line,
          display = line,
          ordinal = line,
          path = file,
          filename = file,
          lnum = lnum or 1,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = conf.grep_previewer({}),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if not entry then return end
        if entry.lnum then
          vim.cmd(string.format("edit +%d %s", entry.lnum, vim.fn.fnameescape(entry.filename)))
        else
          vim.cmd("edit " .. vim.fn.fnameescape(entry.filename))
        end
      end)
      return true
    end,
  }):find()
end

vim.api.nvim_create_user_command("Brain", function(opts)
  M.fzf(opts.args)
end, { nargs = 1 })

return M
