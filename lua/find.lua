-- `:find` backed by a `findfunc`, in place of telescope's find_files.
--
-- Candidates come from fd rather than a glob: glob("**/*") misses dotfiles and
-- walks ignored directories, and fd is both faster than a Lua walk and
-- .gitignore-aware for free. ripgrep is the second choice -- it is already a
-- dependency for :grep, see lua/grep.lua -- and the glob fallback keeps :find
-- working when neither is installed.

local M = {}

local root_markers = {
  "package-lock.json",
  "pnpm-lock.yaml",
  "yarn.lock",
  "bun.lock",
  "go.work",
  "go.mod",
  "pyproject.toml",
  "package.json",
}

-- Resolved at call time, not at load time, so it follows the buffer.
--
-- `.git` is asked for first and on its own. vim.fs.root() resolves a list of
-- markers by priority rather than by distance, so with `.git` sitting in the
-- same list as go.mod/pyproject.toml/the lockfiles, any nested module wins:
-- open services/api/main.go in a monorepo and the "root" became services/api,
-- which is what `;f` then searched. The repository is the project. The other
-- markers are the fallback for trees that are not repositories at all.
function M.project_root()
  return vim.fs.root(0, ".git") or vim.fs.root(0, root_markers) or vim.fn.getcwd()
end

-- `.git` is the only directory excluded outright: nothing in it is worth
-- completing over, and fd will happily walk it once `--hidden` is on.
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
--
-- fd first, ripgrep second, nil when neither is installed. Both are given the
-- same three properties: hidden files included, .gitignore obeyed even outside
-- a repository, `.git` itself skipped. The `--hidden` and `--no-ignore` flags
-- are spelled the same either way, which is what fzf-lua's alt-h/alt-i toggles
-- rewrite.
function M.files_command()
  if vim.fn.executable("fd") == 1 then
    local args = {
      "fd",
      "--type",
      "f",
      "--hidden",
      -- fd, like ripgrep, only applies .gitignore when it detects a git
      -- repository. Without this a directory that is not a repo -- a scratch
      -- project, a worktree checked out elsewhere, anything before `git init`
      -- -- has its ignore file silently disregarded, and since .gitignore is
      -- the only thing keeping build output out of the list, completion fills
      -- up with node_modules.
      "--no-require-git",
      -- Print paths as `lua/find.lua`, not `./lua/find.lua`.
      "--strip-cwd-prefix",
    }
    for _, dir in ipairs(always_ignore) do
      args[#args + 1] = "--exclude"
      args[#args + 1] = dir
    end
    return args
  end

  if vim.fn.executable("rg") == 1 then
    local args = { "rg", "--files", "--hidden", "--no-require-git" }
    for _, dir in ipairs(always_ignore) do
      args[#args + 1] = "--glob"
      args[#args + 1] = "!**/" .. dir .. "/**"
    end
    return args
  end

  return nil
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

-- findfunc runs on the main loop, so everything below blocks the editor while
-- it works. Two things keep that bounded: the scan is cached for a couple of
-- seconds, which is what turns a burst of completion requests into one fd run,
-- and the run itself has a deadline, so a tree big enough -- or a network
-- mount stalled enough -- to outlast it gives back an empty list instead of a
-- Neovim that cannot be interrupted.
local SCAN_TIMEOUT_MS = 2000
local SCAN_TTL_NS = 2e9
local cache = { root = nil, files = nil, at = 0 }

local function remember(root, files)
  cache.root, cache.files, cache.at = root, files, vim.uv.hrtime()
  return files
end

local function candidates(root)
  if cache.root == root and cache.files and (vim.uv.hrtime() - cache.at) < SCAN_TTL_NS then
    return cache.files
  end

  local cmd = M.files_command()
  if cmd then
    local out = vim.system(cmd, { cwd = root, text = true }):wait(SCAN_TIMEOUT_MS)
    if out.code == 0 then
      return remember(root, vim.split(out.stdout, "\n", { trimempty = true }))
    end
    -- A timeout kills the process, which comes back as code 124 with a signal
    -- set. Falling through to the glob below would be worse than useless: it
    -- is the slower of the two walks, on the tree that just proved too large.
    if out.signal ~= 0 then
      vim.notify(cmd[1] .. " timed out listing " .. root, vim.log.levels.WARN)
      return remember(root, {})
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
  return remember(root, files)
end

function _G.native_find(text, _)
  local root = M.project_root()
  local cwd = vim.fn.getcwd()
  local result = candidates(root)

  -- fd already prints paths relative to the directory it ran in, so when that
  -- is also :pwd the list is ready as-is. Rewriting it anyway cost more than
  -- the fd call itself on a large tree. Only the root ~= cwd case needs work.
  if root ~= cwd then
    -- Into a new table, not over the old one: `result` is the cached scan, and
    -- rewriting it in place would leave cwd-relative paths behind for the next
    -- call to hand out as if they were root-relative.
    local rewritten = {}
    for i, rel in ipairs(result) do
      local abs = vim.fs.joinpath(root, rel)
      -- Display relative to cwd when the file is underneath it, so completion
      -- stays readable; :find opens either form.
      rewritten[i] = vim.startswith(abs, cwd .. "/") and abs:sub(#cwd + 2) or abs
    end
    result = rewritten
  end

  if text == "" then
    return result
  end
  return vim.fn.matchfuzzy(result, text)
end

vim.opt.findfunc = "v:lua.native_find"

return M
