-- エディタの機能を拡張するプラグイン
return {
  -- undoの履歴表示
  {
    'mbbill/undotree',
    lazy = true,
    enabled = false,
    cmd = {
      "UndotreeToggle",
    },
    keys = {
      { "<c-e><c-u>", "<cmd>UndotreeToggle<CR>" },
    }
  },
  {
    "jiaoshijie/undotree",
    name = "undotree-lua",
    lazy = true,
    -- dependencies = "nvim-lua/plenary.nvim",
    config = true,
    keys = { -- load the plugin only when using it's keybinding:
      { "<c-e><c-u>", "<cmd>lua require('undotree').toggle()<cr>" },
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
      { '*',  '<Plug>(asterisk-z*)',  mode = { "n", "x" } },
      { '#',  '<Plug>(asterisk-z#)',  mode = { "n", "x" } },
      { 'g*', '<Plug>(asterisk-gz*)', mode = { "n", "x" } },
      { 'g#', '<Plug>(asterisk-gz#)', mode = { "n", "x" } },
    }
  },
  -- 検索数の表示
  {
    'osyo-manga/vim-anzu',
    lazy = true,
    keys = {
      { "n", "<Plug>(anzu-n-with-echo)" },
      { "N", "<Plug>(anzu-N-with-echo)" },
    },
    config = function()
      vim.o.statusline = '%{anzu#search_status()}'
    end
  },

  -- 移動
  {
    'easymotion/vim-easymotion',
    lazy = true,
    config = function()
      -- EasyMotionの設定
      vim.g.EasyMotion_smartcase = 1
    end,
    keys = {
      { '<leader><leader>s', '<Plug>(easymotion-sn)',        mode = { "n" } },
      { '<leader>j',         '<Plug>(easymotion-j)',         mode = { "n", "x" } },
      { '<leader>k',         '<Plug>(easymotion-k)',         mode = { "n", "x" } },
      { '<leader>w',         '<Plug>(easymotion-overwin-w)', mode = { "n" } },
    }
  },
  {
    'unblevable/quick-scope',
    lazy = true,
    -- let g:qs_lazy_highlight = 1
    -- let g:qs_hi_priority = 2
    -- autocmd ColorScheme * highlight QuickScopePrimary guifg='#afff5f' gui=underline ctermfg=155 cterm=underline
    -- autocmd ColorScheme * highlight QuickScopeSecondary guifg='#5fffff' gui=underline ctermfg=81 cterm=underline
    event = "BufEnter",
    config = function()
      vim.g.qs_lazy_highlight = 1
      vim.g.qs_hi_priority = 2

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
      -- " session management
      { "<leader>so", ":SessionManager load_current_dir_session<CR>", mode = "n" },
      { "<leader>sf", ":SessionManager load_session<CR>",             mode = "n" },
      { "<leader>ss", ":SessionManager save_current_session<CR>",     mode = "n" },
      { "<leader>sd", ":SessionManager delete_session<CR>",           mode = "n" },
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
      { "v", "<Plug>(expand_region_expand)", mode = "x" },
      -- { "<C-v>", "<Plug>(expand_region_shrink)", mode = "x" },
    },

  },

  -- 指定文字での整列
  {
    'junegunn/vim-easy-align',
    lazy = true,
    keys = {
      { "ea", "<Plug>(EasyAlign)", mode = "x" },
      { "ea", "<Plug>(EasyAlign)", mode = "n" },
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
      { "so", ":MaximizerToggle<CR>",   mode = "n" },
      { "so", ":MaximizerToggle<CR>gv", mode = "v" },
    }
  },

  -- 矩形選択に対して:<range>!<filter>を実行
  {
    'vim-scripts/vis',
    lazy = true,
    cmd = {
      "B",
      "S",
    }
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
      { "<localleader>ld", ":Linediff<CR>", mode = { "n", "x" } }
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
      { "<leader>cc", ":BD<CR>" },
    }
  },

  -- Abbreviation + Substitution + Coercion
  {
    'tpope/vim-abolish',
    lazy = true,
    keys = {
      -- crm        (MixedCase)
      -- crc        (camelCase)
      -- crs        (snake_case)
      -- cru        (UPPER_CASE)
      -- cr-        (dash-case)
      -- cr.        (dot.case)
      -- cr<space>  (space case)
      -- crt        (and Title Case)
    }
  },

  -- テンプレート
  {
    'mattn/vim-sonictemplate',
    lazy = true,
    command = function()
      vim.g.sonictemplate_vim_template_dir = vim.fn.stdpath('config') .. '/sonictemplate'
    end,
    cmd = {
      "SonicTemplate",
    }
  },

  -- vimのコマンドの実行結果をバッファに出力
  {
    'vim-scripts/ViewOutput',
    lazy = true,
    cmd = {
      "VO",
    }
  },

  -- 行末の空白を強調
  {
    'bronson/vim-trailing-whitespace',
    lazy = true,
    event = 'BufEnter',
    init = function()
      vim.g.extra_whitespace_ignored_filetypes = nil
    end,
    cmd = {
      "FixWhitespace",
    }
  },

  -- 指定ワードをハイライト
  {
    't9md/vim-quickhl',
    lazy = true,
    keys = {
      { "<space>m", "<Plug>(quickhl-manual-this)",  mode = { "n", "x" } },
      { "<space>M", "<Plug>(quickhl-manual-reset)", mode = { "n", "x" } },
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
      { "<c-c><c-p>", ":CccPick<cr>",              mode = "n" },
      { "<c-c><c-p>", "<Plug>(ccc-insert)",        mode = "i" },
      { "<c-c><c-p>", "<Plug>(ccc-select-color)",  mode = "x" },
      { "<c-c><c-c>", ":CccHighlighterToggle<cr>", mode = "n" },
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
