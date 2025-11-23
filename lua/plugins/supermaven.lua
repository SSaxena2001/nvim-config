return {
  {
    "supermaven-inc/supermaven-nvim",
    opts = function()
      return {
        keymaps = {
          accept_suggestion = "<C-[>",
          clear_suggestion = "<C-]>",
        },
        color = {
          suggestion_color = "#ffffff",
          cterm = 244,
        },
      }
    end,
  },
}
