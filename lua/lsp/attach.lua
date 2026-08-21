-- Buffer-local LSP setup. Everything here needs a buffer that actually has a
-- server attached, so it cannot live in core/keymaps/ with the global maps.
--
-- Keymap layout follows LazyVim, with two deliberate differences: LazyVim's
-- <leader>c prefix is already the blackhole-change operator in editor.lua, so
-- LSP actions live under <leader>l (the "lsp" which-key group), and pickers go
-- through Telescope.

-- LazyVim's LazyVim.lsp.action[...]: request a code action of one specific
-- kind and apply it straight away when the server returns exactly one. Used
-- for the "source.*" actions (organize imports, add missing imports, ...)
-- which have no meaningful choice to present.
local function source_action(kind)
  return function()
    vim.lsp.buf.code_action({
      apply = true,
      context = { only = { kind }, diagnostics = {} },
    })
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("AcuriteLspAttach", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    local function map(mode, lhs, rhs, desc, extra)
      local o = vim.tbl_extend("force", { buffer = ev.buf, desc = desc }, extra or {})
      vim.keymap.set(mode, lhs, rhs, o)
    end

    -- Only map what this server can actually service, so a keypress on a
    -- buffer whose server lacks the method falls through instead of erroring.
    local function supports(method)
      return client:supports_method(method)
    end

    -- nvim-cmp handles completion for all servers. No need for native completion.
    -- cmp is enabled globally in configs/cmp.lua with better handling of
    -- continuous completion while typing.

    -- Navigation ------------------------------------------------------------
    -- Buffer-local so Vim's own `gd` (go to local declaration) survives in
    -- every buffer without a language server.
    -- Note 'tagfunc' already routes CTRL-] through the LSP for free.
    if supports("textDocument/definition") then
      map("n", "gd", function()
        require("telescope.builtin").lsp_definitions()
      end, "Goto Definition")
    end

    -- No `nowait` here (LazyVim sets it). Waiting out 'timeoutlen' keeps
    -- Nvim's own gr-prefixed defaults — grn, gra, grr, gri, grt, grx —
    -- reachable instead of swallowing the r.
    if supports("textDocument/references") then
      map("n", "gr", function()
        require("telescope.builtin").lsp_references()
      end, "References")
    end

    if supports("textDocument/implementation") then
      map("n", "gI", function()
        require("telescope.builtin").lsp_implementations()
      end, "Goto Implementation")
    end

    if supports("textDocument/typeDefinition") then
      map("n", "gy", function()
        require("telescope.builtin").lsp_type_definitions()
      end, "Goto Type Definition")
    end

    if supports("textDocument/declaration") then
      map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
    end

    -- Nvim's built-in insert-mode <C-s> already calls signature_help.
    if supports("textDocument/signatureHelp") then
      map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
    end

    -- Hover ------------------------------------------------------------------
    -- ThePrimeagen style: K for hover (overrides built-in)
    map("n", "K", vim.lsp.buf.hover, "Hover")

    -- Formatting is <leader>bf via conform, which falls back to the LSP
    -- anyway. A second buffer-local <leader>f would shadow the "find" group.

    -- Code actions ----------------------------------------------------------
    if supports("textDocument/codeAction") then
      -- ThePrimeagen style: <leader>ca for code actions
      map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")

      -- Source actions (organize imports, fix all, etc.)
      -- Use server-specific kinds if available, fall back to generic
      local organize_imports_kind = "source.organizeImports"
      local fix_all_kind = "source.fixAll"

      if client.name == "tsgo" then
        organize_imports_kind = "source.organizeImports.ts"
        fix_all_kind = "source.fixAll.ts"
      end

      -- Under <leader>l, not <leader>o: <leader>o is the open-line-without-
      -- comment-continuation map, which a buffer-local binding would shadow in
      -- every buffer that has a server attached.
      map("n", "<leader>lo", source_action(organize_imports_kind), "Organize Imports")
      map("n", "<leader>lF", source_action(fix_all_kind), "Fix All")
    end

    -- Rename ----------------------------------------------------------------
    if supports("textDocument/rename") then
      -- ThePrimeagen style: <leader>rn for rename
      map("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
    end

    if supports("workspace/willRenameFiles") then
      map("n", "<leader>lR", function()
        require("lsp.file-rename").rename_current_file()
      end, "Rename File")
    end

    -- Code lens -------------------------------------------------------------
    if supports("textDocument/codeLens") then
      map({ "n", "v" }, "<leader>ll", vim.lsp.codelens.run, "Run Code Lens")

      -- 0.12 turned code lens into a capability that refreshes itself, so the
      -- old refresh-on-autocmd dance (and codelens.refresh) is gone. Respect a
      -- manual toggle-off: a second client attaching must not re-enable it.
      if not vim.b[ev.buf].acurite_codelens_off then
        vim.lsp.codelens.enable(true, { bufnr = ev.buf })
      end

      map("n", "<leader>lL", function()
        local on = vim.lsp.codelens.is_enabled({ bufnr = 0 })
        vim.b.acurite_codelens_off = on
        vim.lsp.codelens.enable(not on, { bufnr = 0 })
      end, "Toggle Code Lens")
    end
  end,
})
