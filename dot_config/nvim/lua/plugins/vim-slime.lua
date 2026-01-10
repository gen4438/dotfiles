return {
  -- tmuxに行を送る
  {
    'jpalardy/vim-slime',
    branch = 'main',
    lazy = true,
    event = {
      'TermOpen',
    },
    cmd = {
      'SlimeConfig',
      'SlimeConfigTmux',
      'SlimeConfigNeovim',
      'SlimeSendCurrentLine',
      'SlimeSend',
      'SlimeSend1',
      'SlimeSend0',
    },
    keys = {
      { '<space>sct', ':SlimeConfigTmux<CR>',                           mode = 'n', noremap = true },
      { '<space>scn', ':SlimeConfigNeovim<CR>',                         mode = 'n', noremap = true },
      { '<space>l',   ':SlimeSendCurrentLine<CR>',                      mode = 'n', noremap = true },
      { '<space>p',   'mzvip :SlimeSend<CR>:SlimeSend0 "\\n\\n"<CR>`z', mode = 'n', noremap = true },
      { '<space>p',   ':SlimeSend<CR>:SlimeSend0 "\\n\\n"<CR>',         mode = 'x', noremap = true },
      { '<space>cd',  ':SlimeSend0 "cd ".getcwd()."\\n"<CR>',           mode = 'n', noremap = true },
      '<space>00',
      '<space>a',
      '<space>i',
      '<space>e',
      'y<space>e',
    },

    init = function()
      -- these two should be set before the plugin loads
      vim.g.slime_target = "tmux"
      -- vim.g.slime_target = "neovim"
      vim.g.slime_no_mappings = true

      -- ipython の設定
      vim.api.nvim_create_augroup("vimSlime", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "python", "ipynb" },
        callback = function()
          -- vim.b.slime_python_ipython = 1
          vim.b.slime_bracketed_paste = 1
        end,
      })
      vim.api.nvim_create_autocmd("BufEnter", {
        -- ipynb はファイル自体は json だったりするのでBufEnterで設定
        pattern = { "*.py", "*.ipynb" },
        callback = function()
          -- vim.b.slime_python_ipython = 1
          vim.b.slime_bracketed_paste = 1
        end,
      })
    end,

    config = function()
      vim.g.slime_paste_file = vim.fn.tempname()
      vim.g.slime_dont_ask_default = true

      -- 送信先を tmux に設定
      local function SlimeConfigTmux()
        if vim.g.slime_target ~= "tmux" and vim.b.slime_config then
          vim.b.slime_config = nil
        end
        vim.g.slime_target = "tmux"
        vim.g.slime_default_config = { socket_name = vim.split(vim.env.TMUX, ",")[1], target_pane = ":.+1" }
        if not vim.b.slime_config or (vim.b.slime_config.socket_name == "" and vim.b.slime_config.target_pane == "") then
          vim.b.slime_config = vim.g.slime_default_config
        end
      end

      vim.api.nvim_create_user_command("SlimeConfigTmux", function()
        SlimeConfigTmux()
        vim.cmd("SlimeConfig")
      end, {})

      -- ウィンドウが開かれたときにチャンネルを設定
      vim.api.nvim_create_augroup("nvim_slime", { clear = true })

      vim.api.nvim_create_autocmd("TermOpen", {
        group = "nvim_slime",
        pattern = "*",
        callback = function()
          vim.g.slime_last_channel = { { jobid = vim.o.channel } }
        end,
      })

      -- 送信先を neovim に設定
      local function SlimeConfigNeovim()
        if vim.g.slime_target ~= "neovim" and vim.b.slime_config then
          vim.b.slime_config = nil
        end

        vim.g.slime_target = "neovim"
        vim.g.slime_input_pid = false
        vim.g.slime_suggest_default = true
        vim.g.slime_menu_config = false
        vim.g.slime_neovim_ignore_unlisted = false
        vim.g.slime_get_jobid = false

        vim.g.slime_default_config = { jobid = vim.g.slime_last_channel }
        if not vim.b.slime_config or vim.b.slime_config.jobid == "" then
          vim.b.slime_config = vim.g.slime_default_config
        end
      end

      vim.api.nvim_create_user_command("SlimeConfigNeovim", function()
        SlimeConfigNeovim()
        vim.cmd("SlimeConfig")
      end, {})

      if vim.env.TMUX then
        SlimeConfigTmux()
      else
        SlimeConfigNeovim()
      end

      vim.api.nvim_create_augroup("vimSlimeCommand", { clear = true })

      -- ファイルタイプごとにキーマップを設定
      -- キーマップ設定関数
      local function set_keymaps()
        -- REPL を起動
        vim.api.nvim_set_keymap('n', '<Space>i', ':lua handle_keymap_space_i()<CR>', { noremap = true })
        -- REPL を再起動
        vim.api.nvim_set_keymap('n', '<Space>00', ':lua handle_keymap_space_00()<CR>', { noremap = true })
        -- ipython リロード
        vim.api.nvim_set_keymap('n', '<Space>a', ':lua handle_keymap_space_a()<CR>', { noremap = true })
        -- スクリプト実行
        vim.api.nvim_set_keymap('n', '<Space>e', ':lua handle_keymap_space_e()<CR>', { noremap = true })
        -- スクリプト実行コマンドをヤンク
        vim.api.nvim_set_keymap('n', 'y<Space>e', ':lua handle_keymap_space_e_yank()<CR>', { noremap = true })
      end

      -- キーマップ実行時の処理関数
      function handle_keymap_space_i()
        local filetype = vim.bo.filetype
        if filetype == "python" or filetype == "ipynb" then
          -- vim.cmd('SlimeSend0 "\\x15ipython\\n"')
          vim.cmd([[SlimeSend0 "\e[201~\x15\e[200~"]]) -- ctrl-u to clear the line
          vim.cmd('SlimeSend0 "ipython\\n"')
          vim.cmd('SlimeSend0 "%load_ext autoreload\\n"')
        elseif filetype == "javascript" or filetype == "javascriptreact" or filetype == "typescript" or filetype == "typescriptreact" then
          vim.cmd('SlimeSend0 "\\x15node\\n"')
        elseif filetype == "go" then
          vim.cmd('SlimeSend0 "\\x15gore\\n"')
        end
      end

      function handle_keymap_space_00()
        local filetype = vim.bo.filetype
        if filetype == "python" or filetype == "ipynb" then
          vim.cmd([[SlimeSend0 "\e[201~\x15\e[200~"]]) -- ctrl-u to clear the line
          vim.cmd('SlimeSend0 "exit\\n"')
          vim.cmd('SlimeSend0 "ipython\\n"')
          vim.cmd('SlimeSend0 "%load_ext autoreload\\n"')
        elseif filetype == "javascript" or filetype == "javascriptreact" or filetype == "typescript" or filetype == "typescriptreact" then
          vim.cmd('SlimeSend0 "\\x15.exit\\n"')
          vim.cmd('SlimeSend0 "node\\n"')
        elseif filetype == "go" then
          vim.cmd('SlimeSend0 "\\x15\\x04\\n"')
          vim.cmd('SlimeSend0 "gore\\n"')
        end
      end

      function handle_keymap_space_a()
        local filetype = vim.bo.filetype
        if filetype == "python" or filetype == "ipynb" then
          vim.cmd([[SlimeSend0 "\e[201~\x15\e[200~"]]) -- ctrl-u to clear the line
          vim.cmd('SlimeSend0 "%autoreload\\n"')
        end
      end

      -- コマンド生成関数
      local function get_command_for_space_e()
        local filetype = vim.bo.filetype
        local cmd = ""

        if filetype == "ruby" then
          cmd = 'clear; ruby ' .. vim.fn.bufname("%")
        elseif filetype == "python" then
          cmd = 'clear; python ' .. vim.fn.bufname("%")
        elseif filetype == "perl" then
          cmd = 'clear; perl ' .. vim.fn.bufname("%")
        elseif filetype == "html" then
          cmd = 'clear; google-chrome ' .. vim.fn.bufname("%")
        elseif filetype == "javascript" then
          cmd = 'clear; node ' .. vim.fn.bufname("%")
        elseif filetype == "typescript" then
          cmd = 'clear; ts-node ' .. vim.fn.bufname("%")
        elseif filetype == "markdown" then
          cmd = 'clear; md-to-pdf ' .. vim.fn.bufname("%")
        elseif filetype == "go" then
          cmd = 'clear; go run ' .. vim.fn.bufname("%")
        elseif filetype == "rust" then
          cmd = 'clear; cargo run'
        end

        return cmd
      end

      -- キーマップ実行時の処理関数
      function handle_keymap_space_e()
        local filetype = vim.bo.filetype
        local cmd = get_command_for_space_e()

        if cmd ~= "" and (filetype == "python" or filetype == "ipynb") then
          -- python
          vim.cmd([[SlimeSend0 "\e[201~\x15\e[200~"]]) -- ctrl-u to clear the line
          vim.cmd('SlimeSend0 "' .. cmd .. '\\n"')
        elseif cmd ~= "" then
          -- python 以外
          vim.cmd('SlimeSend0 "\\x15' .. cmd .. '\\n"')
        end
      end

      -- スクリプト実行コマンドをヤンク
      function handle_keymap_space_e_yank()
        local cmd = get_command_for_space_e()

        if cmd ~= "" then
          -- コマンドを無名レジスタにヤンク
          vim.fn.setreg('"', cmd)
          -- + レジスタ（システムクリップボード）にもコピー
          vim.fn.setreg('+', cmd)
          print('Yanked: ' .. cmd)
        else
          print('No command for this filetype')
        end
      end

      -- 初期化時にキーマップを設定
      set_keymaps()
    end
  },
  -- vim-slime と ipython の連携
  {
    'hanschen/vim-ipython-cell',
    lazy = true,
    enabled = false,
  },

}
