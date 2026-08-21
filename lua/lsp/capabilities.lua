-- Capabilities advertised to every server.
--
-- Completion is Neovim's own `vim.lsp.completion` (see init.lua), so there is
-- no nvim-cmp to merge extras in from. snippetSupport is still worth asking
-- for: it is what makes servers return function signatures with placeholders
-- rather than bare names.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

return capabilities
