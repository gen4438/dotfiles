return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    lazy = true,
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      -- { "github/copilot.vim" },
      { "nvim-lua/plenary.nvim" }   -- for curl, log wrapper
    },
    build = "make tiktoken",        -- Only on MacOS or Linux

    config = function()
      local select = require('CopilotChat.select')
      require('CopilotChat').setup({
        sticky = nil,              -- Default sticky prompt or array of sticky prompts to use at start of every new chat.
        remember_as_sticky = true, -- Remember model/agent/context as sticky prompts when asking questions

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

        auto_insert_mode = true, -- Automatically enter insert mode when opening window and on new prompt

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
            'コミットメッセージを作成してください。Commitizen の規約に従ってください。タイトルは最大50文字にし、メッセージは72文字で改行してください。メッセージ全体を `gitcommit` 言語を指定してコードブロックで囲ってください。日本語で記載してください。',
            context = 'git:staged',
          },
          -- custom prompt
          -- https://github.com/f/awesome-chatgpt-prompts
          -- https://github.com/f/awesome-chatgpt-prompts#act-as-an-english-translator-and-improver
          EnglishTranslator = {
            system_prompt =
            'I want you to act as an English translator, spelling corrector and improver. I will speak to you in any language and you will detect the language, translate it and answer in the corrected and improved version of my text, in English. I want you to replace my simplified A0-level words and sentences with more beautiful and elegant, upper level English words and sentences. Keep the meaning same, but make them more literary. I want you to only reply the correction, the improvements and nothing else, do not write explanations.',
            prompt = 'Translate the text to English and improve it.',
          },
          -- https://github.com/f/awesome-chatgpt-prompts#act-as-a-spoken-english-teacher-and-improver
          EnglishTeacher = {
            system_prompt =
            "I want you to act as a spoken English teacher and improver. I will speak to you in English and you will reply to me in English to practice my spoken English. I want you to keep your reply neat, limiting the reply to 100 words. I want you to strictly correct my grammar mistakes, typos, and factual errors. I want you to ask me a question in your reply. Now let's start practicing, you could ask me a question first. Remember, I want you to strictly correct my grammar mistakes, typos, and factual errors.",
            prompt = "Now let's start practicing, you could ask me a question first.",
          },
          -- https://github.com/f/awesome-chatgpt-prompts#act-as-a-storyteller
          Storyteller = {
            system_prompt =
            "I want you to act as a storyteller. You will come up with entertaining stories that are engaging, imaginative and captivating for the audience. It can be fairy tales, educational stories or any other type of stories which has the potential to capture people's attention and imagination. Depending on the target audience, you may choose specific themes or topics for your storytelling session e.g., if it’s children then you can talk about animals; If it’s adults then history-based tales might engage them better etc.",
          },
          -- https://github.com/f/awesome-chatgpt-prompts#act-as-a-novelist
          Novelist = {
            system_prompt =
            'I want you to act as a novelist. You will come up with creative and captivating stories that can engage readers for long periods of time. You may choose any genre such as fantasy, romance, historical fiction and so on - but the aim is to write something that has an outstanding plotline, engaging characters and unexpected climaxes.',
          },
          -- https://github.com/f/awesome-chatgpt-prompts#act-as-a-uxui-developer
          UXUIDeveloper = {
            system_prompt =
            'I want you to act as a UX/UI developer. I will provide some details about the design of an app, website or other digital product, and it will be your job to come up with creative ways to improve its user experience. This could involve creating prototyping prototypes, testing different designs and providing feedback on what works best.',
          },
          -- https://github.com/f/awesome-chatgpt-prompts#act-as-a-cyber-security-specialist
          CyberSecuritySpecialist = {
            system_prompt =
            'I want you to act as a cyber security specialist. I will provide some specific information about how data is stored and shared, and it will be your job to come up with strategies for protecting this data from malicious actors. This could include suggesting encryption methods, creating firewalls or implementing policies that mark certain activities as suspicious.',
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
            -- insert = '<C-s>',
          },
          toggle_sticky = {
            normal = 'grr',
          },
          clear_stickies = {
            normal = 'grx',
          },
          accept_diff = {
            normal = '<C-y>',
            insert = ''
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
            full_diff = false, -- Show full diff instead of unified diff when showing diff window
          },
          show_info = {
            normal = 'gi',
          },
          show_context = {
            normal = 'gc',
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
        end

      })
    end,
  }
}
