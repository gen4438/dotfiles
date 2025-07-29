-- Keymap configuration for VSCode Neovim
-- Only execute in VSCode environment
if not vim.g.vscode then
  return
end

local vscode = require('vscode')

-- Set leader keys early
vim.g.mapleader = ','
vim.g.maplocalleader = '\\'

-- Default options for most keymaps
local opts = { noremap = true, silent = true }

-- ============================================================================
-- Basic Neovim Keymaps (VSCode Compatible)
-- ============================================================================

-- Disable space in normal mode to use as prefix key
vim.keymap.set('', '<Space>', '<Nop>', opts)

-- Disable potentially dangerous shortcuts
vim.keymap.set('n', 'ZZ', '<Nop>', opts)
vim.keymap.set('n', 'ZQ', '<Nop>', opts)

-- Restore default functionality for leader keys
vim.keymap.set('n', ',,', ',', opts)
vim.keymap.set('n', ';;', ';', opts)
vim.keymap.set('n', '<leader><C-l>', '<C-l>', opts)

-- Search without moving cursor
vim.keymap.set('n', '*', 'm`*``', { desc = "Search word under cursor without moving" })

-- Clear search highlighting
vim.keymap.set('n', '<Esc><Esc>', ':nohlsearch<CR><Esc>', { desc = "Clear search highlight" })

-- Japanese input mode helpers
vim.keymap.set('n', 'い', 'i', { desc = "Insert mode (Japanese い → i)" })
vim.keymap.set('n', 'あ', 'a', { desc = "Append mode (Japanese あ → a)" })

-- Text selection and yanking
vim.keymap.set('n', 'vaa', 'gg<S-v>G', { desc = "Select all" })
vim.keymap.set('n', 'yaa', 'mzggyG`z', { desc = "Yank all" })

-- Visual mode improvements
vim.keymap.set('x', '<', '<gv', { desc = "Decrease indent and reselect" })
vim.keymap.set('x', '>', '>gv', { desc = "Increase indent and reselect" })

-- Better line navigation for wrapped lines
vim.keymap.set('n', 'j', 'gj', { desc = "Move down (display line)" })
vim.keymap.set('n', 'k', 'gk', { desc = "Move up (display line)" })

-- ============================================================================
-- File Path Operations
-- ============================================================================

-- File path yanking
vim.keymap.set('n', 'yn', function() vim.fn.setreg('+', vim.fn.expand('%:t')) end, { desc = "Yank filename" })
vim.keymap.set('n', 'yp', function() vim.fn.setreg('+', vim.fn.expand('%:p')) end, { desc = "Yank full path" })
vim.keymap.set('n', 'yr', function() vim.fn.setreg('+', vim.fn.expand('%:p:.')) end, { desc = "Yank relative path" })
vim.keymap.set('n', 'yd', function() vim.fn.setreg('+', vim.fn.expand('%:p:h')) end, { desc = "Yank directory" })

-- Yank relative path from user input
vim.api.nvim_create_user_command('YankRelativePath', function()
  local function split_path(path)
    local parts = {}
    for part in string.gmatch(path, "[^/]+") do
      table.insert(parts, part)
    end
    return parts
  end

  local function get_relative_path(base_path, path)
    local base_parts = split_path(base_path)
    local path_parts = split_path(path)

    -- Find the common prefix
    local i = 1
    while i <= #base_parts and i <= #path_parts and base_parts[i] == path_parts[i] do
      i = i + 1
    end

    -- Calculate the number of ".." needed
    local relative_parts = {}
    for _ = i, #base_parts do
      table.insert(relative_parts, "..")
    end

    -- Add the remaining parts of the path
    for j = i, #path_parts do
      table.insert(relative_parts, path_parts[j])
    end

    -- Join the parts to form the relative path
    return table.concat(relative_parts, "/")
  end

  -- user input
  local input_path = vim.fn.input('Yank relative path from: ', '', 'file')
  if input_path == '' then
    return
  end

  local base_dir = ''
  if vim.fn.filereadable(input_path) == 1 then
    base_dir = vim.fn.fnamemodify(input_path, ':p:h')
  else
    base_dir = input_path
  end

  -- get relative path
  local relative_path = get_relative_path(base_dir, vim.fn.expand('%:p'))
  vim.fn.setreg('+', relative_path)
end, {})
vim.keymap.set('n', 'yR', ':YankRelativePath<CR>', { desc = "Yank relative path from input" })

-- ============================================================================
-- VSCode Integration - Editor Management
-- ============================================================================

-- Window management (s prefix)
vim.keymap.set('n', 's', '<Nop>', opts)  -- Disable 's' to use as prefix

-- Buffer/Editor operations with VSCode API
vim.keymap.set('n', 'sq', function()
  vscode.call('workbench.action.closeGroup')
end, { desc = "Close current split/group" })

vim.keymap.set('n', 'sn', function()
  vscode.call('workbench.action.nextEditor')
end, { desc = "Next editor" })

vim.keymap.set('n', 'sp', function()
  vscode.call('workbench.action.previousEditor')
end, { desc = "Previous editor" })

vim.keymap.set('n', 'st', function()
  vscode.call('workbench.action.files.newUntitledFile')
end, { desc = "New file" })

-- Editor splitting
vim.keymap.set('n', 'ss', function()
  vscode.call('workbench.action.duplicateActiveEditorGroupDown')
end, { desc = "Split editor horizontally" })

vim.keymap.set('n', 'sv', function()
  vscode.call('workbench.action.duplicateActiveEditorGroupRight')
end, { desc = "Split editor vertically" })

-- Editor group navigation
vim.keymap.set('n', 'sh', function()
  vscode.call('workbench.action.focusLeftGroup')
end, { desc = "Move to window left" })

vim.keymap.set('n', 'sl', function()
  vscode.call('workbench.action.focusRightGroup')
end, { desc = "Move to window right" })

vim.keymap.set('n', 'sk', function()
  vscode.call('workbench.action.focusAboveGroup')
end, { desc = "Move to window above" })

vim.keymap.set('n', 'sj', function()
  vscode.call('workbench.action.focusBelowGroup')
end, { desc = "Move to window below" })

-- Tab/Editor navigation
vim.keymap.set('n', '<c-l>', function()
  vscode.call('workbench.action.nextEditorInGroup')
end, { desc = "Next file in group" })

vim.keymap.set('n', '<c-h>', function()
  vscode.call('workbench.action.previousEditorInGroup')
end, { desc = "Previous file in group" })

vim.keymap.set('n', '<c-t>', function()
  vscode.call('workbench.action.files.newUntitledFile')
end, { desc = "New file" })

vim.keymap.set('n', '<c-pagedown>', function()
  vscode.call('workbench.action.nextEditor')
end, { desc = "Next editor" })

vim.keymap.set('n', '<c-pageup>', function()
  vscode.call('workbench.action.previousEditor')
end, { desc = "Previous editor" })

-- Additional s-prefix editor operations
vim.keymap.set('n', 'sT', function()
  vscode.call('workbench.action.files.newUntitledFile')
end, { desc = "New file" })

vim.keymap.set('n', 'sN', function()
  vscode.call('workbench.action.nextEditor')
end, { desc = "Next editor" })

vim.keymap.set('n', 'sP', function()
  vscode.call('workbench.action.previousEditor')
end, { desc = "Previous editor" })

vim.keymap.set('n', 'sc', function()
  vscode.call('workbench.action.closeActiveEditor')
end, { desc = "Close editor" })

vim.keymap.set('n', 'sC', function()
  vscode.call('workbench.action.closeActiveEditor')
end, { desc = "Close editor" })

-- ============================================================================
-- VSCode Integration - Problems Navigation (replaces quickfix)
-- ============================================================================

-- Problems navigation (replaces quickfix lists)
vim.keymap.set('n', ']q', function()
  vscode.call('editor.action.marker.next')
end, { desc = "Next problem" })

vim.keymap.set('n', '[q', function()
  vscode.call('editor.action.marker.prev')
end, { desc = "Previous problem" })

vim.keymap.set('n', ']Q', function()
  vscode.call('editor.action.marker.nextInFiles')
end, { desc = "Next problem in files" })

vim.keymap.set('n', '[Q', function()
  vscode.call('editor.action.marker.prevInFiles')
end, { desc = "Previous problem in files" })

-- Show problems panel
vim.keymap.set('n', '<leader>sp', function()
  vscode.call('workbench.actions.view.problems')
end, { desc = "Show problems" })

-- ============================================================================
-- VSCode Integration - Code Operations
-- ============================================================================

-- Comments
vim.keymap.set('x', 'gc', function()
  vscode.call('editor.action.commentLine')
end, { desc = "Toggle comment (visual)" })

vim.keymap.set('n', 'gcc', function()
  vscode.call('editor.action.commentLine')
end, { desc = "Toggle comment line" })

-- Code navigation
vim.keymap.set('n', 'gd', function()
  vscode.call('editor.action.revealDefinition')
end, { desc = "Go to definition" })

vim.keymap.set('n', 'gr', function()
  vscode.call('editor.action.goToReferences')
end, { desc = "Go to references" })

-- References navigation
vim.keymap.set('n', ']r', function()
  vscode.call('references-view.next')
end, { desc = "Next reference" })

vim.keymap.set('n', '[r', function()
  vscode.call('references-view.prev')
end, { desc = "Previous reference" })

-- Code actions
vim.keymap.set('n', '<leader>a', function()
  vscode.call('editor.action.quickFix')
end, { desc = "Quick fix" })

vim.keymap.set('n', '<leader>rn', function()
  vscode.call('editor.action.rename')
end, { desc = "Rename symbol" })

-- Formatting
vim.keymap.set('n', '<c-p>', function()
  vscode.call('editor.action.formatDocument')
end, { desc = "Format document" })

vim.keymap.set('x', '<c-p>', function()
  vscode.call('editor.action.formatSelection')
end, { desc = "Format selection" })

-- ============================================================================
-- VSCode Integration - File Operations
-- ============================================================================

-- File search and operations
vim.keymap.set('n', ';ff', function()
  vscode.call('workbench.action.quickOpen')
end, { desc = "Quick open files" })

vim.keymap.set('n', ';fg', function()
  vscode.call('workbench.action.findInFiles')
end, { desc = "Find in files" })

-- Compare files
vim.keymap.set('n', ';dt', function()
  vscode.call('workbench.files.action.compareFileWith')
end, { desc = "Compare file with..." })

-- -- Search and replace
-- vim.keymap.set('n', '<leader>/', function()
--   vscode.call('actions.find')
-- end, { desc = "Find in file" })

-- vim.keymap.set('n', '<leader>rr', function()
--   vscode.call('editor.action.startFindReplaceAction')
-- end, { desc = "Find and replace" })

-- ============================================================================
-- VSCode Integration - Terminal and Panels
-- ============================================================================

-- Terminal management
vim.keymap.set('n', '<leader>sh', function()
  vscode.call('workbench.action.terminal.new')
end, { desc = "Open new terminal" })

vim.keymap.set('n', '<leader>t', function()
  vscode.call('workbench.action.terminal.toggleTerminal')
end, { desc = "Toggle terminal" })

-- Explorer
vim.keymap.set('n', '<c-e><c-e>', function()
  vscode.call('workbench.view.explorer')
end, { desc = "Focus explorer" })

-- ============================================================================
-- VSCode Integration - Git Operations
-- ============================================================================

-- Source control
vim.keymap.set('n', '<leader>gst', function()
  vscode.call('workbench.view.scm')
end, { desc = "Source control" })

-- Git operations
vim.keymap.set('n', '<leader>gb', function()
  vscode.call('gitlens.toggleFileBlame')
end, { desc = "Toggle git blame" })

vim.keymap.set('n', '<leader>gd', function()
  vscode.call('git.openChange')
end, { desc = "Git diff" })

vim.keymap.set('n', '<leader>ga', function()
  vscode.call('git.stage')
end, { desc = "Git stage" })

vim.keymap.set('n', '<leader>gc', function()
  vscode.call('git.commit')
end, { desc = "Git commit" })

vim.keymap.set('n', '<leader>gsh', function()
  vscode.call('git.push')
end, { desc = "Git push" })

vim.keymap.set('n', '<leader>gll', function()
  vscode.call('git.pull')
end, { desc = "Git pull" })

-- Merge conflict resolution
vim.keymap.set('n', 'dp', function()
  vscode.call('git.diff.stageSelection')
end, { desc = "Accept current change" })

vim.keymap.set('n', 'do', function()
  vscode.call('git.unstageSelectedRanges')
end, { desc = "Accept incoming change" })

-- ============================================================================
-- VSCode Integration - Inline Suggestions
-- ============================================================================

-- Accept next word from inline suggestion
vim.keymap.set('i', '<c-w>', function()
  vscode.call('editor.action.inlineSuggest.acceptNextWord')
end, { desc = "Accept next word from inline suggestion" })

-- Accept next line from inline suggestion
vim.keymap.set('i', '<c-l>', function()
  vscode.call('editor.action.inlineSuggest.acceptNextLine')
end, { desc = "Accept next line from inline suggestion" })

-- Commit inline suggestion
vim.keymap.set('i', '<c-j>', function()
  vscode.call('editor.action.inlineSuggest.commit')
end, { desc = "Commit inline suggestion" })

-- Trigger inline edit explicitly
vim.keymap.set('n', '<c-m>', function()
  vscode.call('editor.action.inlineSuggest.triggerInlineEditExplicit')
end, { desc = "Trigger inline edit explicitly" })

-- Accept next line from inline suggestion
vim.keymap.set('n', '<c-j>', function()
  vscode.call('editor.action.inlineSuggest.commit')
end, { desc = "Commit inline suggestion" })