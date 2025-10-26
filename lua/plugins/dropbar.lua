-- return {}

return {
  "Bekaboo/dropbar.nvim",
  opts = {
    bar = {
      truncate = true, -- allow shortening if overflow
    },
    sources = {
      path = {
        max_depth = 1, -- limit folder nesting on file path
        relative_to = function(buf, _)
          local file = vim.api.nvim_buf_get_name(buf)
          if file == "" then
            return vim.fn.getcwd()
          end

          -- Get the parent folder of the current file
          local parent = vim.fn.fnamemodify(file, ":h")
          -- Return *that* so breadcrumbs start one folder above file
          local last_folder = parent:match(".*/([^/]+)/[^/]+$")
          return last_folder or parent
        end,
      },
      treesitter = {
        max_depth = 3, -- limit symbol depth in syntax tree
      },
      lsp = {
        max_depth = 3, -- limit LSP nesting
      },
    },
    -- icons = {
    --   ui = {
    --     bar = {
    --       separator = "", -- > arrow for sections
    --     },
    --   },
    -- },
  },
  config = function()
    local dropbar_api = require("dropbar.api")
    vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
    vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
    vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })

    local hl = vim.api.nvim_set_hl
    hl(0, "DropBarMenuNormal", { bg = "none" })
    hl(0, "DropBarMenuHoverEntry", { bg = "none" })
    hl(0, "DropBarBackdrop", { bg = "none" })
    hl(0, "WinBar", { bg = "none" })
    hl(0, "WinBarNC", { bg = "none" })
  end,
}
