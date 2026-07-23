require("bufferline").setup({
  options = {
    mode = "tabs",
    show_buffer_close_icons = false,
    show_close_icon = false,
    tab_size = 18,
    max_name_length = 18,
  },
  highlights = {
    fill = {
      bg = "none",
    },
  },
})

local colors = require("solarized-osaka.colors").setup()
require("incline").setup({
  highlight = {
    groups = {
      InclineNormal = { guibg = colors.blue, guifg = colors.bg },
      InclineNormalNC = { guifg = colors.base01, guibg = "NONE" },
    },
  },
  window = { margin = { vertical = 0, horizontal = 1 } },
  hide = {
    cursorline = true,
  },
  render = function(props)
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
    if vim.bo[props.buf].modified then
      filename = "[+] " .. filename
    end

    local icon, color = require("nvim-web-devicons").get_icon_color(filename)
    return { { icon, guifg = color }, { " " }, { filename } }
  end,
})

require("zen-mode").setup({
  plugins = {
    gitsigns = true,
    tmux = true,
    kitty = { enabled = false, font = "+2" },
  },
})

vim.keymap.set("n", "<leader>z", "<cmd>ZenMode<cr>", { desc = "Zen Mode" })

require("trouble").setup({
  modes = {
    lsp = {
      win = { position = "right" },
    },
  },
})

vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics (Trouble)" })
vim.keymap.set("n", "<leader>cs", "<cmd>Trouble symbols toggle<cr>", { desc = "Symbols (Trouble)" })
vim.keymap.set("n", "<leader>cS", "<cmd>Trouble lsp toggle<cr>", { desc = "LSP references/definitions/... (Trouble)" })
vim.keymap.set("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
vim.keymap.set("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })

vim.keymap.set("n", "[q", function()
  if require("trouble").is_open() then
    require("trouble").prev({ skip_groups = true, jump = true })
  else
    local ok, err = pcall(vim.cmd.cprev)
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end
end, { desc = "Previous Trouble/Quickfix Item" })

vim.keymap.set("n", "]q", function()
  if require("trouble").is_open() then
    require("trouble").next({ skip_groups = true, jump = true })
  else
    local ok, err = pcall(vim.cmd.cnext)
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end
end, { desc = "Next Trouble/Quickfix Item" })
