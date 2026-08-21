-- Statusline: mode chip, git branch, path, then diagnostics, filetype and
-- position on the right.
--
-- Colours come from the active colorscheme's own palette rather than from
-- whatever PmenuSel and Visual happen to be, and are rebuilt on every
-- ColorScheme event so they survive a theme switch. Only the mode chip carries
-- a background; the rest is coloured foreground over whatever StatusLine
-- already paints.

local modes = {
  n = { "NORMAL", "blue" },
  i = { "INSERT", "green" },
  v = { "VISUAL", "magenta" },
  V = { "V-LINE", "magenta" },
  ["\22"] = { "V-BLOCK", "magenta" },
  s = { "SELECT", "violet" },
  S = { "S-LINE", "violet" },
  ["\19"] = { "S-BLOCK", "violet" },
  R = { "REPLACE", "red" },
  c = { "COMMAND", "orange" },
  t = { "TERMINAL", "cyan" },
}

-- Every accent the mode chip can take, so the highlight groups can be defined
-- up front instead of on each redraw.
local accents = { "blue", "green", "magenta", "violet", "red", "orange", "cyan" }

-- Fall back to deriving something reasonable from the standard highlight
-- groups when the colorscheme exposes no palette module.
local function derived_palette()
  local function fg_of(name, default)
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    return hl.fg and string.format("#%06x", hl.fg) or default
  end

  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  return {
    bg = normal.bg and string.format("#%06x", normal.bg) or "#000000",
    fg = fg_of("Normal", "#ffffff"),
    blue = fg_of("Function", "#2ea3f6"),
    green = fg_of("String", "#98b000"),
    magenta = fg_of("Statement", "#ef579b"),
    violet = fg_of("Identifier", "#878bdd"),
    red = fg_of("DiagnosticError", "#fb514f"),
    orange = fg_of("Constant", "#f45e1d"),
    cyan = fg_of("Type", "#30b9ae"),
    base00 = fg_of("Comment", "#79949d"),
    base01 = fg_of("Comment", "#6f8a92"),
  }
end

-- nightfox ships several variants -- nightfox, dayfox, dawnfox, duskfox,
-- nordfox, terafox, carbonfox -- and its palette module loads any of them by
-- name. Its accent colours are tables of base/bright/dim shades.
local nightfox_variants = {
  nightfox = true,
  dayfox = true,
  dawnfox = true,
  duskfox = true,
  nordfox = true,
  terafox = true,
  carbonfox = true,
}

local function palette()
  -- Gate on the *active* colorscheme, not on whether the module happens to be
  -- loadable: nightfox.palette resolves whenever the plugin is installed, so
  -- requiring it blindly would keep its palette after a switch to some other
  -- theme.
  local name = vim.g.colors_name
  if name and nightfox_variants[name] then
    local ok, nightfox = pcall(require, "nightfox.palette")
    if ok then
      local p = nightfox.load(name)
      return {
        bg = p.bg0,
        fg = p.fg1,
        blue = p.blue.base,
        green = p.green.base,
        magenta = p.magenta.base,
        violet = p.pink.base,
        red = p.red.base,
        orange = p.orange.base,
        cyan = p.cyan.base,
        base00 = p.comment,
        base01 = p.fg3,
      }
    end
  end
  return derived_palette()
end

local function set_highlights()
  local c = palette()

  for _, accent in ipairs(accents) do
    vim.api.nvim_set_hl(0, "Stl" .. accent, { fg = c.bg, bg = c[accent], bold = true })
  end

  vim.api.nvim_set_hl(0, "StlGit", { fg = c.violet })
  vim.api.nvim_set_hl(0, "StlPath", { fg = c.fg })
  vim.api.nvim_set_hl(0, "StlFt", { fg = c.base01 })
  vim.api.nvim_set_hl(0, "StlPos", { fg = c.base00 })
end

set_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("StatuslineColors", { clear = true }),
  desc = "Rebuild statusline highlights for the new colorscheme",
  callback = set_highlights,
})

-- Filetype glyph, coloured with the icon's own highlight group. Falls back to
-- the bare filetype name when devicons has nothing for the buffer.
local function filetype_icon()
  local ft = vim.bo.filetype
  if ft == "" then
    return ""
  end

  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then
    return "%#StlFt#" .. ft .. "%*"
  end

  local icon, hl = devicons.get_icon(vim.fn.expand("%:t"), vim.fn.expand("%:e"), { default = true })
  if not icon then
    return "%#StlFt#" .. ft .. "%*"
  end

  return "%#" .. hl .. "#" .. icon .. "%* %#StlFt#" .. ft .. "%*"
end

function _G._statusline()
  local mode = modes[vim.fn.mode()] or { vim.fn.mode():upper(), "blue" }
  local chip = "%#Stl" .. mode[2] .. "# " .. mode[1] .. " %*"

  local branch = vim.b.git_branch and "%#StlGit#  " .. vim.b.git_branch .. "%* " or " "
  local path = "%#StlPath#" .. (vim.b.rel_path or "%f") .. "%*"

  local diag = ""
  local counts = vim.diagnostic.count(0) or {}
  local labels = { " ", " ", " ", " " }
  local hls = { "DiagnosticError", "DiagnosticWarn", "DiagnosticInfo", "DiagnosticHint" }
  for i = 1, 4 do
    if counts[i] and counts[i] > 0 then
      diag = diag .. "%#" .. hls[i] .. "#" .. labels[i] .. counts[i] .. "%* "
    end
  end

  return chip .. branch .. path .. "%=" .. diag .. filetype_icon() .. " %#StlPos#%l:%c%*"
end

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("StatuslineContext", { clear = true }),
  callback = function()
    local root = vim.fs.root(0, ".git")
    if root then
      local out = vim.system({ "git", "branch", "--show-current" }, { cwd = root, text = true }):wait()
      local branch = vim.trim(out.stdout or "")
      vim.b.git_branch = branch ~= "" and branch or nil
      vim.b.rel_path = vim.fn.expand("%:p"):sub(#root + 2)
    else
      vim.b.git_branch = nil
      vim.b.rel_path = vim.fn.expand("%:p:~")
    end
  end,
})

vim.api.nvim_create_autocmd("DiagnosticChanged", {
  group = vim.api.nvim_create_augroup("StatuslineDiagnostics", { clear = true }),
  callback = function()
    vim.cmd("redrawstatus!")
  end,
})

vim.o.statusline = "%!v:lua._statusline()"
