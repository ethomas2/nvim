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
-- tsgo (native TypeScript server) when installed: one process per monorepo and far less memory.
-- Fallback is typescript-language-server with tsserver's heap capped, so it restarts instead of
-- growing for days. Set vim.g.ts_lsp = "ts_ls" before this loads to force the old server.
vim.lsp.config("tsgo", {
  on_attach = on_attach,
  capabilities = capabilities,
})
vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "javascript", "typescript", "typescriptreact", "javascriptreact" },
  init_options = { maxTsServerMemory = 3072 },
})
if vim.g.ts_lsp ~= "ts_ls" and vim.fn.executable("tsgo") == 1 then
  vim.lsp.enable("tsgo")
else
  vim.lsp.enable("ts_ls")
end

-- Biome (JS/TS/JSON/CSS linting + formatting)
vim.lsp.config('biome', {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "jsonc", "css" },
})
vim.lsp.enable('biome')

-- Setup for Rust (rust-analyzer)
vim.lsp.config('rust_analyzer', {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {"rust"},
})
vim.lsp.enable('rust_analyzer')
