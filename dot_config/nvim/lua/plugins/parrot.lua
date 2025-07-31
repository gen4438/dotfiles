return {
  {
    "frankroeder/parrot.nvim",
    dependencies = { "ibhagwan/fzf-lua", "nvim-lua/plenary.nvim" },
    enabled = false,
    lazy = true,
    event = "VeryLazy",
    keys = {

      -- Normal and Insert mode mappings
      { "<C-g><c-g>", "<cmd>PrtChatRespond<cr>",       mode = { "n", "i" },           desc = "Respond" },
      { "<C-g>c",     "<cmd>PrtChatNew<cr>",           mode = { "n", "i" },           desc = "New Chat" },
      { "<C-g>t",     "<cmd>PrtChatToggle tabnew<cr>", mode = { "n", "i" },           desc = "Toggle Popup Chat" },
      { "<C-g>f",     "<cmd>PrtChatFinder<cr>",        mode = { "n", "i" },           desc = "Chat Finder" },
      { "<C-g>d",     "<cmd>PrtChatDelete<cr>",        mode = { "n", "i" },           desc = "Delete Chat" },
      { "<C-g>r",     "<cmd>PrtRewrite<cr>",           mode = { "n", "i" },           desc = "Inline Rewrite" },
      { "<C-g>a",     "<cmd>PrtAppend<cr>",            mode = { "n", "i" },           desc = "Append" },
      { "<C-g>o",     "<cmd>PrtPrepend<cr>",           mode = { "n", "i" },           desc = "Prepend" },

      -- Visual mode mappings
      { "<C-g>p",     "<cmd>PrtChatPaste<cr>",         mode = "v",                    desc = "Visual Chat Paste" },
      { "<C-g>c",     "<cmd>PrtChatNew<cr>",           mode = "v",                    desc = "Visual Chat New" },
      { "<C-g>r",     "<cmd>PrtRewrite<cr>",           mode = "v",                    desc = "Visual Rewrite" },
      { "<C-g>a",     "<cmd>PrtAppend<cr>",            mode = "v",                    desc = "Visual Append" },
      { "<C-g>o",     "<cmd>PrtPrepend<cr>",           mode = "v",                    desc = "Visual Prepend" },
      { "<C-g>e",     "<cmd>PrtEnew<cr>",              mode = "v",                    desc = "Visual Enew" },
      { "<C-g>.",     "<cmd>PrtRetry<cr>",             mode = "v",                    desc = "Visual Retry" },

      -- Additional mappings
      { "<C-g>s",     "<cmd>PrtStop<cr>",              mode = { "n", "i", "v", "x" }, desc = "Stop" },
      { "<C-g>i",     "<cmd>PrtComplete<cr>",          mode = { "n", "i", "v", "x" }, desc = "Complete the visual selection" },

      -- Context and agent/provider selection mappings
      { "<C-g>x",     "<cmd>PrtContext<cr>",           mode = "n",                    desc = "Open file with custom context" },
      { "<C-g>A",     "<cmd>PrtAgent<cr>",             mode = "n",                    desc = "Select agent or show info" },
      { "<C-g>P",     "<cmd>PrtProvider<cr>",          mode = "n",                    desc = "Select provider or show info" },
      { "<C-g>m",     "<cmd>PrtModel<cr>",             mode = "n",                    desc = "Select model or show info" },
      { "<C-g>?",     "<cmd>PrtStatus<cr>",            mode = "n",                    desc = "Prints current provider and model selection" },
    },

    config = function()
      local parrot = require("parrot")

      -- GitHub のトークンを取得 / Get GitHub token
      local github_token = ""
      
      -- Helper function to extract token from JSON
      local function extract_github_token(json_str)
        if json_str then
          local token = json_str:match('"oauth_token"%s*:%s*"([^"]+)"')
          return token or ""
        end
        return ""
      end
      
      -- Cross-platform GitHub Copilot config paths
      local config_paths = {}
      if vim.fn.has('win32') == 1 then
        local localappdata = vim.env.LOCALAPPDATA or vim.env.USERPROFILE .. "\\AppData\\Local"
        config_paths = {
          localappdata .. "\\github-copilot\\apps.json",
          localappdata .. "\\github-copilot\\hosts.json",
        }
      else
        config_paths = {
          vim.fn.expand("~/.config/github-copilot/apps.json"),
          vim.fn.expand("~/.config/github-copilot/hosts.json"),
        }
      end
      
      -- Try to read token from config files
      for _, path in ipairs(config_paths) do
        if vim.fn.filereadable(path) == 1 then
          local file = io.open(path, "r")
          if file then
            local content = file:read("*all")
            file:close()
            local token = extract_github_token(content)
            if token ~= "" then
              github_token = token
              break
            end
          end
        end
      end

      parrot.setup({
        providers                      = {
          -- azure = {
          --   api_key = os.getenv("AZURE_API_KEY"),
          --   endpoint = os.getenv("AZURE_API_ENDPOINT"),
          -- },
          github = {
            api_key = github_token,
          },
        },

        cmd_prefix                     = "Prt",
        curl_params                    = (function()
          local params = {}
          if os.getenv("http_proxy") then
            table.insert(params, "--proxy")
            table.insert(params, os.getenv("http_proxy"))
          end
          return params
        end)(),

        state_dir                      = vim.loop.fs_realpath(vim.fn.stdpath("data"):gsub("/$", "") .. "/parrot/persisted"),
        chat_dir                       = vim.loop.fs_realpath(vim.fn.stdpath("data"):gsub("/$", "") .. "/parrot/chats"),

        chat_user_prefix               = "🗨:",
        llm_prefix                     = "🦜:",
        chat_confirm_delete            = true,
        online_model_selection         = false,

        chat_shortcut_respond          = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g><C-g>" },
        chat_shortcut_delete           = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>d" },
        chat_shortcut_stop             = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>s" },
        chat_shortcut_new              = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>c" },

        chat_free_cursor               = false,
        chat_prompt_buf_type           = false,
        toggle_target                  = "vsplit",
        user_input_ui                  = "native",

        style_popup_border             = "single",
        style_popup_margin_bottom      = 8,
        style_popup_margin_left        = 1,
        style_popup_margin_right       = 2,
        style_popup_margin_top         = 2,
        style_popup_max_width          = 160,

        command_prompt_prefix_template = "🤖 {{llm}} ~ ",
        command_auto_select_response   = true,

        fzf_lua_opts                   = {
          ["--ansi"] = true,
          ["--sort"] = "",
          ["--info"] = "inline",
          ["--layout"] = "reverse",
          ["--preview-window"] = "nohidden:right:75%",
        },

        enable_spinner                 = true,
        spinner_type                   = "star",
        show_context_hints             = true,
      })

      -- 以下、補助的なカーソル移動関数とキーマッピング（必要に応じて）
      local function goto_marker(marker, backward)
        local cur_cursor = vim.api.nvim_win_get_cursor(0)
        local cur_row = cur_cursor[1]
        local line_count = vim.api.nvim_buf_line_count(0)
        local start = backward and (cur_row - 1) or (cur_row + 1)
        if start < 1 then start = line_count end
        if start > line_count then start = 1 end
        vim.api.nvim_win_set_cursor(0, { start, 0 })
        local flags = backward and "b" or ""
        local pattern = "^" .. vim.pesc(marker)
        local target = vim.fn.search(pattern, flags)
        if target == 0 then
          vim.notify("Marker (" .. marker .. ") not found", vim.log.levels.INFO)
          vim.api.nvim_win_set_cursor(0, cur_cursor)
          return
        end
        vim.api.nvim_win_set_cursor(0, { target, 0 })
      end

      vim.keymap.set("n", "[u", function()
        goto_marker("🗨:", true)
      end, { noremap = true, silent = true, desc = "前のユーザープロンプトへ移動" })

      vim.keymap.set("n", "]u", function()
        goto_marker("🗨:", false)
      end, { noremap = true, silent = true, desc = "次のユーザープロンプトへ移動" })

      vim.keymap.set("n", "[r", function()
        goto_marker("🦜:", true)
      end, { noremap = true, silent = true, desc = "前の LLM 応答へ移動" })

      vim.keymap.set("n", "]r", function()
        goto_marker("🦜:", false)
      end, { noremap = true, silent = true, desc = "次の LLM 応答へ移動" })
    end,
  }
}
