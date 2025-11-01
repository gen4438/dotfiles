-- Auto commands configuration for VSCode-Neovim
-- VSCode handles most file operations, so we only keep essential autocmds

-- Create autocommand groups for organization
local formatting_group = vim.api.nvim_create_augroup("VSCodeFormattingOptions", { clear = true })
local general_group = vim.api.nvim_create_augroup("VSCodeGeneralAutocmds", { clear = true })

-- Disable auto-commenting on new lines
-- This prevents ftplugin from adding unwanted comment leaders
vim.api.nvim_create_autocmd("BufEnter", {
  group = formatting_group,
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
  desc = "Disable auto-commenting",
})

-- Highlight yanked text (useful visual feedback in VSCode)
vim.api.nvim_create_autocmd("TextYankPost", {
  group = general_group,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 300,
    })
  end,
  desc = "Highlight yanked text",
})

-- Note: The following are NOT included for VSCode environment:
-- - Cursor position restoration (VSCode handles this)
-- - Auto-create directories (VSCode handles this)
-- - Check for external file changes (VSCode handles this)
-- - Auto-resize windows (VSCode handles this)
-- - Terminal settings (VSCode terminal is separate)
-- - Spell checking (causes unwanted annotations in VSCode)
-- - Large file optimizations (VSCode handles this)
