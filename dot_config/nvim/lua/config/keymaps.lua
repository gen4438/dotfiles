local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true }

vim.g.mapleader = ','
vim.g.maplocalleader = '\\'

-- ctrl + arrow
keymap('', '<ESC>[1;5D', '<C-Left>', { noremap = false, silent = true })
keymap('', '<ESC>[1;5C', '<C-Right>', { noremap = false, silent = true })
keymap('', '<ESC>[1;5A', '<C-Up>', { noremap = false, silent = true })
keymap('', '<ESC>[1;5B', '<C-Down>', { noremap = false, silent = true })
keymap('!', '<ESC>[1;5D', '<C-Left>', { noremap = false, silent = true })
keymap('!', '<ESC>[1;5C', '<C-Right>', { noremap = false, silent = true })
keymap('!', '<ESC>[1;5A', '<C-Up>', { noremap = false, silent = true })
keymap('!', '<ESC>[1;5B', '<C-Down>', { noremap = false, silent = true })

-- ctrl + PageUp / PageDown
keymap('', '<ESC>[6;5~', '<C-PageDown>', { noremap = false, silent = true })
keymap('', '<ESC>[5;5~', '<C-PageUp>', { noremap = false, silent = true })
keymap('!', '<ESC>[6;5~', '<C-PageDown>', { noremap = false, silent = true })
keymap('!', '<ESC>[5;5~', '<C-PageUp>', { noremap = false, silent = true })

-- 上記のマップにより <esc> 一回押しただけでノーマルモードに戻れないので設定
-- keymap('!', '<Esc><Esc>', '<Esc>', { noremap = true, silent = true })

-- leaderっぽい使い方のキーの設定
keymap('', '<Space>', '<Nop>', opts)

-- 無効化
keymap('n', 'ZZ', '<Nop>', opts)
keymap('n', 'ZQ', '<Nop>', opts)

-- デフォルトの操作を代用
keymap('n', '<C-,>', ',', opts)
keymap('n', '<C-;>', ';', opts)
keymap('n', ',,', ',', opts)
keymap('n', ';;', ';', opts)
keymap('n', '<leader><C-l>', '<C-l>', opts)

-- ノーマルモードで <leader>sh を押すとターミナルを開く
keymap('n', '<leader>sh', ':terminal<CR>', { noremap = true, silent = true })
-- ターミナルモードで <Esc><Esc> を押すとノーマルモードに戻る
keymap('t', '<Esc><Esc>', '<C-\\><C-n>', opts)
-- ターミナルモードで <Esc><CR> を押すと <Esc> を送信
keymap('t', '<Esc><CR>', '<Esc>', opts)

keymap('n', '<Esc><Esc>', ':nohlsearch<CR><Esc>', opts)

-- -- ファイルタイプによっては <esc><esc> は unmap
-- vim.api.nvim_create_augroup("custom-map", { clear = true })
-- vim.api.nvim_create_autocmd("BufEnter", {
--   pattern = { 'neo-tree', "neo-tree-popup", "notify" },
--   group = "custom-map",
--   callback = function()
--     vim.api.nvim_buf_del_keymap(0, 'n', '<Esc><Esc>')
--   end,
-- })

-- 数式計算
keymap('n', '<space>=', ':.!bc -l<CR>', opts)
keymap('x', '<space>=', ':B !bc -l<CR>', opts)

-- 16進数計算
keymap('n', '<space>x', ':.!( read EQUATION ; echo "obase=16; ibase=16; ${EQUATION}" ) | bc -l<CR>', opts)
keymap('x', '<space>x', ':B !while read EQUATION ; do echo "obase=16; ibase=16; ${EQUATION}" | bc -l; done<CR>', opts)

-- 10進数 -> 16進数の変換
keymap('n', '<space>X', ':.!( read EQUATION ; echo "obase=16; ibase=10; ${EQUATION}" ) | bc -l<CR>', opts)
keymap('x', '<space>X', ':B !while read EQUATION ; do echo "obase=16; ibase=10; ${EQUATION}" | bc -l; done<CR>', opts)

-- 16進数 -> 10進数の変換
keymap('n', '<space>D', ':.!( read EQUATION ; echo "obase=10; ibase=16; ${EQUATION}" ) | bc -l<CR>', opts)
keymap('x', '<space>D', ':B !while read EQUATION ; do echo "obase=10; ibase=16; ${EQUATION}" | bc -l; done<CR>', opts)

-- 日本語環境
keymap('n', 'い', 'i', opts)
keymap('n', 'あ', 'a', opts)

-- specify input encoding
keymap('n', '-E', ':e ++enc=euc-jp<CR>', opts)
keymap('n', '-J', ':e ++enc=iso-2022-jp<CR>', opts)
keymap('n', '-S', ':e ++enc=cp932 ++ff=dos<CR>', opts)
keymap('n', '-U', ':e ++enc=utf-8 ++ff=unix<CR>', opts)

-- specify output encoding
keymap('n', '=E', ':set fileencoding=euc-jp<CR>', opts)
keymap('n', '=J', ':set fileencoding=iso-2022-jp<CR>', opts)
keymap('n', '=S', ':set fileencoding=cp932 | set ff=dos<CR>', opts)
keymap('n', '=U', ':set fileencoding=utf-8 | set ff=unix<CR>', opts)

-- ファイルパスをヤンク
keymap('n', 'yn', ':let @+ = expand("%:t")<CR>', { noremap = true, silent = true })
keymap('n', 'yp', ':let @+ = expand("%:p")<CR>', { noremap = true, silent = true })
keymap('n', 'yr', ':let @+ = expand("%:p:.")<CR>', { noremap = true, silent = true })
keymap('n', 'yd', ':let @+ = expand("%:p:h")<CR>', { noremap = true, silent = true })

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
keymap('n', 'yR', ':YankRelativePath<CR>', { noremap = true, silent = true })

-- パス補完
keymap('c', '<c-p>', '<c-r>=expand("%:p")<cr>', { noremap = true })
-- 親ディレクトリ
keymap('c', '<c-d>', '<c-r>=expand("%:p:h")<cr>', { noremap = true })
-- ファイル名
keymap('c', '<c-n>', '<c-r>=expand("%:t")<cr>', { noremap = true })

-- 編集中ファイルのディレクトリに移動
keymap('n', '<leader>.', ':lcd %:p:h<CR>', { noremap = true })
-- 前のディレクトリに戻る
keymap('n', '<leader>-', ':lcd -<CR>', { noremap = true })
-- グローバルのディレクトリに戻る
keymap('n', '<leader>z', ':lcd <c-r>=getcwd(-1)<CR><CR>', { noremap = true })
keymap('n', '<leader>Z', ':cd <c-r>=getcwd(-1)<CR><CR>', { noremap = true })

-- Opens an edit command with the path of the currently edited file filled in
keymap('n', '<Leader>e', ':e <C-R>=expand("%:p:h") . "/" <CR>', { noremap = true })
-- Opens a tab edit command with the path of the currently edited file filled
-- keymap('n', '<Leader>te', ':tabe <C-R>=expand("%:p:h") . "/" <CR>', { noremap = true })

-- select all
keymap("n", "vaa", "gg<S-v>G", opts)

-- yank all
keymap('n', 'yay', 'mzggyG`z', opts)

-- Vmap for maintain Visual Mode after shifting > and <
keymap('x', '<', '<<esc>gv', opts)
keymap('x', '>', '><esc>gv', opts)

-- Move visual block (commented out in original)
-- keymap('x', 'J', ":m '>+1<CR>gv=gv", opts)
-- keymap('x', 'K', ":m '<-2<CR>gv=gv", opts)

-- 折り返し時に表示行単位での移動できるようにする
keymap('n', 'j', 'gj', opts)
keymap('n', 'k', 'gk', opts)

-- 折りたたみトグル
keymap('n', '<Space>w', ':setlocal wrap!<CR>', opts)

-- diff
keymap('n', ';dt', ':diffthis<CR>', opts)
keymap('n', ';du', ':diffupdate<CR>', opts)
keymap('n', ';do', ':diffoff!<CR>', opts)
keymap('n', ';wdt', ':windo diffthis<CR>', opts)

-- scrollbind
keymap('n', 'sb', ':set scrollbind!<CR>', opts)

-- vscodeと同じような操作をするためのmap
keymap('n', '<c-k>m', ':set filetype=', opts)
keymap('n', '<c-k><c-t>', ':Colors<CR>', opts)

-- バッファ操作
keymap('n', '<]b>', ':bn<CR>', opts)
keymap('n', '<[b>', ':bp<CR>', opts)
keymap('n', 'sq', ':bp<CR>:bd #<CR>', opts)

-- split
keymap('n', 's', '<Nop>', opts)
keymap('n', 'ss', ':split<CR>', opts)
keymap('n', 'sv', ':vsplit<CR>', opts)
keymap('n', 'sj', '<C-w>j', opts)
keymap('n', 'sk', '<C-w>k', opts)
keymap('n', 'sl', '<C-w>l', opts)
keymap('n', 'sh', '<C-w>h', opts)
keymap('n', 's1', '<C-w>t', opts)
keymap('n', 's9', '<C-w>b', opts)
keymap('n', 'sJ', '<C-w>J', opts)
keymap('n', 'sK', '<C-w>K', opts)
keymap('n', 'sL', '<C-w>L', opts)
keymap('n', 'sH', '<C-w>H', opts)
keymap('n', 'sr', '<C-w>r', opts)
keymap('n', 's=', '<C-w>=', opts)
-- keymap('n', 's<', '<C-w><', opts)
-- keymap('n', 's>', '<C-w>>', opts)
keymap('n', 's-', '<C-w>-', opts)
keymap('n', 's+', '<C-w>+', opts)
keymap('n', 'so', '<C-w>\\|', opts)
keymap('n', 'sO', '<C-w>=', opts)
keymap('n', 's<C-]>', '<C-w>]', opts)
keymap('n', 'sw', '<C-w>w', opts)

-- バッファ
keymap('n', 'sn', ':bn<CR>', opts)
keymap('n', 'sp', ':bp<CR>', opts)
keymap('n', 'st', ':enew<CR>', opts)

-- タブ
keymap('n', '<c-t>', ':tab split<CR>', opts)
keymap('n', '<c-pagedown>', ':tabnext<CR>', opts)
keymap('n', '<c-pageup>', ':tabprevious<CR>', opts)
keymap('n', 'sT', ':tab split<CR>', opts)
keymap('n', 'sN', ':tabnext<CR>', opts)
keymap('n', 'sP', ':tabprevious<CR>', opts)
keymap('n', 'sC', ':tabclose<CR>', opts)
keymap('n', 'sc', ':tabclose<CR>', opts)

-- quickfix
keymap('n', '[q', ':<C-u>cprevious<CR>', opts)
keymap('n', ']q', ':<C-u>cnext<CR>', opts)
-- quickfix stack
keymap('n', '[Q', ':<C-u>colder<CR>', opts)
keymap('n', ']Q', ':<C-u>cnewer<CR>', opts)
-- location list
keymap('n', '[l', ':<C-u>lprevious<CR>', opts)
keymap('n', ']l', ':<C-u>lnext<CR>', opts)
-- location list stack
keymap('n', '[L', ':<C-u>lolder<CR>', opts)
keymap('n', ']L', ':<C-u>lnewer<CR>', opts)

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

vim.api.nvim_set_keymap('n', '<c-q>', ':lua AddCursorToQuickfix()<CR>', { noremap = true, silent = true })

-- 補完 (<c-x> が押しづらいので)
keymap('i', '<c-o><c-l>', '<c-x><c-l>', opts)
keymap('i', '<c-o><c-n>', '<c-x><c-n>', opts)
keymap('i', '<c-o><c-k>', '<c-x><c-k>', opts)
keymap('i', '<c-o><c-t>', '<c-x><c-t>', opts)
keymap('i', '<c-o><c-i>', '<c-x><c-i>', opts)
keymap('i', '<c-o><c-]>', '<c-x><c-]>', opts)
keymap('i', '<c-o><c-f>', '<c-x><c-f>', opts)
keymap('i', '<c-o><c-d>', '<c-x><c-d>', opts)
keymap('i', '<c-o><c-v>', '<c-x><c-v>', opts)
keymap('i', '<c-o><c-u>', '<c-x><c-u>', opts)
keymap('i', '<c-o><c-o>', '<c-x><c-o>', opts)
keymap('i', '<c-o><c-s>', '<c-x>s', opts)

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

keymap('n', '<leader>fw', ':lua GoToFloatingWindow()<CR>', { noremap = true, silent = true })
