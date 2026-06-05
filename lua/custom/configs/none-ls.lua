local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
-- none-ls keeps the same module name:
local null_ls = require("null-ls")

local sources = {
  -- Python
  null_ls.builtins.formatting.isort.with({
    prefer_local = ".venv/bin",
  }),
  null_ls.builtins.formatting.black.with({
    prefer_local = ".venv/bin",
    extra_args = { "--fast" },
  }),
  null_ls.builtins.diagnostics.pylint.with({
    prefer_local = ".venv/bin",
  }),

  -- Typescript / Web
  null_ls.builtins.formatting.biome.with({
    filetypes = {
      "typescriptreact", "javascriptreact", "javascript", "typescript",
      "json", "jsonc", "css",
    },
  }),
}

-- Rust: only register if rustfmt is on PATH
if vim.fn.executable("rustfmt") == 1 then
  table.insert(sources, null_ls.builtins.formatting.rustfmt.with({
    filetypes = { "rust" },
  }))
end

local opts = {
  sources = sources,

  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({
            bufnr = bufnr,
            -- ensure we use null-ls (Black/Prettier) as the formatter
            filter = function(c) return c.name == "null-ls" end,
          })
          vim.api.nvim_command("echo 'Formatted with LSP.'")
        end,
      })
    end
  end,
}

-- start none-ls/null-ls with the configured opts
null_ls.setup(opts)
