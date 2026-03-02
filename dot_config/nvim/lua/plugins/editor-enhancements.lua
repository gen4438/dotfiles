-- エディタの機能を拡張するプラグイン
return {
  -- Undo history tree
  {
    "jiaoshijie/undotree",
    name = "undotree-lua",
    lazy = true,
    config = true,
    keys = {
      { "<c-e><c-u>", "<cmd>lua require('undotree').toggle()<cr>", desc = "Toggle undo tree" },
    },
  },
  {
    "folke/which-key.nvim",
    lazy = true,
    event = "VeryLazy",
    opts = {
      preset = "modern",
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    }
  },

  -- * による検索を便利に
  {
    'haya14busa/vim-asterisk',
    lazy = true,
    config = function()
      -- To enable keepCursor feature:
      vim.g['asterisk#keeppos'] = 1
    end,
    keys = {
      { '*',  '<Plug>(asterisk-z*)',  mode = { "n", "x" }, desc = "Search forward (keep cursor)" },
      { '#',  '<Plug>(asterisk-z#)',  mode = { "n", "x" }, desc = "Search backward (keep cursor)" },
      { 'g*', '<Plug>(asterisk-gz*)', mode = { "n", "x" }, desc = "Search forward partial" },
      { 'g#', '<Plug>(asterisk-gz#)', mode = { "n", "x" }, desc = "Search backward partial" },
    }
  },
  -- Search count display
  {
    'osyo-manga/vim-anzu',
    lazy = true,
    keys = {
      { "n", "<Plug>(anzu-n-with-echo)", desc = "Next search result" },
      { "N", "<Plug>(anzu-N-with-echo)", desc = "Previous search result" },
    },
    config = function()
      vim.o.statusline = '%{anzu#search_status()}'
    end
  },

  -- Easy motion
  {
    'easymotion/vim-easymotion',
    lazy = true,
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
  -- Quick scope: highlight unique characters for f/F/t/T movement
  {
    'unblevable/quick-scope',
    event = "BufEnter",
    init = function()
      vim.g.qs_lazy_highlight = 1
      vim.g.qs_hi_priority = 2
    end,
    config = function()
      local qsg = vim.api.nvim_create_augroup('quick-scope', { clear = true })
      vim.api.nvim_create_autocmd('ColorScheme', {
        pattern = "*",
        group = qsg,
        command = "highlight QuickScopePrimary guifg='#afff5f' gui=underline ctermfg=155 cterm=underline",
      })
      vim.api.nvim_create_autocmd('ColorScheme', {
        pattern = "*",
        group = qsg,
        command = "highlight QuickScopeSecondary guifg='#5fffff' gui=underline ctermfg=81 cterm=underline",
      })
    end
  },

  -- session management
  {
    'Shatur/neovim-session-manager',
    lazy = true,
    -- event = 'VimEnter',
    -- dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { "<leader>so", ":SessionManager load_current_dir_session<CR>", mode = "n", desc = "Load current dir session" },
      { "<leader>sf", ":SessionManager load_session<CR>",             mode = "n", desc = "Load session" },
      { "<leader>ss", ":SessionManager save_current_session<CR>",     mode = "n", desc = "Save current session" },
      { "<leader>sd", ":SessionManager delete_session<CR>",           mode = "n", desc = "Delete session" },
    },
    opts = function()
      local Path = require('plenary.path')
      local config = require('session_manager.config')
      return {
        sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'), -- The directory where the session files will be saved.
        session_filename_to_dir = session_filename_to_dir,           -- Function that replaces symbols into separators and colons to transform filename into a session directory.
        dir_to_session_filename = dir_to_session_filename,           -- Function that replaces separators and colons into special symbols to transform session directory into a filename. Should use `vim.uv.cwd()` if the passed `dir` is `nil`.
        autoload_mode = config.AutoloadMode.Disabled,                -- Define what to do when Neovim is started without arguments. See "Autoload mode" section below. (Disabled, CurrentDir, LastSession, GitSession)
        autosave_last_session = true,                                -- Automatically save last session on exit and on session switch.
        autosave_ignore_not_normal = true,                           -- Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed.
        autosave_ignore_dirs = {},                                   -- A list of directories where the session will not be autosaved.
        autosave_ignore_filetypes = {                                -- All buffers of these file types will be closed before the session is saved.
          'gitcommit',
          'gitrebase',
        },
        autosave_ignore_buftypes = { "nowrite" }, -- All buffers of these bufer types will be closed before the session is saved.
        autosave_only_in_session = false,         -- Always autosaves session. If true, only autosaves after a session is active.
        max_path_length = 256,                    -- Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all.
      }
    end
  },

  -- visual modeの範囲選択を簡単に
  {
    'terryma/vim-expand-region',
    lazy = true,
    event = "BufEnter",
    keys = {
      { "v", "<Plug>(expand_region_expand)", mode = "x", desc = "Expand region" },
    },

  },

  -- 指定文字での整列
  {
    'junegunn/vim-easy-align',
    lazy = true,
    keys = {
      { "ea", "<Plug>(EasyAlign)", mode = "x", desc = "Align text (visual)" },
      { "ea", "<Plug>(EasyAlign)", mode = "n", desc = "Align text (normal)" },
    }
  },

  -- テーブル整形
  {
    'dhruvasagar/vim-table-mode',
    lazy = true,
    keys = {
      "<leader>tm",
      "<leader>tt",
    }
  },

  -- 分割の最大化・リストア
  {
    'szw/vim-maximizer',
    lazy = true,
    init = function()
      vim.g.maximizer_set_default_mapping = 0
    end,
    keys = {
      { "so", ":MaximizerToggle<CR>",   mode = "n", desc = "Toggle window maximize" },
      { "so", ":MaximizerToggle<CR>gv", mode = "v", desc = "Toggle window maximize (restore visual)" },
    }
  },

  -- 矩形選択に対して:<range>!<filter>を実行
  {
    'vim-scripts/vis',
    lazy = true,
    cmd = { "B", "S" },
  },

  -- 一時ファイル作成
  {
    'Shougo/junkfile.vim',
    lazy = true,
    cmd = { "JunkfileOpen" },
    config = function()
      vim.api.nvim_create_user_command(
        'JunkfileOpen',
        function(opts)
          local args = opts.args or ''
          vim.fn['junkfile#open'](os.date('%Y-%m-%d-%H%M%S.') .. args)
        end,
        { nargs = '?' }
      )
    end
  },

  -- ファイル内での別位置の行を始点としたdiff
  {
    'AndrewRadev/linediff.vim',
    lazy = true,
    cmd = {
      "Linediff",
    },
    keys = {
      { "<localleader>ld", ":Linediff<CR>", mode = { "n", "x" }, desc = "Compare lines/selection" }
    }
  },

  -- 矢印キーで線を引ける
  {
    'vim-scripts/DrawIt',
    lazy = true,
    cmd = {
      "DrawItStart",
      "DrawItStop",
    },
    -- keys = {
    --   { '<leader>di', '<Plug>DrawItStart', mode = 'n' },
    --   { '<leader>ds', '<Plug>DrawItStop',  mode = 'n' },
    -- }
  },

  -- ウィンドウを閉じずにbuffer削除
  {
    'qpkorr/vim-bufkill',
    lazy = true,
    event = 'BufEnter',
    init = function()
      vim.g.BufKillCreateMappings = 0
      vim.g.BufKillActionWhenBufferDisplayedInAnotherWindow = 'kill'
    end,
    keys = {
      { "<leader>cc", ":BD<CR>", mode = "n", desc = "Delete buffer (keep window)" },
    }
  },

  -- Abbreviation + Substitution + Coercion
  {
    'tpope/vim-abolish',
    lazy = true,
    event = { "BufReadPost", "BufNewFile" },
    -- Uses built-in coercion mappings:
    -- crm        (MixedCase)
    -- crc        (camelCase)
    -- crs        (snake_case)
    -- cru        (UPPER_CASE)
    -- cr-        (dash-case)
    -- cr.        (dot.case)
    -- cr<space>  (space case)
    -- crt        (Title Case)
  },

  -- テンプレート
  {
    'mattn/vim-sonictemplate',
    lazy = true,
    init = function()
      vim.g.sonictemplate_vim_template_dir = vim.fn.stdpath('config') .. '/sonictemplate'
    end,
    cmd = { "SonicTemplate" },
  },

  -- vimのコマンドの実行結果をバッファに出力
  {
    'vim-scripts/ViewOutput',
    lazy = true,
    cmd = { "VO" },
  },

  -- 行末の空白を強調
  {
    'bronson/vim-trailing-whitespace',
    lazy = true,
    event = 'BufEnter',
    init = function()
      vim.g.extra_whitespace_ignored_filetypes = nil
    end,
    cmd = { "FixWhitespace" },
  },

  -- 指定ワードをハイライト
  {
    't9md/vim-quickhl',
    lazy = true,
    keys = {
      { "<space>h", "<Plug>(quickhl-manual-this)",  mode = { "n", "x" }, desc = "Highlight word/selection" },
      { "<space>H", "<Plug>(quickhl-manual-reset)", mode = { "n", "x" }, desc = "Clear all highlights" },
    }
  },

  -- -- display chunks
  -- {
  --   "shellRaining/hlchunk.nvim",
  --   -- lazy = true,
  --   event = { "BufReadPre", "BufNewFile" },
  --   dependencies = { "nvim-treesitter/nvim-treesitter" },
  --   opts = {
  --     chunk = {
  --       enable = true,
  --     }
  --   }
  -- },

  -- -- カラーコードに色付け
  -- {
  --   'norcalli/nvim-colorizer.lua',
  --   lazy = true,
  --   enabled = false,
  --   cmd = 'ColorizerToggle',
  --   keys = {
  --     { "<c-c><c-c>", ":ColorizerToggle<CR>" },
  --   }
  -- },

  -- カラーピッカー
  {
    'uga-rosa/ccc.nvim',
    lazy = true,
    init = function()
      vim.opt.termguicolors = true
    end,
    opts = {
    },
    cmd = {
      "CccPick",
      "CccHighlighterToggle",
    },
    keys = {
      { "<c-c><c-p>", ":CccPick<cr>",              mode = "n", desc = "Color picker" },
      { "<c-c><c-p>", "<Plug>(ccc-insert)",        mode = "i", desc = "Insert color" },
      { "<c-c><c-p>", "<Plug>(ccc-select-color)",  mode = "x", desc = "Select color" },
      { "<c-c><c-c>", ":CccHighlighterToggle<cr>", mode = "n", desc = "Toggle color highlighter" },
    }
  },

  {
    'anuvyklack/help-vsplit.nvim',
    opts = {
      always = true,  -- Always open help in a vertical split.
      side = 'right', -- 'left' or 'right'
      buftype = { 'help' },
      filetype = { 'man' }
    }
  }
}
