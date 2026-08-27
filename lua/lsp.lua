-- LSP, in one file.
--
-- There is no nvim-lspconfig here and Neovim ships no `runtime/lsp/` configs
-- of its own, so every server has to state its own `cmd`, `filetypes` and
-- `root_markers` -- `vim.lsp.enable` finds nothing to start otherwise.
-- Everything past those three keys is a deliberate exception, not boilerplate.

local capabilities = vim.lsp.protocol.make_client_capabilities()
-- Completion is Neovim's own `vim.lsp.completion` (below), so there is no
-- nvim-cmp to merge extras in from. snippetSupport is still worth asking for:
-- it is what makes servers return signatures with placeholders, not bare names.
capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config("*", {
  capabilities = capabilities,
  flags = { debounce_text_changes = 250 },
})

-- Servers -------------------------------------------------------------------

vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", "stylua.toml", ".git" },
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      completion = { callSnippet = "Replace" },
      workspace = {
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.stdpath("config") .. "/lua"] = true,
        },
      },
    },
  },
})

-- TypeScript 7 -- the native compiler -- serves the language server from the
-- same binary as the compiler.
--
-- `--lsp` arrived in TypeScript 7. A 5.x or 6.x tsc answers it with "Unknown
-- compiler option" and exits 1, which Neovim surfaces only as the client
-- quitting -- so the version is checked before anything is launched, for the
-- binary on $PATH as much as for the project's own. Both need it: mason
-- installs a tsc, and lua/options.lua puts mason's bin ahead of everything
-- else, so $PATH is not the system's answer either.
--
-- The check lives in root_dir rather than in cmd because root_dir is the only
-- one of the two that can decline. cmd has to return a client -- returning nil
-- throws on every buffer that opens -- while root_dir simply never calls
-- on_dir.
local tsc_bin = {}
local tsc_checked = {}

local function tsc_serves_lsp(bin)
  if not bin or vim.fn.executable(bin) == 0 then
    return false
  end
  local out = vim.system({ bin, "--version" }, { text = true }):wait(5000)
  local major = out.code == 0 and tonumber((out.stdout or ""):match("Version (%d+)"))
  return major ~= nil and major >= 7
end

vim.lsp.config("tsc", {
  cmd = function(dispatchers, config)
    return vim.lsp.rpc.start({ tsc_bin[config.root_dir] or "tsc", "--lsp", "--stdio" }, dispatchers)
  end,
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_dir = function(bufnr, on_dir)
    -- Lockfiles first so a monorepo reuses one server, then TS/JS markers.
    -- Two calls rather than one nested `root_markers` list: this is vim.fs.root,
    -- which takes a flat list, and the fallback is what encodes the priority.
    local root = vim.fs.root(bufnr, { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock" })
      or vim.fs.root(bufnr, { "tsconfig.json", "jsconfig.json", "package.json", ".git" })
    if not root then
      return
    end

    -- Resolved once per root. Each check spawns a process, and root_dir runs
    -- for every buffer opened underneath it.
    if not tsc_checked[root] then
      tsc_checked[root] = true
      local local_bin = vim.fs.joinpath(root, "node_modules", ".bin", "tsc")
      if tsc_serves_lsp(local_bin) then
        tsc_bin[root] = local_bin
      elseif tsc_serves_lsp("tsc") then
        tsc_bin[root] = "tsc"
      else
        vim.notify("tsc: no TypeScript 7+ for " .. root .. "; no language server started", vim.log.levels.WARN)
      end
    end

    if tsc_bin[root] then
      on_dir(root)
    end
  end,
})

vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "pyrightconfig.json", ".git" },
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
      },
    },
  },
})

vim.lsp.config("ruff", {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
  -- Pyright owns hover; two providers means two floats on K.
  on_attach = function(client)
    client.server_capabilities.hoverProvider = false
  end,
  -- Under init_options, not settings: ruff reads its configuration from
  -- `initializationOptions.settings`.
  init_options = { settings = { organizeImports = true, fixAll = true } },
})

vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
  settings = {
    gopls = {
      analyses = { unusedparams = true },
      staticcheck = true,
      gofumpt = true,
    },
  },
})

vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    -- clangd needs permission to ask a compiler driver for its system include
    -- paths. Without this, libc++ headers -- <vector>, <iostream> -- do not
    -- resolve on macOS.
    "--query-driver=/usr/bin/clang*,/usr/bin/gcc,/usr/bin/g++,/opt/homebrew/bin/*,/usr/local/bin/*",
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt", "CMakeLists.txt", "Makefile", ".git" },
})

vim.lsp.config("html", {
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html" },
  root_markers = { "package.json", ".git" },
})

vim.lsp.config("cssls", {
  cmd = { "vscode-css-language-server", "--stdio" },
  filetypes = { "css", "scss", "less" },
  root_markers = { "package.json", ".git" },
  init_options = { provideFormatter = true },
  -- Tailwind and friends put at-rules in stylesheets that the schema does not
  -- know about; the warnings are noise.
  settings = {
    css = { lint = { unknownAtRules = "ignore" } },
    scss = { lint = { unknownAtRules = "ignore" } },
    less = { lint = { unknownAtRules = "ignore" } },
  },
})

vim.lsp.config("jsonls", {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  root_markers = { ".git" },
  -- conform (prettier) owns formatting for json/jsonc.
  init_options = { provideFormatter = false },
})

vim.lsp.config("emmet_ls", {
  cmd = { "emmet-ls", "--stdio" },
  -- Kept out of TS/TSX on purpose: it is another node server per buffer.
  filetypes = { "html", "css", "sass", "scss", "less", "svelte" },
  root_markers = { "package.json", ".git" },
})

vim.lsp.config("marksman", {
  cmd = { "marksman", "server" },
  filetypes = { "markdown", "markdown.mdx" },
  root_markers = { ".marksman.toml", ".git" },
})

vim.lsp.config("astro", {
  cmd = { "astro-ls", "--stdio" },
  filetypes = { "astro" },
  root_markers = { "astro.config.mjs", "package.json", ".git" },
  -- astro-ls has no TypeScript of its own to borrow, so it has to be handed a
  -- tsdk path. Prefer the project's copy, fall back to the one mason unpacked.
  --
  -- Resolved in before_init rather than in a literal `init_options` above: this
  -- table is built once, when the module loads, so anything computed here is
  -- pinned to whatever directory Neovim happened to start in -- which made the
  -- "prefer the project's copy" half only work when Neovim was launched from
  -- the project root. before_init runs per client, against the root it
  -- actually resolved.
  before_init = function(params, config)
    local tsdk = vim.fn.stdpath("data") .. "/mason/packages/astro-language-server/node_modules/typescript/lib"

    -- Walking up rather than checking the root alone: a monorepo hoists
    -- TypeScript to the workspace root, leaving the package's own
    -- node_modules without it.
    local dir = config.root_dir or vim.fn.getcwd()
    while dir do
      local candidate = vim.fs.joinpath(dir, "node_modules", "typescript", "lib")
      if vim.fn.isdirectory(candidate) == 1 then
        tsdk = candidate
        break
      end
      local parent = vim.fs.dirname(dir)
      dir = parent ~= dir and parent or nil
    end

    params.initializationOptions =
      vim.tbl_deep_extend("force", params.initializationOptions or {}, { typescript = { tsdk = tsdk } })
  end,
})

vim.lsp.config("ols", {
  cmd = { "ols" },
  filetypes = { "odin" },
  -- ols.json is where a project declares its collections -- the import paths
  -- beyond `core:` and `vendor:` -- so it is the truest marker of an Odin
  -- project root. odinfmt.json is the formatter's own config and sits in the
  -- same place; .git is the fallback for a project that carries neither.
  root_markers = { "ols.json", "odinfmt.json", ".git" },
  init_options = {
    -- Passed to `odin check`, which is what ols runs to produce diagnostics.
    checker_args = "-strict-style",
    -- ols formats through odinfmt, and so does conform
    -- (lua/plugins/conform.lua). Turning it off here leaves one owner: without
    -- it, conform's `lsp_format = "fallback"` has a second formatter to pick
    -- between for the same buffer.
    enable_format = false,
  },
})

-- Servers are launched by name off $PATH. mason installs the binaries and
-- lua/options.lua puts its bin directory on $PATH; the install list lives in
-- lua/plugins/mason.lua.
vim.lsp.enable({
  "lua_ls",
  "tsc",
  "pyright",
  "ruff",
  "gopls",
  "clangd",
  "html",
  "cssls",
  "jsonls",
  "emmet_ls",
  "marksman",
  "astro",
  "ols",
})

-- Diagnostics ---------------------------------------------------------------
local signs = {
  ERROR = "",
  HINT = "",
  WARN = "",
  INFO = "",
}

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = signs.ERROR,
      [vim.diagnostic.severity.WARN] = signs.WARN,
      [vim.diagnostic.severity.INFO] = signs.INFO,
      [vim.diagnostic.severity.HINT] = signs.HINT,
    },
  },
  float = {
    border = "rounded",
    source = true,
  },
  jump = {
    -- ]d / [d land on a diagnostic and pop the float describing it. There is
    -- no `jump.float` option any more -- `on_jump` replaced it -- so the
    -- float is opened by hand, scoped to the cursor and left unfocused so the
    -- next motion dismisses it.
    on_jump = function(diagnostic, bufnr)
      if not diagnostic then
        return
      end
      vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
    end,
  },
  underline = false,
  update_in_insert = false,
  severity_sort = true,
  virtual_text = {
    spacing = 4,
    source = "if_many",
    prefix = function(diagnostics)
      return signs[vim.diagnostic.severity[diagnostics.severity]]
    end,
  },
})

-- Attach --------------------------------------------------------------------

-- `autotrigger` opens the popup on the server's `triggerCharacters` and on
-- nothing else, so left alone it only fires after `.` or `:` -- never while you
-- are part way through a name. Adding the word characters is the documented way
-- to trigger on every keypress (`:h vim.lsp.completion.enable()`).
--
-- The list is rebuilt as a set rather than appended to: `server_capabilities` is
-- one table shared by every buffer the client attaches to, and appending would
-- grow it on each attach.
local function enable_completion(client, bufnr)
  local provider = client.server_capabilities.completionProvider
  if not provider then
    return
  end

  local chars = {}
  for _, char in ipairs(provider.triggerCharacters or {}) do
    chars[char] = true
  end
  for char in ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"):gmatch(".") do
    chars[char] = true
  end
  provider.triggerCharacters = vim.tbl_keys(chars)

  vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspAttach", { clear = true }),
  callback = function(e)
    local client = vim.lsp.get_client_by_id(e.data.client_id)

    local opts = { buffer = e.buf }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", function()
      vim.lsp.buf.hover({ border = "rounded" })
    end, opts)
    vim.keymap.set("n", "<leader>lws", vim.lsp.buf.workspace_symbol, opts)
    vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "<leader>lrr", vim.lsp.buf.references, opts)
    -- Code action and rename sit directly under <leader>; they are reached
    -- often enough not to live behind the <leader>l group.
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    -- <C-k>, not <C-h>: <C-h> is the byte 0x08, which is what a terminal
    -- running `stty erase ^H` sends for Backspace -- mapping it there costs
    -- Backspace in every buffer a server attaches to. <C-k> gives up
    -- insert-mode digraphs instead, which is a far cheaper thing to lose.
    vim.keymap.set("i", "<C-k>", function()
      vim.lsp.buf.signature_help({ border = "rounded" })
    end, opts)

    vim.keymap.set("n", "]d", function()
      vim.diagnostic.jump({ count = 1 })
    end, opts)
    vim.keymap.set("n", "[d", function()
      vim.diagnostic.jump({ count = -1 })
    end, opts)

    -- Native completion, in place of nvim-cmp. Neovim drives the popup from
    -- the server's items; `autotrigger` opens it as you type rather than only
    -- on <C-x><C-o>.
    if client and client:supports_method("textDocument/completion") then
      enable_completion(client, e.buf)
    end
  end,
})

-- Set outright rather than appended: 0.12 defaults to "menu,popup", and
-- appending left `menuone` off, so the autotrigger popup stayed hidden
-- whenever the server returned exactly one candidate -- the common case when
-- completing a partly typed identifier.
vim.opt.completeopt = { "menu", "menuone", "noselect", "popup", "fuzzy" }
