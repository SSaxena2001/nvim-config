vim.api.nvim_create_user_command("PackAdd", function(opts)
  vim.pack.add(opts.fargs)
end, { nargs = "+", desc = "Add plugins (:PackAdd user/repo)" })

vim.api.nvim_create_user_command("PackDel", function(opts)
  vim.pack.del(opts.fargs)
end, { nargs = "+", desc = "Delete plugins (:PackDel plug1 plug2)" })

vim.api.nvim_create_user_command("PackUpdate", function(opts)
  if opts.args:match("%S") then
    local plugins = vim.split(opts.args, "%s+", { trimempty = true })
    vim.pack.update(plugins)
  else
    vim.pack.update()
  end
end, { nargs = "*", desc = "Update all plugins or specific ones" })

local function non_active_plugins()
  return vim
    .iter(vim.pack.get(nil, { info = false }))
    :filter(function(plugin)
      return not plugin.active
    end)
    :map(function(plugin)
      return plugin.spec.name
    end)
    :totable()
end

vim.api.nvim_create_user_command("PackSync", function(opts)
  local removed = non_active_plugins()
  if #removed > 0 then
    table.sort(removed)
    vim.pack.del(removed)
    vim.notify("Removed unused plugins: " .. table.concat(removed, ", "), vim.log.levels.INFO)
  else
    vim.notify("No unused plugins to remove", vim.log.levels.INFO)
  end

  -- Without !, keep Neovim's native review buffer: :write applies the
  -- proposed revisions and :quit cancels. :PackSync! updates immediately.
  vim.pack.update(nil, { force = opts.bang })
end, {
  bang = true,
  desc = "Remove unused plugins and update the configured set (! skips review)",
})

vim.api.nvim_create_user_command("PackCheck", function()
  local non_active = non_active_plugins()

  if #non_active == 0 then
    vim.notify("No non-active plugins found.", vim.log.levels.INFO)
    return
  end

  vim.notify("Non-active plugins: " .. table.concat(non_active, ", "), vim.log.levels.WARN)
end, { desc = "Check for non-active plugins" })
