return {
  {
    'zbirenbaum/copilot.lua',
    lazy = true,
    enabled = true,
    event = "InsertEnter",
    config = function()
      -- ハイライト設定（github/copilot.vim から移行）
      vim.api.nvim_set_hl(0, 'CopilotSuggestion', { fg = '#FF5555', ctermfg = 8 })

      require("copilot").setup({
        panel = {
          enabled = true,
          auto_refresh = false,
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
          auto_trigger = false,
          hide_during_completion = true,
          debounce = 75,
          keymap = {
            accept = "<C-j>",       -- github/copilot.vim から移行
            accept_word = "<C-w>",  -- github/copilot.vim から移行
            accept_line = "<C-l>",  -- github/copilot.vim から移行
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>"
          }
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
      {
        "<c-k><c-k>",
        function()
          require("copilot.suggestion").next()
        end,
        mode = "i",
        silent = true,
        desc = "Trigger Copilot suggestion"
      },
    }
  },
}
