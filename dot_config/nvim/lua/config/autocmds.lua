-- Auto commands configuration
-- Organized by functionality with better error handling

-- Create autocommand groups for organization
local general_group = vim.api.nvim_create_augroup("GeneralAutocmds", { clear = true })
local file_ops_group = vim.api.nvim_create_augroup("FileOperations", { clear = true })
local formatting_group = vim.api.nvim_create_augroup("FormattingOptions", { clear = true })

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

-- Restore cursor position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
  group = general_group,
  pattern = "*",
  callback = function()
    local ft = vim.bo.filetype
    -- Skip for git commits and other special file types
    if ft == "gitcommit" or ft == "gitrebase" or ft == "svn" or ft == "hgcommit" then
      return
    end
    
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = "Restore cursor position",
})

-- Auto-create directories when saving files
local function auto_mkdir(dir, force)
  if vim.fn.isdirectory(dir) == 0 then
    if force or vim.fn.confirm(string.format('Directory "%s" does not exist. Create?', dir), "&Yes\n&No") == 1 then
      vim.fn.mkdir(dir, "p")
    end
  end
end

vim.api.nvim_create_autocmd("BufWritePre", {
  group = file_ops_group,
  pattern = "*",
  callback = function(ev)
    local file = vim.fn.expand("<afile>")
    local dir = vim.fn.fnamemodify(file, ":p:h")
    
    -- Skip for special protocols and patterns
    if file:match("^%w+://") or file:match("^oil://") then
      return
    end
    
    auto_mkdir(dir, vim.v.cmdbang == 1)
  end,
  desc = "Auto-create parent directories",
})

-- -- Remove trailing whitespace on save (optional, can be disabled)
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   group = formatting_group,
--   pattern = { "*.lua", "*.py", "*.js", "*.ts", "*.jsx", "*.tsx", "*.go", "*.rs" },
--   callback = function()
--     -- Save cursor position
--     local cursor_pos = vim.api.nvim_win_get_cursor(0)
--     -- Remove trailing whitespace
--     vim.cmd([[%s/\s\+$//e]])
--     -- Restore cursor position
--     vim.api.nvim_win_set_cursor(0, cursor_pos)
--   end,
--   desc = "Remove trailing whitespace",
-- })

-- Highlight yanked text
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

-- Auto-close certain windows when they're the last one
vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
  group = general_group,
  callback = function()
    local bt = vim.bo.buftype
    if bt == "quickfix" or bt == "help" then
      if #vim.api.nvim_list_wins() == 1 then
        vim.cmd("quit")
      end
    end
  end,
  desc = "Auto-close auxiliary windows",
})

-- Better terminal handling
vim.api.nvim_create_autocmd("TermOpen", {
  group = general_group,
  pattern = "*",
  callback = function()
    -- Disable line numbers in terminal
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    
    -- Start in insert mode for terminal buffers
    vim.cmd("startinsert")
  end,
  desc = "Terminal setup",
})

-- Auto-resize windows when Vim is resized
vim.api.nvim_create_autocmd("VimResized", {
  group = general_group,
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
  desc = "Auto-resize windows",
})

-- Check if file changed on disk
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = file_ops_group,
  pattern = "*",
  callback = function()
    local buftype = vim.api.nvim_buf_get_option(0, "buftype")
    if buftype == "" and vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
  desc = "Check for external file changes",
})

-- Create missing directories when editing new files
vim.api.nvim_create_autocmd("BufWritePre", {
  group = file_ops_group,
  pattern = "*",
  callback = function()
    local dir = vim.fn.expand("<afile>:p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
  desc = "Create directories for new files",
})

-- Set up better defaults for certain file types
vim.api.nvim_create_autocmd("FileType", {
  group = formatting_group,
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.linebreak = true
  end,
  desc = "Text file settings",
})

-- Disable certain features for large files
vim.api.nvim_create_autocmd("BufReadPre", {
  group = general_group,
  pattern = "*",
  callback = function()
    local max_filesize = 100 * 1024 -- 100KB
    local filename = vim.fn.expand("<afile>")
    local filesize = vim.fn.getfsize(filename)
    
    if filesize > max_filesize or filesize == -2 then
      vim.opt_local.eventignore:append({
        "FileType",
        "Syntax",
        "BufReadPost",
        "BufReadPre",
      })
      vim.opt_local.undolevels = -1
      vim.cmd("syntax clear")
    end
  end,
  desc = "Optimize for large files",
})
