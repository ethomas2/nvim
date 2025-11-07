dofile(vim.g.base46_cache .. "lsp")
require "nvchad.lsp"

local M = {}
local utils = require "core.utils"

-- Helper function to check if any LSP client supports signatureHelp
local function has_signature_help_support(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
  for _, client in ipairs(clients) do
    if client.server_capabilities.signatureHelpProvider then
      return true
    end
  end
  return false
end

-- Override signature_help to check capabilities first
-- This prevents errors when signatureHelp is called but no server supports it
local original_signature_help = vim.lsp.buf.signature_help
vim.lsp.buf.signature_help = function(opts, ...)
  if has_signature_help_support() then
    return original_signature_help(opts, ...)
  end
  -- Silently return if no server supports signatureHelp
end

-- Wrap buf_request to catch signatureHelp requests and check capabilities
-- Only wrap if the function exists (for compatibility with different Neovim versions)
if vim.lsp.buf_request then
  local original_buf_request = vim.lsp.buf_request
  vim.lsp.buf_request = function(bufnr, method, params, handler, ...)
    if method == "textDocument/signatureHelp" and not has_signature_help_support(bufnr) then
      -- Silently ignore signatureHelp requests when no server supports it
      return
    end
    return original_buf_request(bufnr, method, params, handler, ...)
  end
end

-- export on_attach & capabilities for custom lspconfigs
M.on_attach = function(client, bufnr)
  utils.load_mappings("lspconfig", { buffer = bufnr })

  if client.server_capabilities.signatureHelpProvider then
    -- Wrap signature setup in pcall to handle errors gracefully
    local ok, err = pcall(function()
      require("nvchad.signature").setup(client)
    end)
    if not ok then
      vim.notify("Failed to setup signature help: " .. tostring(err), vim.log.levels.WARN)
    end
  end
end

-- disable semantic tokens
M.on_init = function(client, _)
  if not utils.load_config().ui.lsp_semantic_tokens and client.supports_method "textDocument/semanticTokens" then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()

M.capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

require("lspconfig").lua_ls.setup {
  on_init = M.on_init,
  on_attach = M.on_attach,
  capabilities = M.capabilities,

  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          [vim.fn.expand "$VIMRUNTIME/lua"] = true,
          [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
          [vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types"] = true,
          [vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy"] = true,
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
}

return M
