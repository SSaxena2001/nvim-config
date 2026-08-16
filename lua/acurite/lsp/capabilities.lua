-- Capabilities advertised to every server.
--
-- cmp-nvim-lsp loads on InsertEnter, which is usually *after* the servers are
-- configured, so its extras are merged in only when it happens to be loaded
-- already. The base set is what actually matters for starting a server.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok then
  capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
end

return capabilities
