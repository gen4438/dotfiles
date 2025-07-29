return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "FzfLua" },
    keys = {
      -- Files and buffers
      { ';fb',  function() require('fzf-lua').buffers() end,                                       mode = "n", desc = "Find buffers" },
      { ';ff',  function() require('fzf-lua').files() end,                                         mode = "n", desc = "Find files" },
      { ';fe',  function() require('fzf-lua').files({ cwd = vim.fn.expand('%:p:h') }) end,         mode = "n", desc = "Find files (current dir)" },
      { ';f.',  function() require('fzf-lua').files({ cwd = ".", fd_opts = "--max-depth=1" }) end, mode = "n", desc = "Find files (shallow)" },
      { ';fh',  function() require('fzf-lua').oldfiles() end,                                      mode = "n", desc = "Find recent files" },
      { ';fa',  function() require('fzf-lua').args() end,                                          mode = "n", desc = "Find arguments" },

      -- Quickfix and lists
      { ';fqq', function() require('fzf-lua').quickfix() end,                                      mode = "n", desc = "Quickfix list" },
      { ';fqs', function() require('fzf-lua').quickfix_stack() end,                                mode = "n", desc = "Quickfix stack" },
      { ';fql', function() require('fzf-lua').loclist() end,                                       mode = "n", desc = "Location list" },
      { ';fll', function() require('fzf-lua').lines() end,                                         mode = "n", desc = "Find lines (all buffers)" },
      { ';flb', function() require('fzf-lua').blines() end,                                        mode = "n", desc = "Find lines (current buffer)" },

      -- Grep
      { ';gw',  function() require('fzf-lua').grep_cword() end,                                    mode = "n", desc = "Grep word under cursor" },
      { ';gg',  function() require('fzf-lua').grep_visual() end,                                   mode = "x", desc = "Grep visual selection" },
      { ';gg',  function() require('fzf-lua').live_grep() end,                                     mode = "n", desc = "Live grep" },
      { ';ge',  function() require('fzf-lua').live_grep({ cwd = vim.fn.expand('%:p:h') }) end,     mode = "n", desc = "Live grep (current dir)" },
      { ';gr',  function() require('fzf-lua').live_grep_resume() end,                              mode = "n", desc = "Resume last grep" },

      -- Tags
      { ';ftt', function() require('fzf-lua').tags() end,                                          mode = "n", desc = "Find tags" },
      { ';ftb', function() require('fzf-lua').btags() end,                                         mode = "n", desc = "Find buffer tags" },
      { ';ftg', function() require('fzf-lua').tags_live_grep() end,                                mode = "n", desc = "Live grep tags" },
      { ';ftg', function() require('fzf-lua').tags_grep_visual() end,                              mode = "x", desc = "Grep tags (visual)" },

      -- Git
      { ';gf',  function() require('fzf-lua').git_files() end,                                     mode = "n", desc = "Git files" },
      { ';gst', function() require('fzf-lua').git_status() end,                                    mode = "n", desc = "Git status" },
      { ';gcc', function() require('fzf-lua').git_commits() end,                                   mode = "n", desc = "Git commits" },
      { ';gcb', function() require('fzf-lua').git_bcommits() end,                                  mode = "n", desc = "Git buffer commits" },
      { ';gbl', function() require('fzf-lua').git_blame() end,                                     mode = "n", desc = "Git blame" },
      { ';gbr', function() require('fzf-lua').git_branches() end,                                  mode = "n", desc = "Git branches" },
      { ';gt',  function() require('fzf-lua').git_tags() end,                                      mode = "n", desc = "Git tags" },
      { ';gss', function() require('fzf-lua').git_stash() end,                                     mode = "n", desc = "Git stash" },

      -- LSP
      { ';lr',  function() require('fzf-lua').lsp_references() end,                                mode = "n", desc = "LSP references" },
      { ';ld',  function() require('fzf-lua').lsp_definitions() end,                               mode = "n", desc = "LSP definitions" },
      { ';ls',  function() require('fzf-lua').lsp_document_symbols() end,                          mode = "n", desc = "LSP document symbols" },
      { ';li',  function() require('fzf-lua').lsp_implementations() end,                           mode = "n", desc = "LSP implementations" },
      { ';lws', function() require('fzf-lua').lsp_live_workspace_symbols() end,                    mode = "n", desc = "LSP workspace symbols" },
      { ';la',  function() require('fzf-lua').lsp_code_actions() end,                              mode = "n", desc = "LSP code actions" },
      { ';lgb', function() require('fzf-lua').diagnostics_document() end,                          mode = "n", desc = "LSP diagnostics (buffer)" },
      { ';lgg', function() require('fzf-lua').diagnostics_workspace() end,                         mode = "n", desc = "LSP diagnostics (workspace)" },

      -- Miscellaneous
      { ';fr',  function() require('fzf-lua').resume() end,                                        mode = "n", desc = "Resume last search" },
      { ';fm',  function() require('fzf-lua').colorschemes() end,                                  mode = "n", desc = "Colorschemes" },
      { ';fcc', function() require('fzf-lua').commands() end,                                      mode = "n", desc = "Commands" },
      { ';fch', function() require('fzf-lua').command_history() end,                               mode = "n", desc = "Command history" },
      { ';fu',  function() require('fzf-lua').changes() end,                                       mode = "n", desc = "Changes" },
      { ';fk',  function() require('fzf-lua').keymaps() end,                                       mode = "n", desc = "Keymaps" },
      { ';fT',  function() require('fzf-lua').filetypes() end,                                     mode = "n", desc = "Filetypes" },

      -- Custom directory pickers

      -- 将来実装したい
      -- { ';fv',   function() require('fzf-lua').treesitter() end,                       mode = "n" },
      {
        ';fp',
        function()
          local path = vim.fn.input('Find in dir: ', '', 'dir')
          if path == '' then return end
          require('fzf-lua').files({ cwd = path })
        end,
        mode = "n",
        desc = "Find files in custom directory"
      },
      {
        ";gp",
        function()
          local path = vim.fn.input('Grep in dir: ', '', 'dir')
          if path == '' then return end
          require('fzf-lua').live_grep({ cwd = path })
        end,
        mode = "n",
        desc = "Grep in custom directory"
      },
      { ";fgp", ";gp", mode = "n", remap = true },

      -- Path completion with multi-selection support
      {
        '<c-o><c-p>',
        function()
          local function return_to_insert(opts)
            if opts.__CTX and opts.__CTX.mode == "i" then
              vim.cmd [[noautocmd lua vim.api.nvim_feedkeys('i', 'n', true)]]
            end
          end

          require("fzf-lua").complete_path({
            fzf_opts = {
              ["--no-multi"] = false,
              ["--multi"] = "",
            },
            winopts = {
              preview = { title = "複数選択可能 (TAB: 選択切替, Ctrl-A: 全選択)" }
            },
            actions = {
              ["default"] = function(selected, opts)
                if #selected == 0 then
                  return_to_insert(opts)
                  return
                end

                -- Extract file paths
                local paths = {}
                for _, item in ipairs(selected) do
                  local entry = require('fzf-lua.path').entry_to_file(item, opts)
                  if entry and entry.path and entry.path ~= "<none>" then
                    local relpath = require('fzf-lua.path').relative_to(entry.path, opts.cwd)
                    local resolved_path = opts._cwd and require('fzf-lua.path').join({ opts._cwd, relpath }) or relpath
                    table.insert(paths, resolved_path)
                  end
                end

                if #paths == 0 then
                  return_to_insert(opts)
                  return
                end

                -- Calculate insertion position
                local line = opts.__CTX.line
                local col = opts.__CTX.cursor[2] + 1
                local match = opts.word_pattern or "[^%s\"']*"
                local before = col > 1 and line:sub(1, col - 1):reverse():match(match):reverse() or ""
                local after = line:sub(col):match(match) or ""
                if #before == 0 and #after == 0 and #line > col then
                  col = col + 1
                  after = line:sub(col):match(match) or ""
                end

                local replace_at = col - #before
                local before_path = replace_at > 1 and line:sub(1, replace_at - 1) or ""
                local rest_of_line = #line >= (col + #after) and line:sub(col + #after) or ""

                -- Insert first path in current line
                local new_line = before_path .. paths[1] .. rest_of_line
                vim.api.nvim_set_current_line(new_line)

                -- Handle multiple paths
                if #paths > 1 then
                  vim.schedule(function()
                    local current_row = opts.__CTX.cursor[1]
                    local additional_lines = {}
                    for i = 2, #paths do
                      table.insert(additional_lines, paths[i])
                    end
                    vim.api.nvim_buf_set_lines(0, current_row, current_row, false, additional_lines)
                    vim.api.nvim_win_set_cursor(0, { current_row + #additional_lines, #paths[#paths] })
                    return_to_insert(opts)
                  end)
                else
                  vim.api.nvim_win_set_cursor(0, { opts.__CTX.cursor[1], replace_at + #paths[1] - 2 })
                  return_to_insert(opts)
                end
              end
            }
          })
        end,
        mode = { "i", "v" },
        desc = "Insert multiple file paths"
      },
    },
    config = function()
      -- https://github.com/ibhagwan/fzf-lua?tab=readme-ov-file#default-options
      local actions = require "fzf-lua.actions"
      require 'fzf-lua'.setup {
        winopts = {
          fullscreen = false, -- start fullscreen?
          preview = {
            default = 'bat',  -- override the default previewer?
          },
        },

        keymap = {
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
        actions = {
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
        files = {
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
