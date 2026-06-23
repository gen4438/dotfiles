return {
  -- https://github.com/nvim-treesitter/nvim-treesitter
  -- main ブランチ (Neovim 0.11.0+ 必須)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = true,
    event = "VeryLazy",
    cmd = { "TSInstall", "TSUpdate" },
    config = function()
      require('nvim-treesitter').setup {
        install_dir = vim.fn.stdpath('data') .. '/site',
      }

      -- パーサーの自動インストール (MSYS2 gcc / clang でコンパイル)
      require('nvim-treesitter').install {
        'bash', 'css', 'go', 'html', 'javascript', 'json', 'lua',
        'markdown', 'markdown_inline', 'powershell', 'python', 'vim', 'vimdoc', 'yaml',
      }

      -- highlight と indent は vim.treesitter の標準機能を使用
      -- FileType autocmd で有効化
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          -- パーサーが利用可能な場合のみ有効化
          local ok, _ = pcall(vim.treesitter.start, args.buf)
          if ok then
            -- indent を有効化 (experimental)
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      -- 大きいファイルで無効化されたtreesitterを手動で有効化するキーマップ
      vim.keymap.set('n', '<leader>ts', function()
        vim.bo.syntax = 'on'
        vim.b.large_file = nil
        local ok, _ = pcall(vim.treesitter.start)
        if ok then
          vim.notify('Treesitter enabled', vim.log.levels.INFO)
        else
          vim.notify('Treesitter not available', vim.log.levels.WARN)
        end
      end, { desc = 'Enable Treesitter for current buffer' })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    lazy = true,
    event = "VeryLazy",
    config = function()
      -- register custom filetypes
      vim.treesitter.language.register('markdown', 'copilot-chat')

      require('nvim-treesitter-textobjects').setup {
        select = {
          lookahead = true,
          selection_modes = {
            ['@parameter.outer'] = 'v', -- charwise
            ['@function.outer'] = 'V',  -- linewise
            ['@class.outer'] = '<c-v>', -- blockwise
            ['@code_fence.content'] = 'V',
            ['@code_fence.outer'] = 'V',
          },
          include_surrounding_whitespace = false,
        },
        move = {
          set_jumps = true,
        },
      }

      -- Textobject keymaps
      local ts_select = require('nvim-treesitter-textobjects.select')
      local ts_move = require('nvim-treesitter-textobjects.move')

      -- Select keymaps: { lhs, textobject, desc, query_group? }
      -- 例: vik = inner code fence を選択 (markdown のコードブロック中身)
      local selects = {
        { 'af', '@function.outer',      'outer function' },
        { 'if', '@function.inner',      'inner function' },
        { 'ac', '@class.outer',         'outer class' },
        { 'ic', '@class.inner',         'inner class' },
        { 'as', '@scope',               'language scope', 'locals' },
        -- markdown code fence (queries/markdown/textobjects.scm で定義)
        { 'ik', '@code_fence.content',  'code fence content' },
        { 'ak', '@code_fence.outer',    'outer code fence' },
      }
      for _, m in ipairs(selects) do
        local obj, group = m[2], m[4]
        vim.keymap.set({ 'x', 'o' }, m[1], function() ts_select.select_textobject(obj, group) end,
          { desc = 'Select ' .. m[3] })
      end

      -- Move keymaps: { lhs, move_fn, textobject, desc }
      local moves = {
        { ']m', 'goto_next_start',     '@function.outer',    'Next function start' },
        { ']]', 'goto_next_start',     '@class.outer',       'Next class start' },
        { ']o', 'goto_next_start',     '@loop.*',            'Next loop' },
        { ']k', 'goto_next_start',     '@code_fence.outer',  'Next code fence' },
        { ']M', 'goto_next_end',       '@function.outer',    'Next function end' },
        { '][', 'goto_next_end',       '@class.outer',       'Next class end' },
        { ']K', 'goto_next_end',       '@code_fence.outer',  'Next code fence end' },
        { '[m', 'goto_previous_start', '@function.outer',    'Previous function start' },
        { '[[', 'goto_previous_start', '@class.outer',       'Previous class start' },
        { '[k', 'goto_previous_start', '@code_fence.outer',  'Previous code fence' },
        { '[M', 'goto_previous_end',   '@function.outer',    'Previous function end' },
        { '[]', 'goto_previous_end',   '@class.outer',       'Previous class end' },
        { '[K', 'goto_previous_end',   '@code_fence.outer',  'Previous code fence end' },
        { ']d', 'goto_next',           '@conditional.outer', 'Next conditional' },
        { '[d', 'goto_previous',       '@conditional.outer', 'Previous conditional' },
      }
      for _, m in ipairs(moves) do
        local fn, obj = m[2], m[3]
        vim.keymap.set({ 'n', 'x', 'o' }, m[1], function() ts_move[fn](obj) end, { desc = m[4] })
      end
    end
  },

}
