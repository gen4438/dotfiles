local autocmd = vim.api.nvim_create_autocmd
local mygroup = vim.api.nvim_create_augroup("vimrc", { clear = true })

-- -- Stop insert mode when entering terminal mode
-- autocmd("TermOpen", {
--   pattern = "bash",
--   group = mygroup,
--   command = "stopinsert",
-- })

-- Don"t auto commenting new lines
-- ftplugin で設定されがちなのを防ぐ
autocmd("BufEnter", {
  pattern = "*",
  group = mygroup,
  command = "set fo-=c fo-=r fo-=o",
})

-- -- ファイル名認識の設定
-- -- = が使われないように設定すると、`FILENAME=/usr/local/'みたいに=の後にスペースがなくても補完できるようになる
-- autocmd("FileType", {
--   pattern = "*",
--   group = mygroup,
--   command = "setlocal isfname-==",
-- })

-- Restore cursor location when file is opened
autocmd({ "BufReadPost" }, {
  pattern = { "*" },
  group = mygroup,
  callback = function()
    -- commit のときは除外
    if vim.bo.filetype == "gitcommit" then
      return
    end
    vim.api.nvim_exec('silent! normal! g`"zv', false)
  end,
})

-- 保存先のディレクトリが存在しなければ作る
local function auto_mkdir(dir, force)
  if vim.fn.isdirectory(dir) == 0 and (force == 1 or vim.fn.input(string.format('"%s" does not exist. Create? [y/N]', dir)) == 'y') then
    vim.fn.mkdir(dir, 'p')
  end
end

vim.api.nvim_create_autocmd("BufWritePre", {
  group = mygroup,
  pattern = "*",
  callback = function()
    dir = vim.fn.expand("<afile>:p:h")

    -- プロトコルで始まるファイルを無視
    if vim.regex([[^\w\+://]]):match_str(dir) then
      return
    end

    auto_mkdir(dir, vim.v.cmdbang)
  end,
})

-- ヘルプを vsplit で開く設定
-- 今ひとつうまく動かないのでプラグインで対応
-- vim.api.nvim_create_autocmd("FileType", {
--   group = mygroup,
--   pattern = { "help", "man" },
--   command = "wincmd L",
-- })
