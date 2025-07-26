-- ドキュメント作成ツール
return {
  {
    'preservim/vim-markdown',
    ft = 'markdown',
    lazy = true,
    -- event = 'BufReadPre',
    dependencies = {
      'godlygeek/tabular',
    },
    init = function()
      vim.g.vim_markdown_new_list_item_indent = 0
      vim.g.vim_markdown_auto_insert_bullets = 1
      vim.g.vim_markdown_folding_disabled = 0
      vim.g.markdown_recommended_style = 0
    end,
  },
  {
    'godlygeek/tabular',
    ft = { 'markdown' },
    cmd = { "Tabularize" },
    lazy = true,
  },

  -- markdownのプレビュー表示 こっちの方が軽い
  {
    'previm/previm',
    lazy = true,
    init = function()
      vim.g.previm_enable_realtime = 1
      vim.g.previm_disable_default_css = 1
      vim.g.previm_custom_css_path = vim.fn.stdpath('config') .. '/misc/github-markdown.css'
    end,
    ft = { 'markdown' },
    dependencies = {
      'tyru/open-browser.vim',
    },
    cmd = {
      "PrevimOpen",
    },
    keys = {
      { "<c-k>v", ":PrevimOpen<CR>" },
    }
  },

  -- markdownのプレビュー表示 こっちの方がきれい
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    lazy = true,
    build = function()
      -- install without yarn or npm
      vim.cmd [[Lazy load markdown-preview.nvim]]
      vim.fn["mkdp#util#install"]()
    end,
    ft = { "markdown" },
    keys = {
      -- " normal/insert
      -- <Plug>MarkdownPreview
      -- <Plug>MarkdownPreviewStop
      -- <Plug>MarkdownPreviewToggle
      { "<leader>mv", "<Plug>MarkdownPreview", mode = "n" },
    },
    config = function()
      vim.g.mkdp_refresh_slow                 = 1
      vim.g.mkdp_auto_start                   = 0
      vim.g.mkdp_auto_close                   = 0
      vim.g.mkdp_combine_preview              = 0
      vim.g.mkdp_combine_preview_auto_refresh = 0
      vim.g.mkdp_echo_preview_url             = 1
      -- vim.g.mkdp_theme                        = 'dark'
      -- vim.g.mkdp_open_to_the_world            = 1
      -- vim.g.mkdp_open_ip                      = ""
      -- vim.g.mkdp_port                         = "8080"
    end,
  },

  -- -- TOC作成
  -- {
  --   'mzlogin/vim-markdown-toc',
  --   lazy = true,
  --   ft = { 'markdown' },
  -- },

  -- markdown で クリップボードの画像を貼り付け
  {
    'img-paste-devs/img-paste.vim',
    lazy = true,
    ft = { 'markdown' },
    config = function()
      -- " there are some defaults for image directory and image name, you can change them
      vim.g.mdip_imgdir = 'img'
      vim.g.mdip_imgname = 'image'
    end,
    keys = {
      -- autocmd FileType markdown nmap <buffer><silent> <leader>p :call mdip#MarkdownClipboardImage()<CR>
      { "<leader>p", ":call mdip#MarkdownClipboardImage()<CR>", mode = "n", { noremap = true, silent = true } }
    }
  },

  -- code fence の中身を編集
  -- AckslD/nvim-FeMaco.lua
  {
    'AckslD/nvim-FeMaco.lua',
    lazy = true,
    ft = { 'markdown' },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      -- デフォルトは float window だが vsplit に変更
      prepare_buffer = function()
        local buf = vim.api.nvim_create_buf(false, false)
        vim.api.nvim_command('vsplit')
        vim.api.nvim_set_current_buf(buf)
        return vim.api.nvim_get_current_win()
      end,

      -- what to do after opening the float
      post_open_float = function(winnr)
        -- vim.wo.signcolumn = 'no'
      end,

      -- create the path to a temporary file
      create_tmp_filepath = function(filetype)
        return os.tmpname()
      end,
    },
    keys = {
      { "<leader>fe", ":FeMaco<cr>",      mode = "n" },
      -- visual mode では選択を解除してから FeMaco を実行
      { "<leader>fe", ":<C-u>FeMaco<cr>", mode = "x" },
    },
  }
}
