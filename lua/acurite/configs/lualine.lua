local function lsp_clients()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return "No LSP"
  end

  local names = vim
    .iter(clients)
    :map(function(client)
      return client.name
    end)
    :totable()

  table.sort(names)
  return table.concat(names, ",")
end

require("lualine").setup({
  options = {
    theme = "rose-pine",
  },
  sections = {
    lualine_c = {
      {
        "filename",
        path = 1,
        symbols = {
          modified = "",
          readonly = " 󰌾 ",
          unnamed = "[No Name]",
          newfile = "[New]",
        },
      },
    },
    lualine_x = {
      lsp_clients,
      "encoding",
      "fileformat",
      "filetype",
    },
  },
})
