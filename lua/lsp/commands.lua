-- LSP-related user commands.

vim.api.nvim_create_user_command("LspClients", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    vim.notify("No LSP clients attached to current buffer", vim.log.levels.WARN)
    return
  end

  local lines = vim
    .iter(clients)
    :map(function(client)
      return string.format("%s  root=%s", client.name, client.root_dir or "")
    end)
    :totable()

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Attached LSP clients" })
end, { desc = "Show LSP clients attached to current buffer" })
