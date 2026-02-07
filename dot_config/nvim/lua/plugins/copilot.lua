return {
  {
    'github/copilot.vim',
    enabled = false,
    lazy = true,
    event = "VimEnter",
    init = function()
      vim.g.copilot_filetypes = {
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
        -- ["copilot-chat"] = false,
      }
      vim.g.copilot_no_tab_map = true
      vim.api.nvim_set_hl(0, 'CopilotSuggestion', { fg = '#FF5555', ctermfg = 8 })

      -- 大きいファイルでは無効化（パフォーマンス改善）
      vim.api.nvim_create_autocmd("BufReadPre", {
        pattern = "*",
        callback = function()
          local file_size = vim.fn.getfsize(vim.fn.expand("<afile>"))
          if file_size > 100000 or file_size == -2 then
            vim.b.copilot_enabled = false
          end
        end,
        desc = "Disable Copilot for large files"
      })
    end,
    keys = {
      {
        "<C-j>",
        'copilot#Accept("<CR>")',
        mode = "i",
        silent = true,
        expr = true,
        replace_keycodes = false,
        desc = "Accept"
      },
      {
        "cp",
        ":Copilot panel<CR>",
        mode = "n",
        silent = true,
        desc = "Open Copilot panel"
      },
      {
        "<C-]>",
        "copilot#Dismiss()",
        mode = "i",
        silent = true,
        expr = true,
        desc = "Dismiss"
      },
      {
        "<M-]>",
        "copilot#Next()",
        mode = "i",
        silent = true,
        expr = true,
        desc = "Next"
      },
      {
        "<M-[>",
        "copilot#Previous()",
        mode = "i",
        silent = true,
        expr = true,
        desc = "Previous"
      },
      {
        "<c-k><c-k>",
        "copilot#Suggest()",
        mode = "i",
        silent = false,
        expr = true,
        desc = "Suggest"
      },
      {
        "<c-w>",
        "<Plug>(copilot-accept-word)",
        mode = "i",
        silent = true,
        expr = false,
        desc = "Accept word"
      },
      {
        "<c-l>",
        "<Plug>(copilot-accept-line)",
        mode = "i",
        silent = true,
        expr = false,
        desc = "Accept line"
      }
    }
  },
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
