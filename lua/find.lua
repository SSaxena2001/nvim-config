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

-- `.git` is the only directory excluded outright: nothing in it is worth
-- completing over, and rg will happily walk it once `--hidden` is on.
--
-- Everything else is left to .gitignore. That keeps hidden directories the
-- project actually tracks -- .github, .config, .cargo -- reachable from `:find`
-- and `;f`, which a blanket "skip dotfiles" rule would hide.
local always_ignore = { ".git" }

-- The fallback below has no .gitignore handling at all, so it needs its own
-- list of what would otherwise swamp completion. `.zig-cache`/`zig-out` are
-- Zig's build output; `zig-cache` is what older Zig called it. Note this is
-- about directories -- .zig source files are still found.
local fallback_dirs = {
  ".git",
  "node_modules",
  ".zig-cache",
  "zig-cache",
  "zig-out",
}

-- The file list `:find` completes over. lua/plugins/fzf.lua reuses this so
-- the fzf picker and `:find` see the same set of files.
function M.rg_command()
  local args = {
    "rg",
    "--files",
    "--hidden",
    -- ripgrep only applies .gitignore when it detects a git repository. Without
    -- this, a directory that is not a repo -- a scratch project, a worktree
    -- checked out elsewhere, anything before `git init` -- has its ignore file
    -- silently disregarded, and since .gitignore is now the only thing keeping
    -- build output out of the list, completion fills up with node_modules.
    "--no-require-git",
  }

  for _, dir in ipairs(always_ignore) do
    args[#args + 1] = "--glob"
    args[#args + 1] = "!**/" .. dir .. "/**"
  end

  return args
end

local function fallback_ignored(path)
  for _, dir in ipairs(fallback_dirs) do
    if path:find("/" .. dir .. "/", 1, true) or vim.startswith(path, dir .. "/") then
      return true
    end
  end
  -- Without ripgrep there is no .gitignore handling; these are the leftovers
  -- that matter most in practice.
  for _, pat in ipairs({ "/dist/", "/build/", "/%.cache/", "%.tmp$", "%.log$" }) do
    if path:match(pat) then
      return true
    end
  end
  return false
end

local function candidates(root)
  if vim.fn.executable("rg") == 1 then
    local out = vim.system(M.rg_command(), { cwd = root, text = true }):wait()
    if out.code == 0 then
      return vim.split(out.stdout, "\n", { trimempty = true })
    end
  end

  local files = {}
  for _, abs in ipairs(vim.fn.glob(root .. "/**/*", true, true)) do
    if vim.fn.isdirectory(abs) == 0 then
      local rel = abs:sub(#root + 2)
      if not fallback_ignored(rel) then
        files[#files + 1] = rel
      end
    end
  end
  return files
end

function _G.native_find(text, _)
  local root = M.project_root()
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
