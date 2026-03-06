-- :Telescope dbase — files changed vs merge-base with default branch
return require("telescope").register_extension({
  exports = {
    dbase = function()
      require("custom.git_file_picker").pick(
        "git dbase --name-only",
        "dbase (changed vs default branch)"
      )
    end,
  },
})
