return {
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    config = function()
      local dap = require('dap')

      -- -- C/C++/Rust
      -- dap.adapters.codelldb = {
      --   type = "executable",
      --   command = vim.fn.stdpath("data") .. "/mason/packages/codelldb/codelldb",
      --   -- On windows you may have to uncomment this:
      --   -- detached = false,
      -- }
      -- dap.configurations.cpp = {
      --   {
      --     name = "Launch file",
      --     type = "codelldb",
      --     request = "launch",
      --     program = function()
      --       return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      --     end,
      --     cwd = '${workspaceFolder}',
      --     stopOnEntry = false,
      --   },
      -- }
      -- dap.configurations.c = dap.configurations.cpp
      -- dap.configurations.rust = dap.configurations.cpp

      -- ブレークポイント（通常）の定義
      vim.fn.sign_define("DapBreakpoint", {
        text = "🟥", -- 目立つ赤いブロックアイコン
        texthl = "DapBreakpoint", -- カスタムハイライトグループ（必要に応じて定義）
        linehl = "", -- 行全体のハイライトは必要に応じて設定可能
        numhl = "" -- 行番号のハイライトも同様
      })

      -- 条件付きブレークポイントの場合（必要なら）
      vim.fn.sign_define("DapBreakpointCondition", {
        text = "🟧",
        texthl = "DapBreakpoint",
        linehl = "",
        numhl = ""
      })

      -- 失敗したブレークポイントの定義
      vim.fn.sign_define("DapBreakpointRejected", {
        text = "❌",
        texthl = "DapBreakpointRejected",
        linehl = "",
        numhl = ""
      })

      -- 現在停止中の位置
      vim.fn.sign_define("DapStopped", {
        text = "⭐",
        texthl = "DapStopped",
        linehl = "DapStoppedLine", -- 行全体をハイライトさせる場合
        numhl = "DapStoppedLine"
      })

      local function select_breakpoint()
        local dap_breakpoints = require('dap.breakpoints').get()
        local items = {}

        -- dap_breakpoints はキーがファイルパス（もしくはバッファ番号の文字列）となっているので、
        -- キーが数値の場合はバッファから実際のファイルパスを取得する
        for key, bps in pairs(dap_breakpoints) do
          local actual_file = key
          if tonumber(key) then
            actual_file = vim.api.nvim_buf_get_name(tonumber(key))
          end

          for _, bp in ipairs(bps) do
            -- バッファ番号（存在しなければ作成）
            local bufnr = vim.fn.bufnr(actual_file, true)
            -- ファイル名はパスから末尾のみを抽出
            local filename = vim.fn.fnamemodify(actual_file, ":t")
            -- 対象行の内容を取得（ファイルが読める場合）
            local line_content = ""
            if vim.fn.filereadable(actual_file) == 1 then
              local lines = vim.fn.readfile(actual_file)
              line_content = lines[bp.line] or ""
            end
            line_content = vim.fn.trim(line_content)
            if #line_content > 80 then
              line_content = string.sub(line_content, 1, 80) .. "..."
            end

            -- 表示フォーマット: バッファ番号, アイコン, ファイル名, 行番号, 行の内容
            local label = string.format("%-3d  %-15s %4d  %s", bufnr, filename, bp.line, line_content)
            if bp.condition and bp.condition ~= "" then
              label = label .. " (条件: " .. bp.condition .. ")"
            end

            table.insert(items, { label = label, file = actual_file, line = bp.line, bp = bp })
          end
        end

        vim.ui.select(items, {
          prompt = 'ブレークポイントを選択してください:',
          format_item = function(item)
            return item.label
          end,
        }, function(choice)
          if choice then
            print("選択したブレークポイント: " .. choice.label)
            -- ファイル名に特殊文字がある場合に備えて fnameescape を利用
            vim.cmd("edit " .. vim.fn.fnameescape(choice.file))
            local bufnr = vim.api.nvim_get_current_buf()
            local line_count = vim.api.nvim_buf_line_count(bufnr)
            local target_line = choice.line
            if target_line > line_count then
              target_line = line_count
            end
            vim.api.nvim_win_set_cursor(0, { target_line, 0 })
          end
        end)
      end

      -- ノーマルモードで ;f<F9> を押すと実行
      vim.keymap.set("n", ";f<F9>", select_breakpoint, { desc = "ブレークポイント選択" })
    end,

    -- <f5> start debug
    -- <s-f5> stop debug
    -- <s-c-f5> restart debug
    -- <f9> toggle breakpoint
    -- <f10> step over
    -- <f11> step into
    -- <s-f11> step out

    -- ~/.local/share/nvim/lazy/nvim-dap/plugin/dap.lua
    -- local cmd = api.nvim_create_user_command
    -- cmd('DapSetLogLevel',
    --   function(opts)
    --     require('dap').set_log_level(unpack(opts.fargs))
    --   end,
    --   {
    --     nargs = 1,
    --     complete = function()
    --       return vim.tbl_keys(require('dap.log').levels)
    --     end
    --   }
    -- )
    -- cmd('DapShowLog', 'split | e ' .. vim.fn.stdpath('cache') .. '/dap.log | normal! G', {})
    -- cmd('DapContinue', function() require('dap').continue() end, { nargs = 0 })
    -- cmd('DapToggleBreakpoint', function() require('dap').toggle_breakpoint() end, { nargs = 0 })
    -- cmd('DapToggleRepl', function() require('dap.repl').toggle() end, { nargs = 0 })
    -- cmd('DapStepOver', function() require('dap').step_over() end, { nargs = 0 })
    -- cmd('DapStepInto', function() require('dap').step_into() end, { nargs = 0 })
    -- cmd('DapStepOut', function() require('dap').step_out() end, { nargs = 0 })
    -- cmd('DapTerminate', function() require('dap').terminate() end, { nargs = 0 })
    -- cmd('DapDisconnect', function() require('dap').disconnect({ terminateDebuggee = false }) end, { nargs = 0 })
    -- cmd('DapLoadLaunchJSON', function() require('dap.ext.vscode').load_launchjs() end, { nargs = 0 })
    -- cmd('DapRestartFrame', function() require('dap').restart_frame() end, { nargs = 0 })

    keys = {
      { "<F5>",        function() require("dap").continue() end,                                             desc = "Start/Continue Debug" },
      { "<S-F5>",      function() require("dap").terminate() end,                                            desc = "Stop Debug" },
      { "<F17>",       function() require("dap").terminate() end,                                            desc = "Stop Debug" },
      { "<S-C-F5>",    function() require("dap").restart() end,                                              desc = "Restart Debug" },
      { "<F41>",       function() require("dap").restart() end,                                              desc = "Restart Debug" },
      { "<F9>",        function() require("dap").toggle_breakpoint() end,                                    desc = "Toggle Breakpoint" },
      -- 条件付きブレークポイント
      { "<S-F9>",      function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Set Conditional Breakpoint" },
      { "<F21>",       function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Set Conditional Breakpoint" },
      { "<F10>",       function() require("dap").step_over() end,                                            desc = "Step Over" },
      { "<F11>",       function() require("dap").step_into() end,                                            desc = "Step Into" },
      { "<S-F11>",     function() require("dap").step_out() end,                                             desc = "Step Out" },
      { "<F23>",       function() require("dap").step_out() end,                                             desc = "Step Out" },
      { "<leader>dgt", function() require("dap").set_log_level('TRACE') end },
      { "<leader>dge", function() vim.cmd(":edit " .. vim.fn.stdpath('cache') .. "/dap.log") end },
    },
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "nvim-neotest/nvim-nio" },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
  },

  {
    "mfussenegger/nvim-dap-python",
    cond = function()
      return vim.fn.executable("debugpy")
    end,
    ft = { "python" },
    config = function()
      -- with mason
      require('dap-python').setup(vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python")
    end,
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      { "<leader>dm", function() require('dap-python').test_method() end,     desc = "Test Method" },
      { "<leader>dc", function() require('dap-python').test_class() end,      desc = "Test Class" },
      { "<leader>ds", function() require('dap-python').debug_selection() end, desc = "Debug Selection" },
    },
  },

  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
        "nvim-dap-ui",
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
  {                                        -- optional completion source for require statements and module annotations
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, {
        name = "lazydev",
        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      })
    end,
  },
  {
    "julianolf/nvim-dap-lldb",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = { codelldb_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/codelldb" },
  }

  -- -- Remember nvim-dap breakpoints between sessions, ``:PBToggleBreakpoint``
  -- {
  --   "Weissle/persistent-breakpoints.nvim",
  --   config = function()
  --     require("persistent-breakpoints").setup {
  --       load_breakpoints_event = { "BufReadPost" }
  --     }

  --     vim.keymap.set("n", "<leader>db", ":PBToggleBreakpoint<CR>")
  --   end,
  -- }

}
