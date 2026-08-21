-- Per-server configuration. Every server is declared here with
-- `vim.lsp.config`; the enable list lives in configs/lsp/init.lua.
local util = require("lsp.util")
local capabilities = require("lsp.capabilities")

local on_attach_disable_semantic_tokens = util.on_attach_disable_semantic_tokens

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
    -- JSON null decodes to vim.NIL, which is truthy; test it explicitly.
    if result == nil or result == vim.NIL then
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
    if err or result == nil or result == vim.NIL or vim.tbl_isempty(result) then
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

-- tsgo: Microsoft's native TypeScript/JavaScript language server.
vim.lsp.config("tsgo", {
  cmd = { "tsgo", "--lsp", "--stdio" },
  on_attach = on_attach_disable_semantic_tokens,
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  root_dir = function(bufnr, on_dir)
    -- Native Nvim LSP requires root_dir() to call on_dir(); otherwise the
    -- server is skipped for that buffer. Prefer package-manager roots first so
    -- monorepos reuse one TS server, then fall back to TS/JS project markers,
    -- then to the file's directory for standalone .ts/.tsx files.
    local root = vim.fs.root(bufnr, {
      "package-lock.json",
      "yarn.lock",
      "pnpm-lock.yaml",
      "bun.lockb",
      "bun.lock",
    }) or vim.fs.root(bufnr, {
      "tsconfig.json",
      "jsconfig.json",
      "package.json",
      ".git",
    })

    if not root then
      local fname = vim.api.nvim_buf_get_name(bufnr)
      root = fname ~= "" and vim.fs.dirname(fname) or vim.fn.getcwd()
    end

    on_dir(root)
  end,
})

-- pyright
vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    "pyrightconfig.json",
    ".git",
  },
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

local function clangd_query_driver_arg()
  -- clangd needs permission to query compiler drivers for their system include
  -- paths. This is especially important on macOS and for libstdc++/libc++
  -- headers such as <vector>, <iostream>, etc.
  local candidates = {
    vim.fn.exepath("clang"),
    vim.fn.exepath("clang++"),
    vim.fn.exepath("gcc"),
    vim.fn.exepath("g++"),
    vim.fn.exepath("cc"),
    vim.fn.exepath("c++"),
    "/usr/bin/clang",
    "/usr/bin/clang++",
    "/usr/bin/gcc",
    "/usr/bin/g++",
    "/opt/homebrew/bin/gcc-*",
    "/opt/homebrew/bin/g++-*",
    "/usr/local/bin/gcc-*",
    "/usr/local/bin/g++-*",
  }

  local drivers = {}
  for _, candidate in ipairs(candidates) do
    if candidate and candidate ~= "" then
      if candidate:find("*", 1, true) then
        for _, match in ipairs(vim.fn.glob(candidate, false, true)) do
          table.insert(drivers, match)
        end
      else
        table.insert(drivers, candidate)
      end
    end
  end

  table.sort(drivers)
  return "--query-driver=" .. table.concat(vim.fn.uniq(drivers), ",")
end

vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--completion-style=detailed",
    "--header-insertion=iwyu",
    "--enable-config",
    clangd_query_driver_arg(),
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, {
      ".clangd",
      ".clang-tidy",
      ".clang-format",
      "compile_commands.json",
      "compile_flags.txt",
      "configure.ac",
      "CMakeLists.txt",
      "Makefile",
      ".git",
    })

    if not root then
      local fname = vim.api.nvim_buf_get_name(bufnr)
      root = fname ~= "" and vim.fs.dirname(fname) or vim.fn.getcwd()
    end

    on_dir(root)
  end,
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

    -- Buffer-local, so these stay with the server rather than moving to
    -- core/keymaps/. Under the <leader>l LSP group; <leader>c is the
    -- blackhole-change operator.
    vim.keymap.set("n", "<leader>lh", function()
      clangd_switch_source_header(bufnr, client)
    end, { buffer = bufnr, desc = "Switch C/C++ source/header" })

    vim.keymap.set("n", "<leader>li", function()
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

-- jsonls. Biome used to be the only server covering json/jsonc; this takes
-- over its schema validation and completion now that Biome is gone.
vim.lsp.config("jsonls", {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  root_markers = { ".git" },
  -- conform (prettier) owns formatting for json/jsonc.
  init_options = { provideFormatter = false },
  settings = {
    json = {
      validate = { enable = true },
      -- Resolve schemas declared by a file's own "$schema" key.
      schemaDownload = { enable = true },
    },
  },
})

-- astro
vim.lsp.config("astro", {
  cmd = { "astro-ls", "--stdio" },
  filetypes = { "astro" },

  init_options = {
    typescript = {
      -- astro-ls needs a TypeScript install to borrow. Prefer the project's
      -- own copy, then whatever `tsc` is on $PATH (npm -g), so this no longer
      -- depends on mason having unpacked the server.
      tsdk = (function()
        local local_tsdk = vim.fs.joinpath(vim.fn.getcwd(), "node_modules", "typescript", "lib")
        if vim.fn.isdirectory(local_tsdk) == 1 then
          return local_tsdk
        end
        local tsc = vim.fn.exepath("tsc")
        if tsc ~= "" then
          local resolved = vim.fn.resolve(tsc)
          local lib = vim.fs.joinpath(vim.fs.dirname(vim.fs.dirname(resolved)), "lib")
          if vim.fn.isdirectory(lib) == 1 then
            return lib
          end
        end
        return nil
      end)(),
    },
  },
})
