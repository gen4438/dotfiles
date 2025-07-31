return {
  {
    -- "robitx/gp.nvim",
    -- "tarruda/gp.nvim",
    "gen4438/gp.nvim",
    enabled = true,
    config = function()
      local config = {
        providers = {
          openai = {
            disable = false,
            endpoint = "https://api.openai.com/v1/chat/completions",
            -- secret = os.getenv("OPENAI_API_KEY"),
          },
          azure = {
            disable = true,
            endpoint = os.getenv("AZURE_API_ENDPOINT"),
            secret = os.getenv("AZURE_API_KEY"),
          },
          copilot = {
            disable = false,
            secret = (function()
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
              if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
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
                      return token
                    end
                  end
                end
              end
              
              return ""
            end)(),  -- Execute the function immediately to return a string
          },
        },

        -- curl_params = { "--proxy", "http://X.X.X.X:XXXX" },
        curl_params = (function()
          -- local params = { "--other-param", "value" }
          local params = {}
          if os.getenv("http_proxy") then
            table.insert(params, "--proxy")
            table.insert(params, os.getenv("http_proxy"))
          end
          return params
        end)(),
        -- directory for storing chat files
        -- chat_dir = vim.fn.stdpath("data"):gsub("/$", "") .. "/gp/chats",
        -- chat user prompt prefix

        agents = {

          {
            provider = "openai",
            name = "Chat OpenAI (o1-preview)",
            chat = true,
            command = false,
            -- string with model name or table with model name and parameters
            model = {
              model = "o1-preview",
              temperature = 1.1,
              top_p = 1,
            },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").chat_system_prompt,
          },
          {
            provider = "azure",
            name = "Code OpenAI (o1-preview)",
            chat = false,
            command = true,
            -- string with model name or table with model name and parameters
            model = {
              model = "o1-preview",
              temperature = 0.8,
              top_p = 1,
            },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").code_system_prompt,
          },

          {
            provider = "openai",
            name = "Chat OpenAI (o3-mini)",
            chat = true,
            command = false,
            -- string with model name or table with model name and parameters
            model = {
              model = "o3-mini",
              temperature = 1.1,
              top_p = 1,
            },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").chat_system_prompt,
          },
          {
            provider = "azure",
            name = "Code OpenAI (o3-mini)",
            chat = false,
            command = true,
            -- string with model name or table with model name and parameters
            model = {
              model = "o3-mini",
              temperature = 0.8,
              top_p = 1,
            },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").code_system_prompt,
          },

          {
            provider = "azure",
            name = "Chat Azure OpenAI (o3-mini)",
            chat = true,
            command = false,
            -- string with model name or table with model name and parameters
            model = {
              model = "o3-mini",
              temperature = 1.1,
              top_p = 1,
            },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").chat_system_prompt,
          },
          {
            provider = "azure",
            name = "Code Azure OpenAI (o3-mini)",
            chat = false,
            command = true,
            -- string with model name or table with model name and parameters
            -- model = { model = "gpt-4o", temperature = 0.8, top_p = 1 },
            model = {
              model = "o3-mini",
              temperature = 0.8,
              top_p = 1,
            },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").code_system_prompt,
          },

          {
            provider = "azure",
            name = "Chat Azure OpenAI (o1)",
            chat = true,
            command = false,
            -- string with model name or table with model name and parameters
            model = {
              model = "o1",
              temperature = 1.1,
              top_p = 1,
            },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").chat_system_prompt,
          },
          {
            provider = "azure",
            name = "Code Azure OpenAI (o1)",
            chat = false,
            command = true,
            -- string with model name or table with model name and parameters
            -- model = { model = "gpt-4o", temperature = 0.8, top_p = 1 },
            model = {
              model = "o1",
              temperature = 0.8,
              top_p = 1,
            },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").code_system_prompt,
          },

          {
            provider = "azure",
            name = "Chat Azure OpenAI (GPT4o)",
            chat = true,
            command = false,
            -- string with model name or table with model name and parameters
            model = {
              model = "gpt-4o",
              temperature = 1.1,
              top_p = 1,
            },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").chat_system_prompt,
          },
          {
            provider = "azure",
            name = "Code Azure OpenAI (GPT4o)",
            chat = false,
            command = true,
            -- string with model name or table with model name and parameters
            -- model = { model = "gpt-4o", temperature = 0.8, top_p = 1 },
            model = {
              model = "gpt-4o",
              temperature = 0.8,
              top_p = 1,
            },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").code_system_prompt,
          },

          {
            provider = "copilot",
            name = "Chat Copilot (o3-mini)",
            chat = true,
            command = false,
            -- string with model name or table with model name and parameters
            model = { model = "o3-mini", temperature = 1.1, top_p = 1 },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").chat_system_prompt,
          },
          {
            provider = "copilot",
            name = "Code Copilot (o3-mini)",
            chat = false,
            command = true,
            -- string with model name or table with model name and parameters
            model = { model = "o3-mini", temperature = 0.8, top_p = 1, n = 1 },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").code_system_prompt,
          },

          {
            provider = "copilot",
            name = "Chat Copilot (o1)",
            chat = true,
            command = false,
            -- string with model name or table with model name and parameters
            model = { model = "o1", temperature = 1.1, top_p = 1 },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").chat_system_prompt,
          },
          {
            provider = "copilot",
            name = "Code Copilot (o1)",
            chat = false,
            command = true,
            -- string with model name or table with model name and parameters
            model = { model = "o1", temperature = 0.8, top_p = 1, n = 1 },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").code_system_prompt,
          },

          {
            provider = "copilot",
            name = "Chat Copilot (o1-mini)",
            chat = true,
            command = false,
            -- string with model name or table with model name and parameters
            model = { model = "o1-mini", temperature = 1.1, top_p = 1 },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").chat_system_prompt,
          },

          {
            provider = "copilot",
            name = "Code Copilot (o1-mini)",
            chat = false,
            command = true,
            -- string with model name or table with model name and parameters
            model = { model = "o1-mini", temperature = 0.8, top_p = 1, n = 1 },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").code_system_prompt,
          },

          {
            provider = "copilot",
            name = "Chat Copilot (claude 3.7)",
            chat = true,
            command = false,
            -- string with model name or table with model name and parameters
            model = { model = "claude-3.7-sonnet", temperature = 1.1, top_p = 1 },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").chat_system_prompt,
          },
          {
            provider = "copilot",
            name = "Code Copilot (claude 3.7)",
            chat = false,
            command = true,
            -- string with model name or table with model name and parameters
            model = { model = "claude-3.7-sonnet", temperature = 0.8, top_p = 1, n = 1 },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").code_system_prompt,
          },

          {
            provider = "copilot",
            name = "Chat Copilot (claude 3.7 thought)",
            chat = true,
            command = false,
            -- string with model name or table with model name and parameters
            model = { model = "claude-3.7-sonnet-thought", temperature = 1.1, top_p = 1 },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").chat_system_prompt,
          },
          {
            provider = "copilot",
            name = "Code Copilot (claude 3.7 thought)",
            chat = false,
            command = true,
            -- string with model name or table with model name and parameters
            model = { model = "claude-3.7-sonnet-thought", temperature = 0.8, top_p = 1, n = 1 },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").code_system_prompt,
          },

          {
            provider = "copilot",
            name = "Chat Copilot (claude 3.5)",
            chat = true,
            command = false,
            -- string with model name or table with model name and parameters
            model = { model = "claude-3.5-sonnet", temperature = 1.1, top_p = 1 },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").chat_system_prompt,
          },
          {
            provider = "copilot",
            name = "Code Copilot (claude 3.5)",
            chat = false,
            command = true,
            -- string with model name or table with model name and parameters
            model = { model = "claude-3.5-sonnet", temperature = 0.8, top_p = 1, n = 1 },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").code_system_prompt,
          },

          {
            provider = "copilot",
            name = "Chat Copilot (gemini-2.0-flash-001)",
            chat = true,
            command = false,
            -- string with model name or table with model name and parameters
            model = { model = "gemini-2.0-flash-001", temperature = 1.1, top_p = 1 },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").chat_system_prompt,
          },
          {
            provider = "copilot",
            name = "Code Copilot (gemini-2.0-flash-001)",
            chat = false,
            command = true,
            -- string with model name or table with model name and parameters
            model = { model = "gemini-2.0-flash-001", temperature = 0.8, top_p = 1, n = 1 },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").code_system_prompt,
          },

          -- custom agents
          {
            provider = "copilot",
            name = "EnglishTranslator (Copilot)",
            chat = true,
            command = false,
            -- string with model name or table with model name and parameters
            model = {
              model = "gpt-4o",
              temperature = 1.1,
              top_p = 1,
            },
            system_prompt =
            'I want you to act as an English translator, spelling corrector and improver. I will speak to you in any language and you will detect the language, translate it and answer in the corrected and improved version of my text, in English. I want you to replace my simplified A0-level words and sentences with more beautiful and elegant, upper level English words and sentences. Keep the meaning same, but make them more literary. I want you to only reply the correction, the improvements and nothing else, do not write explanations.'
          },

          {
            provider = "copilot",
            name = "EnglishTeacher (Copilot)",
            chat = true,
            command = false,
            -- string with model name or table with model name and parameters
            model = {
              model = "gpt-4o",
              temperature = 1.1,
              top_p = 1,
            },
            system_prompt =
            "I want you to act as a spoken English teacher and improver. I will speak to you in English and you will reply to me in English to practice my spoken English. I want you to keep your reply neat, limiting the reply to 100 words. I want you to strictly correct my grammar mistakes, typos, and factual errors. I want you to ask me a question in your reply. Now let's start practicing, you could ask me a question first. Remember, I want you to strictly correct my grammar mistakes, typos, and factual errors.",
          },

          {
            provider = "copilot",
            name = "UXUIDeveloper (Copilot)",
            chat = true,
            command = false,
            -- string with model name or table with model name and parameters
            model = {
              model = "gpt-4o",
              temperature = 1.1,
              top_p = 1,
            },
            system_prompt =
            'I want you to act as a UX/UI developer. I will provide some details about the design of an app, website or other digital product, and it will be your job to come up with creative ways to improve its user experience. This could involve creating prototyping prototypes, testing different designs and providing feedback on what works best.',
          },
        },

        -- use prompt buftype for chats (:h prompt-buffer)
        chat_prompt_buf_type = false,

        -- chat_dir = vim.fn.stdpath("data"):gsub("/$", "") .. "/gp/chats",
        -- chat_dir = vim.env.MEMO_DIR .. "/chats",

        -- default agent names set during startup, if nil last used agent is used
        -- default_command_agent = "CodeCopilot",
        -- default_chat_agent = "ChatCopilot",

        chat_conceal_model_params = false,

        -- example hook functions (see Extend functionality section in the README)
        hooks = {

          -- your own functions can go here, see README for more examples like
          -- :GpExplain, :GpUnitTests.., :GpTranslator etc.

          -- -- example of making :%GpChatNew a dedicated command which
          -- -- opens new chat with the entire current buffer as a context
          -- BufferChatNew = function(gp, _)
          -- 	-- call GpChatNew command in range mode on whole buffer
          -- 	vim.api.nvim_command("%" .. gp.config.cmd_prefix .. "ChatNew")
          -- end,

          -- -- example of adding command which opens new chat dedicated for translation
          -- Translator = function(gp, params)
          -- 	local chat_system_prompt = "You are a Translator, please translate between English and Chinese."
          -- 	gp.cmd.ChatNew(params, chat_system_prompt)
          --
          -- 	-- -- you can also create a chat with a specific fixed agent like this:
          -- 	-- local agent = gp.get_chat_agent("ChatGPT4o")
          -- 	-- gp.cmd.ChatNew(params, chat_system_prompt, agent)
          -- end,

          -- -- example of adding command which writes unit tests for the selected code
          -- UnitTests = function(gp, params)
          -- 	local template = "I have the following code from {{filename}}:\n\n"
          -- 		.. "```{{filetype}}\n{{selection}}\n```\n\n"
          -- 		.. "Please respond by writing table driven unit tests for the code above."
          -- 	local agent = gp.get_command_agent()
          -- 	gp.Prompt(params, gp.Target.enew, agent, template)
          -- end,

          -- -- example of adding command which explains the selected code
          -- Explain = function(gp, params)
          -- 	local template = "I have the following code from {{filename}}:\n\n"
          -- 		.. "```{{filetype}}\n{{selection}}\n```\n\n"
          -- 		.. "Please respond by explaining the code above."
          -- 	local agent = gp.get_chat_agent()
          -- 	gp.Prompt(params, gp.Target.popup, agent, template)
          -- end,
        },
      }
      require("gp").setup(config)

      -- fzf-lua setup
      vim.api.nvim_create_user_command("GpSelectAgent", function()
        local buf = vim.api.nvim_get_current_buf()
        local file_name = vim.api.nvim_buf_get_name(buf)
        local is_chat = require("gp").not_chat(buf, file_name) == nil
        local models = is_chat and require("gp")._chat_agents or require("gp")._command_agents
        local prompt_title = is_chat and 'Chat Models' or 'Completion Models'
        require("fzf-lua").fzf_exec(models, {
          prompt = prompt_title,
          actions = {
            ["default"] = function(selected, _)
              require("gp").cmd.Agent({ args = selected[1] })
            end,
          },
        })
      end, {})

      -- Setup shortcuts here (see Usage > Shortcuts in the Documentation/Readme)

      -- local function keymapOptions(desc)
      --   return {
      --     noremap = true,
      --     silent = true,
      --     nowait = true,
      --     desc = "GPT prompt " .. desc,
      --   }
      -- end

      -- -- Chat commands
      -- vim.keymap.set({ "n", "i" }, "<C-g>c", "<cmd>GpChatNew<cr>", keymapOptions("New Chat"))
      -- vim.keymap.set({ "n", "i" }, "<C-g>t", "<cmd>GpChatToggle<cr>", keymapOptions("Toggle Chat"))
      -- vim.keymap.set({ "n", "i" }, "<C-g>f", "<cmd>GpChatFinder<cr>", keymapOptions("Chat Finder"))

      -- vim.keymap.set("v", "<C-g>c", ":<C-u>'<,'>GpChatNew<cr>", keymapOptions("Visual Chat New"))
      -- vim.keymap.set("v", "<C-g>p", ":<C-u>'<,'>GpChatPaste<cr>", keymapOptions("Visual Chat Paste"))
      -- vim.keymap.set("v", "<C-g>t", ":<C-u>'<,'>GpChatToggle<cr>", keymapOptions("Visual Toggle Chat"))

      -- vim.keymap.set({ "n", "i" }, "<C-g><C-x>", "<cmd>GpChatNew split<cr>", keymapOptions("New Chat split"))
      -- vim.keymap.set({ "n", "i" }, "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>", keymapOptions("New Chat vsplit"))
      -- vim.keymap.set({ "n", "i" }, "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>", keymapOptions("New Chat tabnew"))

      -- vim.keymap.set("v", "<C-g><C-x>", ":<C-u>'<,'>GpChatNew split<cr>", keymapOptions("Visual Chat New split"))
      -- vim.keymap.set("v", "<C-g><C-v>", ":<C-u>'<,'>GpChatNew vsplit<cr>", keymapOptions("Visual Chat New vsplit"))
      -- vim.keymap.set("v", "<C-g><C-t>", ":<C-u>'<,'>GpChatNew tabnew<cr>", keymapOptions("Visual Chat New tabnew"))

      -- -- Prompt commands
      -- vim.keymap.set({ "n", "i" }, "<C-g>r", "<cmd>GpRewrite<cr>", keymapOptions("Inline Rewrite"))
      -- vim.keymap.set({ "n", "i" }, "<C-g>a", "<cmd>GpAppend<cr>", keymapOptions("Append (after)"))
      -- vim.keymap.set({ "n", "i" }, "<C-g>b", "<cmd>GpPrepend<cr>", keymapOptions("Prepend (before)"))

      -- vim.keymap.set("v", "<C-g>r", ":<C-u>'<,'>GpRewrite<cr>", keymapOptions("Visual Rewrite"))
      -- vim.keymap.set("v", "<C-g>a", ":<C-u>'<,'>GpAppend<cr>", keymapOptions("Visual Append (after)"))
      -- vim.keymap.set("v", "<C-g>b", ":<C-u>'<,'>GpPrepend<cr>", keymapOptions("Visual Prepend (before)"))
      -- vim.keymap.set("v", "<C-g>i", ":<C-u>'<,'>GpImplement<cr>", keymapOptions("Implement selection"))

      -- vim.keymap.set({ "n", "i" }, "<C-g>gp", "<cmd>GpPopup<cr>", keymapOptions("Popup"))
      -- vim.keymap.set({ "n", "i" }, "<C-g>ge", "<cmd>GpEnew<cr>", keymapOptions("GpEnew"))
      -- vim.keymap.set({ "n", "i" }, "<C-g>gn", "<cmd>GpNew<cr>", keymapOptions("GpNew"))
      -- vim.keymap.set({ "n", "i" }, "<C-g>gv", "<cmd>GpVnew<cr>", keymapOptions("GpVnew"))
      -- vim.keymap.set({ "n", "i" }, "<C-g>gt", "<cmd>GpTabnew<cr>", keymapOptions("GpTabnew"))

      -- vim.keymap.set("v", "<C-g>gp", ":<C-u>'<,'>GpPopup<cr>", keymapOptions("Visual Popup"))
      -- vim.keymap.set("v", "<C-g>ge", ":<C-u>'<,'>GpEnew<cr>", keymapOptions("Visual GpEnew"))
      -- vim.keymap.set("v", "<C-g>gn", ":<C-u>'<,'>GpNew<cr>", keymapOptions("Visual GpNew"))
      -- vim.keymap.set("v", "<C-g>gv", ":<C-u>'<,'>GpVnew<cr>", keymapOptions("Visual GpVnew"))
      -- vim.keymap.set("v", "<C-g>gt", ":<C-u>'<,'>GpTabnew<cr>", keymapOptions("Visual GpTabnew"))

      -- vim.keymap.set({ "n", "i" }, "<C-g>x", "<cmd>GpContext<cr>", keymapOptions("Toggle Context"))
      -- vim.keymap.set("v", "<C-g>x", ":<C-u>'<,'>GpContext<cr>", keymapOptions("Visual Toggle Context"))

      -- vim.keymap.set({ "n", "i", "v", "x" }, "<C-g>s", "<cmd>GpStop<cr>", keymapOptions("Stop"))
      -- vim.keymap.set({ "n", "i", "v", "x" }, "<C-g>n", "<cmd>GpNextAgent<cr>", keymapOptions("Next Agent"))

      require("which-key").add({
        -- VISUAL mode mappings
        -- s, x, v modes are handled the same way by which_key
        {
          mode = { "v" },
          nowait = true,
          remap = false,
          { "<C-g><C-t>", ":<C-u>'<,'>GpChatNew tabnew<cr>", desc = "ChatNew tabnew" },
          { "<C-g><C-v>", ":<C-u>'<,'>GpChatNew vsplit<cr>", desc = "ChatNew vsplit" },
          { "<C-g><C-x>", ":<C-u>'<,'>GpChatNew split<cr>",  desc = "ChatNew split" },
          { "<C-g>a",     ":<C-u>'<,'>GpAppend<cr>",         desc = "Visual Append (after)" },
          { "<C-g>b",     ":<C-u>'<,'>GpPrepend<cr>",        desc = "Visual Prepend (before)" },
          { "<C-g>c",     ":<C-u>'<,'>GpChatNew<cr>",        desc = "Visual Chat New" },
          { "<C-g>g",     group = "generate into new .." },
          { "<C-g>ge",    ":<C-u>'<,'>GpEnew<cr>",           desc = "Visual GpEnew" },
          { "<C-g>gn",    ":<C-u>'<,'>GpNew<cr>",            desc = "Visual GpNew" },
          { "<C-g>gp",    ":<C-u>'<,'>GpPopup<cr>",          desc = "Visual Popup" },
          { "<C-g>gt",    ":<C-u>'<,'>GpTabnew<cr>",         desc = "Visual GpTabnew" },
          { "<C-g>gv",    ":<C-u>'<,'>GpVnew<cr>",           desc = "Visual GpVnew" },
          { "<C-g>i",     ":<C-u>'<,'>GpImplement<cr>",      desc = "Implement selection" },
          { "<C-g>n",     "<cmd>GpSelectAgent<cr>",          desc = "Select Agent" },
          { "<C-g>p",     ":<C-u>'<,'>GpChatPaste<cr>",      desc = "Visual Chat Paste" },
          { "<C-g>r",     ":<C-u>'<,'>GpRewrite<cr>",        desc = "Visual Rewrite" },
          { "<C-g>s",     "<cmd>GpStop<cr>",                 desc = "GpStop" },
          { "<C-g>t",     ":<C-u>'<,'>GpChatToggle<cr>",     desc = "Visual Toggle Chat" },
          { "<C-g>w",     group = "Whisper" },
          { "<C-g>wa",    ":<C-u>'<,'>GpWhisperAppend<cr>",  desc = "Whisper Append" },
          { "<C-g>wb",    ":<C-u>'<,'>GpWhisperPrepend<cr>", desc = "Whisper Prepend" },
          { "<C-g>we",    ":<C-u>'<,'>GpWhisperEnew<cr>",    desc = "Whisper Enew" },
          { "<C-g>wn",    ":<C-u>'<,'>GpWhisperNew<cr>",     desc = "Whisper New" },
          { "<C-g>wp",    ":<C-u>'<,'>GpWhisperPopup<cr>",   desc = "Whisper Popup" },
          { "<C-g>wr",    ":<C-u>'<,'>GpWhisperRewrite<cr>", desc = "Whisper Rewrite" },
          { "<C-g>wt",    ":<C-u>'<,'>GpWhisperTabnew<cr>",  desc = "Whisper Tabnew" },
          { "<C-g>wv",    ":<C-u>'<,'>GpWhisperVnew<cr>",    desc = "Whisper Vnew" },
          { "<C-g>ww",    ":<C-u>'<,'>GpWhisper<cr>",        desc = "Whisper" },
          { "<C-g>x",     ":<C-u>'<,'>GpContext<cr>",        desc = "Visual GpContext" },
        },

        -- NORMAL mode mappings
        {
          mode = { "n" },
          nowait = true,
          remap = false,
          { "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>",   desc = "New Chat tabnew" },
          { "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>",   desc = "New Chat vsplit" },
          { "<C-g><C-x>", "<cmd>GpChatNew split<cr>",    desc = "New Chat split" },
          { "<C-g>a",     "<cmd>GpAppend<cr>",           desc = "Append (after)" },
          { "<C-g>b",     "<cmd>GpPrepend<cr>",          desc = "Prepend (before)" },
          { "<C-g>c",     "<cmd>GpChatNew<cr>",          desc = "New Chat" },
          { "<C-g>f",     "<cmd>GpChatFinder<cr>",       desc = "Chat Finder" },
          { "<C-g>g",     group = "generate into new .." },
          { "<C-g>ge",    "<cmd>GpEnew<cr>",             desc = "GpEnew" },
          { "<C-g>gn",    "<cmd>GpNew<cr>",              desc = "GpNew" },
          { "<C-g>gp",    "<cmd>GpPopup<cr>",            desc = "Popup" },
          { "<C-g>gt",    "<cmd>GpTabnew<cr>",           desc = "GpTabnew" },
          { "<C-g>gv",    "<cmd>GpVnew<cr>",             desc = "GpVnew" },
          { "<C-g>n",     "<cmd>GpSelectAgent<cr>",      desc = "Select Agent" },
          { "<C-g>r",     "<cmd>GpRewrite<cr>",          desc = "Inline Rewrite" },
          { "<C-g>s",     "<cmd>GpStop<cr>",             desc = "GpStop" },
          { "<C-g>t",     "<cmd>GpChatToggle<cr>",       desc = "Toggle Chat" },
          { "<C-g>w",     group = "Whisper" },
          { "<C-g>wa",    "<cmd>GpWhisperAppend<cr>",    desc = "Whisper Append (after)" },
          { "<C-g>wb",    "<cmd>GpWhisperPrepend<cr>",   desc = "Whisper Prepend (before)" },
          { "<C-g>we",    "<cmd>GpWhisperEnew<cr>",      desc = "Whisper Enew" },
          { "<C-g>wn",    "<cmd>GpWhisperNew<cr>",       desc = "Whisper New" },
          { "<C-g>wp",    "<cmd>GpWhisperPopup<cr>",     desc = "Whisper Popup" },
          { "<C-g>wr",    "<cmd>GpWhisperRewrite<cr>",   desc = "Whisper Inline Rewrite" },
          { "<C-g>wt",    "<cmd>GpWhisperTabnew<cr>",    desc = "Whisper Tabnew" },
          { "<C-g>wv",    "<cmd>GpWhisperVnew<cr>",      desc = "Whisper Vnew" },
          { "<C-g>ww",    "<cmd>GpWhisper<cr>",          desc = "Whisper" },
          { "<C-g>x",     "<cmd>GpContext<cr>",          desc = "Toggle GpContext" },
        },

        -- INSERT mode mappings
        {
          mode = { "i" },
          nowait = true,
          remap = false,
          { "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>",   desc = "New Chat tabnew" },
          { "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>",   desc = "New Chat vsplit" },
          { "<C-g><C-x>", "<cmd>GpChatNew split<cr>",    desc = "New Chat split" },
          { "<C-g>a",     "<cmd>GpAppend<cr>",           desc = "Append (after)" },
          { "<C-g>b",     "<cmd>GpPrepend<cr>",          desc = "Prepend (before)" },
          { "<C-g>c",     "<cmd>GpChatNew<cr>",          desc = "New Chat" },
          { "<C-g>f",     "<cmd>GpChatFinder<cr>",       desc = "Chat Finder" },
          { "<C-g>g",     group = "generate into new .." },
          { "<C-g>ge",    "<cmd>GpEnew<cr>",             desc = "GpEnew" },
          { "<C-g>gn",    "<cmd>GpNew<cr>",              desc = "GpNew" },
          { "<C-g>gp",    "<cmd>GpPopup<cr>",            desc = "Popup" },
          { "<C-g>gt",    "<cmd>GpTabnew<cr>",           desc = "GpTabnew" },
          { "<C-g>gv",    "<cmd>GpVnew<cr>",             desc = "GpVnew" },
          { "<C-g>n",     "<cmd>GpSelectAgent<cr>",      desc = "Select Agent" },
          { "<C-g>r",     "<cmd>GpRewrite<cr>",          desc = "Inline Rewrite" },
          { "<C-g>s",     "<cmd>GpStop<cr>",             desc = "GpStop" },
          { "<C-g>t",     "<cmd>GpChatToggle<cr>",       desc = "Toggle Chat" },
          { "<C-g>w",     group = "Whisper" },
          { "<C-g>wa",    "<cmd>GpWhisperAppend<cr>",    desc = "Whisper Append (after)" },
          { "<C-g>wb",    "<cmd>GpWhisperPrepend<cr>",   desc = "Whisper Prepend (before)" },
          { "<C-g>we",    "<cmd>GpWhisperEnew<cr>",      desc = "Whisper Enew" },
          { "<C-g>wn",    "<cmd>GpWhisperNew<cr>",       desc = "Whisper New" },
          { "<C-g>wp",    "<cmd>GpWhisperPopup<cr>",     desc = "Whisper Popup" },
          { "<C-g>wr",    "<cmd>GpWhisperRewrite<cr>",   desc = "Whisper Inline Rewrite" },
          { "<C-g>wt",    "<cmd>GpWhisperTabnew<cr>",    desc = "Whisper Tabnew" },
          { "<C-g>wv",    "<cmd>GpWhisperVnew<cr>",      desc = "Whisper Vnew" },
          { "<C-g>ww",    "<cmd>GpWhisper<cr>",          desc = "Whisper" },
          { "<C-g>x",     "<cmd>GpContext<cr>",          desc = "Toggle GpContext" },
        },
      })

      -- move cursor to user prompt and AI response
      local function goto_marker(marker, backward)
        local cur_cursor = vim.api.nvim_win_get_cursor(0)
        local cur_row = cur_cursor[1]
        local line_count = vim.api.nvim_buf_line_count(0)

        local start
        -- wrap around
        if backward then
          start = cur_row - 1
          if start < 1 then
            start = line_count
          end
        else
          start = cur_row + 1
          if start > line_count then
            start = 1
          end
        end

        -- 検索開始位置に一度カーソルを移動
        vim.api.nvim_win_set_cursor(0, { start, 0 })

        local flags = backward and "b" or ""
        local pattern = "^\\V" .. marker

        local target = vim.fn.search(pattern, flags)
        if target == 0 then
          vim.notify("No marker (" .. marker .. ") found", vim.log.levels.INFO)
          vim.api.nvim_win_set_cursor(0, cur_cursor)
          return
        end
        vim.api.nvim_win_set_cursor(0, { target, 0 })
      end

      -- mappings
      vim.keymap.set("n", "[u", function()
        goto_marker("💬:", true)
      end, { noremap = true, silent = true, desc = "Goto previous user prompt" })

      vim.keymap.set("n", "]u", function()
        goto_marker("💬:", false)
      end, { noremap = true, silent = true, desc = "Goto next user prompt" })

      vim.keymap.set("n", "[r", function()
        goto_marker("🤖:", true)
      end, { noremap = true, silent = true, desc = "Goto previous AI response" })

      vim.keymap.set("n", "]r", function()
        goto_marker("🤖:", false)
      end, { noremap = true, silent = true, desc = "Goto next AI response" })
    end,
  }
}
