-- Buffer-local LSP setup. Everything here needs a buffer that actually has a
-- server attached, so it cannot live in core/keymaps/ with the global maps.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("AcuriteLspAttach", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
    end

    -- Buffer-local so Vim's own `gd` (go to local declaration) and `gt`
    -- (:tabnext) survive in every buffer without a language server.
    -- Note 'tagfunc' already routes CTRL-] through the LSP for free.
    if client:supports_method("textDocument/definition") then
      map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
      map("n", "gt", function()
        vim.cmd("tab split")
        vim.lsp.buf.definition()
      end, "Goto Definition in New Tab")
    end

    -- On by default in 0.12 (:h lsp-document_color). nvim-highlight-colors
    -- already renders colours, so let it own that and avoid double-highlighting.
    if vim.lsp.document_color and client:supports_method("textDocument/documentColor") then
      vim.lsp.document_color.enable(false, { bufnr = ev.buf })
    end
  end,
})
