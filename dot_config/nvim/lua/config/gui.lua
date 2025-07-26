-- font
vim.o.guifont = "CaskaydiaCove Nerd Font:h14"

-- 初期フォントサイズ
local default_font_size = 14
local font_size = default_font_size

-- フォントサイズを更新する関数
function gui_update_font_size(delta)
    font_size = font_size + delta
    vim.o.guifont = string.format("CaskaydiaCove Nerd Font:h%d", font_size)
end

-- フォントサイズをデフォルトに戻す関数
function gui_reset_font_size()
    font_size = default_font_size
    vim.o.guifont = string.format("CaskaydiaCove Nerd Font:h%d", font_size)
end

-- キーマッピングの設定
vim.api.nvim_set_keymap('n', '<C-S-->', ':lua gui_update_font_size(1)<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-->', ':lua gui_update_font_size(-1)<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-0>', ':lua gui_reset_font_size()<CR>', { noremap = true, silent = true })
