-- 見た目に関連するプラグイン

return {
  -- statusline
  {
    'nvim-lualine/lualine.nvim',
    lazy = true,
    event = "VeryLazy",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        icons_enabled = true,
        -- theme = 'auto',
        theme = '16color',
        -- theme = 'powerline_dark',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        }
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename',
          -- function()
          --   return require("nvim-treesitter").statusline()
          -- end,
          -- function()
          --   return require("nvim-treesitter").statusline({
          --     -- indicator_size = 70,
          --     type_patterns = { "class", "function", "method" },
          --     separator = " -> ",
          --   })
          -- end,
          "aerial",
        },
        lualine_x = { 'encoding', { 'fileformat', symbols = { unix = 'LF', dos = 'CRLF', mac = 'CR' } }, 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {}
    }
  },

  -- バッファのタブ表示
  {
    'akinsho/bufferline.nvim',
    version = "*",
    lazy = true,
    event = "VeryLazy",
    dependencies = 'nvim-tree/nvim-web-devicons',
    opts = {
      -- See the docs for details :h bufferline.nvim
      highlights = {
        buffer_selected = {
          fg = '#ffffff',
          bg = '#ff00ff',
        }
      },
    },
    keys = {
      { "<c-l>", ":BufferLineCycleNext<CR>", mode = "n" },
      { "<c-h>", ":BufferLineCyclePrev<CR>", mode = "n" },
      { "s>", ":BufferLineMoveNext<CR>",  mode = "n" },
      { "s<", ":BufferLineMovePrev<CR>",  mode = "n" },
      { "<leader>bse", ":BufferLineSortByExtension<CR>", mode = "n" },
      { "<leader>bsd", ":BufferLineSortByDirectory<CR>", mode = "n" },
    }
  },

}
