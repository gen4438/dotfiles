return {
  {
    -- メインで fzf-lua を使っているが、一部のプラグインで telescope を使っている
    'nvim-telescope/telescope.nvim',
    -- tag = '0.1.8',
    enabled = true,
    cmd = 'Telescope',
    dependencies = {
      -- 'nvim-lua/plenary.nvim',
      -- "nvim-treesitter/nvim-treesitter",
      -- "nvim-telescope/telescope-fzf-native.nvim",
      -- "fhill2/telescope-ultisnips.nvim",
    },
    keys = {
      -- { ';ff',   function() require('telescope.builtin').find_files() end,                                                    mode = "n" },
      -- { ';fe',   function() require('telescope.builtin').find_files({ no_ignore = true }) end,                                mode = "n" },
      -- { ';fgg',  function() require('telescope.builtin').live_grep() end,                                                     mode = "n" },
      -- { ';fb',   function() require('telescope.builtin').buffers() end,                                                       mode = "n" },
      -- { ';fc',   function() require('telescope.builtin').commands() end,                                                      mode = "n" },
      -- { ';fh',   function() require('telescope.builtin').oldfiles() end,                                                      mode = "n" },
      -- { ';ft',   function() require('telescope.builtin').tags() end,                                                          mode = "n" },
      -- { ';fq',   function() require('telescope.builtin').quickfix() end,                                                      mode = "n" },
      -- { ';fll',  function() require('telescope.builtin').current_buffer_fuzzy_find() end,                                     mode = "n" },
      -- { ';fk',   function() require('telescope.builtin').keymaps() end,                                                       mode = "n" },
      -- { ';fm',   function() require('telescope.builtin').colorscheme({ enable_preview = true, ignore_builtins = false }) end, mode = "n" },
      -- -- LSP
      -- { ';flr',  function() require('telescope.builtin').lsp_references() end,                                                mode = "n" },
      -- { ';fls',  function() require('telescope.builtin').lsp_document_symbols() end,                                          mode = "n" },
      -- { ';fli',  function() require('telescope.builtin').lsp_implementations() end,                                           mode = "n" },
      -- { ';fld',  function() require('telescope.builtin').lsp_definitions() end,                                               mode = "n" },
      -- { ';flg',  function() require('telescope.builtin').lsp_diagnostics() end,                                               mode = "n" },
      -- { ';flws', function() require('telescope.builtin').lsp_workspace_symbols() end,                                         mode = "n" },
      -- -- Git
      -- { ';fgf',  function() require('telescope.builtin').git_files() end,                                                     mode = "n" },
      -- { ';fgc',  function() require('telescope.builtin').git_commits() end,                                                   mode = "n" },
      -- { ';fgb',  function() require('telescope.builtin').git_branches() end,                                                  mode = "n" },
      -- { ';fgs',  function() require('telescope.builtin').git_status() end,                                                    mode = "n" },
      -- -- others
      -- { ';fv',   function() require('telescope.builtin').treesitter() end,                                                    mode = "n" },
      -- { ';fs',   function() require 'telescope'.extensions.ultisnips.ultisnips {} end,                                        mode = "n" },
    },
    opts = {
    },
    config = function()
      local telescope_custom_actions = {}
      local actions = require('telescope.actions')

      function telescope_custom_actions._multiopen(prompt_bufnr, open_cmd)
        local action_state = require('telescope.actions.state')
        local picker = action_state.get_current_picker(prompt_bufnr)
        local multi_selections = picker:get_multi_selection()

        if not multi_selections or #multi_selections <= 1 then
          actions.select_default(prompt_bufnr)
          return
        end

        local qf_list = {}
        for _, entry in ipairs(multi_selections) do
          -- Check if the entry is a file
          if entry.path then
            table.insert(qf_list, entry)
          end
        end

        if #qf_list > 0 then
          actions.send_selected_to_qflist(prompt_bufnr)
          vim.cmd("cfdo " .. open_cmd)
          return
        end
        actions.select_default(prompt_bufnr)
      end

      function telescope_custom_actions.multi_selection_open_vsplit(prompt_bufnr)
        telescope_custom_actions._multiopen(prompt_bufnr, "vsplit")
      end

      function telescope_custom_actions.multi_selection_open_split(prompt_bufnr)
        telescope_custom_actions._multiopen(prompt_bufnr, "split")
      end

      function telescope_custom_actions.multi_selection_open_tab(prompt_bufnr)
        telescope_custom_actions._multiopen(prompt_bufnr, "tabe")
      end

      function telescope_custom_actions.multi_selection_open(prompt_bufnr)
        telescope_custom_actions._multiopen(prompt_bufnr, "edit")
      end

      require('telescope').setup {
        defaults = {
          prompt_prefix = '🔍 ',
          sorting_strategy = "ascending",
          layout_config = {
            prompt_position = "bottom",
          },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
              ["<CR>"] = telescope_custom_actions.multi_selection_open,
              ["<C-a>"] = actions.select_all,
              ["<c-d>"] = actions.drop_all,
              ["<c-t>"] = actions.toggle_all,
              ["<c-x>"] = actions.delete_buffer,
            },
            n = {
              ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
              ["<CR>"] = telescope_custom_actions.multi_selection_open,
              ["<C-a>"] = actions.select_all,
              ["<c-d>"] = actions.drop_all,
              ["<c-t>"] = actions.toggle_all,
              ["<c-x>"] = actions.delete_buffer,
              ["<c-c>"] = actions.close,
              ["q"] = actions.close,
            },
          },
        },
        extensions = {
          -- fzf = {
          --   fuzzy = true,                   -- false will only do exact matching
          --   override_generic_sorter = true, -- override the generic sorter
          --   override_file_sorter = true,    -- override the file sorter
          --   case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
          --   -- the default case_mode is "smart_case"
          -- },
          aerial = {
            -- How to format the symbols
            format_symbol = function(symbol_path, filetype)
              if filetype == "json" or filetype == "yaml" then
                return table.concat(symbol_path, ".")
              else
                return symbol_path[#symbol_path]
              end
            end,
            -- Available modes: symbols, lines, both
            show_columns = "both",
          },
        },
      }

      -- -- Disable fzf on windows
      -- local is_windows = vim.loop.os_uname().sysname == "Windows_NT"
      -- if not is_windows then
      --   require('telescope').load_extension('fzf')
      -- end
      -- require('telescope').load_extension('ultisnips')

      require('telescope').load_extension('aerial')
    end,
  },

  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release',
    lazy = true,
    module = true,
  },

  {
    'fhill2/telescope-ultisnips.nvim',
    requires = { 'SirVer/ultisnips' },
    lazy = true,
    module = true,
  },

}
