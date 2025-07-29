-- VSCode環境でのスニペット設定
-- coding-tools.luaの設定をVSCode環境用に調整

return {
  -- UltiSnips（VSCodeでも基本機能は動作）
  {
    'SirVer/ultisnips',
    enabled = false,
    lazy = true,
    event = 'BufEnter',
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
      { "<c-j>", mode = "i" },
      { "<c-k>", mode = "i" },
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