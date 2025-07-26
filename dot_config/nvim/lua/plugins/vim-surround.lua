-- 囲み文字の操作
return {
  {
    'kylechui/nvim-surround',
    enabled = true,
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    keys = {
      { "!", "vip<Plug>(nvim-surround-visual-line)c", mode = { "n" }, { noremap = true, silent = false } },
      { "!", "<Plug>(nvim-surround-visual-line)c",    mode = { "x" }, { noremap = true, silent = false } },
    },
    config = function()
      local config = require("nvim-surround.config")

      require("nvim-surround").setup({
        indent_lines = false,
        surrounds = {
          -- docstring for Python
          ["d"] = {
            add = { '"""', '"""' },
            find = '""".-"""',
            delete = '^(""")().-(""")()$',
          },

          -- Print
          ["p"] = {
            add = function()
              if vim.bo.filetype == "python" then
                return { 'print(f"{', '=}")' }
              elseif vim.bo.filetype == "go" then
                return { "fmt.Println(", ")" }
              end
            end,
            find = function()
              if vim.bo.filetype == "python" then
                return config.get_selection({ pattern = 'print%(f"{.-=}"%)' })
              elseif vim.bo.filetype == "go" then
                return config.get_selection({ pattern = "fmt%.Println%b()" })
              end
            end,
            delete = (function()
              if vim.bo.filetype == "python" then
                return '^(print%(f"{)().-(=}"%))()$'
              elseif vim.bo.filetype == "go" then
                return '^(fmt%.Println%()().-(%))()$'
              end
            end)(),
          },

          -- Markdown code fence
          ["c"] = {
            add = function()
              local filetype = config.get_input("Enter the filetype: ")
              return { '```' .. filetype .. ' ', '```' }
            end,
            find = "```.-```",
            delete = "^(```.-%\n)().-(```)()$",
            change = {
              target = "^```([^\n]*)().-()()```$",
              replacement = function()
                local filetype = config.get_input("Enter the filetype: ")
                return { { filetype }, { '' } }
              end,
            },
          },
          ["!"] = {
            add = function()
              local filetype = config.get_input("Enter the filetype: ")
              return { '```' .. filetype .. ' ', '```' }
            end,
            find = "```.-```",
            delete = "^(```.-%\n)().-(```)()$",
            change = {
              target = "^```([^\n]*)().-()()```$",
              replacement = function()
                local filetype = config.get_input("Enter the filetype: ")
                return { { filetype }, { '' } }
              end,
            },
          },

          -- 全角シリーズ
          -- 「」 kagi kakko
          ["k"] = {
            add = { "「", "」" },
            find = "「.-」",
            delete = "^(「)().-(」)()$",
          },
          -- （） maru kakko
          ["m"] = {
            add = { "（", "）" },
            find = "（.-）",
            delete = "^(（)().-(）)()$",
          },
          -- 『』nijuu kagi kakko
          ["n"] = {
            add = { "『", "』" },
            find = "『.-』",
            delete = "^(『)().-(』)()$",
          },
          -- 【】sumi tuski kakko
          ["s"] = {
            add = { "【", "】" },
            find = "【.-】",
            delete = "^(【)().-(】)()$",
          },
          -- 〈〉 yama kakko
          ["y"] = {
            add = { "〈", "〉" },
            find = "〈.-〉",
            delete = "^(〈)().-(〉)()$",
          },
        },
        aliases = {
          -- dsk など打つと全角カッコを消せる
          ["K"] = { "k", "m", "n", "s", "y" },
        },
      })
    end,
  },


}
