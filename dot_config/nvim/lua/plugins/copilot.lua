return {
  -- Copilot LSP: NES (Next Edit Suggestion) 機能を提供
  {
    "copilotlsp-nvim/copilot-lsp",
    lazy = true,
    event = "InsertEnter",
    init = function()
      -- NES (Next Edit Suggestion) のデバウンス時間（ミリ秒）
      -- カーソル移動後、サジェストが表示されるまでの待機時間
      vim.g.copilot_nes_debounce = 500

      -- Copilot LSP サーバーを有効化
      -- これにより NES 機能が利用可能になる
      vim.lsp.enable("copilot_ls")

      -- Normal mode: Tab で NES サジェストを適用
      -- 1回目の Tab: サジェストの開始位置にジャンプ
      -- 2回目の Tab（開始位置にいる場合）: サジェストを適用して終了位置にジャンプ
      vim.keymap.set("n", "<tab>", function()
        local bufnr = vim.api.nvim_get_current_buf()
        if vim.b[bufnr].nes_state then
          local nes = require("copilot-lsp.nes")
          local _ = nes.walk_cursor_start_edit()
              or (nes.apply_pending_nes() and nes.walk_cursor_end_edit())
          return nil
        else
          -- ターミナルが TAB と <C-i> を区別できない問題を回避
          return "<C-i>"
        end
      end, { desc = "Accept Copilot NES suggestion", expr = true })

      -- Normal mode: Esc Esc で NES サジェストをキャンセル + 検索ハイライト消去
      -- keymaps.lua の <Esc><Esc> をオーバーライドして NES クリアを追加
      -- 注意: 単一 <Esc> をマップすると <Esc><Esc> と競合して timeoutlen 分の遅延が発生するため、
      --       <Esc><Esc> にまとめている
      vim.keymap.set("n", "<esc><esc>", function()
        local bufnr = vim.api.nvim_get_current_buf()
        if vim.b[bufnr].nes_state then
          require("copilot-lsp.nes").clear()
        end
        vim.cmd("nohlsearch")
      end, { desc = "Clear NES and search highlight" })

      -- Insert mode: Esc で NES サジェストをキャンセルしてノーマルモードへ
      vim.keymap.set("i", "<esc>", function()
        local bufnr = vim.api.nvim_get_current_buf()
        if vim.b[bufnr].nes_state then
          require("copilot-lsp.nes").clear()
        end
        return "<esc>"
      end, { expr = true, desc = "Clear NES and exit insert mode" })
    end,
    config = function()
      -- copilot-lsp 固有の設定
      require('copilot-lsp').setup({
        nes = {
          -- カーソル移動後にサジェストをクリアするまでの移動回数の閾値
          -- 高い値にするとカーソル移動してもサジェストが残りやすくなる
          move_count_threshold = 5,
        }
      })
    end,
  },
  {
    'zbirenbaum/copilot.lua',
    lazy = true,
    enabled = true,
    event = "InsertEnter",
    dependencies = {
      "copilotlsp-nvim/copilot-lsp", -- NES 機能のために必要
    },
    config = function()
      -- ハイライト設定（github/copilot.vim から移行）
      require("copilot").setup({
        panel = {
          enabled = true,
          auto_refresh = true,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            open = "<M-CR>"
          },
          layout = {
            position = "bottom",
            ratio = 0.4
          }
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          hide_during_completion = true,
          debounce = 15,
          trigger_on_accept = true,
          keymap = {
            accept = "<C-j>",
            accept_word = "<C-w>",
            accept_line = "<C-l>",
            next = "<c-f>",
            dismiss = "<C-]>",
            toggle_auto_trigger = false,
          }
        },
        nes = {
          enabled = false, -- requires copilot-lsp as a dependency
          auto_trigger = true,
          accept_and_goto = false, -- Tab で手動処理（copilot-lsp.nes 経由）
          accept = false,
          dismiss = false, -- Esc で手動処理（copilot-lsp.nes.clear 経由）
        },
        filetypes = {
          -- github/copilot.vim の設定を移行
          csv = false,
          env = false,
          yaml = true,
          markdown = true,
          help = false,
          gitcommit = true,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          -- 大きいファイルでは無効化（パフォーマンス改善）
          ["*"] = function()
            local file_size = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
            if file_size > 100000 or file_size == -2 then
              return false
            end
            return true
          end,
        },
        copilot_node_command = 'node',
        server_opts_overrides = {}
      })
    end,
    keys = {
      {
        "cp",
        function()
          require("copilot.panel").open()
        end,
        mode = "n",
        silent = true,
        desc = "Open Copilot panel"
      },
    }
  },
}
