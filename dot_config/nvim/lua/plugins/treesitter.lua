return {
  -- https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation#lazynvim
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = true,
    event = "VeryLazy",
    cmd = { "TSInstall", "TSUpdate" },
    config = function()
      -- windows で git 使うとめちゃくちゃ遅いので curl, tar でインストールする
      -- https://github.com/nvim-treesitter/nvim-treesitter/wiki/Windows-support
      require('nvim-treesitter.install').prefer_git = false

      require('nvim-treesitter.configs').setup {
        -- ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html" },
        -- ensure_installed = { "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "python",  },
        -- ensure_installed = {"bash", "css", "go", "html", "javascript", "json", "lua", "markdown", "markdown_inline", "powershell", "python", "vim", "vimdoc", "yaml"},
        -- ensure_installed = "all",

        -- windows で all にしているとめちゃくちゃ重いので、unix だけにする
        ensure_installed = (function()
          if vim.fn.has('unix') == 1 then
            return { "bash", "css", "go", "html", "javascript", "json", "lua", "markdown", "markdown_inline",
              "powershell", "python", "vim", "vimdoc", "yaml" }
            -- return "all"
          else
            return {}
          end
        end)(),

        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
        -- Automatically install missing parsers when entering buffer
        -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
        auto_install = (function()
          if vim.fn.executable('tree-sitter') == 1 then
            return true
          else
            vim.notify("tree-sitter CLI is not installed. Run :npm install -g tree-sitter-cli")
            return false
          end
        end)(),
      }
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    -- dependencies = { "nvim-treesitter/nvim-treesitter" },
    lazy = true,
    event = "VeryLazy",
    config = function()
      -- register custom filetypes
      vim.treesitter.language.register('markdown', 'copilot-chat')

      require('nvim-treesitter.configs').setup {
        textobjects = {
          select = {
            enable = true,
            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,

            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              -- You can optionally set descriptions to the mappings (used in the desc parameter of
              -- nvim_buf_set_keymap) which plugins like which-key display
              ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
              -- You can also use captures from other query groups like `locals.scm`
              ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
              -- markdown code fence
              -- defined in vim.fn.stdpath('config') .. '/queries/markdown/textobjects.scm'
              ["ik"] = "@code_fence.content",
              ["ak"] = "@code_fence.outer",
            },
            -- You can choose the select mode (default is charwise 'v')
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * method: eg 'v' or 'o'
            -- and should return the mode ('v', 'V', or '<c-v>') or a table
            -- mapping query_strings to modes.
            selection_modes = {
              ['@parameter.outer'] = 'v', -- charwise
              ['@function.outer'] = 'V',  -- linewise
              ['@class.outer'] = '<c-v>', -- blockwise
              ['@code_fence.content'] = 'V',
              ['@code_fence.outer'] = 'V',
            },
            -- If you set this to `true` (default is `false`) then any textobject is
            -- extended to include preceding or succeeding whitespace. Succeeding
            -- whitespace has priority in order to act similarly to eg the built-in
            -- `ap`.
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * selection_mode: eg 'v'
            -- and should return true or false
            -- include_surrounding_whitespace = true,
            include_surrounding_whitespace = false,
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = { query = "@class.outer", desc = "Next class start" },
              --
              -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queries.
              ["]o"] = "@loop.*",
              -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
              --
              -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
              -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
              -- ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
              -- ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
              -- markdown code fence
              ["]k"] = "@code_fence.outer",
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
              ["]K"] = "@code_fence.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
              -- markdown code fence
              ["[k"] = "@code_fence.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
              -- markdown code fence
              ["[K"] = "@code_fence.outer",
            },
            -- Below will go to either the start or the end, whichever is closer.
            -- Use if you want more granular movements
            -- Make it even more gradual by adding multiple queries and regex.
            goto_next = {
              ["]d"] = "@conditional.outer",
            },
            goto_previous = {
              ["[d"] = "@conditional.outer",
            }
          },
        },
      }
    end
  },

}
