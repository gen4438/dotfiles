return {
  {
    'zbirenbaum/copilot.lua',
    lazy = true,
    enabled = true,
    event = "InsertEnter",
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
