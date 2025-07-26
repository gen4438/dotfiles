return {
  -- https://github.com/ibhagwan/fzf-lua
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      -- buffers and files
      { ';fb',  function() require('fzf-lua').buffers() end,                                       mode = "n" },
      { ';ff',  function() require('fzf-lua').files() end,                                         mode = "n" },
      -- find parent directory of the current buffer
      { ';fe',  function() require('fzf-lua').files({ cwd = vim.fn.expand('%:p:h') }) end,         mode = "n" },
      -- non-recursive search in current directory only
      { ';f.',  function() require('fzf-lua').files({ cwd = ".", fd_opts = "--max-depth=1" }) end, mode = "n" },
      { ';fh',  function() require('fzf-lua').oldfiles() end,                                      mode = "n" },
      { ';fqq', function() require('fzf-lua').quickfix() end,                                      mode = "n" },
      { ';fqs', function() require('fzf-lua').quickfix_stack() end,                                mode = "n" },
      { ';fql', function() require('fzf-lua').loclist() end,                                       mode = "n" },
      { ';fll', function() require('fzf-lua').lines() end,                                         mode = "n" },
      { ';flb', function() require('fzf-lua').blines() end,                                        mode = "n" },
      -- { ';ft',   function() require('fzf-lua').tabs() end,                       mode = "n" },
      { ';fa',  function() require('fzf-lua').args() end,                                          mode = "n" },

      -- grep
      { ';gw',  function() require('fzf-lua').grep_cword() end,                                    mode = "n" },
      { ';gg',  function() require('fzf-lua').grep_visual() end,                                   mode = "x" },
      { ';gg',  function() require('fzf-lua').live_grep() end,                                     mode = "n" },
      { ';ge',  function() require('fzf-lua').live_grep({ cwd = vim.fn.expand('%:p:h') }) end,     mode = "n" },
      { ';gr',  function() require('fzf-lua').live_grep_resume() end,                              mode = "n" },
      -- alias
      { ';fgw', ';gw',                                                                             mode = "n", remap = true },
      { ';fge', ';ge',                                                                             mode = "n", remap = true },
      { ';fgg', ';gg',                                                                             mode = "n", remap = true },
      { ';fgg', ';gg',                                                                             mode = "x", remap = true },
      { ';fgr', ';gr',                                                                             mode = "n", remap = true },

      -- tags
      { ';ftt', function() require('fzf-lua').tags() end,                                          mode = "n" },
      { ';ftb', function() require('fzf-lua').btags() end,                                         mode = "n" },
      { ';ftg', function() require('fzf-lua').tags_live_grep() end,                                mode = "n" },
      { ';ftg', function() require('fzf-lua').tags_grep_visual() end,                              mode = "x" },

      -- Git
      { ';gf',  function() require('fzf-lua').git_files() end,                                     mode = "n" },
      { ';gst', function() require('fzf-lua').git_status() end,                                    mode = "n" },
      { ';gcc', function() require('fzf-lua').git_commits() end,                                   mode = "n" },
      { ';gcb', function() require('fzf-lua').git_bcommits() end,                                  mode = "n" },
      { ';gbl', function() require('fzf-lua').git_blame() end,                                     mode = "n" },
      { ';gbr', function() require('fzf-lua').git_branches() end,                                  mode = "n" },
      { ';gt',  function() require('fzf-lua').git_tags() end,                                      mode = "n" },
      { ';gss', function() require('fzf-lua').git_stash() end,                                     mode = "n" },

      -- LSP
      { ';lr',  function() require('fzf-lua').lsp_references() end,                                mode = "n" },
      { ';ld',  function() require('fzf-lua').lsp_definitions() end,                               mode = "n" },
      { ';ls',  function() require('fzf-lua').lsp_document_symbols() end,                          mode = "n" },
      { ';li',  function() require('fzf-lua').lsp_implementations() end,                           mode = "n" },
      { ';lws', function() require('fzf-lua').lsp_live_workspace_symbols() end,                    mode = "n" },
      { ';la',  function() require('fzf-lua').lsp_code_actions() end,                              mode = "n" },
      { ';lgb', function() require('fzf-lua').diagnostics_document() end,                          mode = "n" },
      { ';lgg', function() require('fzf-lua').diagnostics_workspace() end,                         mode = "n" },

      -- misc
      { ';fr',  function() require('fzf-lua').resume() end,                                        mode = "n" },
      { ';fm',  function() require('fzf-lua').colorschemes() end,                                  mode = "n" },
      { ';fcc', function() require('fzf-lua').commands() end,                                      mode = "n" },
      { ';fch', function() require('fzf-lua').command_history() end,                               mode = "n" },
      { ';fu',  function() require('fzf-lua').changes() end,                                       mode = "n" },
      { ';fk',  function() require('fzf-lua').keymaps() end,                                       mode = "n" },
      { ';fT',  function() require('fzf-lua').filetypes() end,                                     mode = "n" },

      -- custom
      -- { ';fv',   function() require('fzf-lua').treesitter() end,                       mode = "n" },

      -- プロンプトで入力したパスを検索する
      {
        ';fp',
        function()
          local path = vim.fn.input('Find in dir: ', '', 'dir')
          if path == '' then return end
          require('fzf-lua').files({ cwd = path })
        end,
        mode = "n"
      },
      -- grep
      {
        ";gp",
        function()
          local path = vim.fn.input('Grep in dir: ', '', 'dir')
          if path == '' then return end
          require('fzf-lua').live_grep({ cwd = path })
        end,
        mode = "n"
      },
      { ";fgp", ";gp", mode = "n", remap = true },

      -- complete path in insert mode (with multi-selection)
      {
        '<c-o><c-p>',
        function()
          -- カスタムコールバック関数を定義して複数選択を処理
          local function custom_path_handler(selected)
            if not selected or #selected == 0 then
              return
            end

            -- ファイルパスを抽出
            local paths = {}
            for _, item in ipairs(selected) do
              local path = require('fzf-lua.path').entry_to_file(item)
              if path and path.path ~= "<none>" then
                table.insert(paths, path.path)
              end
            end

            -- 複数行の場合は各行を個別に挿入
            local pos = vim.api.nvim_win_get_cursor(0)
            local row, col = pos[1], pos[2]

            -- 最初のパスを現在の行に挿入
            local current_line = vim.api.nvim_get_current_line()
            local new_line = current_line:sub(1, col) .. paths[1] .. current_line:sub(col + 1)
            vim.api.nvim_set_current_line(new_line)

            -- 残りのパスを新しい行として挿入
            if #paths > 1 then
              local additional_lines = {}
              for i = 2, #paths do
                table.insert(additional_lines, paths[i])
              end
              vim.api.nvim_buf_set_lines(0, row, row, false, additional_lines)

              -- カーソルを最後の挿入行の終わりに移動
              vim.api.nvim_win_set_cursor(0, { row + #additional_lines, 0 })
            else
              -- 1つだけならカーソル位置を更新
              vim.api.nvim_win_set_cursor(0, { row, col + #paths[1] })
            end
          end

          -- complete_pathをカスタムコールバックでオーバーライド
          require("fzf-lua").complete_path({
            actions = {
              ["default"] = custom_path_handler,
              ["ctrl-s"] = custom_path_handler, -- ctrl-sでも選択可能に
            },
            winopts = {
              preview = {
                title = "複数選択可能 (TABで選択切替, CTRL-Aですべて選択)"
              }
            },
            fzf_opts = {
              ["--multi"] = "", -- 複数選択を有効化
            }
          })

          vim.cmd('startinsert')
        end,
        mode = { "i", "v" },
        desc = "複数のパスを選択して挿入（新しい行として追加）"
      },
    },
    config = function()
      -- https://github.com/ibhagwan/fzf-lua?tab=readme-ov-file#default-options
      local actions = require "fzf-lua.actions"
      require 'fzf-lua'.setup {
        winopts  = {
          fullscreen = false, -- start fullscreen?
          preview    = {
            default = 'bat',  -- override the default previewer?
          },
        },

        keymap   = {
          -- Below are the default binds, setting any value in these tables will override
          -- the defaults, to inherit from the defaults change [1] from `false` to `true`
          builtin = {
            false, -- do not inherit from defaults
            ["<c-n>"] = "preview-down",
            ["<c-p>"] = "preview-up",
          },
          fzf = {
            false, -- do not inherit from defaults
            -- fzf '--bind=' options
            ["ctrl-u"] = "unix-line-discard",
            ["ctrl-f"] = "half-page-down",
            ["ctrl-b"] = "half-page-up",
            ["ctrl-a"] = "select-all",
            ["ctrl-d"] = "deselect-all",
            ["ctrl-s"] = "toggle-sort",
            ["ctrl-y"] = "toggle-all",
            ["ctrl-l"] = "last",
            ["ctrl-h"] = "first",
          },
        },
        actions  = {
          -- Below are the default actions, setting any value in these tables will override
          -- the defaults, to inherit from the defaults change [1] from `false` to `true`
          files = {
            false, -- do not inherit from defaults
            -- Pickers inheriting these actions:
            --   files, git_files, git_status, grep, lsp, oldfiles, quickfix, loclist,
            --   tags, btags, args, buffers, tabs, lines, blines
            -- `file_edit_or_qf` opens a single selection or sends multiple selection to quickfix
            -- replace `enter` with `file_edit` to open all files/bufs whether single or multiple
            -- replace `enter` with `file_switch_or_edit` to attempt a switch in current tab first
            ["enter"]  = actions.file_edit_or_qf,
            ["ctrl-q"] = actions.file_sel_to_qf,
            ["ctrl-Q"] = actions.file_sel_to_ll,
            -- ["ctrl-y"] = function(selected)
            --   local path = require('fzf-lua.path')
            --   local entry = path.entry_to_file(selected[1])
            --   if entry.path == "<none>" then return end
            --   print(entry.path)
            -- end
          },
        },
        files    = {
          -- Uncomment for custom vscode-like formatter where the filename is first:
          -- e.g. "fzf-lua/previewer/fzf.lua" => "fzf.lua previewer/fzf-lua"
          -- formatter = "path.filename_first",
          actions = {
            -- inherits from 'actions.files', here we can override
            -- or set bind to 'false' to disable a default action
            -- action to toggle `--no-ignore`, requires fd or rg installed
            ["ctrl-g"] = { actions.toggle_ignore },
            -- uncomment to override `actions.file_edit_or_qf`
            ["enter"]  = actions.file_edit,

            -- カーソル下のファイルの親ディレクトリから edit 入力
            ["ctrl-e"] = function(selected)
              local path = require('fzf-lua.path')
              local entry = path.entry_to_file(selected[1])
              if entry.path == "<none>" then return end
              local parent = path.parent(entry.path, true)
              -- もうちょい良い書き方ない？
              local command = ":e " .. parent .. "/"
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(command, true, true, true), 'n', true)
            end,
          }
        },
        oldfiles = {
          actions = {
            ["enter"] = actions.file_edit,
          }
        },
        grep     = {
          rg_glob   = false,     -- default to glob parsing?
          glob_flag = "--iglob", -- for case sensitive globs use '--glob'
          actions   = {
            ["ctrl-g"] = { actions.toggle_ignore },
            ["ctrl-p"] = { actions.grep_lgrep },
          },
        },
      }

      -- 選択 UI を fzf-lua に設定
      require('fzf-lua').register_ui_select()
    end
  }
}
