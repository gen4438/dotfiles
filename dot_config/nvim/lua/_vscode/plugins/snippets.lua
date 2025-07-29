-- VSCode環境でのスニペット設定
-- coding-tools.luaの設定をVSCode環境用に調整

return {
  -- emmet（VSCodeでも有効）
  {
    'mattn/emmet-vim',
    lazy = true,
    keys = {
      { "<C-y><C-y>", "<plug>(emmet-expand-abbr)", mode = "i", desc = "Expand Abbreviation" },
    }
  },
  -- UltiSnips（VSCodeでも基本機能は動作）
  {
    'SirVer/ultisnips',
    enabled = true,
    lazy = true,
    dependencies = {
      'honza/vim-snippets',
    },
    cmd = {
      'UltiSnipsEdit',
    },
    cond = function()
      return vim.fn.has('python3') == 1
    end,
    keys = {
      { "<c-s>", mode = "i", desc = "Expand snippet" },
    },
    init = function()
      -- 既存の設定を踏襲
      vim.g.UltiSnipsSnippetDirectories = { vim.fn.stdpath("config") .. "/UltiSnips", 'UltiSnips' }
      vim.g.UltiSnipsExpandTrigger = "<c-s>"
      
      -- VSCode環境では競合を避けるため、シンプルな設定を使用
      -- ジャンプ機能は基本的なキーを使用
      vim.g.UltiSnipsJumpForwardTrigger = "<c-j>"
      vim.g.UltiSnipsJumpBackwardTrigger = "<c-k>"
    end,
    config = function()
      -- VSCode環境用の最小限の設定
      if vim.g.vscode then
        -- VSCode環境では複雑なfzf統合は無効にして、基本機能のみを使用
        vim.notify("UltiSnips loaded for VSCode (basic functionality)", vim.log.levels.INFO)
      end
    end
  },
  
  -- vim-snippets（スニペット集）
  {
    'honza/vim-snippets',
    lazy = true,
    config = function()
      vim.g.ultisnips_python_style = "google"
    end
  },
}