local config = require("plugins.configs.lspconfig")

local on_attach = config.on_attach
local capabilities = config.capabilities

-- lspconfig.pylsp.setup({
vim.lsp.config('pyright', {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {"python"},
})
vim.lsp.enable('pyright')

-- TypeScript / JavaScript
-- vim.lsp.config('tsserver', {
--   on_attach = on_attach,
--   capabilities = capabilities,
--   filetypes = {"javascript", "typescript", "typescriptreact", "javascriptreact"},
-- })
-- vim.lsp.enable('tsserver')
vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "javascript", "typescript", "typescriptreact", "javascriptreact" },
})
vim.lsp.enable("ts_ls")

-- Setup for Rust (rust-analyzer)
vim.lsp.config('rust_analyzer', {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {"rust"},
})
vim.lsp.enable('rust_analyzer')
