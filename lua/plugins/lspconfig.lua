return {
  "neovim/nvim-lspconfig",
  opts = {
    diagnostics = {
      float = {
        border = "rounded",
      },
      underline = false,
      update_in_insert = false,
      virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = function(diagnostic)
          local signs = {
            ERROR = "",
            HINT = "",
            WARN = "",
            INFO = "",
          }

          return signs[vim.diagnostic.severity[diagnostic.severity]]
        end,
      },
    },
    inlay_hints = { enabled = false },
    servers = {
      ts_ls = {
        filetypes = {
          "typescript", -- TypeScript files (.ts)
          "javascript", -- JavaScript files (.js)
          "javascriptreact", -- React files with JavaScript (.jsx)
          "typescriptreact",
          "typescript.jsx",
          "javascript.jsx",
        },
        settings = {
          typescript = {
            tsserver = { maxTsServerMemory = 12000 },
            suggest = { enabled = true, completeFunctionCalls = true },
            inlayHints = {
              variableTypes = { enabled = true },
              parameterTypes = { enabled = true },
              enumMemberValues = { enabled = true },
              parameterNames = { enabled = "literals" },
              functionLikeReturnTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
            },
          },
        },
      },
    },
  },
}
