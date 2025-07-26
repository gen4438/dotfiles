return { {
  'github/copilot.vim',
  enabled = true,
  lazy = true,
  event = "VimEnter",
  init = function()
    vim.g.copilot_filetypes = {
      csv = false,
      env = false,
      yaml = true,
      markdown = true,
      help = false,
      gitcommit = true,
      gitrebase = false,
      hgcommit = false,
      svn = false,
      cvs = false,
      -- ["copilot-chat"] = false,
    }
    vim.g.copilot_no_tab_map = true
    vim.api.nvim_set_hl(0, 'CopilotSuggestion', { fg = '#FF5555', ctermfg = 8 })
  end,
  keys = {
    {
      "<C-j>",
      'copilot#Accept("<CR>")',
      mode = "i",
      silent = true,
      expr = true,
      replace_keycodes = false,
      desc = "Accept"
    },
    {
      "cp",
      ":Copilot panel<CR>",
      mode = "n",
      silent = true,
      desc = "Open Copilot panel"
    },
    {
      "<C-]>",
      "copilot#Dismiss()",
      mode = "i",
      silent = true,
      expr = true,
      desc = "Dismiss"
    },
    {
      "<M-]>",
      "copilot#Next()",
      mode = "i",
      silent = true,
      expr = true,
      desc = "Next"
    },
    {
      "<M-[>",
      "copilot#Previous()",
      mode = "i",
      silent = true,
      expr = true,
      desc = "Previous"
    },
    {
      "<c-k><c-k>",
      "copilot#Suggest()",
      mode = "i",
      silent = false,
      expr = true,
      desc = "Suggest"
    },
    {
      "<c-w>",
      "<Plug>(copilot-accept-word)",
      mode = "i",
      silent = true,
      expr = false,
      desc = "Accept word"
    },
    {
      "<c-l>",
      "<Plug>(copilot-accept-line)",
      mode = "i",
      silent = true,
      expr = false,
      desc = "Accept line"
    }
  }

  -- " " coc.nvim との連携
  -- " if !empty(globpath(&rtp, 'plugin/coc.vim'))
  -- " let g:copilot_no_tab_map = v:true
  -- " inoremap <silent><expr> <TAB>
  -- "       \ coc#pum#visible() ? coc#pum#next(1):
  -- "       \ exists('b:_copilot.suggestions') ? copilot#Accept("\<CR>") :
  -- "       \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
  -- "       \ CheckBackspace() ? "\<Tab>" :
  -- "       \ coc#refresh()
  -- " endif

  -- " 大きいファイルでは無効化
  -- augroup file_size_limit
  --   autocmd BufReadPre *
  --      \ let f=getfsize(expand("<afile>"))
  --      \ | if f > 100000 || f == -2
  --      \ | let b:copilot_enabled = v:false
  --      \ | endif
  -- augroup END

},
  {
    'zbirenbaum/copilot.lua',
    lazy = true,
    enabled = false,
    event = "VimEnter",
    opts = {
      panel = {
        enabled = true,
        auto_refresh = false,
        keymap = {
          jump_prev = "[[",
          jump_next = "]]",
          accept = "<CR>",
          refresh = "gr",
          open = "<M-CR>"
        },
        layout = {
          position = "bottom", -- | top | left | right
          ratio = 0.4
        }
      },
      suggestion = {
        enabled = true,
        auto_trigger = false,
        hide_during_completion = true,
        debounce = 75,
        keymap = {
          accept = "<M-l>",
          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>"
        }
      },
      filetypes = {
        yaml = false,
        markdown = false,
        help = false,
        gitcommit = false,
        gitrebase = false,
        hgcommit = false,
        svn = false,
        cvs = false,
        ["."] = false
      },
      copilot_node_command = 'node', -- Node.js version must be > 18.x
      server_opts_overrides = {}
    },
  },
}
