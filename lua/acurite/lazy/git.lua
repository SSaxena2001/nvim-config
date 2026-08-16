return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- Diagnostic signs are off (see lua/acurite/lsp/diagnostics.lua), so the
      -- sign column stays dedicated to Git changes.
      require("gitsigns").setup({
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "-" },
          topdelete = { text = "-" },
          changedelete = { text = "~" },
        },
      })
    end,
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open Git diff view" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Close Git diff view" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Current file Git history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Repository Git history" },
    },
    config = function()
      require("diffview").setup({
        enhanced_diff_hl = true,
        view = {
          merge_tool = {
            layout = "diff3_horizontal",
            disable_diagnostics = true,
            winbar_info = true,
          },
        },
        -- Keep Diffview's documented mappings: [x and ]x move between
        -- conflicts, <leader>co/ct/cb/ca choose ours/theirs/base/all.
        keymaps = { disable_defaults = false },
      })
    end,
  },
}
