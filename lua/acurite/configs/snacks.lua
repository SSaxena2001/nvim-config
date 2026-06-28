local snacks = require("snacks")

snacks.setup({
  explorer = {
    replace_netrw = true,
  },
  picker = {
    ui_select = true,
    layout = {
      preset = function()
        return vim.o.columns >= 120 and "default" or "vertical"
      end,
    },
    matcher = {
      fuzzy = true,
      smartcase = true,
      ignorecase = true,
      filename_bonus = true,
      cwd_bonus = false,
      frecency = false,
      history_bonus = false,
    },
    formatters = {
      file = {
        filename_first = false,
        truncate = "center",
        git_status_hl = true,
      },
    },
    sources = {
      files = {
        hidden = true,
        ignored = false,
        exclude = { ".git" },
      },
      grep = {
        hidden = false,
        ignored = false,
        need_search = true,
        limit_live = 5000,
        exclude = {
          ".git",
          "node_modules",
          "dist",
          "build",
          "coverage",
          ".next",
          ".turbo",
          "target",
        },
        args = {
          "--max-filesize",
          "1M",
          "--glob",
          "!*.lock",
          "--glob",
          "!package-lock.json",
          "--glob",
          "!pnpm-lock.yaml",
          "--glob",
          "!yarn.lock",
        },
      },
      explorer = {
        hidden = true,
        ignored = false,
        git_status = true,
        git_untracked = true,
        diagnostics = true,
        follow_file = true,
        layout = { preset = "sidebar", preview = false },
      },
    },
    win = {
      input = {
        keys = {
          ["<Esc>"] = { "close", mode = { "n", "i" } },
          ["<C-j>"] = { "list_down", mode = { "n", "i" } },
          ["<C-k>"] = { "list_up", mode = { "n", "i" } },
        },
      },
    },
  },
})

local picker = Snacks.picker

vim.keymap.set("n", "<leader>fP", function()
  picker.files({ cwd = vim.fn.stdpath("config"), hidden = true, ignored = false })
end, { desc = "Find config file" })

vim.keymap.set("n", ";f", function()
  picker.files({ hidden = true, ignored = false })
end, { desc = "Find files" })

vim.keymap.set("n", ";r", function()
  picker.grep({ hidden = false, ignored = false, need_search = true, limit_live = 5000 })
end, { desc = "Live grep" })

vim.keymap.set("n", "\\", function()
  picker.buffers()
end, { desc = "Buffers" })

vim.keymap.set("n", ";t", function()
  picker.help()
end, { desc = "Help tags" })

vim.keymap.set("n", ";;", function()
  picker.resume()
end, { desc = "Resume picker" })

vim.keymap.set("n", ";e", function()
  picker.diagnostics()
end, { desc = "Diagnostics" })

vim.keymap.set("n", ";s", function()
  picker.lsp_symbols()
end, { desc = "Document symbols" })

vim.keymap.set("n", "<leader>e", function()
  Snacks.explorer()
end, { desc = "File explorer" })

vim.keymap.set("n", "sf", function()
  Snacks.explorer({ cwd = vim.fn.expand("%:p:h") })
end, { desc = "File explorer at buffer path" })
