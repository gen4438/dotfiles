-- VSCode環境用のオプション調整
-- 共通設定を読み込んだ後に、VSCode固有の最適化を行う

local M = {}

function M.setup()
  -- VSCode環境であることを確認
  if not vim.g.vscode then
    return
  end

  -- VSCode環境でのオプション調整
  -- ========================================
  
  -- UI関連の無効化（VSCodeが管理）
  vim.opt.laststatus = 0      -- ステータスラインを非表示
  vim.opt.showtabline = 0     -- タブラインを非表示
  vim.opt.number = false      -- 行番号を非表示（VSCodeが管理）
  vim.opt.relativenumber = false -- 相対行番号を非表示
  vim.opt.signcolumn = "no"   -- サインカラムを非表示
  vim.opt.foldcolumn = "0"    -- フォールドカラムを非表示
  
  
  -- カーソルライン・カラムの調整
  vim.opt.cursorline = false  -- VSCodeがカーソルライン表示を管理
  vim.opt.cursorcolumn = false
  
  -- クリップボード統合の強化
  vim.opt.clipboard = "unnamedplus"
  
  -- VSCode環境での最適化
  -- ========================================
  
  -- ファイル操作の最適化
  vim.opt.updatetime = 100       -- VSCode環境ではより高速に
  vim.opt.timeoutlen = 300       -- キーシーケンスのタイムアウトを短縮
  
  -- バックアップ・スワップファイルの調整
  -- VSCodeが自動保存を管理するため、設定を軽量化
  vim.opt.backup = false
  vim.opt.writebackup = false
  vim.opt.swapfile = false
  
  -- フォーマットオプションの調整
  -- VSCodeのフォーマッターと競合しないように
  vim.opt.formatoptions:remove({ "c", "r", "o" })
  
  -- ポップアップ・補完メニューの調整
  vim.opt.completeopt = { "menuone", "noselect" }
  vim.opt.pumheight = 10
  vim.opt.pumblend = 0          -- VSCode環境では透明度なし
  
  -- VSCode固有の変数設定
  -- ========================================
  
  -- -- 初期化完了の通知
  -- vim.defer_fn(function()
  --   vim.notify("VSCode optimization applied", vim.log.levels.INFO)
  -- end, 500)
end

return M