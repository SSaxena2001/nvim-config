-- Git as Vim commands. Overlaps lua/lazygit.lua only at the edges: lazygit is
-- a full TUI in its own tab, good for staging a sprawl of changes by eye.
-- Fugitive stays in the editor, and is what the merge-conflict and blame work
-- below needs -- `:Gdiffsplit` puts the two sides in real buffers, which no
-- external TUI can do.
vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Git status (fugitive)" })

-- Inside the status buffer the single-letter commands are fugitive's own
-- (`s` stage, `u` unstage, `=` inline diff, `cc` commit). Only the ones that
-- talk to the remote need binding, since those are the ones worth a prompt.
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("FugitiveRemoteMaps", { clear = true }),
  callback = function(args)
    if vim.bo[args.buf].filetype ~= "fugitive" then
      return
    end

    local opts = { buffer = args.buf, remap = false }

    vim.keymap.set("n", "<leader>p", function()
      vim.cmd.Git("push")
    end, vim.tbl_extend("force", opts, { desc = "Git push" }))

    -- Rebase rather than merge, so pulling does not litter the history with
    -- merge commits for work that was only ever local.
    vim.keymap.set("n", "<leader>P", function()
      vim.cmd.Git({ "pull", "--rebase" })
    end, vim.tbl_extend("force", opts, { desc = "Git pull --rebase" }))

    -- Left unexecuted on the command line: the branch name is the part you
    -- have to fill in, and this is the case where it was never set up.
    vim.keymap.set("n", "<leader>t", ":Git push -u origin ", vim.tbl_extend("force", opts, { desc = "Git push -u origin" }))
  end,
})

-- Merge conflicts: take the target (//2) or the merge (//3) side of the hunk
-- under the cursor.
--
-- `gu` is the builtin lowercase operator and `gh` starts Select mode, so these
-- are expr maps that only claim the key inside a diff and hand back the
-- builtin everywhere else. Fugitive's own three-way diff is the only place
-- //2 and //3 resolve to anything, so nothing is lost by the guard.
local function diffget(side, fallback)
  return function()
    if vim.wo.diff then
      return "<cmd>diffget " .. side .. "<CR>"
    end
    return fallback
  end
end

vim.keymap.set("n", "gu", diffget("//2", "gu"), { expr = true, desc = "Take target side (diff)" })
vim.keymap.set("n", "gh", diffget("//3", "gh"), { expr = true, desc = "Take merge side (diff)" })
