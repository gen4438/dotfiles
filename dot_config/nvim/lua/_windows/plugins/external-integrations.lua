-- 外部ツール連携
return {
  -- vim内の文字列をブラウザで開く
  {
    'tyru/open-browser.vim',
    lazy = true,
    keys = {
      { "<leader>gf", "<Plug>(openbrowser-smart-search)", mode = "n" },
      { "<leader>gf", "<Plug>(openbrowser-smart-search)", mode = "v" },
    }
  },
}
