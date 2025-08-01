return {
  {
    "jackMort/ChatGPT.nvim",
    enabled = false, -- ほぼコメントアウトされているため無効化
    lazy = true,
    config = function()
      require("chatgpt").setup(

        {
          -- api_key_cmd = nil,
          -- yank_register = "+",
          -- extra_curl_params = nil,
          -- show_line_numbers = true,
          -- edit_with_instructions = {
          --   diff = false,
          --   keymaps = {
          --     close = "<C-c>",
          --     close_n = "<Esc>",
          --     accept = "<C-y>",
          --     yank = "<C-u>",
          --     toggle_diff = "<C-d>",
          --     toggle_settings = "<C-o>",
          --     toggle_help = "<C-h>",
          --     cycle_windows = "<Tab>",
          --     use_output_as_input = "<C-i>",
          --   },
          -- },
          chat = {
            -- default_system_message = "",
            -- loading_text = "Loading, please wait ...",
            -- question_sign = "", -- 🙂
            -- answer_sign = "ﮧ", -- 🤖
            -- border_left_sign = "",
            -- border_right_sign = "",
            -- max_line_length = 120,
            -- sessions_window = {
            --   active_sign = "  ",
            --   inactive_sign = "  ",
            --   current_line_sign = "",
            --   border = {
            --     style = "rounded",
            --     text = {
            --       top = " Sessions ",
            --     },
            --   },
            --   win_options = {
            --     winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
            --   },
            -- },
            keymaps = {
              close = nil,
              close_n = "q",
              yank_last = "yl",
              yank_last_code = "yk",
              -- scroll_up = "<C-u>",
              -- scroll_down = "<C-d>",
              new_session = "<c-c><c-l>",
              -- cycle_windows = "<Tab>",
              -- cycle_modes = "<C-f>",
              -- next_message = "<C-j>",
              -- prev_message = "<C-k>",
              -- select_session = "<Space>",
              -- rename_session = "r",
              -- delete_session = "d",
              -- draft_message = "<C-r>",
              -- edit_message = "e",
              -- delete_message = "d",
              -- toggle_settings = "<C-o>",
              -- toggle_sessions = "<C-p>",
              -- toggle_help = "<C-h>",
              -- toggle_message_role = "<C-r>",
              -- toggle_system_role_open = "<C-s>",
              -- stop_generating = "<C-x>",
            },
          },
          -- popup_layout = {
          --   default = "center",
          --   center = {
          --     width = "80%",
          --     height = "80%",
          --   },
          --   right = {
          --     width = "30%",
          --     width_settings_open = "50%",
          --   },
          -- },
          -- popup_window = {
          --   border = {
          --     highlight = "FloatBorder",
          --     style = "rounded",
          --     text = {
          --       top = " ChatGPT ",
          --     },
          --   },
          --   win_options = {
          --     wrap = true,
          --     linebreak = true,
          --     foldcolumn = "1",
          --     winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
          --   },
          --   buf_options = {
          --     filetype = "markdown",
          --   },
          -- },
          -- system_window = {
          --   border = {
          --     highlight = "FloatBorder",
          --     style = "rounded",
          --     text = {
          --       top = " SYSTEM ",
          --     },
          --   },
          --   win_options = {
          --     wrap = true,
          --     linebreak = true,
          --     foldcolumn = "2",
          --     winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
          --   },
          -- },
          -- popup_input = {
          --   prompt = "  ",
          --   border = {
          --     highlight = "FloatBorder",
          --     style = "rounded",
          --     text = {
          --       top_align = "center",
          --       top = " Prompt ",
          --     },
          --   },
          --   win_options = {
          --     winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
          --   },
          --   submit = "<C-Enter>",
          --   submit_n = "<Enter>",
          --   max_visible_lines = 20,
          -- },
          -- settings_window = {
          --   setting_sign = "  ",
          --   border = {
          --     style = "rounded",
          --     text = {
          --       top = " Settings ",
          --     },
          --   },
          --   win_options = {
          --     winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
          --   },
          -- },
          -- help_window = {
          --   setting_sign = "  ",
          --   border = {
          --     style = "rounded",
          --     text = {
          --       top = " Help ",
          --     },
          --   },
          --   win_options = {
          --     winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
          --   },
          -- },
          -- openai_params = {
          --   model = "gpt-3.5-turbo",
          --   frequency_penalty = 0,
          --   presence_penalty = 0,
          --   max_tokens = 300,
          --   temperature = 0,
          --   top_p = 1,
          --   n = 1,
          -- },
          -- openai_edit_params = {
          --   model = "gpt-3.5-turbo",
          --   frequency_penalty = 0,
          --   presence_penalty = 0,
          --   temperature = 0,
          --   top_p = 1,
          --   n = 1,
          -- },
          -- use_openai_functions_for_edits = false,
          -- ignore_default_actions_path = false,
          -- actions_paths = {},
          -- show_quickfixes_cmd = default_quickfix_cmd(),
          -- predefined_chat_gpt_prompts = "https://raw.githubusercontent.com/f/awesome-chatgpt-prompts/main/prompts.csv",
          -- highlights = {
          --   help_key = "@symbol",
          --   help_description = "@comment",
          --   params_value = "Identifier",
          --   input_title = "FloatBorder",
          --   active_session = "ErrorMsg",
          --   code_edit_result_title = "FloatBorder",
          -- },
        }
      )
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim", -- optional
      "nvim-telescope/telescope.nvim"
    },
    cmd = {
      "ChatGPT",
      "ChatGPTActAs",
      "ChatGPTEditWithInstructions",
      "ChatGPTRun",
    },
    -- keys = {
    --   { ";cC", ":ChatGPT<CR>" },
    --   { ";cA", ":ChatGPTActAs<CR>" },
    --   { ";cE", ":ChatGPTEditWithInstructions<CR>" },
    --   { ";cR", ":ChatGPTRun<CR>" },
    -- }
  }
}
