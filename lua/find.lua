-- `:find` backed by a `findfunc`, in place of telescope's find_files.
--
-- Candidates come from ripgrep rather than a glob: glob("**/*") misses dotfiles
-- and walks ignored directories, and ripgrep is already a dependency (see
-- lua/grep.lua). The fallback keeps :find working if it is missing.

local M = {}

local root_markers = {
  "package-lock.json",
  "pnpm-lock.yaml",
  "yarn.lock",
  "bun.lock",
  "go.work",
  "go.mod",
  "pyproject.toml",
  ".git",
  "package.json",
}

-- Resolved at call time, not at load time, so it follows the buffer.
function M.project_root()
  return vim.fs.root(0, root_markers) or vim.fn.getcwd()
end

local fallback_ignore = { "node_modules", "%.git", "%.cache", "dist", "build", "%.tmp", "%.log" }

local function candidates(root)
  if vim.fn.executable("rg") == 1 then
    local out = vim
      .system({
        "rg",
        "--files",
        "--hidden",
        "--glob",
        "!.git/*",
      }, { cwd = root, text = true })
      :wait()

    if out.code == 0 then
      return vim.split(out.stdout, "\n", { trimempty = true })
    end
  end

  local files = {}
  for _, f in ipairs(vim.fn.glob(root .. "/**/*", true, true)) do
    if vim.fn.isdirectory(f) == 0 then
      local skip = false
      for _, pat in ipairs(fallback_ignore) do
        if f:match(pat) then
          skip = true
          break
        end
      end
      if not skip then
        files[#files + 1] = f
      end
    end
  end
  return files
end

-- Where `:find` searches. Set to a directory to scope the next completion
-- somewhere other than the project root -- lua/picker.lua uses this for the
-- "find a config file" mapping.
M.scope = nil

function _G.native_find(text, _)
  local root = M.scope or M.project_root()
  local cwd = vim.fn.getcwd()

  local result = {}
  for _, rel in ipairs(candidates(root)) do
    local abs = vim.fs.normalize(vim.fs.joinpath(root, rel))
    -- Display relative to cwd when the file is underneath it, so completion
    -- stays readable; :find opens either form.
    result[#result + 1] = vim.startswith(abs, cwd .. "/") and abs:sub(#cwd + 2) or abs
  end

  if text == "" then
    return result
  end
  return vim.fn.matchfuzzy(result, text)
end

vim.opt.findfunc = "v:lua.native_find"

return M
