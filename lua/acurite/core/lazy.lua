-- Deferred plugin loading on top of vim.pack.
--
-- `vim.pack.add(..., { load = false })` runs `:packadd!`, which puts the plugin
-- on the runtimepath without sourcing it *at that moment*. That is not enough
-- on its own: once init.lua returns, Nvim sources plugin/ scripts for every
-- runtimepath entry, so a merely-`packadd!`ed plugin still loads at startup.
--
-- So deferred plugins are stripped back off the runtimepath by M.defer(), and
-- M.load() puts them back with a real `:packadd` (no bang), which both restores
-- the path and sources plugin/ — at that point the commands and autocmds the
-- plugin defines finally exist.

local M = {}

local loaded = {}

--- Take deferred plugins off the runtimepath so the post-init plugin phase
--- skips them. Call once, right after registering them with vim.pack.add.
--- @param names string[] plugin directory names
function M.defer(names)
  local drop = {}
  for _, n in ipairs(names) do
    drop[n] = true
  end

  local keep = vim.tbl_filter(function(path)
    return not drop[vim.fn.fnamemodify(path:gsub("/after$", ""), ":t")]
  end, vim.opt.runtimepath:get())

  vim.opt.runtimepath = keep
end

--- Source a deferred plugin and run its config module.
--- @param names string|string[] plugin directory name(s), in dependency order
--- @param config string|nil module to require once the plugin is on the rtp
function M.load(names, config)
  local key = type(names) == "table" and table.concat(names, ",") or names
  if loaded[key] then
    return
  end
  loaded[key] = true

  for _, name in ipairs(type(names) == "table" and names or { names }) do
    vim.cmd.packadd({ name, magic = { file = false } })
  end

  if config then
    local ok, err = pcall(require, config)
    if not ok then
      vim.notify(("Failed to configure %s: %s"):format(key, err), vim.log.levels.ERROR)
    end
  end
end

--- Register a stub command that loads the plugin, then re-runs itself for real.
--- @param cmd string user command the plugin defines
--- @param names string|string[]
--- @param config string|nil
function M.on_command(cmd, names, config)
  vim.api.nvim_create_user_command(cmd, function(args)
    -- Drop the stub first so the plugin's own command replaces it cleanly.
    pcall(vim.api.nvim_del_user_command, cmd)
    M.load(names, config)

    if vim.fn.exists(":" .. cmd) == 0 then
      vim.notify(("%s did not define :%s"):format(tostring(names), cmd), vim.log.levels.ERROR)
      return
    end

    vim.cmd(("%s%s %s"):format(cmd, args.bang and "!" or "", args.args))
  end, { nargs = "*", bang = true, desc = "Load plugin, then run :" .. cmd })
end

--- Load the plugin the first time an event fires.
--- @param event string|string[]
--- @param opts table autocmd options; `config` and `names` are consumed here
function M.on_event(event, names, config, opts)
  opts = opts or {}
  vim.api.nvim_create_autocmd(event, {
    pattern = opts.pattern,
    once = true,
    desc = "Load " .. (type(names) == "table" and names[1] or names),
    callback = function()
      M.load(names, config)
      if opts.after then
        opts.after()
      end
    end,
  })
end

return M
