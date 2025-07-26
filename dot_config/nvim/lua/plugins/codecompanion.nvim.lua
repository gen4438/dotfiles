return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      adapters = {
        opts = {
          language = "Japanese",
          -- allow_insecure = true,
          -- proxy = "socks5://127.0.0.1:9999",
          proxy = os.getenv("http_proxy") or os.getenv("https_proxy") or nil,
        },
        azure_openai = function()
          return require("codecompanion.adapters").extend("azure_openai", {
            schema = {
              model = {
                default = "o3-mini",
              },
            },
          })
        end,
      },
      strategies = {
        -- Change the default chat adapter
        chat = {
          -- adapter = "copilot",
          adapter = vim.env.AZURE_API_KEY and "azure_openai" or "copilot",
          keymaps = {
          },

          slash_commands = {
            ["file"] = {
              opts = {
                provider = "fzf_lua",
                contains_code = true,
              },
            },
          },
        },
        inline = {
          adapter = "copilot",
        },
      },
      opts = {
        -- Set debug logging
        -- log_level = "DEBUG",
      },
    },

    keys = {
      { ";cI", ":CodeCompanion " },
      { ";cI", ":'<,'>CodeCompanion ",       mode = "x" },
      { ";cC", ":CodeCompanionChat<CR>" },
      { ";cP", ":CodeCompanionChat Add<CR>", mode = "x" },
      { ";c:", ":CodeCompanionCmd " },
      { ";cA", ":CodeCompanionActions<CR>" },
    }
  },
}
