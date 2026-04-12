return {
  -- psmux (Windows 版 tmux) のペインにコードを送る
  -- Linux 版 (plugins/vim-slime.lua) との差分:
  --   1. slime#common#system を psmux 対応版に上書き
  --      - neovim の &shell が MSYS2 bash だと psmux に接続不可のため pwsh 経由で実行
  --      - psmux の paste-buffer -t が外部プロセスから動作しないため send-keys -l で代替
  --   2. $TMUX_PANE から同ウィンドウ内の隣接ペインIDを自動検出
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
      vim.g.slime_target = "tmux"
      vim.g.slime_no_mappings = true

      -- ipython の設定
      vim.api.nvim_create_augroup("vimSlime", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "python", "ipynb" },
        callback = function()
          vim.b.slime_bracketed_paste = 1
        end,
      })
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = { "*.py", "*.ipynb" },
        callback = function()
          vim.b.slime_bracketed_paste = 1
        end,
      })
    end,

    config = function()
      vim.g.slime_paste_file = vim.fn.tempname()
      vim.g.slime_dont_ask_default = true

      --------------------------------------------------------------------------
      -- psmux 対応: slime#common#system の上書き
      --
      -- 背景:
      --   neovim の &shell は MSYS2 bash だが、MSYS2 のプロセス空間からは
      --   psmux サーバーに接続できない。また psmux は外部プロセスからの
      --   paste-buffer -t によるペイン指定送信をサポートしていない。
      --
      -- 解決:
      --   vim-slime の load-buffer/paste-buffer パイプラインを
      --   send-keys -l (リテラル送信) に置き換え、pwsh 経由で実行する。
      --
      -- E746 回避:
      --   autoload 関数はパスが一致するファイルからのみ定義可能なため、
      --   一時ディレクトリに autoload/slime/common.vim を作成して source する。
      --------------------------------------------------------------------------
      if vim.env.TMUX and vim.fn.has('win32') == 1 then
        local tmpdir = vim.fn.tempname()
        vim.fn.mkdir(tmpdir .. '/autoload/slime', 'p')
        local override_path = tmpdir .. '/autoload/slime/common.vim'
        local f = io.open(override_path, 'w')
        if f then
          f:write([[
let s:psmux_pending_text = ""

function! slime#common#system(cmd_template, args, ...) abort
  let cmd = call('printf', [a:cmd_template] + copy(a:args))

  if get(g:, 'slime_debug', 0)
    echom "slime system (psmux): " . cmd
  endif

  " load-buffer: テキストを保持するだけ (後続の paste-buffer で送信)
  if cmd =~# 'load-buffer' && a:0 > 0
    let s:psmux_pending_text = a:1
    return ""
  endif

  " paste-buffer → send-keys -l に置き換え
  if cmd =~# 'paste-buffer' && s:psmux_pending_text !=# ""
    let base_cmd = matchstr(cmd, '^tmux\s\+\S\+\s\+\S\+')
    let target = matchstr(cmd, '-t\s\+\zs\S\+')
    let text = s:psmux_pending_text
    let s:psmux_pending_text = ""

    let has_newline = (text =~# '\(\r\n\|\r\|\n\)$')
    let text = substitute(text, '\(\r\n\|\r\|\n\)$', '', '')

    let tmpfile = tempname()
    call writefile(split(text, "\n", 1), tmpfile, 'b')
    let send_cmd = base_cmd . ' send-keys -l -t ' . target
          \ . ' ([System.IO.File]::ReadAllText("' . tmpfile . '"))'

    if get(g:, 'slime_debug', 0)
      echom "slime system (psmux send-keys): " . send_cmd
    endif

    let result = system(["pwsh.exe", "-NoProfile", "-Command", send_cmd])
    call delete(tmpfile)

    if has_newline
      call system(["pwsh.exe", "-NoProfile", "-Command",
            \ base_cmd . ' send-keys -t ' . target . ' Enter'])
    endif

    return result
  endif

  " その他のコマンド (send-keys cancel, send-keys Enter 等)
  return system(["pwsh.exe", "-NoProfile", "-Command", cmd])
endfunction
]])
          f:close()
          vim.cmd('runtime autoload/slime/common.vim')
          vim.cmd('source ' .. vim.fn.fnameescape(override_path))
        end
      end

      --------------------------------------------------------------------------
      -- ペインターゲットの自動検出
      --------------------------------------------------------------------------

      -- $TMUX_PANE から同ウィンドウ内の次のペインIDを取得する
      local function get_psmux_next_pane()
        local my_pane = vim.env.TMUX_PANE
        if not my_pane or my_pane == "" then
          return ":.+1"
        end
        local result = vim.fn.system({
          "pwsh.exe", "-NoProfile", "-Command",
          string.format([[
$myPane = "%s"
$all = @(tmux list-panes -a -F "#{pane_id} #{window_index}")
$myWin = $null
foreach ($line in $all) {
  $parts = $line -split " "
  if ($parts[0] -eq $myPane) { $myWin = $parts[1]; break }
}
if ($myWin) {
  $winPanes = @()
  foreach ($line in $all) {
    $parts = $line -split " "
    if ($parts[1] -eq $myWin) { $winPanes += $parts[0] }
  }
  for ($i = 0; $i -lt $winPanes.Count; $i++) {
    if ($winPanes[$i] -eq $myPane) {
      Write-Output $winPanes[($i + 1) %% $winPanes.Count]
      break
    }
  }
}
]], my_pane)
        })
        local target = vim.trim(result)
        if target ~= "" and target ~= my_pane then
          return target
        end
        return ":.+1"
      end

      --------------------------------------------------------------------------
      -- tmux / neovim ターゲット設定
      --------------------------------------------------------------------------

      local function SlimeConfigTmux()
        if vim.g.slime_target ~= "tmux" and vim.b.slime_config then
          vim.b.slime_config = nil
        end
        vim.g.slime_target = "tmux"
        local target_pane = get_psmux_next_pane()
        vim.g.slime_default_config = { socket_name = vim.split(vim.env.TMUX, ",")[1], target_pane = target_pane }
        if not vim.b.slime_config or (vim.b.slime_config.socket_name == "" and vim.b.slime_config.target_pane == "") then
          vim.b.slime_config = vim.g.slime_default_config
        end
      end

      vim.api.nvim_create_user_command("SlimeConfigTmux", function()
        SlimeConfigTmux()
        vim.cmd("SlimeConfig")
      end, {})

      vim.api.nvim_create_augroup("nvim_slime", { clear = true })

      vim.api.nvim_create_autocmd("TermOpen", {
        group = "nvim_slime",
        pattern = "*",
        callback = function()
          vim.g.slime_last_channel = { { jobid = vim.o.channel } }
        end,
      })

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

      --------------------------------------------------------------------------
      -- ファイルタイプ別キーマップ
      --------------------------------------------------------------------------

      vim.api.nvim_create_augroup("vimSlimeCommand", { clear = true })

      local function set_keymaps()
        vim.api.nvim_set_keymap('n', '<Space>i', ':lua handle_keymap_space_i()<CR>', { noremap = true })
        vim.api.nvim_set_keymap('n', '<Space>00', ':lua handle_keymap_space_00()<CR>', { noremap = true })
        vim.api.nvim_set_keymap('n', '<Space>a', ':lua handle_keymap_space_a()<CR>', { noremap = true })
        vim.api.nvim_set_keymap('n', '<Space>e', ':lua handle_keymap_space_e()<CR>', { noremap = true })
        vim.api.nvim_set_keymap('n', 'y<Space>e', ':lua handle_keymap_space_e_yank()<CR>', { noremap = true })
      end

      function handle_keymap_space_i()
        local filetype = vim.bo.filetype
        if filetype == "python" or filetype == "ipynb" then
          vim.cmd([[SlimeSend0 "\e[201~\x15\e[200~"]])
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
          vim.cmd([[SlimeSend0 "\e[201~\x15\e[200~"]])
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
          vim.cmd([[SlimeSend0 "\e[201~\x15\e[200~"]])
          vim.cmd('SlimeSend0 "%autoreload\\n"')
        end
      end

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

      function handle_keymap_space_e()
        local filetype = vim.bo.filetype
        local cmd = get_command_for_space_e()

        if cmd ~= "" and (filetype == "python" or filetype == "ipynb") then
          vim.cmd([[SlimeSend0 "\e[201~\x15\e[200~"]])
          vim.cmd('SlimeSend0 "' .. cmd .. '\\n"')
        elseif cmd ~= "" then
          vim.cmd('SlimeSend0 "\\x15' .. cmd .. '\\n"')
        end
      end

      function handle_keymap_space_e_yank()
        local cmd = get_command_for_space_e()

        if cmd ~= "" then
          vim.fn.setreg('"', cmd)
          vim.fn.setreg('+', cmd)
          print('Yanked: ' .. cmd)
        else
          print('No command for this filetype')
        end
      end

      set_keymaps()
    end
  },
  {
    'hanschen/vim-ipython-cell',
    lazy = true,
    enabled = false,
  },
}
