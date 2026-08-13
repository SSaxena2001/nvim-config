-- Buffer-local LSP setup. Everything here needs a buffer that actually has a
-- server attached, so it cannot live in core/keymaps/ with the global maps.
--
-- Keymap layout follows LazyVim, with two deliberate differences: LazyVim's
-- <leader>c prefix is already the blackhole-change operator in editor.lua, so
-- LSP actions live under <leader>l (the "lsp" which-key group), and pickers go
-- through Telescope.

local function picker()
  return require("acurite.core.telescope")
end

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

    -- Neovim's native completion applies LSP text edits and expands LSP
    -- snippets through vim.snippet. Autotrigger only on server-declared trigger
    -- characters; <C-Space> explicitly requests completion at any point.
    if supports("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })

      map("i", "<C-Space>", vim.lsp.completion.get, "Trigger Completion")
      map("i", "<CR>", function()
        return vim.fn.pumvisible() == 1 and "<C-y>" or "<CR>"
      end, "Accept Completion", { expr = true })
      map("i", "<Tab>", function()
        if vim.fn.pumvisible() == 1 then
          return "<C-n>"
        end
        if vim.snippet.active({ direction = 1 }) then
          vim.snippet.jump(1)
          return ""
        end
        return "<Tab>"
      end, "Next Completion or Snippet Stop", { expr = true })
      map("i", "<S-Tab>", function()
        if vim.fn.pumvisible() == 1 then
          return "<C-p>"
        end
        if vim.snippet.active({ direction = -1 }) then
          vim.snippet.jump(-1)
          return ""
        end
        return "<S-Tab>"
      end, "Previous Completion or Snippet Stop", { expr = true })
    end

    -- Navigation ------------------------------------------------------------
    -- Buffer-local so Vim's own `gd` (go to local declaration) and `gt`
    -- (:tabnext) survive in every buffer without a language server.
    -- Note 'tagfunc' already routes CTRL-] through the LSP for free.
    if supports("textDocument/definition") then
      map("n", "gd", function()
        picker().builtin("lsp_definitions")
      end, "Goto Definition")
      map("n", "gt", function()
        vim.cmd("tab split")
        vim.lsp.buf.definition()
      end, "Goto Definition in New Tab")
    end

    -- No `nowait` here (LazyVim sets it). Waiting out 'timeoutlen' keeps
    -- Nvim's own gr-prefixed defaults — grn, gra, grr, gri, grt, grx —
    -- reachable instead of swallowing the r.
    if supports("textDocument/references") then
      map("n", "gr", function()
        picker().builtin("lsp_references")
      end, "References")
    end

    if supports("textDocument/implementation") then
      map("n", "gI", function()
        picker().builtin("lsp_implementations")
      end, "Goto Implementation")
    end

    if supports("textDocument/typeDefinition") then
      map("n", "gy", function()
        picker().builtin("lsp_type_definitions")
      end, "Goto Type Definition")
    end

    if supports("textDocument/declaration") then
      map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
    end

    -- Nvim's built-in insert-mode <C-s> already calls signature_help.
    if supports("textDocument/signatureHelp") then
      map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
    end

    -- Code actions ----------------------------------------------------------
    if supports("textDocument/codeAction") then
      map({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, "Code Action")

      -- No `apply` here: "source" prefix-matches every source.* kind, so this
      -- is a chooser, not a single known action.
      map({ "n", "v" }, "<leader>lA", function()
        vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } })
      end, "Source Action")

      -- TypeScript-specific kinds, mirroring LazyVim's typescript extra. The
      -- flag stops a later client on the same buffer from overwriting these
      -- with the generic kinds below.
      if client.name == "tsgo" then
        vim.b[ev.buf].acurite_ts_source_actions = true
        map("n", "<leader>lo", source_action("source.organizeImports.ts"), "Organize Imports")
        map("n", "<leader>lm", source_action("source.addMissingImports.ts"), "Add Missing Imports")
        map("n", "<leader>lu", source_action("source.removeUnused.ts"), "Remove Unused Imports")
        map("n", "<leader>lF", source_action("source.fixAll.ts"), "Fix All")
      elseif not vim.b[ev.buf].acurite_ts_source_actions then
        -- Generic "source.*" kinds. gopls and ruff implement some
        -- subset; servers that do not simply report no action available.
        map("n", "<leader>lo", source_action("source.organizeImports"), "Organize Imports")
        map("n", "<leader>lF", source_action("source.fixAll"), "Fix All")
      end
    end

    -- Rename ----------------------------------------------------------------
    if supports("textDocument/rename") then
      map("n", "<leader>lr", vim.lsp.buf.rename, "Rename Symbol")
    end

    if supports("workspace/willRenameFiles") then
      map("n", "<leader>lR", function()
        require("acurite.configs.lsp.file-rename").rename_current_file()
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
