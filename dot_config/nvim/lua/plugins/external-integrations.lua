-- 外部ツール連携
return {
  -- grep
  {
    'mhinz/vim-grepper',
    lazy = true,
    enabled = true,
    cmd = {
      "Grepper",
    },
    init = function()
      vim.g.grepper = {
        prompt_quote = 0,
        highlight = 1,
        operator = {
          prompt = 1,
        }
      }
    end,
    keys = {
      { "<leader>ff", ":Grepper -cword<cr>",     mode = "n" },
      -- TODO: query に space が含まれてしまう
      -- TODO: blockwise visual mode で選択した場合にもうまく動かない
      -- 違うプラグインを探した方が良いかも
      { "<leader>fg", "<plug>(GrepperOperator)", mode = "x" },
    },
  },
  {
    'vim-scripts/grep.vim',
    lazy = true,
    enabled = false,
    cmd = {
      "Rgrep",
    },
    init = function()
      vim.g.Grep_Default_Options = '-iIR'
      vim.g.Grep_Skip_Files = '*.log *.db'
      vim.g.Grep_Skip_Dirs = '.git node_modules'
    end,
    keys = {
      { "<leader>f", ":Rgrep<CR>", mode = "n" },
    }
  },

  -- vim内の文字列をブラウザで開く
  {
    'tyru/open-browser.vim',
    lazy = true,
    keys = {
      { "<leader>gf", "<Plug>(openbrowser-smart-search)", mode = "n" },
      { "<leader>gf", "<Plug>(openbrowser-smart-search)", mode = "v" },
    }
  },

  -- vim内の文字列をgoogle翻訳
  -- translate-shell が必要
  { 'VincentCordobes/vim-translate',        lazy = true },

  -- DB
  {
    'tpope/vim-dadbod',
    lazy = true,
    cmd = "DB",
  },

  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      'tpope/vim-dadbod',
      'kristijanhusak/vim-dadbod-completion',
    },
    lazy = true,
    cmd = {
      'DBUI',
      'DBUIToggle',
      'DBUIAddConnection',
      'DBUIFindBuffer',
    },
    init = function()
      -- Your DBUI configuration
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },
  { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },

  -- .envの読み込み
  {
    'tpope/vim-dotenv',
    lazy = true,
    cmd = {
      "Dotenv"
    },
  },
}
