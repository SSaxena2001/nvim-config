local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = "acurite.lazy",
  change_detection = { notify = false },
  -- netrw is the file explorer, so it must not be disabled. The rest of the
  -- built-in plugins in this list are dead weight at startup.
  performance = {
    rtp = {
      -- `reset` defaults to true, which strips site/pack/* off the
      -- runtimepath. That breaks :packadd for anything installed outside
      -- lazy.nvim -- notably the local Supermaven checkout in
      -- site/pack/local/opt.
      reset = false,
      disabled_plugins = { "gzip", "tarPlugin", "zipPlugin", "tohtml", "tutor" },
    },
  },
})
