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
vim.lsp.config("tsc", {
  -- Prefer the project's own TypeScript, but only when it is new enough to be
  -- a language server. `--lsp` arrived in TypeScript 7; a 5.x or 6.x tsc
  -- answers it with "Unknown compiler option" and exits 1, which Neovim
  -- surfaces only as the client quitting. Most projects still pin 5.x, so this
  -- check is what keeps them working.
  cmd = function(dispatchers, config)
    local bin = "tsc"
    local root = (config or {}).root_dir
    local local_bin = root and vim.fs.joinpath(root, "node_modules", ".bin", "tsc")
    if local_bin and vim.fn.executable(local_bin) == 1 then
      local out = vim.system({ local_bin, "--version" }, { text = true }):wait(5000)
      local major = out.code == 0 and tonumber((out.stdout or ""):match("Version (%d+)"))
      if major and major >= 7 then
        bin = local_bin
      end
    end
    return vim.lsp.rpc.start({ bin, "--lsp", "--stdio" }, dispatchers)
  end,
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  -- Lockfiles first so a monorepo reuses one server, then TS/JS markers.
  root_markers = {
    { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock" },
    { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
  },
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
  init_options = {
    -- astro-ls has no TypeScript of its own to borrow. Prefer the project's
    -- copy so a monorepo pins its own version, then the one mason unpacked.
    typescript = {
      tsdk = (function()
        local local_tsdk = vim.fs.joinpath(vim.fn.getcwd(), "node_modules", "typescript", "lib")
        if vim.fn.isdirectory(local_tsdk) == 1 then
          return local_tsdk
        end
        return vim.fn.stdpath("data") .. "/mason/packages/astro-language-server/node_modules/typescript/lib"
      end)(),
    },
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
})

-- Diagnostics ---------------------------------------------------------------

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN] = "W",
      [vim.diagnostic.severity.INFO] = "I",
      [vim.diagnostic.severity.HINT] = "N",
    },
  },
  float = {
    border = "rounded",
    style = "minimal",
    focusable = false,
    source = true,
    header = "",
    prefix = "",
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
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  virtual_text = { spacing = 4, source = "if_many", prefix = "" },
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
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>lws", vim.lsp.buf.workspace_symbol, opts)
    vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "<leader>lrr", vim.lsp.buf.references, opts)
    -- Code action and rename sit directly under <leader>; they are reached
    -- often enough not to live behind the <leader>l group.
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)

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
