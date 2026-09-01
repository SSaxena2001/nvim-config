-- LuaSnip: the snippet store, plus the source that puts it in the popup.
--
-- Neovim can already *expand* a snippet -- `vim.snippet` handles the tabstops
-- and placeholders in whatever a language server sends back. What it has no
-- notion of is a snippet library: a set of triggers you can type in any buffer,
-- server or not. That is what LuaSnip supplies, and friendly-snippets fills it.

local ls = require("luasnip")

ls.setup({
  -- Keep the snippet jumpable after the cursor leaves its last tabstop, so
  -- <C-j> can still go back a field once you have typed past the end.
  history = true,
  -- Re-evaluate function and dynamic nodes as you type rather than on
  -- InsertLeave; without this a node that mirrors another updates late.
  update_events = "TextChanged,TextChangedI",
  -- Forget a snippet once its text has been deleted, so <C-k> does not jump
  -- into the ghost of one that is no longer on screen.
  delete_check_events = "TextChanged,InsertLeave",
})

-- friendly-snippets is a directory of VS Code-format JSON, which is the format
-- LuaSnip reads natively. `lazy_load` defers parsing a filetype's snippets
-- until a buffer of that filetype is opened, which keeps this off the startup
-- path.
require("luasnip.loaders.from_vscode").lazy_load()
-- Personal snippets, if the directory exists. Same format, so they can be
-- written by hand or lifted straight out of a VS Code snippets file.
require("luasnip.loaders.from_vscode").lazy_load({
  paths = { vim.fs.joinpath(vim.fn.stdpath("config"), "snippets") },
})

-- Jumping ------------------------------------------------------------------
--
-- Insert *and* select mode: LuaSnip drops the cursor into select mode over a
-- placeholder so typing replaces it, and a jump key that only worked in insert
-- would strand you on the first field.
--
-- <C-k> and <C-j> are free in insert mode -- the window-motion bindings of the
-- same name in lua/keymaps.lua are normal mode only. Tab is not an option: it
-- walks the completion popup (lua/keymaps.lua), and a key that both cycles the
-- menu and jumps tabstops has to guess which you meant every time.
vim.keymap.set({ "i", "s" }, "<C-k>", function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end, { desc = "Snippet: expand or jump forward" })

vim.keymap.set({ "i", "s" }, "<C-j>", function()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end, { desc = "Snippet: jump back" })

-- Choice nodes offer alternatives for one field. Guarded rather than bound
-- outright so <C-e> keeps its built-in meaning everywhere else.
vim.keymap.set({ "i", "s" }, "<C-e>", function()
  return ls.choice_active() and "<Plug>luasnip-next-choice" or "<C-e>"
end, { expr = true, remap = true, desc = "Snippet: next choice" })

-- Completion source --------------------------------------------------------
--
-- Completion in this config is Neovim's own `vim.lsp.completion` (lua/lsp.lua),
-- which shows exactly what a language server returns and nothing else. There is
-- no nvim-cmp here to merge a second source in. So LuaSnip is registered as one
-- more LSP client -- in process, no binary, no socket, just a table that answers
-- the three requests Neovim needs to drive a popup. Its items then sort and
-- render alongside the real server's, and `completeopt=fuzzy` matches them the
-- same way.
--
-- Without this the snippets still expand, but only if you already know the
-- trigger and press <C-k>. Nothing ever suggests them.

local kind_snippet = 15
-- The item text is the bare trigger, inserted as plain text. LuaSnip -- not
-- `vim.snippet` -- does the expanding afterwards, in the CompleteDone below,
-- because only LuaSnip understands its own choice and dynamic nodes.
local format_plaintext = 1

-- Snippets handed out by the last completion request, so `completionItem/
-- resolve` can find the one whose preview is being asked for. Rebuilt each
-- request; rendering every docstring up front is the expensive part and most
-- are never looked at.
local offered = {}

local function completion_items()
  offered = {}
  local items = {}

  -- `available()` is per buffer, not per filetype: it already accounts for the
  -- `all` filetype and for any `filetype_extend` chains.
  for _, snippets in pairs(ls.available(function(snip)
    return snip
  end)) do
    for _, snip in ipairs(snippets) do
      offered[#offered + 1] = snip
      items[#items + 1] = {
        label = snip.trigger,
        kind = kind_snippet,
        detail = snip.name ~= snip.trigger and snip.name or nil,
        insertText = snip.trigger,
        insertTextFormat = format_plaintext,
        data = { luasnip = #offered },
      }
    end
  end

  return items
end

local function resolve(item)
  local snip = offered[(item.data or {}).luasnip or 0]
  if not snip then
    return item
  end

  -- The docstring is the snippet rendered with its tabstops shown, which is a
  -- far better preview than the one-line description most snippets carry. It
  -- comes back as a string for a plain snippet and as a list of lines for a
  -- multi-line one.
  local ok, doc = pcall(function()
    local d = snip:get_docstring()
    return type(d) == "table" and table.concat(d, "\n") or d
  end)
  if ok and type(doc) == "string" and doc ~= "" then
    local description = snip.description and table.concat(snip.description, "\n")
    item.documentation = {
      kind = "markdown",
      value = (description and description ~= snip.trigger and (description .. "\n\n") or "")
        .. "```"
        .. vim.bo.filetype
        .. "\n"
        .. doc
        .. "\n```",
    }
  end
  return item
end

-- The in-process server. `cmd` may be a function returning this table instead
-- of a command to spawn; see `:h vim.lsp.rpc.PublicClient`.
local function snippet_server(dispatchers)
  local closing = false
  local id = 0

  return {
    request = function(method, params, callback)
      if method == "initialize" then
        callback(nil, {
          capabilities = {
            completionProvider = { resolveProvider = true },
          },
          serverInfo = { name = "luasnip" },
        })
      elseif method == "textDocument/completion" then
        callback(nil, { isIncomplete = false, items = completion_items() })
      elseif method == "completionItem/resolve" then
        callback(nil, resolve(params))
      elseif method == "shutdown" then
        callback(nil, nil)
      else
        callback(nil, nil)
      end

      id = id + 1
      return true, id
    end,
    notify = function(method)
      if method == "exit" then
        dispatchers.on_exit(0, 15)
      end
      return true
    end,
    is_closing = function()
      return closing
    end,
    terminate = function()
      closing = true
    end,
  }
end

-- Started per buffer rather than declared through `vim.lsp.enable`, which wants
-- a filetype list to match on. Snippets are wanted in every buffer, including
-- the ones no language server claims. `vim.lsp.start` reuses the running client
-- when the config matches, so this attaches rather than spawning each time.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("LuasnipSource", { clear = true }),
  callback = function(e)
    if vim.bo[e.buf].buftype ~= "" then
      return
    end
    vim.lsp.start({ name = "luasnip", cmd = snippet_server }, { bufnr = e.buf })
  end,
})

-- Expanding ----------------------------------------------------------------
--
-- The completion above inserts the trigger and stops there; this turns it into
-- the snippet. Doing it on CompleteDone rather than through `insertTextFormat`
-- is what keeps LuaSnip in charge of the expansion, so choice and dynamic nodes
-- behave as their authors wrote them.
vim.api.nvim_create_autocmd("CompleteDone", {
  group = vim.api.nvim_create_augroup("LuasnipExpand", { clear = true }),
  callback = function()
    local item = vim.v.completed_item
    if type(item) ~= "table" then
      return
    end

    -- Neovim stashes the original LSP item under this key.
    local lsp_item = vim.tbl_get(item, "user_data", "nvim", "lsp", "completion_item")
    if not (lsp_item and lsp_item.data and lsp_item.data.luasnip) then
      return
    end

    -- Scheduled: CompleteDone fires before the inserted text has settled, and
    -- LuaSnip reads the line to decide what it is expanding.
    vim.schedule(function()
      if ls.expandable() then
        ls.expand()
      end
    end)
  end,
})
