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
      { '<space>l',   mode = 'n' },
      { '<space>p',   mode = { 'n', 'x' } },
      { '<space>cd',  ':SlimeSend0 "cd ".getcwd()."\\n"<CR>',           mode = 'n', noremap = true },
      '<space>ss',
      '<space>si',
      '<space>r',
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
      local group = vim.api.nvim_create_augroup("vimSlime", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = { "python", "ipynb" },
        callback = function()
          -- vim.b.slime_python_ipython = 1
          vim.b.slime_bracketed_paste = 1
        end,
      })
      vim.api.nvim_create_autocmd("BufEnter", {
        -- ipynb はファイル自体は json だったりするのでBufEnterで設定
        group = group,
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

      --------------------------------------------------------------------------
      -- ターミナルチャンネルの追跡
      --------------------------------------------------------------------------

      -- チャンネルを重複なしで記録する
      local function add_terminal_channel(jobid)
        if type(jobid) ~= "number" or jobid <= 0 then
          return
        end
        local channels = vim.g.slime_last_channel or {}
        for _, ch in ipairs(channels) do
          if ch.jobid == jobid then
            return
          end
        end
        table.insert(channels, { jobid = jobid })
        vim.g.slime_last_channel = channels
        -- neovim ターゲット使用中は最新のターミナルをデフォルト送信先にする
        if vim.g.slime_target == "neovim" then
          vim.g.slime_default_config = { jobid = jobid }
        end
      end

      -- 閉じたターミナルのチャンネルを削除する
      local function remove_terminal_channel(jobid)
        local channels = vim.g.slime_last_channel or {}
        local kept = {}
        for _, ch in ipairs(channels) do
          if ch.jobid ~= jobid then
            table.insert(kept, ch)
          end
        end
        vim.g.slime_last_channel = kept
      end

      local group = vim.api.nvim_create_augroup("nvim_slime", { clear = true })

      vim.api.nvim_create_autocmd("TermOpen", {
        group = group,
        pattern = "*",
        callback = function(ev)
          add_terminal_channel(vim.bo[ev.buf].channel)
        end,
      })

      vim.api.nvim_create_autocmd("TermClose", {
        group = group,
        pattern = "*",
        callback = function(ev)
          remove_terminal_channel(vim.bo[ev.buf].channel)
        end,
      })

      -- プラグイン自体が TermOpen で遅延ロードされるため、
      -- ロード時点で既に開いているターミナルもここで登録する
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "terminal" then
          add_terminal_channel(vim.bo[buf].channel)
        end
      end

      --------------------------------------------------------------------------
      -- tmux / neovim ターゲット設定
      --------------------------------------------------------------------------

      -- 送信先を tmux に設定
      local function SlimeConfigTmux()
        local tmux = vim.env.TMUX
        if not tmux or tmux == "" then
          vim.notify("vim-slime: $TMUX が未設定のため tmux ターゲットを設定できません", vim.log.levels.WARN)
          return false
        end
        -- 別ターゲット用の設定が残っていたら破棄
        if vim.g.slime_target ~= "tmux" and vim.b.slime_config then
          vim.b.slime_config = nil
        end
        vim.g.slime_target = "tmux"
        vim.g.slime_default_config = { socket_name = vim.split(tmux, ",")[1], target_pane = ":.+1" }
        local cfg = vim.b.slime_config
        if not cfg or not cfg.target_pane or cfg.target_pane == "" then
          vim.b.slime_config = vim.g.slime_default_config
        end
        return true
      end

      vim.api.nvim_create_user_command("SlimeConfigTmux", function()
        if SlimeConfigTmux() then
          vim.cmd("SlimeConfig")
        end
      end, {})

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

        -- jobid には数値を渡す (リストを渡すと chansend が失敗する)
        local channels = vim.g.slime_last_channel or {}
        local last = channels[#channels]
        if last and last.jobid then
          vim.g.slime_default_config = { jobid = last.jobid }
        else
          vim.g.slime_default_config = nil
        end

        local cfg = vim.b.slime_config
        if (not cfg or not cfg.jobid or cfg.jobid == "") and vim.g.slime_default_config then
          vim.b.slime_config = vim.g.slime_default_config
        end
        return true
      end

      vim.api.nvim_create_user_command("SlimeConfigNeovim", function()
        if SlimeConfigNeovim() then
          vim.cmd("SlimeConfig")
        end
      end, {})

      if vim.env.TMUX then
        SlimeConfigTmux()
      else
        SlimeConfigNeovim()
      end

      --------------------------------------------------------------------------
      -- ファイルタイプ別キーマップ
      --------------------------------------------------------------------------

      local ESC = "\27"
      local CTRL_U = "\21" -- 行をクリア
      local CTRL_D = "\4"
      -- bracketed paste を閉じてから行をクリアし、開き直す
      local CLEAR_LINE = ESC .. "[201~" .. CTRL_U .. ESC .. "[200~"

      -- SlimeSend0 の文字列組み立てを介さず直接送信する
      -- (ファイル名などのエスケープ問題を避ける)
      local function slime_send(text)
        local ok, err = pcall(vim.fn["slime#send"], text)
        if not ok then
          vim.notify("vim-slime: 送信に失敗しました: " .. tostring(err), vim.log.levels.ERROR)
        end
      end

      -- カウント付きで送信先を一時的に切り替えて fn を実行する
      -- 例: 2<space>l → tmux なら +2 のペイン、neovim なら 2 番目のターミナルに送信
      -- 送信後は元の設定に戻るため、b:slime_config は変更されない
      -- count は :normal! の実行で v:count がリセットされる前に
      -- 呼び出し元でキャプチャして渡せる (省略時は v:count を読む)
      local function with_count_target(fn, count)
        count = count or vim.v.count
        if count == 0 then
          return fn()
        end
        local saved = vim.b.slime_config
        if vim.g.slime_target == "tmux" then
          local tmux = vim.env.TMUX
          if not tmux or tmux == "" then
            vim.notify("vim-slime: $TMUX が未設定です", vim.log.levels.WARN)
            return
          end
          vim.b.slime_config = { socket_name = vim.split(tmux, ",")[1], target_pane = ":.+" .. count }
        else
          local channels = vim.g.slime_last_channel or {}
          local ch = channels[count]
          if not ch then
            vim.notify(string.format("vim-slime: %d 番目のターミナルがありません", count), vim.log.levels.WARN)
            return
          end
          vim.b.slime_config = { jobid = ch.jobid }
        end
        local ok, err = pcall(fn)
        vim.b.slime_config = saved
        if not ok then
          vim.notify("vim-slime: 送信に失敗しました: " .. tostring(err), vim.log.levels.ERROR)
        end
      end

      -- 直前送信の再送用 (<space>r で再実行するクロージャを保持)
      local last_send = nil

      -- 現在行を送信
      local function send_current_line()
        local text = vim.fn.getline(".") .. "\n"
        local send = function()
          slime_send(text)
        end
        last_send = send
        with_count_target(send)
      end

      -- '< から '> までの行を送信するクロージャを作る
      local function make_range_sender()
        local lines = vim.fn.getline(vim.fn.line("'<"), vim.fn.line("'>"))
        local text = table.concat(lines, "\n") .. "\n"
        return function()
          slime_send(text)
          slime_send("\n\n")
        end
      end

      -- 段落を送信 (ノーマルモード)
      local function send_paragraph()
        local count = vim.v.count
        local view = vim.fn.winsaveview()
        vim.cmd('silent normal! vip' .. ESC) -- '< '> マークを設定
        vim.fn.winrestview(view)
        local send = make_range_sender()
        last_send = send
        with_count_target(send, count)
      end

      -- 選択範囲を送信 (ビジュアルモード)
      local function send_selection()
        local count = vim.v.count
        vim.cmd('silent normal! ' .. ESC) -- ビジュアルを抜けて '< '> を確定
        local send = make_range_sender()
        last_send = send
        with_count_target(send, count)
      end

      -- 直前の送信を再送 (カウント併用可: 2<space>r → +2 ペインへ再送)
      local function resend_last()
        if not last_send then
          vim.notify("vim-slime: 再送する送信履歴がありません", vim.log.levels.WARN)
          return
        end
        with_count_target(last_send)
      end

      -- 送信先に Ctrl-C (割り込み) を送る
      local function send_interrupt()
        with_count_target(function()
          slime_send("\3")
        end)
      end

      -- 送信先ペイン / ターミナルを一覧から選択して b:slime_config に保存
      local function pick_target()
        if vim.g.slime_target == "tmux" then
          local tmux = vim.env.TMUX
          if not tmux or tmux == "" then
            vim.notify("vim-slime: $TMUX が未設定です", vim.log.levels.WARN)
            return
          end
          local panes = vim.fn.systemlist({
            "tmux", "list-panes", "-a", "-F",
            "#{pane_id}\t#{session_name}:#{window_index}.#{pane_index}\t#{pane_current_command}",
          })
          if vim.v.shell_error ~= 0 or #panes == 0 then
            vim.notify("vim-slime: ペイン一覧を取得できません", vim.log.levels.WARN)
            return
          end
          vim.ui.select(panes, {
            prompt = "送信先ペインを選択",
            format_item = function(line)
              return (line:gsub("\t", "  "))
            end,
          }, function(choice)
            if not choice then
              return
            end
            local pane_id = vim.split(choice, "\t")[1]
            vim.b.slime_config = { socket_name = vim.split(tmux, ",")[1], target_pane = pane_id }
            vim.notify("vim-slime: 送信先を " .. pane_id .. " に設定しました")
          end)
        else
          local channels = vim.g.slime_last_channel or {}
          if #channels == 0 then
            vim.notify("vim-slime: 送信先のターミナルがありません", vim.log.levels.WARN)
            return
          end
          local function label(ch)
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "terminal"
                  and vim.bo[buf].channel == ch.jobid then
                return string.format("%d: %s", ch.jobid, vim.api.nvim_buf_get_name(buf))
              end
            end
            return tostring(ch.jobid)
          end
          vim.ui.select(channels, {
            prompt = "送信先ターミナルを選択",
            format_item = label,
          }, function(choice)
            if not choice then
              return
            end
            vim.b.slime_config = { jobid = choice.jobid }
            vim.notify("vim-slime: 送信先を jobid " .. choice.jobid .. " に設定しました")
          end)
        end
      end

      local function is_python()
        local ft = vim.bo.filetype
        return ft == "python" or ft == "ipynb"
      end

      local function is_node()
        local ft = vim.bo.filetype
        return ft == "javascript" or ft == "javascriptreact"
            or ft == "typescript" or ft == "typescriptreact"
      end

      -- REPL を起動
      local function repl_start()
        if is_python() then
          slime_send(CLEAR_LINE)
          slime_send("ipython\n")
          slime_send("%load_ext autoreload\n")
        elseif is_node() then
          slime_send(CTRL_U .. "node\n")
        elseif vim.bo.filetype == "go" then
          slime_send(CTRL_U .. "gore\n")
        end
      end

      -- REPL を再起動
      local function repl_restart()
        if is_python() then
          slime_send(CLEAR_LINE)
          slime_send("exit\n")
          slime_send("ipython\n")
          slime_send("%load_ext autoreload\n")
        elseif is_node() then
          slime_send(CTRL_U .. ".exit\n")
          slime_send("node\n")
        elseif vim.bo.filetype == "go" then
          slime_send(CTRL_U .. CTRL_D .. "\n")
          slime_send("gore\n")
        end
      end

      -- ipython リロード
      local function ipython_autoreload()
        if is_python() then
          slime_send(CLEAR_LINE)
          slime_send("%autoreload\n")
        end
      end

      -- スクリプト実行コマンドの生成
      local runners = {
        ruby = "ruby",
        python = "python",
        perl = "perl",
        html = "google-chrome",
        javascript = "node",
        typescript = "ts-node",
        markdown = "md-to-pdf",
        go = "go run",
      }

      local function get_run_command()
        local ft = vim.bo.filetype
        if ft == "rust" then
          return "clear; cargo run"
        end
        local runner = runners[ft]
        if not runner then
          return ""
        end
        local file = vim.fn.bufname("%")
        if file == "" then
          return ""
        end
        return "clear; " .. runner .. " " .. vim.fn.shellescape(file)
      end

      -- スクリプト実行
      local function run_script()
        local cmd = get_run_command()
        if cmd == "" then
          return
        end
        local send = function()
          if is_python() then
            slime_send(CLEAR_LINE)
            slime_send(cmd .. "\n")
          else
            slime_send(CTRL_U .. cmd .. "\n")
          end
        end
        last_send = send
        with_count_target(send)
      end

      -- スクリプト実行コマンドをヤンク
      local function yank_run_command()
        local cmd = get_run_command()
        if cmd ~= "" then
          -- 無名レジスタと + レジスタ (システムクリップボード) にコピー
          vim.fn.setreg('"', cmd)
          vim.fn.setreg('+', cmd)
          vim.notify('Yanked: ' .. cmd)
        else
          vim.notify('No command for this filetype', vim.log.levels.WARN)
        end
      end

      vim.keymap.set('n', '<Space>l', send_current_line, { silent = true, desc = 'Slime: 現在行を送信 (N<Space>l で +N ペイン)' })
      vim.keymap.set('n', '<Space>p', send_paragraph, { silent = true, desc = 'Slime: 段落を送信 (N<Space>p で +N ペイン)' })
      vim.keymap.set('x', '<Space>p', send_selection, { silent = true, desc = 'Slime: 選択範囲を送信' })
      vim.keymap.set('n', '<Space>ss', pick_target, { silent = true, desc = 'Slime: 送信先を一覧から選択' })
      vim.keymap.set('n', '<Space>si', send_interrupt, { silent = true, desc = 'Slime: 割り込み (Ctrl-C) を送信' })
      vim.keymap.set('n', '<Space>r', resend_last, { silent = true, desc = 'Slime: 直前の送信を再送 (N<Space>r で +N ペイン)' })
      vim.keymap.set('n', '<Space>i', repl_start, { silent = true, desc = 'Slime: REPL を起動' })
      vim.keymap.set('n', '<Space>00', repl_restart, { silent = true, desc = 'Slime: REPL を再起動' })
      vim.keymap.set('n', '<Space>a', ipython_autoreload, { silent = true, desc = 'Slime: ipython autoreload' })
      vim.keymap.set('n', '<Space>e', run_script, { silent = true, desc = 'Slime: スクリプト実行 (N<Space>e で +N ペイン)' })
      vim.keymap.set('n', 'y<Space>e', yank_run_command, { silent = true, desc = 'Slime: 実行コマンドをヤンク' })
    end
  },
  -- vim-slime と ipython の連携
  {
    'hanschen/vim-ipython-cell',
    lazy = true,
    enabled = false,
  },

}
