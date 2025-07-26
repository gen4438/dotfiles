-- 開発支援ツール
return {
  -- vim-test との連携のためにインストール
  -- vim-slime よりスターが多い。どちらが良いか要検討。
  -- {
  --   'preservim/vimux',
  --   lazy = true,
  --   cond = function()
  --     return vim.fn.executable("tmux") == 1
  --   end
  -- },

  -- vimからtestを実行
  { 'janko-m/vim-test', lazy = true },

  -- コンパイラの非同期実行（janko-m/vim-testで使用）
  { 'tpope/vim-dispatch', lazy = true },

  -- カバレッジ表示
  { 'google/vim-maktaba', lazy = true },
  { 'google/vim-coverage', lazy = true },
  { 'google/vim-glaive', lazy = true },

  -- debugger
  -- { 'mfussenegger/nvim-dap-python', lazy = true },
  -- { 'mfussenegger/nvim-dap', lazy = true },
  -- { 'theHamsta/nvim-dap-virtual-text', lazy = true },
  -- { 'rcarriga/nvim-dap-ui', lazy = true },
  -- { 'nvim-telescope/telescope-dap.nvim', lazy = true },

  -- { 'puremourning/vimspector', lazy = true },

}
