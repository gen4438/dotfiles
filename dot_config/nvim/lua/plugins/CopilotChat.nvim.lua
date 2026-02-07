return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    lazy = true,
    dependencies = {
      { "nvim-lua/plenary.nvim" } -- for curl, log wrapper
    },
    build = "make tiktoken",      -- Only on MacOS or Linux

    config = function()
      local select = require('CopilotChat.select')
      require('CopilotChat').setup({
        -- Shared config (can be passed to functions at runtime)
        model = "oswe-vscode-prime", -- AI model: 'gpt-4.1', 'gpt-4o', 'claude-3.5-sonnet', 'o3-mini', etc.
        temperature = 0.1,           -- Controls creativity (0.1 = focused, higher = creative)
        sticky = nil,                -- Default sticky prompt or array of sticky prompts to use at start of every new chat.
        remember_as_sticky = true,   -- Remember model/agent/context as sticky prompts when asking questions

        diff = 'block',              -- Diff format: 'block' (side-by-side) or 'unified' (traditional)
        language = 'English',        -- Language for AI responses

        -- default window options
        window = {
          layout = 'vertical',    -- 'vertical', 'horizontal', 'float', 'replace'
          width = 0.5,            -- fractional width of parent, or absolute width in columns when > 1
          height = 0.5,           -- fractional height of parent, or absolute height in rows when > 1
          -- Options below only apply to floating windows
          relative = 'editor',    -- 'editor', 'win', 'cursor', 'mouse'
          border = 'single',      -- 'none', single', 'double', 'rounded', 'solid', 'shadow'
          row = nil,              -- row position of the window, default is centered
          col = nil,              -- column position of the window, default is centered
          title = 'Copilot Chat', -- title of chat window
          footer = nil,           -- footer of chat window
          zindex = 1,             -- determines if window is on top or below other floating windows
        },

        auto_insert_mode = false, -- Automatically enter insert mode when opening window and on new prompt
        auto_fold = false,        -- Automatically collapse non-assistant messages

        -- Static config starts here (can be configured only via setup function)
        debug = false,                                                      -- Enable debug logging (same as 'log_level = 'debug')
        log_level = 'info',                                                 -- Log level to use, 'trace', 'debug', 'info', 'warn', 'error', 'fatal'
        proxy = os.getenv("http_proxy") or os.getenv("https_proxy") or nil, -- [protocol://]host[:port] Use this proxy
        allow_insecure = false,                                             -- Allow insecure server connections

        history_path = vim.fn.stdpath('data') .. '/copilotchat_history',    -- Default path to stored history

        -- default prompts
        -- see config/prompts.lua for implementation
        prompts = {
          CommitJp = {
            prompt =
            '##git://diff/staged\n\nコミットメッセージを作成してください。Commitizen の規約に従ってください。タイトルは最大50文字にし、メッセージは72文字で改行してください。メッセージ全体を `gitcommit` 言語を指定してコードブロックで囲ってください。日本語で記載してください。',
            context = 'git:staged',
          },
          -- custom prompt
          -- https://github.com/f/awesome-chatgpt-prompts
          EnglishTranslator = {
            system_prompt =
            "I want you to act as an English translator, spelling corrector and improver. I will speak to you in any language and you will detect the language, translate it and answer in the corrected and improved version of my text, in English. I want you to replace my simplified A0-level words and sentences with more beautiful and elegant, upper level English words and sentences. Keep the meaning same, but make them more literary. I want you to only reply the correction, the improvements and nothing else, do not write explanations.",
            prompt = 'Translate the text to English and improve it.',
          },
          EnglishTeacher = {
            system_prompt =
            "I want you to act as a spoken English teacher and improver. I will speak to you in English and you will reply to me in English to practice my spoken English. I want you to keep your reply neat, limiting the reply to 100 words. I want you to strictly correct my grammar mistakes, typos, and factual errors. I want you to ask me a question in your reply. Now let's start practicing, you could ask me a question first. Remember, I want you to strictly correct my grammar mistakes, typos, and factual errors.",
            prompt = "Now let's start practicing, you could ask me a question first.",
          },
        },

        -- default mappings
        -- see config/mappings.lua for implementation
        mappings = {
          complete = {
            insert = '<Tab>',
          },
          close = {
            normal = 'q',
            insert = '<C-c>',
          },
          reset = {
            normal = '<c-c><c-l>',
            insert = '<c-c><c-l>',
          },
          submit_prompt = {
            normal = '<CR>',
            insert = '<C-s>',
          },
          accept_diff = {
            normal = '<C-y>',
            insert = '<C-y>'
          },
          jump_to_diff = {
            normal = 'gj',
          },
          quickfix_answers = {
            normal = 'gqa',
          },
          quickfix_diffs = {
            normal = 'gqd',
          },
          yank_diff = {
            normal = 'yk',
            register = '+',
          },
          show_diff = {
            normal = 'gd',
          },
          show_info = {
            normal = 'gc', -- Combines context and info display
          },
          show_help = {
            normal = 'gh',
          },
        },
      })
    end,

    -- See Commands section for default commands if you want to lazy load on them
    cmd = {
      "CopilotChat",
      "CopilotChatOpen",
      "CopilotChatClose",
      "CopilotChatToggle",
      "CopilotChatStop",
      "CopilotChatReset",
      "CopilotChatSave",
      "CopilotChatLoad",
      "CopilotChatPrompts",
      "CopilotChatModels",
      "CopilotChatAgents",
      "CopilotChatExplain",
      "CopilotChatReview",
      "CopilotChatFix",
      "CopilotChatOptimize",
      "CopilotChatDocs",
      "CopilotChatTests",
      "CopilotChatCommit",
      "CopilotChatCommitJp",
    },
    keys = {
      {
        ";cc",
        ":CopilotChatOpen<CR>",
        mode = { "n" },
        remap = false,
        silent = true,
        desc = "CopilotChat",
      },

      {
        ";ca",
        function()
          require("CopilotChat").open({ selection = require("CopilotChat.select").buffer })
        end,
        mode = { "n" },
        desc = "CopilotChat",
      },

      {
        ";cc",
        function()
          require("CopilotChat").open({ selection = require("CopilotChat.select").visual })
        end,
        mode = { "v" },
        desc = "CopilotChat for the selection",
      },

      -- Quick chat with Copilot
      {
        ";cq",
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
          end
        end,
        mode = { "n" },
        desc = "CopilotChat - Quick chat",
      },


      -- Quick chat with Copilot
      {
        ";cq",
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            require("CopilotChat").ask(input, { selection = require("CopilotChat.select").visual })
          end
        end,
        mode = { "v" },
        desc = "CopilotChat - Quick chat for the selection",
      },

      -- -- CopilotChatSave
      -- {
      --   ";cs",
      --   ":CopilotChatSave ",
      --   mode = { "n" },
      --   remap = false,
      --   silent = false,
      --   desc = "CopilotChat - Save the chat",
      -- },
      --
      -- -- CopilotChatLoad
      -- {
      --   ";cl",
      --   ":CopilotChatLoad ",
      --   mode = { "n" },
      --   remap = false,
      --   silent = false,
      --   desc = "CopilotChat - Load the chat",
      -- },
      --

      -- Show help actions with telescope/fzf
      {
        ";ch",
        function()
          local actions = require("CopilotChat.actions")
          -- require("CopilotChat.integrations.telescope").pick(actions.help_actions())
          require("CopilotChat.integrations.fzflua").pick(actions.help_actions())
        end,
        mode = { "n" },
        remap = false,
        silent = false,
        desc = "CopilotChat - Help actions",
      },

      -- Show prompts actions with telescope/fzf
      {
        ";cp",
        function()
          local actions = require("CopilotChat.actions")
          -- require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
          require("CopilotChat.integrations.fzflua").pick(actions.prompt_actions())
        end,
        mode = { "n" },
        remap = false,
        silent = false,
        desc = "CopilotChat - Prompt actions",
      },

      -- CopilotChatExplain
      {
        ";ce",
        ":CopilotChatExplain<CR>",
        mode = { "n", "v" },
        remap = false,
        silent = true,
        desc = "CopilotChat - Explain the selection",
      },

      -- CopilotChatReview
      {
        ";cr",
        ":CopilotChatReview<CR>",
        mode = { "n", "v" },
        remap = false,
        silent = true,
        desc = "CopilotChat - Review the selection",
      },

      -- CopilotChatFix
      {
        ";cf",
        ":CopilotChatFix<CR>",
        mode = { "n", "v" },
        remap = false,
        silent = true,
        desc = "CopilotChat - Fix the selection",
      },

      -- CopilotChatOptimize
      {
        ";co",
        ":CopilotChatOptimize<CR>",
        mode = { "n", "v" },
        remap = false,
        silent = true,
        desc = "CopilotChat - Optimize the selection",
      },

      -- CopilotChatDocs
      {
        ";cd",
        ":CopilotChatDocs<CR>",
        mode = { "n", "v" },
        remap = false,
        silent = true,
        desc = "CopilotChat - Add documentation for the selection",
      },

      -- CopilotChatTests
      {
        ";ct",
        ":CopilotChatTests<CR>",
        mode = { "n", "v" },
        remap = false,
        silent = true,
        desc = "CopilotChat - Generate tests for the selection",
      },

      -- CopilotChatCommit
      {
        ";cgm",
        ":CopilotChatCommit<CR>",
        mode = { "n" },
        remap = false,
        silent = true,
        desc = "CopilotChat - Write commit message",
      },

      -- CopilotChatCommitJp
      {
        ";cgj",
        ":CopilotChatCommitJp<CR>",
        mode = { "n" },
        remap = false,
        silent = true,
        desc = "CopilotChat - Write commit message in Japanese",
      },

      -- Search saved chat history with fzf (formatted for readability)
      {
        ";cgg",
        function()
          local history_path = vim.fn.stdpath('data') .. '/copilotchat_history'
          -- Check if directory exists
          if vim.fn.isdirectory(history_path) == 0 then
            vim.notify("No chat history directory found: " .. history_path, vim.log.levels.WARN)
            return
          end

          -- Use jq to format JSON for better grep results
          -- Each message is converted to: [filename] role: content
          require('fzf-lua').fzf_exec(
            string.format(
              "cd %s && for file in *.json; do " ..
              "  [ -f \"$file\" ] && jq -r --arg fname \"$file\" " ..
              "    '.[] | \"[\" + $fname + \"] \" + .role + \": \" + .content' \"$file\" 2>/dev/null; " ..
              "done",
              vim.fn.shellescape(history_path)
            ),
            {
              prompt = 'Copilot History❯ ',
              actions = {
                ['default'] = function(selected)
                  if not selected or #selected == 0 then return end
                  -- Extract filename from [filename] format
                  local filename = selected[1]:match("%[(.-)%]")
                  if filename then
                    local filepath = history_path .. '/' .. filename
                    vim.cmd('edit ' .. vim.fn.fnameescape(filepath))
                  end
                end
              },
              fzf_opts = {
                ['--delimiter'] = "': '",
                ['--preview-window'] = 'right:60%:wrap',
                ['--preview'] = string.format(
                  "filename=$(echo {} | sed 's/.*\\[\\(.*\\)\\].*/\\1/'); " ..
                  "[ -f '%s'/$filename ] && jq -C -r '.[] | \"[\" + .role + \"]\\n\" + .content + \"\\n\"' '%s'/$filename 2>/dev/null || echo 'File not found: '$filename",
                  history_path, history_path
                )
              }
            }
          )
        end,
        mode = { "n" },
        remap = false,
        silent = true,
        desc = "CopilotChat - Search saved chat history",
      },

    },

    init = function()
      vim.api.nvim_create_augroup("MyCopilotChat", { clear = true })


      vim.api.nvim_create_autocmd('BufEnter', {
        pattern = 'copilot-*',
        group = 'MyCopilotChat',
        callback = function()
          vim.opt_local.cursorline = false
          vim.opt_local.conceallevel = 0

          -- yl to yank last response
          vim.keymap.set('n', 'yl', function()
            local response = require("CopilotChat").response()
            if response then
              local clipboard = vim.opt.clipboard:get()
              if vim.tbl_contains(clipboard, 'unnamedplus') then
                vim.fn.setreg('+', response)
              elseif vim.tbl_contains(clipboard, 'unnamed') then
                vim.fn.setreg('*', response)
              else
                vim.fn.setreg('"', response)
              end
            else
              print("No response available to yank.")
            end
          end, { buffer = true, remap = false })

          -- <c-s> to save chat
          vim.keymap.set('n', '<c-s>', ':CopilotChatSave ', { buffer = true, remap = false })
          -- <c-o> to load chat
          vim.keymap.set('n', '<c-o>', ':CopilotChatLoad ', { buffer = true, remap = false })

          -- reset後にredraw!を実行して描画崩れを修正
          vim.keymap.set({ 'n', 'i' }, '<c-c><c-l>', function()
            require('CopilotChat').reset()
            vim.cmd('stopinsert')
            vim.schedule(function()
              vim.cmd('redraw!')
            end)
          end, { buffer = true, remap = false, desc = 'CopilotChat Reset with redraw' })
        end

      })

      -- Auto-save chat history when leaving the buffer
      vim.api.nvim_create_autocmd('BufLeave', {
        pattern = 'copilot-*',
        group = 'MyCopilotChat',
        callback = function()
          -- Only save if there are actual messages with content
          local ok, messages = pcall(function()
            return require("CopilotChat").chat:get_messages()
          end)

          if not ok or not messages then
            return
          end

          -- Check if there are any messages with non-empty content
          local has_messages = false
          for _, message in ipairs(messages) do
            if message.content and message.content ~= "" then
              has_messages = true
              break
            end
          end

          if has_messages then
            local timestamp = os.date('%Y%m%d_%H%M%S')
            vim.cmd('silent! CopilotChatSave auto_save_' .. timestamp)
          end
        end
      })
    end,
  }
}
