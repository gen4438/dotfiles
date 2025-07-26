return {
  -- nvim-cmp 関連プラグインの設定
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter", -- インサートモードに入った時に読み込む
    enabled = false,
    dependencies = {
      -- "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      -- vsnip 用のプラグイン
      -- "hrsh7th/cmp-vsnip",
      -- "hrsh7th/vim-vsnip",
      -- LuaSnip を使用する場合は以下を有効化
      -- "L3MON4D3/LuaSnip",
      -- "saadparwaiz1/cmp_luasnip",
      -- ultisnips / snippy / mini.snippets などを使う場合も同様に追加
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        -- snippet = {
        --   -- 必須: 利用するスニペットエンジンを指定する
        --   expand = function(args)
        --     vim.fn["vsnip#anonymous"](args.body) -- vsnip を使用する場合の設定
        --     -- LuaSnip を利用する場合は下記に差し替え:
        --     -- require("luasnip").lsp_expand(args.body)
        --   end,
        -- },
        window = {
          -- 必要に応じてウィンドウの見た目をカスタマイズ可能（コメント解除して利用）
          -- completion = cmp.config.window.bordered(),
          -- documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- 現在選択中の候補を確定。select を false にすれば明示的に選んだ時のみ確定。
        }),
        -- sources = cmp.config.sources({
        --   { name = "nvim_lsp" },
        --   { name = "vsnip" }, -- vsnip を利用する場合
        --   -- { name = "luasnip" },  -- LuaSnip 利用時はこちらに差し替え
        --   -- { name = "ultisnips" },
        --   -- { name = "snippy" },
        -- }, {
        --   { name = "buffer" },
        -- })
      })

      -- '/' および '?' 用の設定（buffer ソースを使用）
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" }
        }
      })

      -- ':' 用の設定: path と cmdline のソースを使用
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" }
        }, {
          { name = "cmdline" }
        }),
        matching = { disallow_symbol_nonprefix_matching = false }
      })
    end,
  },

  -- -- LSP 関連プラグインの設定
  -- {
  --   "neovim/nvim-lspconfig",
  --   event = "BufReadPre", -- バッファ読み込み前にロードする
  --   config = function()
  --     local capabilities = require("cmp_nvim_lsp").default_capabilities()
  --     -- ※ 利用する LSP サーバー名に置き換えてください。
  --     require("lspconfig")["<YOUR_LSP_SERVER>"].setup({
  --       capabilities = capabilities,
  --       -- 他の LSP サーバー固有の設定を追加してもよい
  --     })
  --   end,
  -- },

  -- 他の必要なプラグインをここに追加可能
}
