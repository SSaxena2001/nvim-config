return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = "<C-l>",
          accept_word = "<M-l>",
          accept_line = "<M-S-l>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = true, -- Show hidden files and folders
            ignored = true, -- Optional: also show gitignored files if desired
          },
        },
      },
    },
    keys = {
      {
        "<leader>fP",
        function()
          Snacks.picker.files({ cwd = require("lazy.core.config").options.root })
        end,
        desc = "Find Plugin File",
      },
      {
        ";f",
        function()
          Snacks.picker.files({ hidden = true, include_ignored = false })
        end,
        desc = "Lists files in your current working directory, respects .gitignore",
      },
      {
        ";r",
        function()
          Snacks.picker.grep({ rg_opts = "--hidden --color=always --line-number --column" })
        end,
        desc = "Live Grep (shows hidden, uses .gitignore)",
      },
      {
        "\\",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Lists open buffers",
      },
      {
        ";t",
        function()
          Snacks.picker.help()
        end,
        desc = "Lists available help tags",
      },
      {
        ";;",
        function()
          Snacks.picker.resume()
        end,
        desc = "Resume previous Snacks picker",
      },
      {
        ";e",
        function()
          Snacks.picker.diagnostics()
        end,
        desc = "Lists diagnostics",
      },
      {
        ";s",
        function()
          Snacks.picker.lsp_symbols()
        end,
        desc = "Lists function names/variables from Treesitter",
      },
      {
        "sf",
        function()
          local buffer_dir = vim.fn.expand("%:p:h")
          Snacks.explorer({ cwd = buffer_dir })
        end,
        desc = "Open File Explorer with buffer path",
      },
      {
        "gd",
        function()
          Snacks.picker.lsp_definitions()
        end,
        desc = "Goto Definition",
      },
    },
  },
}
