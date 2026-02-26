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

      -- Windows では最小限のパーサーのみインストール
      require('nvim-treesitter').install {
        'css', 'go', 'html', 'javascript', 'json', 'lua',
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

      -- Select keymaps
      vim.keymap.set({ 'x', 'o' }, 'af', function() ts_select.select_textobject('@function.outer') end,
        { desc = 'Select outer function' })
      vim.keymap.set({ 'x', 'o' }, 'if', function() ts_select.select_textobject('@function.inner') end,
        { desc = 'Select inner function' })
      vim.keymap.set({ 'x', 'o' }, 'ac', function() ts_select.select_textobject('@class.outer') end,
        { desc = 'Select outer class' })
      vim.keymap.set({ 'x', 'o' }, 'ic', function() ts_select.select_textobject('@class.inner') end,
        { desc = 'Select inner class' })
      vim.keymap.set({ 'x', 'o' }, 'as', function() ts_select.select_textobject('@scope', 'locals') end,
        { desc = 'Select language scope' })
      -- markdown code fence (defined in queries/markdown/textobjects.scm)
      vim.keymap.set({ 'x', 'o' }, 'ik', function() ts_select.select_textobject('@code_fence.content') end,
        { desc = 'Select code fence content' })
      vim.keymap.set({ 'x', 'o' }, 'ak', function() ts_select.select_textobject('@code_fence.outer') end,
        { desc = 'Select outer code fence' })

      -- Move keymaps
      vim.keymap.set({ 'n', 'x', 'o' }, ']m', function() ts_move.goto_next_start('@function.outer') end,
        { desc = 'Next function start' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']]', function() ts_move.goto_next_start('@class.outer') end,
        { desc = 'Next class start' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']o', function() ts_move.goto_next_start('@loop.*') end, { desc = 'Next loop' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']k', function() ts_move.goto_next_start('@code_fence.outer') end,
        { desc = 'Next code fence' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']M', function() ts_move.goto_next_end('@function.outer') end,
        { desc = 'Next function end' })
      vim.keymap.set({ 'n', 'x', 'o' }, '][', function() ts_move.goto_next_end('@class.outer') end,
        { desc = 'Next class end' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']K', function() ts_move.goto_next_end('@code_fence.outer') end,
        { desc = 'Next code fence end' })

      vim.keymap.set({ 'n', 'x', 'o' }, '[m', function() ts_move.goto_previous_start('@function.outer') end,
        { desc = 'Previous function start' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[[', function() ts_move.goto_previous_start('@class.outer') end,
        { desc = 'Previous class start' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[k', function() ts_move.goto_previous_start('@code_fence.outer') end,
        { desc = 'Previous code fence' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[M', function() ts_move.goto_previous_end('@function.outer') end,
        { desc = 'Previous function end' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[]', function() ts_move.goto_previous_end('@class.outer') end,
        { desc = 'Previous class end' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[K', function() ts_move.goto_previous_end('@code_fence.outer') end,
        { desc = 'Previous code fence end' })

      vim.keymap.set({ 'n', 'x', 'o' }, ']d', function() ts_move.goto_next('@conditional.outer') end,
        { desc = 'Next conditional' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[d', function() ts_move.goto_previous('@conditional.outer') end,
        { desc = 'Previous conditional' })
    end
  },

}
