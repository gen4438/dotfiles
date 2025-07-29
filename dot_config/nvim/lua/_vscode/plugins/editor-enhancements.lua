-- VSCode環境専用のプラグイン設定
-- VSCodeと競合せず、編集体験を向上させるプラグインのみを含む

return {
  -- テキスト編集を向上させるプラグイン
  -- emmet
  {
    'mattn/emmet-vim',
    lazy = true,
    keys = {
      { "<C-y><C-y>", "<plug>(emmet-expand-abbr)", mode = "i", desc = "Expand Abbreviation" },
    }
  },
  {
    'kylechui/nvim-surround',
    enabled = true,
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

  -- Easy motion
  {
    'easymotion/vim-easymotion',
    event = "BufEnter",
    init = function()
      vim.g.EasyMotion_smartcase = 1
    end,
    keys = {
      { '<leader>/', '<Plug>(easymotion-sn)',        mode = { "n" },      desc = "EasyMotion search" },
      { '<leader>j', '<Plug>(easymotion-j)',         mode = { "n", "x" }, desc = "EasyMotion down" },
      { '<leader>k', '<Plug>(easymotion-k)',         mode = { "n", "x" }, desc = "EasyMotion up" },
      { '<leader>w', '<Plug>(easymotion-overwin-w)', mode = { "n" },      desc = "EasyMotion word" },
    }
  },

  -- Quick-scope（f/F移動を強化）
  {
    'unblevable/quick-scope',
    event = "BufEnter",
    init = function()
      vim.g.qs_lazy_highlight = 1
      vim.g.qs_hi_priority = 2
    end,
    config = function()
      -- VSCode環境で動作するための明示的なハイライト設定
      vim.api.nvim_set_hl(0, 'QuickScopePrimary', {
        fg = '#afff5f',
        underline = true,
        ctermfg = 155,
        cterm = { underline = true }
      })
      vim.api.nvim_set_hl(0, 'QuickScopeSecondary', {
        fg = '#5fffff',
        underline = true,
        ctermfg = 81,
        cterm = { underline = true }
      })
    end
  },

  -- visual modeの範囲選択を簡単に
  {
    'terryma/vim-expand-region',
    event = "BufEnter",
    keys = {
      { "v", "<Plug>(expand_region_expand)", mode = "x", desc = "Expand region" },
    },
  },

  -- 行末空白の表示
  {
    'bronson/vim-trailing-whitespace',
    event = 'BufEnter',
    init = function()
      vim.g.extra_whitespace_ignored_filetypes = nil
    end,
  },

  -- 指定ワードをハイライト
  {
    't9md/vim-quickhl',
    lazy = true,
    keys = {
      { "<space>m", "<Plug>(quickhl-manual-this)",  mode = { "n", "x" }, desc = "Highlight word/selection" },
      { "<space>M", "<Plug>(quickhl-manual-reset)", mode = { "n", "x" }, desc = "Clear all highlights" },
    }
  },

  -- テキスト整列
  {
    'junegunn/vim-easy-align',
    keys = {
      { "ea", "<Plug>(EasyAlign)", mode = "x", desc = "Align text (visual)" },
      { "ea", "<Plug>(EasyAlign)", mode = "n", desc = "Align text (normal)" },
    }
  },
}
