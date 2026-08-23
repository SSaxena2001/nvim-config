-- Statusline: craftzdog's lualine, lifted from his dotfiles.
--
-- His config is a LazyVim override -- he keeps LazyVim's stock spec and
-- replaces one component, `lualine_c[4]`, with LazyVim's `pretty_path`. There
-- is no LazyVim here, so the two helpers he leans on (`pretty_path` and
-- `root_dir`) are ported below, and the sections that read snacks, noice, dap
-- and lazy.nvim are dropped because this config has none of them.

-- `Bold` is what his pretty_path names for the filename, but neither LazyVim
-- nor solarized-osaka defines the group -- it exists and is empty, so the
-- filename ends up unstyled. Give it the one attribute its name promises.
local function ensure_bold()
  if vim.tbl_isempty(vim.api.nvim_get_hl(0, { name = "Bold" })) then
    vim.api.nvim_set_hl(0, "Bold", { bold = true })
  end
end
ensure_bold()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("LualineBold", { clear = true }),
  callback = ensure_bold,
})

-- LazyVim.lualine.format: render `text` in `hl_group`'s foreground, caching
-- the lualine-side highlight it has to create to do it.
local function format(component, text, hl_group)
  text = text:gsub("%%", "%%%%")
  if not hl_group or hl_group == "" then
    return text
  end
  component.hl_cache = component.hl_cache or {}
  local lualine_hl_group = component.hl_cache[hl_group]
  if not lualine_hl_group then
    local utils = require("lualine.utils.utils")
    local gui = vim.tbl_filter(function(x)
      return x
    end, {
      utils.extract_highlight_colors(hl_group, "bold") and "bold",
      utils.extract_highlight_colors(hl_group, "italic") and "italic",
    })
    lualine_hl_group = component:create_hl({
      fg = utils.extract_highlight_colors(hl_group, "fg"),
      gui = #gui > 0 and table.concat(gui, ",") or nil,
    }, "LV_" .. hl_group)
    component.hl_cache[hl_group] = lualine_hl_group
  end
  return component:format_hl(lualine_hl_group) .. text .. component:get_default_hl()
end

local function get_cwd()
  return vim.fs.normalize(vim.uv.cwd() or ".")
end

-- Stands in for LazyVim.root.get(). LazyVim asks the attached LSP for its
-- workspace folders first and only then falls back to marker files; this walks
-- straight to the markers, then to :pwd.
local function get_root()
  local root = vim.fs.root(vim.api.nvim_get_current_buf(), { ".git", "lua", "package.json" })
  return root and vim.fs.normalize(root) or get_cwd()
end

-- LazyVim.lualine.pretty_path, with his options as the defaults.
local function pretty_path(opts)
  opts = vim.tbl_extend("force", {
    relative = "cwd",
    modified_hl = "MatchParen",
    directory_hl = "",
    filename_hl = "Bold",
    modified_sign = "",
    readonly_icon = " 󰌾 ",
    length = 0,
  }, opts or {})

  return function(self)
    local path = vim.fn.expand("%:p")
    if path == "" then
      return ""
    end

    path = vim.fs.normalize(path)
    local root = get_root()
    local cwd = get_cwd()

    if opts.relative == "cwd" and path:find(cwd, 1, true) == 1 then
      path = path:sub(#cwd + 2)
    elseif path:find(root, 1, true) == 1 then
      path = path:sub(#root + 2)
    end

    local sep = "/"
    local parts = vim.split(path, "[\\/]")

    -- length 0 keeps every component; anything else elides the middle.
    if opts.length ~= 0 and #parts > opts.length then
      parts = { parts[1], "…", unpack(parts, #parts - opts.length + 2, #parts) }
    end

    -- Modified is signalled by recolouring the filename, not by a [+] flag:
    -- his modified_sign is the empty string.
    if opts.modified_hl and vim.bo.modified then
      parts[#parts] = parts[#parts] .. opts.modified_sign
      parts[#parts] = format(self, parts[#parts], opts.modified_hl)
    else
      parts[#parts] = format(self, parts[#parts], opts.filename_hl)
    end

    local dir = ""
    if #parts > 1 then
      dir = table.concat({ unpack(parts, 1, #parts - 1) }, sep)
      dir = format(self, dir .. sep, opts.directory_hl)
    end

    local readonly = ""
    if vim.bo.readonly then
      readonly = format(self, opts.readonly_icon, opts.modified_hl)
    end
    return dir .. parts[#parts] .. readonly
  end
end

local function hl_fg(name)
  local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  return hl and hl.fg and string.format("#%06x", hl.fg) or nil
end

-- LazyVim.lualine.root_dir. `cwd = false`, so it stays hidden while the
-- project root and :pwd are the same directory, which is the usual case.
local function root_dir(opts)
  opts = vim.tbl_extend("force", {
    cwd = false,
    subdirectory = true,
    parent = true,
    other = true,
    icon = "󱉭 ",
  }, opts or {})

  local function get()
    local cwd = get_cwd()
    local root = get_root()
    local name = vim.fs.basename(root)

    if root == cwd then
      return opts.cwd and name
    elseif root:find(cwd, 1, true) == 1 then
      return opts.subdirectory and name
    elseif cwd:find(root, 1, true) == 1 then
      return opts.parent and name
    else
      return opts.other and name
    end
  end

  return {
    function()
      return opts.icon .. " " .. get()
    end,
    cond = function()
      return type(get()) == "string"
    end,
    color = function()
      return { fg = hl_fg("Special") }
    end,
  }
end

require("lualine").setup({
  options = {
    -- LazyVim's default. Resolves vim.g.colors_name to the lualine theme
    -- solarized-osaka.nvim ships, so it tracks the colorscheme.
    theme = "auto",
    globalstatus = vim.o.laststatus == 3,
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch" },
    lualine_c = {
      root_dir(),
      {
        "diagnostics",
        symbols = { error = " ", warn = " ", info = " ", hint = " " },
      },
      { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
      { pretty_path() },
    },
    lualine_x = {
      {
        "diff",
        symbols = { added = " ", modified = " ", removed = " " },
        source = function()
          local gitsigns = vim.b.gitsigns_status_dict
          if gitsigns then
            return {
              added = gitsigns.added,
              modified = gitsigns.changed,
              removed = gitsigns.removed,
            }
          end
        end,
      },
    },
    lualine_y = {
      { "progress", separator = " ", padding = { left = 1, right = 0 } },
      { "location", padding = { left = 0, right = 1 } },
    },
    lualine_z = {
      function()
        return " " .. os.date("%R")
      end,
    },
  },
  -- Only names lualine actually ships a module for (see its
  -- lua/lualine/extensions/). quicker.nvim styles the native quickfix window,
  -- so the "quickfix" extension is the one that covers it.
  extensions = { "fzf", "oil", "quickfix", "mason" },
})
