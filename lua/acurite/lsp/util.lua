-- Shared helpers for resolving project roots and trimming server features.
-- Used by configs/lsp/servers.lua.

local function disable_semantic_tokens(client)
  -- Treesitter already handles syntax highlighting. Disabling semantic tokens
  -- avoids extra per-buffer LSP work, especially noticeable in large TS/JS projects.
  client.server_capabilities.semanticTokensProvider = nil
end

local function on_attach_disable_semantic_tokens(client)
  disable_semantic_tokens(client)
end

return {
  disable_semantic_tokens = disable_semantic_tokens,
  on_attach_disable_semantic_tokens = on_attach_disable_semantic_tokens,
}
