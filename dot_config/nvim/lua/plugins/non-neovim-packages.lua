-- neovim プラグイン以外で必要なパッケージをインストールする

return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    opts = {
      ensure_installed = {
        "copilot-language-server",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      -- ensure_installed のパッケージを自動インストール
      local registry = require("mason-registry")
      for _, name in ipairs(opts.ensure_installed or {}) do
        local ok, pkg = pcall(registry.get_package, name)
        if ok and not pkg:is_installed() then
          pkg:install()
        end
      end
    end,
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
