local M = {}

local plugins = {
  "telescope.nvim",
  "telescope-fzf-native.nvim",
  "telescope-ui-select.nvim",
}

local function load()
  -- If a keymap gets here before :Telescope has been invoked, remove the lazy
  -- command stub so Telescope can define its real command during packadd.
  pcall(vim.api.nvim_del_user_command, "Telescope")
  require("acurite.core.lazy").load(plugins, "acurite.configs.telescope")
end

function M.builtin(name, opts)
  load()
  return require("telescope.builtin")[name](opts or {})
end

return M
