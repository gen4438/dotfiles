-- Git 関連
return {
  -- Git操作
  {
    'tpope/vim-fugitive',
    keys = {
      { '<leader>go',  ':GBrowse!<CR>',         mode = 'v', desc = "Open in browser (visual)" },
      { '<leader>go',  ':GBrowse!<CR>',         mode = 'n', desc = "Open in browser" },
      { '<leader>ga',  ':Gwrite<CR>',           mode = 'n', desc = "Git add current file" },
      { '<leader>gc',  ':Git commit -v',        mode = 'n', desc = "Git commit" },
      { '<leader>gsh', ':Git push',             mode = 'n', desc = "Git push" },
      { '<leader>glh', ':Gclog<CR>',            mode = 'n', desc = "Git log (current file)" },
      { '<leader>glg', ':0Gclog<CR>',           mode = 'n', desc = "Git log (current line)" },
      { '<leader>glg', ':Gclog<CR>',            mode = 'v', desc = "Git log (visual range)" },
      { '<leader>gll', ':Git pull',             mode = 'n', desc = "Git pull" },
      { '<leader>gst', ':Git<CR>',              mode = 'n', desc = "Git status" },
      { '<leader>gb',  ':Git blame<CR>',        mode = 'n', desc = "Git blame" },
      { '<leader>gd',  ':Gvdiffsplit',          mode = 'n', desc = "Git diff (vertical split)" },
      { '<leader>grb', ':Git rebase -i origin', mode = 'n', desc = "Git rebase interactive" },
      { '<leader>grd', ':Gread',                mode = 'n', desc = "Git restore file" },
      { '<leader>ge',  ':Gedit',                mode = 'n', desc = "Git edit" },
      { '<leader>grm', ':GRemove',              mode = 'n', desc = "Git remove file" },
      { '<leader>gmv', ':GRename',              mode = 'n', desc = "Git rename file" },
    },
    cmd = {
      "Git",
      "Gbrowse",
      "Gwrite",
      "Gcommit",
      "Gpush",
      "Gclog",
      "Gpull",
      "Gvdiffsplit",
      "Gread",
      "Gedit",
      "GRemove",
      "GRename",
    },

    config = function()
      -- commit hook 失敗時にバッファ読み込み
      -- https://github.com/tpope/vim-fugitive/issues/1854
      local function after_git()
        if not vim.fn.exists('*FugitiveResult') then
          return
        end

        local result = vim.fn.FugitiveResult()
        if not vim.fn.filereadable(result.file or '') or not result.args or (result.args[1] or '') ~= 'commit' or not result.exit_status then
          return
        end

        vim.cmd('Gsplit -')
      end

      vim.api.nvim_create_augroup('my_fugitive_stuff', { clear = true })
      vim.api.nvim_create_autocmd('User', {
        pattern = 'FugitiveChanged',
        callback = after_git,
        group = 'my_fugitive_stuff'
      })

      -- fugitive-index でのマッピング変更
      vim.api.nvim_create_autocmd('User', {
        pattern = 'FugitiveIndex',
        callback = function()
          local function copy_keymap(mode, original_key, new_key)
            -- 元々 original_key にマッピングされている <SID> 付きのマッピングを取得して new_key にマッピングする
            -- <SID> がついていて外部から呼び出せないのでこういう方法を取っている
            -- original_key に別のマッピングを行いたいので new_key を remap にするだけではうまくいかない
            local mappings = vim.api.nvim_buf_get_keymap(0, mode)
            for _, mapping in ipairs(mappings) do
              if mapping.lhs == original_key then
                vim.api.nvim_buf_set_keymap(0, mode, new_key, mapping.rhs, { noremap = true, silent = true })
                break
              end
            end
          end

          -- マッピングを移し替える
          for _, mode in ipairs({ 'n', 'x' }) do
            copy_keymap(mode, 's', '<c-s>')
            copy_keymap(mode, 'u', '<c-u>')
            copy_keymap(mode, 's', '<left>')
            copy_keymap(mode, 'u', '<right>')
          end

          -- s を無効化
          vim.api.nvim_buf_set_keymap(0, 'n', 's', '<nop>', { noremap = true, silent = true })
          vim.api.nvim_buf_set_keymap(0, 'x', 's', '<nop>', { noremap = true, silent = true })

          -- u を無効化
          vim.api.nvim_buf_set_keymap(0, 'n', 'u', '<nop>', { noremap = true, silent = true })
          vim.api.nvim_buf_set_keymap(0, 'x', 'u', '<nop>', { noremap = true, silent = true })
        end,
      })
    end
  },

  -- github を開く
  {
    'tpope/vim-rhubarb',
    dependencies = {
      'tpope/vim-fugitive',
    },
  },

  -- gitlab を開く
  {
    'shumphrey/fugitive-gitlab.vim',
    dependencies = {
      'tpope/vim-fugitive',
    },
  },

  -- Gitの追加/削除/変更された行を行番号の左に表示
  -- { 'airblade/vim-gitgutter', lazy = true },
  {
    'lewis6991/gitsigns.nvim',
    event = "BufRead",
    keys = {
      {
        ']c',
        function()
          if vim.wo.diff then
            vim.cmd.normal({ ']c', bang = true })
          else
            require('gitsigns').nav_hunk('next')
          end
        end,
        mode = 'n',
        desc = "Next git hunk"
      },
      {
        '[c',
        function()
          if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
          else
            require('gitsigns').nav_hunk('prev')
          end
        end,
        mode = 'n',
        desc = "Previous git hunk"
      },
    },
    config = function()
      require('gitsigns').setup {
        signs                        = {
          add          = { text = '+' },
          change       = { text = '┃' },
          delete       = { text = '-' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signs_staged                 = {
          add          = { text = '+' },
          change       = { text = '┃' },
          delete       = { text = '-' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signs_staged_enable          = true,
        signcolumn                   = true,  -- Toggle with `:Gitsigns toggle_signs`
        numhl                        = false, -- Toggle with `:Gitsigns toggle_numhl`
        linehl                       = false, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff                    = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir                 = {
          follow_files = true
        },
        auto_attach                  = true,
        attach_to_untracked          = false,
        current_line_blame           = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts      = {
          virt_text = true,
          virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
          delay = 1000,
          ignore_whitespace = false,
          virt_text_priority = 100,
          use_focus = true,
        },
        current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
        sign_priority                = 6,
        update_debounce              = 100,
        status_formatter             = nil,   -- Use default
        max_file_length              = 40000, -- Disable if file is longer than this (in lines)
        preview_config               = {
          -- Options passed to nvim_open_win
          border = 'single',
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1
        },
      }

      vim.o.statusline = vim.o.statusline .. "%{get(b:,'gitsigns_status','')}"

      -- " ステータスラインに統計情報を表示
      -- function! GitStatus()
      --   let [a,m,r] = GitGutterGetHunkSummary()
      --   return printf('+%d ~%d -%d', a, m, r)
      -- endfunction
    end,
  },

  -- -- git commitのメッセージ編集画面をいい感じにする
  -- { 'rhysd/committia.vim',           lazy = true },

}
