-- :Telescope diff commit=HEAD~3
return require("telescope").register_extension({
  exports = {
    diff = function(opts)
      local commit = opts.commit
      if not commit or commit == "" then
        vim.notify(
          "Usage: :Telescope diff commit=HEAD~1",
          vim.log.levels.ERROR
        )
        return
      end
      require("custom.git_file_picker").pick(
        "git diff " .. vim.fn.shellescape(commit) .. " --name-only",
        "diff " .. commit
      )
    end,
  },
})
