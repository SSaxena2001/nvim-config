local signs = {
  ERROR = "",
  HINT = "",
  WARN = "",
  INFO = "",
}

local severity_signs = {
  [vim.diagnostic.severity.ERROR] = signs.ERROR,
  [vim.diagnostic.severity.WARN] = signs.WARN,
  [vim.diagnostic.severity.INFO] = signs.INFO,
  [vim.diagnostic.severity.HINT] = signs.HINT,
}

-- toggle for virtual text
vim.keymap.set("n", "<leader>lx", function()
  local current = vim.diagnostic.config().virtual_text
  vim.diagnostic.config({ virtual_text = not current })
end, { desc = "Toggle LSP virtual text" })

vim.diagnostic.config({
  signs = { text = severity_signs },
  float = {
    border = "rounded",
    style = "minimal",
    focusable = false,
    source = true,
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  virtual_text = {
    spacing = 4,
    source = "if_many",
    prefix = function(diagnostic)
      return severity_signs[diagnostic.severity] or "●"
    end,
  },
})

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })

vim.keymap.set("n", "gt", function()
  vim.cmd("tab split")
  vim.lsp.buf.definition()
end, { desc = "Goto Definition in New Tab" })

local capabilities = vim.lsp.protocol.make_client_capabilities()
-- blink cmp
capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

vim.lsp.config("*", {
  capabilities = capabilities,
  flags = {
    -- Reduce didChange traffic to language servers while typing.
    debounce_text_changes = 250,
  },
})

local function root_with_markers(bufnr, markers)
  return vim.fs.root(bufnr, markers)
end

local function package_json_has_field(path, field)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return false
  end

  local ok_json, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
  return ok_json and type(decoded) == "table" and decoded[field] ~= nil
end

local function root_with_package_field(bufnr, markers, package_field)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  local found = vim.fs.find(markers, { path = fname, upward = true })[1]
  if found then
    return vim.fs.dirname(found)
  end

  local package_json = vim.fs.find("package.json", { path = fname, upward = true })[1]
  if package_json and package_json_has_field(package_json, package_field) then
    return vim.fs.dirname(package_json)
  end

  return nil
end

local function disable_semantic_tokens(client)
  -- Treesitter already handles syntax highlighting. Disabling semantic tokens
  -- avoids extra per-buffer LSP work, especially noticeable in large TS/JS projects.
  client.server_capabilities.semanticTokensProvider = nil
end

local function on_attach_disable_semantic_tokens(client)
  disable_semantic_tokens(client)
end

local function clangd_switch_source_header(bufnr, client)
  local method = "textDocument/switchSourceHeader"
  if not client or not client:supports_method(method) then
    vim.notify("clangd source/header switching is not available", vim.log.levels.WARN)
    return
  end

  client:request(method, vim.lsp.util.make_text_document_params(bufnr), function(err, result)
    if err then
      vim.notify(tostring(err), vim.log.levels.ERROR)
      return
    end
    if not result then
      vim.notify("No corresponding source/header found", vim.log.levels.INFO)
      return
    end
    vim.cmd.edit(vim.uri_to_fname(result))
  end, bufnr)
end

local function clangd_symbol_info(bufnr, client)
  local method = "textDocument/symbolInfo"
  if not client or not client:supports_method(method) then
    vim.notify("clangd symbol info is not available", vim.log.levels.WARN)
    return
  end

  local params = vim.lsp.util.make_position_params(vim.api.nvim_get_current_win(), client.offset_encoding)
  client:request(method, params, function(err, result)
    if err or not result or vim.tbl_isempty(result) then
      return
    end

    local container = "container: " .. result[1].containerName
    local name = "name: " .. result[1].name
    vim.lsp.util.open_floating_preview({ name, container }, "", {
      height = 2,
      width = math.max(#name, #container),
      focusable = false,
      title = "Symbol Info",
    })
  end, bufnr)
end

-- Configure and enable LSP servers
-- lua_ls
vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", ".git" },
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      completion = {
        callSnippet = "Replace",
      },
      workspace = {
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.stdpath("config") .. "/lua"] = true,
        },
      },
    },
  },
})

-- emmet_ls
vim.lsp.config("emmet_ls", {
  cmd = { "emmet-ls", "--stdio" },
  -- Keep emmet out of TS/TSX by default. It is another node server and can be
  -- manually enabled later if needed.
  filetypes = {
    "html",
    "css",
    "sass",
    "scss",
    "less",
    "svelte",
  },
})

-- ts_ls (TypeScript/JavaScript)
vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  on_attach = on_attach_disable_semantic_tokens,
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  single_file_support = false,
  root_dir = function(bufnr, on_dir)
    -- Prefer one TS server at the package-manager root for monorepos. Falling
    -- back to every nested package.json/tsconfig can spawn many tsserver node
    -- processes and quickly consume several GB of RAM.
    local root = root_with_markers(bufnr, {
      "package-lock.json",
      "yarn.lock",
      "pnpm-lock.yaml",
      "bun.lockb",
      "bun.lock",
    }) or root_with_markers(bufnr, {
      "tsconfig.json",
      "jsconfig.json",
      "package.json",
    })
    if root then
      on_dir(root)
    end
  end,
  init_options = {
    preferences = {
      includeCompletionsForModuleExports = true,
      includeCompletionsForImportStatements = true,
    },
  },
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayVariableTypeHints = true,
        includeInlayFunctionParameterTypeHints = true,
      },
    },
    javascript = {
      validate = {
        enable = true,
      },
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayVariableTypeHints = true,
      },
    },
  },
})

-- pyright
vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "pyrightconfig.json", ".git" },
  on_attach = on_attach_disable_semantic_tokens,
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
  root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
  on_attach = function(client)
    -- Prefer Pyright for hover to avoid duplicate providers.
    client.server_capabilities.hoverProvider = false
  end,
  settings = {
    organizeImports = true,
    fixAll = true,
  },
})

local eslint_config_files = {
  ".eslintrc",
  ".eslintrc.js",
  ".eslintrc.cjs",
  ".eslintrc.yaml",
  ".eslintrc.yml",
  ".eslintrc.json",
  "eslint.config.js",
  "eslint.config.mjs",
  "eslint.config.cjs",
  "eslint.config.ts",
  "eslint.config.mts",
  "eslint.config.cts",
}

local function is_buffer_using_eslint(bufnr, project_root)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local stop = vim.fs.dirname(project_root)

  if vim.fs.find(eslint_config_files, { path = filename, type = "file", upward = true, stop = stop })[1] then
    return true
  end

  local package_json = vim.fs.find("package.json", { path = filename, type = "file", upward = true, stop = stop })[1]
  return package_json and package_json_has_field(package_json, "eslintConfig")
end

-- eslint
vim.lsp.config("eslint", {
  cmd = function(dispatchers, config)
    local cmd = "vscode-eslint-language-server"
    if config and config.root_dir then
      local local_cmd = vim.fs.joinpath(config.root_dir, "node_modules/.bin", cmd)
      if vim.fn.executable(local_cmd) == 1 then
        cmd = local_cmd
      end
    end
    return vim.lsp.rpc.start({ cmd, "--stdio" }, dispatchers)
  end,
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte", "astro" },
  workspace_required = true,
  root_dir = function(bufnr, on_dir)
    if vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "deno.lock" }) then
      return
    end

    local project_root = root_with_markers(bufnr, {
      "package-lock.json",
      "yarn.lock",
      "pnpm-lock.yaml",
      "bun.lockb",
      "bun.lock",
      ".git",
    }) or vim.fn.getcwd()

    if is_buffer_using_eslint(bufnr, project_root) then
      on_dir(project_root)
    end
  end,
  before_init = function(_, config)
    local root_dir = config.root_dir
    if not root_dir then
      return
    end

    config.settings = config.settings or {}
    config.settings.workspaceFolder = {
      uri = vim.uri_from_fname(root_dir),
      name = vim.fn.fnamemodify(root_dir, ":t"),
    }

    local pnp_cjs = root_dir .. "/.pnp.cjs"
    local pnp_js = root_dir .. "/.pnp.js"
    if type(config.cmd) == "table" and (vim.uv.fs_stat(pnp_cjs) or vim.uv.fs_stat(pnp_js)) then
      config.cmd = vim.list_extend({ "yarn", "exec" }, config.cmd)
    end
  end,
  settings = {
    validate = "on",
    packageManager = nil,
    useESLintClass = false,
    experimental = {},
    format = false,
    quiet = false,
    onIgnoredFiles = "off",
    rulesCustomizations = {},
    run = "onType",
    problems = {
      shortenToSingleLine = false,
    },
    nodePath = "",
    workingDirectory = { mode = "auto" },
    codeActionOnSave = {
      enable = false,
      mode = "all",
    },
    codeAction = {
      disableRuleComment = {
        enable = true,
        location = "separateLine",
      },
      showDocumentation = {
        enable = true,
      },
    },
  },
  handlers = {
    ["eslint/openDoc"] = function(_, result)
      if result then
        vim.ui.open(result.url)
      end
      return {}
    end,
    ["eslint/confirmESLintExecution"] = function(_, result)
      if not result then
        return
      end
      return 4
    end,
    ["eslint/probeFailed"] = function()
      vim.notify("ESLint probe failed", vim.log.levels.WARN)
      return {}
    end,
    ["eslint/noLibrary"] = function()
      vim.notify("Unable to find ESLint library", vim.log.levels.WARN)
      return {}
    end,
  },
})

-- biome
vim.lsp.config("biome", {
  cmd = { "biome", "lsp-proxy" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "jsonc" },
  root_dir = function(bufnr, on_dir)
    local root = root_with_package_field(bufnr, { "biome.json", "biome.jsonc" }, "biome")
    if root then
      on_dir(root)
    end
  end,
})

-- gopls
vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
  on_attach = on_attach_disable_semantic_tokens,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      gofumpt = true,
    },
  },
})

vim.lsp.config("clangd", {
  cmd = { "clangd", "--background-index", "--clang-tidy", "--completion-style=detailed", "--header-insertion=iwyu" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_markers = {
    ".clangd",
    ".clang-tidy",
    ".clang-format",
    "compile_commands.json",
    "compile_flags.txt",
    "configure.ac",
    ".git",
  },
  capabilities = vim.tbl_deep_extend("force", capabilities, {
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
    },
    offsetEncoding = { "utf-8", "utf-16" },
  }),
  get_language_id = function(_, filetype)
    local language_ids = {
      objc = "objective-c",
      objcpp = "objective-cpp",
      cuda = "cuda-cpp",
    }
    return language_ids[filetype] or filetype
  end,
  on_init = function(client, init_result)
    if init_result.offsetEncoding then
      client.offset_encoding = init_result.offsetEncoding
    end
  end,
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, "LspClangdSwitchSourceHeader", function()
      clangd_switch_source_header(bufnr, client)
    end, { desc = "Switch between C/C++ source and header" })

    vim.api.nvim_buf_create_user_command(bufnr, "LspClangdShowSymbolInfo", function()
      clangd_symbol_info(bufnr, client)
    end, { desc = "Show clangd symbol info" })

    vim.keymap.set("n", "<leader>ch", function()
      clangd_switch_source_header(bufnr, client)
    end, { buffer = bufnr, desc = "Switch C/C++ source/header" })

    vim.keymap.set("n", "<leader>ci", function()
      clangd_symbol_info(bufnr, client)
    end, { buffer = bufnr, desc = "C/C++ symbol info" })
  end,
})

-- css/html
vim.lsp.config("html", {
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html" },
  root_markers = { "package.json", ".git" },
})

vim.lsp.config("marksman", {
  cmd = { "marksman", "server" },
  filetypes = { "markdown", "markdown.mdx" },
  root_markers = { ".marksman.toml", ".git" },
})

vim.lsp.config("cssls", {
  cmd = { "vscode-css-language-server", "--stdio" },
  filetypes = { "css", "scss", "less" },
  init_options = { provideFormatter = true },
  single_file_support = true,
  settings = {
    css = {
      lint = {
        unknownAtRules = "ignore",
      },
      validate = true,
    },
    scss = {
      lint = {
        unknownAtRules = "ignore",
      },
      validate = true,
    },
    less = {
      lint = {
        unknownAtRules = "ignore",
      },
      validate = true,
    },
  },
})

-- tailwind
vim.lsp.config("tailwindcss", {
  cmd = { "tailwindcss-language-server", "--stdio" },
  root_dir = function(bufnr, on_dir)
    local root = root_with_package_field(bufnr, {
      "tailwind.config.js",
      "tailwind.config.cjs",
      "tailwind.config.mjs",
      "tailwind.config.ts",
      "postcss.config.js",
      "postcss.config.cjs",
      "postcss.config.mjs",
      "postcss.config.ts",
    }, "tailwindcss")
    if root then
      on_dir(root)
    end
  end,
  filetypes = {
    "html",
    "css",
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "svelte",
    "vue",
    "astro",
  },
  init_options = {
    userLanguages = {
      astro = "html",
    },
  },
})

vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", "rust-project.json", ".git" },
  on_attach = on_attach_disable_semantic_tokens,
})

-- astro
vim.lsp.config("astro", {
  cmd = { "astro-ls", "--stdio" },
  filetypes = { "astro" },

  init_options = {
    typescript = {
      tsdk = vim.fn.stdpath("data") .. "/mason/packages/typescript-language-server/node_modules/typescript/lib",
    },
  },
})

-- Instead of using mason enable all configured LSP via `automatic_enable=true`
-- Prefer more control by enable manual server call below via vim.lsp.enable("")
-- mason config: lua/acurite/configs/mason.lua
vim.lsp.enable({
  "lua_ls",
  "cssls",
  "html",
  "emmet_ls",
  "ts_ls",
  "eslint",
  "biome",
  "pyright",
  "ruff",
  "gopls",
  "clangd",
  "rust_analyzer",
  "astro",
  "tailwindcss",
  "marksman",
})
