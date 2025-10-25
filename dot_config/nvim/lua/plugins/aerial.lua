return {
  {
    'stevearc/aerial.nvim',
    cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle", "AerialPrev", "AerialNext" },
    keys = {
      { ';aa', "<cmd>AerialToggle!<CR>",   mode = 'n', desc = "Toggle aerial outline" },
      { ';aA', "<cmd>AerialOpen<CR>",      mode = 'n', desc = "Open aerial outline" },
      { ';ao', "<cmd>AerialOpen<CR>",      mode = 'n', desc = "Open aerial outline" },
      { ';an', "<cmd>AerialNavToggle<CR>", mode = 'n', desc = "Toggle aerial navigation" },
      { ';af', function() require("telescope").extensions.aerial.aerial() end, mode = 'n', desc = "Aerial telescope" },
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
        vim.keymap.set("n", "[a", "<cmd>AerialPrev<CR>", { buffer = bufnr, desc = "Previous aerial item" })
        vim.keymap.set("n", "]a", "<cmd>AerialNext<CR>", { buffer = bufnr, desc = "Next aerial item" })
      end,
      markdown = {
        update_delay = 100,
      },
    },
    config = function(_, opts)
      local aerial = require("aerial")
      aerial.setup(opts)

      -- 再帰的に子孫シンボルを収集する関数
      local function collect_descendants(item, result)
        table.insert(result, item)
        if item.children then
          for _, child in ipairs(item.children) do
            collect_descendants(child, result)
          end
        end
      end

      -- シンボルが折りたたまれているかチェックする関数
      local function is_symbol_folded(item)
        -- 子要素があり、かつ折りたたまれている場合
        -- Aerialでは collapsed フラグまたは fold_state で管理される
        if item.children and #item.children > 0 then
          -- collapsed フラグがあればそれを使用
          if item.collapsed ~= nil then
            return item.collapsed
          end
          -- または、iter({ skip_hidden = true }) で子が見えないかチェック
          -- 簡易的に: 子がいるのに次の表示行に子が現れない = 折りたたまれている
          return true -- デフォルトは折りたたまれているとみなす
        end
        return false
      end

      -- 表示行番号から実際のシンボルを取得する関数（折りたたみ状態を考慮）
      local function get_symbols_by_display_lines(source_bufnr, start_line, end_line)
        local data = require("aerial.data")
        local bufdata = data.get_or_create(source_bufnr)
        local selected_symbols = {}
        local display_line = 1
        local visible_items = {}

        -- まず表示されている全シンボルのリストを作成
        for _, item in bufdata:iter({ skip_hidden = true }) do
          visible_items[item] = display_line
          if display_line >= start_line and display_line <= end_line then
            table.insert(selected_symbols, item)
          end
          if display_line > end_line then
            break
          end
          display_line = display_line + 1
        end

        -- 選択されたシンボルを処理
        local all_symbols = {}
        for _, symbol in ipairs(selected_symbols) do
          -- 子要素があるか確認
          local has_visible_children = false
          if symbol.children then
            for _, child in ipairs(symbol.children) do
              if visible_items[child] then
                has_visible_children = true
                break
              end
            end
          end

          -- 子要素が表示されていない（折りたたまれている）場合のみ子孫を含める
          if symbol.children and #symbol.children > 0 and not has_visible_children then
            collect_descendants(symbol, all_symbols)
          else
            -- 展開されている、または子要素がない場合は自分自身のみ
            table.insert(all_symbols, symbol)
          end
        end

        return all_symbols
      end

      -- Markdownヘッダーレベルを変更する関数
      local function change_header_level_in_source(symbols, increment)
        if #symbols == 0 then
          return 0
        end

        local util = require("aerial.util")
        local aerial_bufnr = vim.api.nvim_get_current_buf()
        local source_bufnr = util.get_source_buffer(aerial_bufnr)

        if not source_bufnr then
          vim.notify("Could not find source buffer", vim.log.levels.ERROR)
          return 0
        end

        local current_win = vim.api.nvim_get_current_win()
        local current_pos = vim.api.nvim_win_get_cursor(current_win)

        -- 変更を準備
        local changes = {}
        for _, item in ipairs(symbols) do
          if item and item.lnum then
            local ok, lines = pcall(vim.api.nvim_buf_get_lines, source_bufnr, item.lnum - 1, item.lnum, false)
            if ok and #lines > 0 then
              local source_line = lines[1]
              local new_line

              if increment then
                new_line = "#" .. source_line
              else
                new_line = source_line:match("^##") and source_line:sub(2) or source_line
              end

              if new_line ~= source_line then
                table.insert(changes, { lnum = item.lnum, new_line = new_line })
              end
            end
          end
        end

        if #changes == 0 then
          return 0
        end

        -- 行番号の降順でソート（下から上に変更することで行番号ずれを防ぐ）
        table.sort(changes, function(a, b) return a.lnum > b.lnum end)

        -- 変更を適用
        local success_count = 0
        local source_win = util.get_source_win(current_win)

        if not source_win then
          -- 直接バッファを編集
          for _, change in ipairs(changes) do
            if pcall(vim.api.nvim_buf_set_lines, source_bufnr, change.lnum - 1, change.lnum, false, { change.new_line }) then
              success_count = success_count + 1
            end
          end
        else
          -- ソースウィンドウ経由で編集（undoが正しく機能）
          local prev_win = vim.api.nvim_get_current_win()
          if pcall(function()
            vim.api.nvim_set_current_win(source_win)
            for _, change in ipairs(changes) do
              vim.api.nvim_buf_set_lines(source_bufnr, change.lnum - 1, change.lnum, false, { change.new_line })
              success_count = success_count + 1
            end
            vim.api.nvim_set_current_win(prev_win)
            if current_win == prev_win and vim.api.nvim_win_is_valid(current_win) then
              vim.api.nvim_win_set_cursor(current_win, current_pos)
            end
          end) then
            -- Success
          else
            vim.notify("Error applying changes", vim.log.levels.ERROR)
          end
        end

        -- シンボル再取得を遅延実行（バッファ更新の完了を待つ）
        if success_count > 0 then
          vim.defer_fn(function()
            pcall(aerial.refetch_symbols, source_bufnr)
          end, 50)
        end

        return success_count
      end

      -- ソースバッファでundo/redoを実行する関数
      local function execute_source_command(command, error_msg)
        local util = require("aerial.util")
        local aerial_bufnr = vim.api.nvim_get_current_buf()
        local source_bufnr = util.get_source_buffer(aerial_bufnr)
        
        if not source_bufnr then
          return
        end

        local source_win = util.get_source_win()
        if not source_win then
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == source_bufnr then
              source_win = win
              break
            end
          end
        end

        local current_win = vim.api.nvim_get_current_win()

        if not source_win then
          -- 一時ウィンドウを作成
          if not pcall(function()
            vim.cmd("split")
            source_win = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(source_win, source_bufnr)
            
            if command == "undo" then
              vim.cmd("normal! u")
            else
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-r>", true, false, true), "nx", true)
              vim.cmd("redraw")
            end
            
            vim.api.nvim_win_close(source_win, true)
            vim.api.nvim_set_current_win(current_win)
          end) then
            vim.notify(error_msg, vim.log.levels.ERROR)
          end
        else
          if not pcall(function()
            vim.api.nvim_set_current_win(source_win)
            
            if command == "undo" then
              vim.cmd("normal! u")
            else
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-r>", true, false, true), "nx", true)
              vim.cmd("redraw")
            end
            
            vim.api.nvim_set_current_win(current_win)
          end) then
            vim.notify(error_msg, vim.log.levels.ERROR)
            pcall(vim.api.nvim_set_current_win, current_win)
          end
        end

        pcall(aerial.refetch_symbols, source_bufnr)
      end

      -- ビジュアルモード用のヘルパー関数（ローカルスコープ）
      local function aerial_visual_helper(increment)
        local util = require("aerial.util")
        local aerial_bufnr = vim.api.nvim_get_current_buf()
        local source_bufnr = util.get_source_buffer(aerial_bufnr)

        if not source_bufnr then
          vim.notify("Could not find source buffer", vim.log.levels.ERROR)
          return
        end

        -- visual mode中にカーソル位置を取得
        local start_pos = vim.fn.getpos("v")
        local end_pos = vim.fn.getpos(".")

        -- 開始と終了を正規化（小さい方が開始）
        local start_line = math.min(start_pos[2], end_pos[2])
        local end_line = math.max(start_pos[2], end_pos[2])

        -- visual modeを抜ける
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)

        vim.defer_fn(function()
          if start_line <= 0 or end_line <= 0 then
            vim.notify("Invalid selection range", vim.log.levels.ERROR)
            return
          end

          local win = vim.api.nvim_get_current_win()
          local cur_pos = vim.api.nvim_win_get_cursor(win)

          -- 表示行番号から実際のシンボル（子孫含む）を取得
          local symbols = get_symbols_by_display_lines(source_bufnr, start_line, end_line)
          local success_count = change_header_level_in_source(symbols, increment)

          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_set_cursor(win, cur_pos)
          end

          if success_count <= 0 then
            vim.notify("Failed to change header level", vim.log.levels.ERROR)
          end
        end, 10)
      end

      -- aerial バッファ用のキーマップ設定
      local augroup = vim.api.nvim_create_augroup("AerialCustom", { clear = true })
      
      vim.api.nvim_create_autocmd("FileType", {
        group = augroup,
        pattern = "aerial",
        callback = function()
          local bufnr = vim.api.nvim_get_current_buf()

          -- 既存のマッピングを削除
          pcall(vim.keymap.del, "n", ">>", { buffer = bufnr })
          pcall(vim.keymap.del, "n", "<<", { buffer = bufnr })
          pcall(vim.keymap.del, "x", ">>", { buffer = bufnr })
          pcall(vim.keymap.del, "x", "<<", { buffer = bufnr })

          -- ノーマルモード: ヘッダーレベル変更
          vim.keymap.set("n", ">>", function()
            local util = require("aerial.util")
            local aerial_bufnr = vim.api.nvim_get_current_buf()
            local source_bufnr = util.get_source_buffer(aerial_bufnr)

            if not source_bufnr then
              vim.notify("Could not find source buffer", vim.log.levels.ERROR)
              return
            end

            local win = vim.api.nvim_get_current_win()
            local cur_pos = vim.api.nvim_win_get_cursor(win)
            local current_line = cur_pos[1]

            -- 現在の表示行からシンボルを取得
            local symbols = get_symbols_by_display_lines(source_bufnr, current_line, current_line)
            local success_count = change_header_level_in_source(symbols, true)

            if vim.api.nvim_win_is_valid(win) then
              vim.api.nvim_win_set_cursor(win, cur_pos)
            end

            if success_count <= 0 then
              vim.notify("Failed to change header level", vim.log.levels.ERROR)
            end
          end, { buffer = bufnr, desc = "ヘッダーレベルを下げる (#を追加)" })

          vim.keymap.set("n", "<<", function()
            local util = require("aerial.util")
            local aerial_bufnr = vim.api.nvim_get_current_buf()
            local source_bufnr = util.get_source_buffer(aerial_bufnr)

            if not source_bufnr then
              vim.notify("Could not find source buffer", vim.log.levels.ERROR)
              return
            end

            local win = vim.api.nvim_get_current_win()
            local cur_pos = vim.api.nvim_win_get_cursor(win)
            local current_line = cur_pos[1]

            -- 現在の表示行からシンボルを取得
            local symbols = get_symbols_by_display_lines(source_bufnr, current_line, current_line)
            local success_count = change_header_level_in_source(symbols, false)

            if vim.api.nvim_win_is_valid(win) then
              vim.api.nvim_win_set_cursor(win, cur_pos)
            end

            if success_count <= 0 then
              vim.notify("ヘッダーレベルの変更に失敗しました", vim.log.levels.ERROR)
            end
          end, { buffer = bufnr, desc = "ヘッダーレベルを上げる (#を削除)" })

          -- ビジュアルモード用（直接マッピング）

          -- ビジュアルモードマッピング
          vim.keymap.set("x", ">>", function()
            aerial_visual_helper(true)
          end, { buffer = bufnr, desc = "ヘッダーレベルを下げる (選択範囲)" })

          vim.keymap.set("x", "<<", function()
            aerial_visual_helper(false)
          end, { buffer = bufnr, desc = "ヘッダーレベルを上げる (選択範囲)" })

          -- undo/redo
          vim.keymap.set("n", "u", function()
            execute_source_command("undo", "Error occurred during undo operation")
          end, { buffer = bufnr, desc = "元に戻す (ソースバッファ)" })

          vim.keymap.set("n", "<C-r>", function()
            execute_source_command("redo", "Error occurred during redo operation")
          end, { buffer = bufnr, desc = "やり直す (ソースバッファ)" })
        end
      })
    end,
  },
}