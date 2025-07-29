-- Keymap configuration
-- Better organized and using modern vim.keymap.set

-- Set leader keys early
vim.g.mapleader = ','
vim.g.maplocalleader = '\\'

-- Default options for most keymaps
local opts = { noremap = true, silent = true }
local expr_opts = { noremap = true, silent = true, expr = true }

-- Terminal key sequence mappings for better compatibility
-- Map terminal escape sequences to proper key codes
local terminal_map_opts = { noremap = false, silent = true }

-- Ctrl + arrow keys
vim.keymap.set('', '<ESC>[1;5D', '<C-Left>', terminal_map_opts)
vim.keymap.set('', '<ESC>[1;5C', '<C-Right>', terminal_map_opts)
vim.keymap.set('', '<ESC>[1;5A', '<C-Up>', terminal_map_opts)
vim.keymap.set('', '<ESC>[1;5B', '<C-Down>', terminal_map_opts)
vim.keymap.set('!', '<ESC>[1;5D', '<C-Left>', terminal_map_opts)
vim.keymap.set('!', '<ESC>[1;5C', '<C-Right>', terminal_map_opts)
vim.keymap.set('!', '<ESC>[1;5A', '<C-Up>', terminal_map_opts)
vim.keymap.set('!', '<ESC>[1;5B', '<C-Down>', terminal_map_opts)

-- Ctrl + PageUp/PageDown
vim.keymap.set('', '<ESC>[6;5~', '<C-PageDown>', terminal_map_opts)
vim.keymap.set('', '<ESC>[5;5~', '<C-PageUp>', terminal_map_opts)
vim.keymap.set('!', '<ESC>[6;5~', '<C-PageDown>', terminal_map_opts)
vim.keymap.set('!', '<ESC>[5;5~', '<C-PageUp>', terminal_map_opts)

-- Disable space in normal mode to use as prefix key
vim.keymap.set('', '<Space>', '<Nop>', opts)

-- Disable potentially dangerous shortcuts
vim.keymap.set('n', 'ZZ', '<Nop>', opts)
vim.keymap.set('n', 'ZQ', '<Nop>', opts)

-- Restore default functionality for leader keys
vim.keymap.set('n', ',,', ',', opts)
vim.keymap.set('n', ';;', ';', opts)
vim.keymap.set('n', '<leader><C-l>', '<C-l>', opts)

-- Terminal management
vim.keymap.set('n', '<leader>sh', ':terminal<CR>', { desc = "Open terminal" })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = "Exit terminal mode" })
vim.keymap.set('t', '<Esc><CR>', '<Esc>', { desc = "Send escape to terminal" })

-- Clear search highlighting
vim.keymap.set('n', '<Esc><Esc>', ':nohlsearch<CR><Esc>', { desc = "Clear search highlight" })

-- -- ファイルタイプによっては <esc><esc> は unmap
-- vim.api.nvim_create_augroup("custom-map", { clear = true })
-- vim.api.nvim_create_autocmd("BufEnter", {
--   pattern = { 'neo-tree', "neo-tree-popup", "notify" },
--   group = "custom-map",
--   callback = function()
--     vim.api.nvim_buf_del_keymap(0, 'n', '<Esc><Esc>')
--   end,
-- })

-- Calculator and number conversion utilities
vim.keymap.set('n', '<space>=', ':.!bc -l<CR>', { desc = "Calculate math expression" })
vim.keymap.set('x', '<space>=', ':B !bc -l<CR>', { desc = "Calculate selected expression" })

vim.keymap.set('n', '<space>x', ':.!( read EQUATION ; echo "obase=16; ibase=16; ${EQUATION}" ) | bc -l<CR>', { desc = "Hex calculation" })
vim.keymap.set('x', '<space>x', ':B !while read EQUATION ; do echo "obase=16; ibase=16; ${EQUATION}" | bc -l; done<CR>', { desc = "Hex calculation on selection" })

vim.keymap.set('n', '<space>X', ':.!( read EQUATION ; echo "obase=16; ibase=10; ${EQUATION}" ) | bc -l<CR>', { desc = "Dec to hex conversion" })
vim.keymap.set('x', '<space>X', ':B !while read EQUATION ; do echo "obase=16; ibase=10; ${EQUATION}" | bc -l; done<CR>', { desc = "Dec to hex on selection" })

vim.keymap.set('n', '<space>D', ':.!( read EQUATION ; echo "obase=10; ibase=16; ${EQUATION}" ) | bc -l<CR>', { desc = "Hex to dec conversion" })
vim.keymap.set('x', '<space>D', ':B !while read EQUATION ; do echo "obase=10; ibase=16; ${EQUATION}" | bc -l; done<CR>', { desc = "Hex to dec on selection" })

-- Japanese input mode helpers
vim.keymap.set('n', 'い', 'i', { desc = "Insert mode (Japanese い → i)" })
vim.keymap.set('n', 'あ', 'a', { desc = "Append mode (Japanese あ → a)" })

-- Encoding management
vim.keymap.set('n', '-E', ':e ++enc=euc-jp<CR>', { desc = "Reopen as EUC-JP" })
vim.keymap.set('n', '-J', ':e ++enc=iso-2022-jp<CR>', { desc = "Reopen as ISO-2022-JP" })
vim.keymap.set('n', '-S', ':e ++enc=cp932 ++ff=dos<CR>', { desc = "Reopen as Shift-JIS (DOS)" })
vim.keymap.set('n', '-U', ':e ++enc=utf-8 ++ff=unix<CR>', { desc = "Reopen as UTF-8 (Unix)" })

vim.keymap.set('n', '=E', ':set fileencoding=euc-jp<CR>', { desc = "Set encoding to EUC-JP" })
vim.keymap.set('n', '=J', ':set fileencoding=iso-2022-jp<CR>', { desc = "Set encoding to ISO-2022-JP" })
vim.keymap.set('n', '=S', ':set fileencoding=cp932 | set ff=dos<CR>', { desc = "Set encoding to Shift-JIS (DOS)" })
vim.keymap.set('n', '=U', ':set fileencoding=utf-8 | set ff=unix<CR>', { desc = "Set encoding to UTF-8 (Unix)" })

-- File path yanking
vim.keymap.set('n', 'yn', function() vim.fn.setreg('+', vim.fn.expand('%:t')) end, { desc = "Yank filename" })
vim.keymap.set('n', 'yp', function() vim.fn.setreg('+', vim.fn.expand('%:p')) end, { desc = "Yank full path" })
vim.keymap.set('n', 'yr', function() vim.fn.setreg('+', vim.fn.expand('%:p:.')) end, { desc = "Yank relative path" })
vim.keymap.set('n', 'yd', function() vim.fn.setreg('+', vim.fn.expand('%:p:h')) end, { desc = "Yank directory" })

-- 入力したパスからの相対パスをヤンク
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

-- Command line path completion
vim.keymap.set('c', '<c-p>', '<c-r>=expand("%:p")<cr>', { desc = "Insert full path" })
vim.keymap.set('c', '<c-d>', '<c-r>=expand("%:p:h")<cr>', { desc = "Insert directory" })
vim.keymap.set('c', '<c-n>', '<c-r>=expand("%:t")<cr>', { desc = "Insert filename" })

-- Directory navigation
vim.keymap.set('n', '<leader>.', ':lcd %:p:h<CR>', { desc = "Change to file directory" })
vim.keymap.set('n', '<leader>-', ':lcd -<CR>', { desc = "Return to previous directory" })
vim.keymap.set('n', '<leader>z', ':lcd <c-r>=getcwd(-1)<CR><CR>', { desc = "Change to global directory (local)" })
vim.keymap.set('n', '<leader>Z', ':cd <c-r>=getcwd(-1)<CR><CR>', { desc = "Change to global directory (global)" })

-- File editing shortcuts
vim.keymap.set('n', '<leader>e', ':e <C-R>=expand("%:p:h") . "/" <CR>', { desc = "Edit file in current directory" })
-- vim.keymap.set('n', '<leader>te', ':tabe <C-R>=expand("%:p:h") . "/" <CR>', { desc = "Edit in new tab" })

-- Text selection and yanking
vim.keymap.set('n', 'vaa', 'gg<S-v>G', { desc = "Select all" })
vim.keymap.set('n', 'yaa', 'mzggyG`z', { desc = "Yank all" })

-- Visual mode improvements
vim.keymap.set('x', '<', '<gv', { desc = "Decrease indent and reselect" })
vim.keymap.set('x', '>', '>gv', { desc = "Increase indent and reselect" })

-- Move visual block (disabled by default)
-- vim.keymap.set('x', 'J', ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
-- vim.keymap.set('x', 'K', ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Better line navigation for wrapped lines
vim.keymap.set('n', 'j', 'gj', { desc = "Move down (display line)" })
vim.keymap.set('n', 'k', 'gk', { desc = "Move up (display line)" })

-- Line wrap toggle (also available in ui.lua)
vim.keymap.set('n', '<Space>w', ':setlocal wrap!<CR>', { desc = "Toggle line wrap" })

-- Diff mode shortcuts
vim.keymap.set('n', ';dt', ':diffthis<CR>', { desc = "Diff this buffer" })
vim.keymap.set('n', ';du', ':diffupdate<CR>', { desc = "Update diff" })
vim.keymap.set('n', ';do', ':diffoff!<CR>', { desc = "Turn off diff" })
vim.keymap.set('n', ';wdt', ':windo diffthis<CR>', { desc = "Diff all windows" })

-- Scroll binding toggle
vim.keymap.set('n', 'sb', ':set scrollbind!<CR>', { desc = "Toggle scroll bind" })

-- VSCode-like shortcuts
vim.keymap.set('n', '<c-k>m', ':set filetype=', { desc = "Set filetype" })
vim.keymap.set('n', '<c-k><c-t>', ':Colors<CR>', { desc = "Choose colorscheme" })

-- Buffer navigation
vim.keymap.set('n', ']b', ':bn<CR>', { desc = "Next buffer" })
vim.keymap.set('n', '[b', ':bp<CR>', { desc = "Previous buffer" })
vim.keymap.set('n', 'sq', ':bp<CR>:bd #<CR>', { desc = "Close current buffer" })

-- Window management (s prefix)
vim.keymap.set('n', 's', '<Nop>', opts)  -- Disable 's' to use as prefix

-- Window splitting
vim.keymap.set('n', 'ss', ':split<CR>', { desc = "Horizontal split" })
vim.keymap.set('n', 'sv', ':vsplit<CR>', { desc = "Vertical split" })

-- Window navigation
vim.keymap.set('n', 'sj', '<C-w>j', { desc = "Move to window below" })
vim.keymap.set('n', 'sk', '<C-w>k', { desc = "Move to window above" })
vim.keymap.set('n', 'sl', '<C-w>l', { desc = "Move to window right" })
vim.keymap.set('n', 'sh', '<C-w>h', { desc = "Move to window left" })
vim.keymap.set('n', 's1', '<C-w>t', { desc = "Move to top-left window" })
vim.keymap.set('n', 's9', '<C-w>b', { desc = "Move to bottom-right window" })
vim.keymap.set('n', 'sw', '<C-w>w', { desc = "Cycle through windows" })

-- Window movement
vim.keymap.set('n', 'sJ', '<C-w>J', { desc = "Move window to bottom" })
vim.keymap.set('n', 'sK', '<C-w>K', { desc = "Move window to top" })
vim.keymap.set('n', 'sL', '<C-w>L', { desc = "Move window to right" })
vim.keymap.set('n', 'sH', '<C-w>H', { desc = "Move window to left" })
vim.keymap.set('n', 'sr', '<C-w>r', { desc = "Rotate windows" })

-- Window resizing
vim.keymap.set('n', 's=', '<C-w>=', { desc = "Equalize window sizes" })
vim.keymap.set('n', 's-', '<C-w>-', { desc = "Decrease window height" })
vim.keymap.set('n', 's+', '<C-w>+', { desc = "Increase window height" })
vim.keymap.set('n', 'so', '<C-w>|', { desc = "Maximize window width" })
vim.keymap.set('n', 'sO', '<C-w>=', { desc = "Reset window sizes" })

-- Misc window operations
vim.keymap.set('n', 's]', '<C-w>]', { desc = "Jump to tag in new window" })

-- Buffer operations with s prefix
vim.keymap.set('n', 'sn', ':bn<CR>', { desc = "Next buffer" })
vim.keymap.set('n', 'sp', ':bp<CR>', { desc = "Previous buffer" })
vim.keymap.set('n', 'st', ':enew<CR>', { desc = "New buffer" })

-- Tab management
vim.keymap.set('n', '<c-t>', ':tab split<CR>', { desc = "Open buffer in new tab" })
vim.keymap.set('n', '<c-pagedown>', ':tabnext<CR>', { desc = "Next tab" })
vim.keymap.set('n', '<c-pageup>', ':tabprevious<CR>', { desc = "Previous tab" })

-- Tab operations with s prefix
vim.keymap.set('n', 'sT', ':tab split<CR>', { desc = "Open in new tab" })
vim.keymap.set('n', 'sN', ':tabnext<CR>', { desc = "Next tab" })
vim.keymap.set('n', 'sP', ':tabprevious<CR>', { desc = "Previous tab" })
vim.keymap.set('n', 'sc', ':tabclose<CR>', { desc = "Close tab" })
vim.keymap.set('n', 'sC', ':tabclose<CR>', { desc = "Close tab" })

-- Quickfix and location list navigation
vim.keymap.set('n', '[q', ':<C-u>cprevious<CR>', { desc = "Previous quickfix item" })
vim.keymap.set('n', ']q', ':<C-u>cnext<CR>', { desc = "Next quickfix item" })
vim.keymap.set('n', '[Q', ':<C-u>colder<CR>', { desc = "Older quickfix list" })
vim.keymap.set('n', ']Q', ':<C-u>cnewer<CR>', { desc = "Newer quickfix list" })

vim.keymap.set('n', '[l', ':<C-u>lprevious<CR>', { desc = "Previous location item" })
vim.keymap.set('n', ']l', ':<C-u>lnext<CR>', { desc = "Next location item" })
vim.keymap.set('n', '[L', ':<C-u>lolder<CR>', { desc = "Older location list" })
vim.keymap.set('n', ']L', ':<C-u>lnewer<CR>', { desc = "Newer location list" })

function AddCursorToQuickfix()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local bufnr = vim.api.nvim_get_current_buf()
  vim.fn.setqflist({
    {
      bufnr = bufnr,
      lnum = row,
      col = col + 1,
      text = "Cursor position"
    }
  }, 'a')
end

vim.keymap.set('n', '<c-q>', AddCursorToQuickfix, { desc = "Add cursor position to quickfix" })

-- Insert mode completion shortcuts (easier than <c-x> combinations)
vim.keymap.set('i', '<c-o><c-l>', '<c-x><c-l>', { desc = "Line completion" })
-- vim.keymap.set('i', '<c-o><c-p>', '<c-x><c-p>', { desc = "Keyword completion" })  -- used for <c-o><c-p> in fzf-lua
vim.keymap.set('i', '<c-o><c-n>', '<c-x><c-n>', { desc = "Keyword completion" })
vim.keymap.set('i', '<c-o><c-k>', '<c-x><c-k>', { desc = "Dictionary completion" })
vim.keymap.set('i', '<c-o><c-t>', '<c-x><c-t>', { desc = "Thesaurus completion" })
vim.keymap.set('i', '<c-o><c-i>', '<c-x><c-i>', { desc = "Include file completion" })
vim.keymap.set('i', '<c-o><c-]>', '<c-x><c-]>', { desc = "Tag completion" })
vim.keymap.set('i', '<c-o><c-f>', '<c-x><c-f>', { desc = "File path completion" })
vim.keymap.set('i', '<c-o><c-d>', '<c-x><c-d>', { desc = "Definition completion" })
vim.keymap.set('i', '<c-o><c-v>', '<c-x><c-v>', { desc = "Vim command completion" })
vim.keymap.set('i', '<c-o><c-u>', '<c-x><c-u>', { desc = "User-defined completion" })
vim.keymap.set('i', '<c-o><c-o>', '<c-x><c-o>', { desc = "Omni completion" })
vim.keymap.set('i', '<c-o><c-s>', '<c-x>s', { desc = "Spell completion" })

-- return to floating window
function GoToFloatingWindow()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= '' then
      vim.api.nvim_set_current_win(win)
      break
    end
  end
end

vim.keymap.set('n', '<leader>fw', GoToFloatingWindow, { desc = "Go to floating window" })
