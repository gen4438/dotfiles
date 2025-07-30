-- neovim プラグイン以外で必要なパッケージをインストールする

return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = true,
  },

  -- fzf
  {
    "junegunn/fzf",
    build = (function()
      if vim.fn.has("win32") == 1 then
        return nil
      else
        return "./install --bin"
      end
    end)(),
    lazy = true,
    module = true
  },

  -- neovim 以外のパッケージをインストール
  -- {
  --   dir = vim.fn.stdpath("config") .. "/scripts/nonvim.nvim",
  --   -- winodows でのみ実行
  --   cond = function()
  --     return vim.fn.has("win32") == 1
  --   end,
  --   build = "powershell.exe -File ./install.ps1",
  --   lazy = false,
  -- },
}
