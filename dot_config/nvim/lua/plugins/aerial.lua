return {
  {
    'stevearc/aerial.nvim',
    lazy = false,
    keys = {
      { ';aa', "<cmd>AerialToggle!<CR>",   mode = 'n' },
      { ';aA', "<cmd>AerialOpen<CR>",      mode = 'n' },
      { ';ao', "<cmd>AerialOpen<CR>",      mode = 'n' },
      { ';af', "<cmd>AerialNavToggle<CR>", mode = 'n' },
      {
        ';af', function() require("telescope").extensions.aerial.aerial() end, mode = 'n'
      },
    },
    opts = {
      backends = { "treesitter", "lsp", "markdown", "asciidoc", "man" },
      layout = {
        max_width = { 40, 0.2 },
        width = 0.2,
        min_width = 20,
        win_opts = {},
        default_direction = "left",
        placement = "edge",
        resize_to_content = true,
        preserve_equality = true,
      },
      attach_mode = "window",
      close_automatic_events = {},
      keymaps = {
        ["?"] = "actions.show_help",
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.jump",
        ["<2-LeftMouse>"] = "actions.jump",
        ["<C-v>"] = "actions.jump_vsplit",
        ["<C-s>"] = "actions.jump_split",
        ["p"] = "actions.scroll",
        ["<C-j>"] = "actions.down_and_scroll",
        ["<C-k>"] = "actions.up_and_scroll",
        ["{"] = "actions.prev",
        ["}"] = "actions.next",
        ["[["] = "actions.prev_up",
        ["]]"] = "actions.next_up",
        ["q"] = "actions.close",
        ["o"] = "actions.tree_toggle",
        ["za"] = "actions.tree_toggle",
        ["O"] = "actions.tree_toggle_recursive",
        ["zA"] = "actions.tree_toggle_recursive",
        ["l"] = "actions.tree_open",
        ["zo"] = "actions.tree_open",
        ["L"] = "actions.tree_open_recursive",
        ["zO"] = "actions.tree_open_recursive",
        ["h"] = "actions.tree_close",
        ["zc"] = "actions.tree_close",
        ["H"] = "actions.tree_close_recursive",
        ["zC"] = "actions.tree_close_recursive",
        ["zr"] = "actions.tree_increase_fold_level",
        ["zR"] = "actions.tree_open_all",
        ["zm"] = "actions.tree_decrease_fold_level",
        ["zM"] = "actions.tree_close_all",
        ["zx"] = "actions.tree_sync_folds",
        ["zX"] = "actions.tree_sync_folds",
      },
      lazy_load = true,
      disable_max_lines = 10000,
      disable_max_size = 2000000,
      filter_kind = {
        "Class", "Constructor", "Enum", "Function",
        "Interface", "Module", "Method", "Struct",
      },
      highlight_mode = "split_width",
      highlight_closest = true,
      highlight_on_hover = false,
      highlight_on_jump = 1000,
      autojump = false,
      icons = {},
      ignore = {
        unlisted_buffers = false,
        diff_windows = true,
        filetypes = {},
        buftypes = "special",
        wintypes = "special",
      },
      manage_folds = false,
      link_folds_to_tree = false,
      link_tree_to_folds = true,
      nerd_font = "auto",
      on_attach = function(bufnr)
        vim.keymap.set("n", "[a", "<cmd>AerialPrev<CR>", { buffer = bufnr })
        vim.keymap.set("n", "]a", "<cmd>AerialNext<CR>", { buffer = bufnr })
      end,
      markdown = {
        update_delay = 100,
      },
    },
    config = function(_, opts)
      -- 基本設定を適用
      local aerial = require("aerial")
      aerial.setup(opts)

      -- aerial bufferに基づいてソースバッファでMarkdownヘッダーレベルを変更する関数
      local function change_header_level_in_source(aerial_line, increment, visual_mode, visual_end_line)
        -- 現在のバッファと位置を取得
        local aerial_bufnr = vim.api.nvim_get_current_buf()
        local util = require("aerial.util")

        -- ソースバッファとウィンドウを取得
        local source_bufnr = util.get_source_buffer(aerial_bufnr)
        if not source_bufnr then
          vim.notify("Could not find source buffer", vim.log.levels.ERROR)
          return 0
        end

        -- 現在のウィンドウとカーソル位置を保存
        local current_win = vim.api.nvim_get_current_win()
        local current_pos = vim.api.nvim_win_get_cursor(current_win)

        -- データモジュールを使用してシンボル情報を取得
        local data = require("aerial.data")
        local bufdata = data.get_or_create(source_bufnr)

        -- 選択されたシンボルを収集
        local selected_items = {}

        -- 全シンボルを取得して選択範囲内のものを収集 (skip_hidden=falseで非表示のシンボルも含む)
        if visual_mode then
          for _, item, i in bufdata:iter({ skip_hidden = false }) do
            if i >= aerial_line and i <= visual_end_line then
              table.insert(selected_items, item)
            end
          end
        else
          -- 単一行の場合
          local item = nil
          for _, candidate, i in bufdata:iter({ skip_hidden = false }) do
            if i == aerial_line then
              item = candidate
              break
            end
          end

          if item then
            table.insert(selected_items, item)
          end
        end

        -- 変更を適用するための準備
        local changes = {}
        for _, item in ipairs(selected_items) do
          if item and item.lnum then
            local status, lines = pcall(vim.api.nvim_buf_get_lines, source_bufnr, item.lnum - 1, item.lnum, false)
            if not status or #lines == 0 then
              goto continue
            end

            local source_line = lines[1]

            -- 新しい行を作成
            local new_line
            if increment then
              -- ヘッダーレベルを下げる（#を追加）
              new_line = "#" .. source_line
            else
              -- ヘッダーレベルを上げる（#を削除 - 少なくとも##がある場合のみ）
              if source_line:match("^##") then
                new_line = source_line:sub(2)
              else
                new_line = source_line -- 変更なし
              end
            end

            -- 変更があれば収集
            if new_line ~= source_line then
              table.insert(changes, {
                lnum = item.lnum,
                old_line = source_line,
                new_line = new_line
              })
            end
          end
          ::continue::
        end

        -- 変更がなければ終了
        if #changes == 0 then
          return 0
        end

        -- 変更をソースバッファに適用
        local success_count = 0

        -- ソースウィンドウを探す
        local source_win = util.get_source_win(current_win)

        if not source_win then
          -- ソースウィンドウが見つからない場合、別の方法でバッファを直接編集
          for _, change in ipairs(changes) do
            local status = pcall(function()
              vim.api.nvim_buf_set_lines(source_bufnr, change.lnum - 1, change.lnum, false, { change.new_line })
              success_count = success_count + 1
            end)
          end
        else
          -- ソースウィンドウを使用して変更を適用（undoが正しく機能するように）
          -- 現在のウィンドウを保存
          local prev_win = vim.api.nvim_get_current_win()

          local status = pcall(function()
            -- ソースウィンドウに切り替え
            vim.api.nvim_set_current_win(source_win)

            -- 全ての変更を一括で適用
            for _, change in ipairs(changes) do
              vim.api.nvim_win_set_cursor(source_win, { change.lnum, 0 })
              vim.api.nvim_buf_set_lines(source_bufnr, change.lnum - 1, change.lnum, false, { change.new_line })
              success_count = success_count + 1
            end

            -- 元のウィンドウに戻る
            vim.api.nvim_set_current_win(prev_win)
            if current_win == prev_win and vim.api.nvim_win_is_valid(current_win) then
              vim.api.nvim_win_set_cursor(current_win, current_pos)
            end
          end)
        end

        -- シンボルを更新
        if success_count > 0 then
          pcall(aerial.refetch_symbols, source_bufnr)
        end

        return success_count
      end

      -- augroup を作成してキーマップを設定
      local augroup = vim.api.nvim_create_augroup("AerialCustom", { clear = true })

      -- aerial バッファが読み込まれたときにキーマップを設定
      vim.api.nvim_create_autocmd("FileType", {
        group = augroup,
        pattern = "aerial",
        callback = function()
          local bufnr = vim.api.nvim_get_current_buf()

          -- 古いマッピングを削除
          pcall(vim.keymap.del, "n", ">>", { buffer = bufnr })
          pcall(vim.keymap.del, "n", "<<", { buffer = bufnr })
          pcall(vim.keymap.del, "x", ">>", { buffer = bufnr })
          pcall(vim.keymap.del, "x", "<<", { buffer = bufnr })

          -- ノーマルモードでヘッダーレベルを下げる (# を追加)
          vim.keymap.set("n", ">>", function()
            local win = vim.api.nvim_get_current_win()
            local cur_pos = vim.api.nvim_win_get_cursor(win)
            local success_count = change_header_level_in_source(cur_pos[1], true, false)

            -- 操作後、元のカーソル位置に戻す
            if vim.api.nvim_win_is_valid(win) then
              vim.api.nvim_win_set_cursor(win, cur_pos)
            end

            if success_count <= 0 then
              vim.notify("Failed to change header level", vim.log.levels.ERROR)
            end
          end, { buffer = bufnr, desc = "ヘッダーレベルを下げる (#を追加)" })

          -- ノーマルモードでヘッダーレベルを上げる (# を削除)
          vim.keymap.set("n", "<<", function()
            local win = vim.api.nvim_get_current_win()
            local cur_pos = vim.api.nvim_win_get_cursor(win)
            local success_count = change_header_level_in_source(cur_pos[1], false, false)

            -- 操作後、元のカーソル位置に戻す
            if vim.api.nvim_win_is_valid(win) then
              vim.api.nvim_win_set_cursor(win, cur_pos)
            end

            if success_count <= 0 then
              vim.notify("ヘッダーレベルの変更に失敗しました", vim.log.levels.ERROR)
            end
          end, { buffer = bufnr, desc = "ヘッダーレベルを上げる (#を削除)" })

          -- ビジュアルモード用のヘルパー関数
          _G.aerial_visual_helper = function(increment)
            -- Escキーを押してビジュアルモードを終了
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)

            -- 少し待ってからマークを取得
            vim.defer_fn(function()
              -- 現在のウィンドウとカーソル位置を保存
              local win = vim.api.nvim_get_current_win()
              local cur_pos = vim.api.nvim_win_get_cursor(win)

              -- 選択範囲を取得
              local start_line = vim.fn.line("'<")
              local end_line = vim.fn.line("'>")

              -- 行番号の検証
              if start_line <= 0 or end_line <= 0 then
                vim.notify("Invalid selection range", vim.log.levels.ERROR)
                return
              end

              -- 変更を適用
              local success_count = change_header_level_in_source(start_line, increment, true, end_line)

              -- 操作後、元のカーソル位置に戻す
              if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_set_cursor(win, cur_pos)
              end

              if success_count <= 0 then
                vim.notify("Failed to change header level", vim.log.levels.ERROR)
              end
            end, 10) -- 10ms遅延を設定
          end

          -- グローバルコマンドを登録
          if not vim.api.nvim_get_commands({})["AerialVisualHeaderDown"] then
            vim.api.nvim_create_user_command("AerialVisualHeaderDown", function()
              _G.aerial_visual_helper(true)
            end, {})

            vim.api.nvim_create_user_command("AerialVisualHeaderUp", function()
              _G.aerial_visual_helper(false)
            end, {})
          end

          -- ビジュアルモードのマッピングをExコマンド経由で設定
          vim.cmd([[
            xnoremap <buffer> <silent> >> <Esc>:AerialVisualHeaderDown<CR>
            xnoremap <buffer> <silent> << <Esc>:AerialVisualHeaderUp<CR>
          ]])

          -- undoとredoのキーマッピング
          vim.keymap.set("n", "u", function()
            -- aerial bufferのウィンドウとソースバッファを取得
            local aerial_bufnr = vim.api.nvim_get_current_buf()
            local util = require("aerial.util")
            local source_bufnr = util.get_source_buffer(aerial_bufnr)

            if not source_bufnr then
              return
            end

            -- ソースウィンドウを探す
            local source_win = util.get_source_win()

            if not source_win then
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == source_bufnr then
                  source_win = win
                  break
                end
              end
            end

            -- 現在のウィンドウを記憶
            local current_win = vim.api.nvim_get_current_win()

            if not source_win then
              -- ソースバッファを表示するウィンドウが見つからない場合
              -- 一時的なウィンドウを作成
              local status = pcall(function()
                vim.cmd("split")
                source_win = vim.api.nvim_get_current_win()
                vim.api.nvim_win_set_buf(source_win, source_bufnr)

                -- undoを実行
                vim.cmd("normal! u")

                -- 一時ウィンドウを閉じる
                vim.api.nvim_win_close(source_win, true)
                vim.api.nvim_set_current_win(current_win)
              end)

              if not status then
                vim.notify("Error occurred during undo operation", vim.log.levels.ERROR)
              end
            else
              local status = pcall(function()
                -- ソースウィンドウに切り替えてundoを実行
                vim.api.nvim_set_current_win(source_win)
                vim.cmd("normal! u")

                -- 元のaerialウィンドウに戻る
                vim.api.nvim_set_current_win(current_win)
              end)

              if not status then
                vim.notify("undo操作中にエラーが発生しました", vim.log.levels.ERROR)
                -- エラーが発生したら元のウィンドウに戻るように試みる
                pcall(vim.api.nvim_set_current_win, current_win)
              end
            end

            -- シンボルを更新
            pcall(aerial.refetch_symbols, source_bufnr)
          end, { buffer = bufnr, desc = "元に戻す (ソースバッファでundo)" })

          vim.keymap.set("n", "<C-r>", function()
            -- aerial bufferのウィンドウとソースバッファを取得
            local aerial_bufnr = vim.api.nvim_get_current_buf()
            local util = require("aerial.util")
            local source_bufnr = util.get_source_buffer(aerial_bufnr)

            if not source_bufnr then
              return
            end

            -- ソースウィンドウを探す
            local source_win = util.get_source_win()

            if not source_win then
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == source_bufnr then
                  source_win = win
                  break
                end
              end
            end

            -- 現在のウィンドウを記憶
            local current_win = vim.api.nvim_get_current_win()

            if not source_win then
              -- ソースバッファを表示するウィンドウが見つからない場合
              -- 一時的なウィンドウを作成
              local status = pcall(function()
                vim.cmd("split")
                source_win = vim.api.nvim_get_current_win()
                vim.api.nvim_win_set_buf(source_win, source_bufnr)

                -- feedkeysでredoを実行
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-r>", true, false, true), "nx", true)

                -- 確実に更新するため
                vim.cmd("redraw")

                -- 一時ウィンドウを閉じる
                vim.api.nvim_win_close(source_win, true)
                vim.api.nvim_set_current_win(current_win)
              end)

              if not status then
                vim.notify("Error occurred during redo operation", vim.log.levels.ERROR)
              end
            else
              local status = pcall(function()
                -- ソースウィンドウに切り替えてredoを実行
                vim.api.nvim_set_current_win(source_win)
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-r>", true, false, true), "nx", true)

                -- 確実に更新するため
                vim.cmd("redraw")

                -- 元のaerialウィンドウに戻る
                vim.api.nvim_set_current_win(current_win)
              end)

              if not status then
                vim.notify("redo操作中にエラーが発生しました", vim.log.levels.ERROR)
                -- エラーが発生したら元のウィンドウに戻るように試みる
                pcall(vim.api.nvim_set_current_win, current_win)
              end
            end

            -- シンボルを更新
            pcall(aerial.refetch_symbols, source_bufnr)
          end, { buffer = bufnr, desc = "やり直す (ソースバッファでredo)" })
        end
      })
    end,
  },
}
