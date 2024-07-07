local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local null_ls = require('null-ls')

local opts = {
  sources = {
    null_ls.builtins.formatting.isort,
    null_ls.builtins.formatting.black,
    null_ls.builtins.diagnostics.pylint,
    -- Typescript stuff
    null_ls.builtins.formatting.prettier.with({
   		filetypes = {
   			"typescriptreact", "javascriptreact", "javascript", "typescript",
        "css", "scss", "html", "json", "yaml", "graphql", "md",
        "txt",
  		},
  	}),
    -- null_ls.builtins.code_actions.ts_node_action({
    --   title = "Add Missing Imports",
    --   command = "source.addMissingImports.ts"
    -- }),
    -- null_ls.builtins.code_actions.ts_node_action({
    --   title = "Remove Unused Imports",
    --   command = "source.removeUnusedImports.ts"
    -- }),
    -- null_ls.builtins.code_actions.ts_node_action({
    --   title = "Sort Imports",
    --   command = "source.sortImports.ts"
    -- }),
    -- null_ls.builtins.code_actions.ts_node_action({
    --   title = "Organize Imports",
    --   command = "source.organizeImports.ts"
    -- }),
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({
        group = augroup,
        buffer = bufnr,
      })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({bufnr = bufnr})
          vim.api.nvim_command("echo 'Formatted with LSP.'")
        end,
      })
    end
  end,
}
return opts
