return {
  "neovim/nvim-lspconfig",
  opts = {
    diagnostics = {
      float = {
        border = "rounded",
      },
      underline = true,
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
  },
}
