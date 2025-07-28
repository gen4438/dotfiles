return {
  -- nvim-cmp: コマンドライン補完に最適化（COCと併用）
  {
    "hrsh7th/nvim-cmp",
    event = { "CmdlineEnter" }, -- コマンドラインモードでのみ読み込み
    enabled = true, -- コマンドライン補完として有効化
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
    },
    config = function()
      local cmp = require("cmp")
      
      -- コマンドライン補完のみを設定（COCとの競合を避ける）
      -- 検索用（/ と ?）
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer", keyword_length = 3 } -- 3文字以上で補完開始
        },
        completion = {
          completeopt = 'menu,menuone,noselect'
        }
      })

      -- コマンド用（:）
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" }
        }, {
          { name = "cmdline", keyword_length = 2 } -- 2文字以上で補完開始
        }),
        matching = { disallow_symbol_nonprefix_matching = false },
        completion = {
          completeopt = 'menu,menuone,noselect'
        }
      })
      
      -- インサート補完は無効化（COCに任せる）
      cmp.setup({
        enabled = false -- インサートモードでは無効
      })
    end,
  },
}
