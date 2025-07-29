local coc_setup = function()
  -- https://raw.githubusercontent.com/neoclide/coc.nvim/master/doc/coc-example-config.lua

  vim.g.coc_global_extensions = {
    'coc-marketplace',
    'coc-ultisnips',
    'coc-clangd',
    'coc-css',
    'coc-emmet',
    'coc-html',
    'coc-json',
    'coc-lists',
    'coc-markdownlint',
    'coc-prettier',
    'coc-pyright',
    'coc-pydocstring',
    'coc-sh',
    'coc-snippets',
    'coc-todolist',
    'coc-tsserver',
    'coc-vimlsp',
    'coc-yaml',
    'coc-toml',
    'coc-react-refactor',
    '@yaegassy/coc-volar',
    'coc-styled-components',
    'coc-eslint',
    'coc-go',
    'coc-pairs',
    'coc-powershell',
    'coc-webview',
    'coc-markdown-preview-enhanced',
    'coc-lua',
    'coc-db',
    'coc-rust-analyzer',
  }

  -- Some servers have issues with backup files, see #649
  vim.opt.backup = false
  vim.opt.writebackup = false

  -- Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
  -- delays and poor user experience
  vim.opt.updatetime = 300

  -- Always show the signcolumn, otherwise it would shift the text each time
  -- diagnostics appeared/became resolved
  vim.opt.signcolumn = "yes"

  local keyset = vim.keymap.set
  -- Autocomplete helper (local function)
  local function check_back_space()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
  end

  -- Use Tab for trigger completion with characters ahead and navigate
  -- NOTE: There's always a completion item selected by default, you may want to enable
  -- no select by setting `"suggest.noselect": true` in your configuration file
  -- NOTE: Use command ':verbose imap <tab>' to make sure Tab is not mapped by
  -- other plugins before putting this into your config
  local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
  keyset("i", "<TAB>", function()
    if vim.fn['coc#pum#visible']() ~= 0 then
      return vim.fn['coc#pum#next'](1)
    elseif check_back_space() then
      return vim.api.nvim_replace_termcodes("<TAB>", true, false, true)
    else
      return vim.fn['coc#refresh']()
    end
  end, { silent = true, expr = true })
  keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

  -- Make <CR> to accept selected completion item or notify coc.nvim to format
  -- <C-g>u breaks current undo, please make your own choice
  keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

  -- Use <c-j> to trigger snippets
  -- keyset("i", "<c-s>", "<Plug>(coc-snippets-expand-jump)", { silent = true, desc = "Expand snippet" })
  -- Use <c-space> to trigger completion
  keyset("i", "<c-space>", "coc#refresh()", { silent = true, expr = true, desc = "Trigger completion" })

  -- Use `[g` and `]g` to navigate diagnostics
  keyset("n", "[g", "<Plug>(coc-diagnostic-prev)", { silent = true, desc = "Previous diagnostic" })
  keyset("n", "]g", "<Plug>(coc-diagnostic-next)", { silent = true, desc = "Next diagnostic" })

  -- GoTo code navigation
  keyset("n", "gd", "<Plug>(coc-definition)", { silent = true, desc = "Go to definition" })
  keyset("n", "gy", "<Plug>(coc-type-definition)", { silent = true, desc = "Go to type definition" })
  keyset("n", "gi", "<Plug>(coc-implementation)", { silent = true, desc = "Go to implementation" })
  keyset("n", "gr", "<Plug>(coc-references)", { silent = true, desc = "Go to references" })


  -- Use K to show documentation in preview window
  local function show_docs()
    local cw = vim.fn.expand('<cword>')
    if vim.tbl_contains({ 'vim', 'help' }, vim.bo.filetype) then
      vim.cmd('help ' .. cw)
    elseif vim.fn['coc#rpc#ready']() then
      vim.fn.CocActionAsync('doHover')
    else
      vim.cmd('!' .. vim.o.keywordprg .. ' ' .. cw)
    end
  end

  keyset("n", "K", show_docs, { silent = true, desc = "Show documentation" })


  -- Highlight the symbol and its references on a CursorHold event(cursor is idle)
  vim.api.nvim_create_augroup("CocGroup", {})
  vim.api.nvim_create_autocmd("CursorHold", {
    group = "CocGroup",
    command = "silent call CocActionAsync('highlight')",
    desc = "Highlight symbol under cursor on CursorHold"
  })

  -- Custom highlight colors for COC document highlighting
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = "CocGroup",
    callback = function()
      -- Document highlight groups used by COC for cursor position highlighting
      vim.api.nvim_set_hl(0, "CocHighlightText", { bg = "#5c5c0a", fg = "#ffffff" })
      vim.api.nvim_set_hl(0, "CocHighlightRead", { bg = "#5c5c0a", fg = "#ffffff" })
      vim.api.nvim_set_hl(0, "CocHighlightWrite", { bg = "#c2780a", fg = "#ffffff" })
    end,
    desc = "Set custom COC highlight colors after colorscheme changes"
  })

  -- Apply highlight immediately if colorscheme is already loaded
  vim.api.nvim_set_hl(0, "CocHighlightText", { bg = "#5c5c0a", fg = "#ffffff" })
  vim.api.nvim_set_hl(0, "CocHighlightRead", { bg = "#5c5c0a", fg = "#ffffff" })
  vim.api.nvim_set_hl(0, "CocHighlightWrite", { bg = "#c2780a", fg = "#ffffff" })


  -- Symbol renaming
  keyset("n", "<leader>rn", "<Plug>(coc-rename)", { silent = true, desc = "Rename symbol" })

  -- Formatting selected code
  keyset("x", "<localleader>f", "<Plug>(coc-format-selected)", { silent = true, desc = "Format selected" })
  keyset("n", "<localleader>f", "<Plug>(coc-format)", { silent = true, desc = "Format buffer" })
  keyset("x", "<c-p>", "<Plug>(coc-format-selected)", { silent = true, desc = "Format selected" })
  keyset("n", "<c-p>", "<Plug>(coc-format)", { silent = true, desc = "Format buffer" })


  -- Setup formatexpr specified filetype(s)
  vim.api.nvim_create_autocmd("FileType", {
    group = "CocGroup",
    pattern = "typescript,json",
    command = "setl formatexpr=CocAction('formatSelected')",
    desc = "Setup formatexpr specified filetype(s)."
  })

  -- Update signature help on jump placeholder
  vim.api.nvim_create_autocmd("User", {
    group = "CocGroup",
    pattern = "CocJumpPlaceholder",
    command = "call CocActionAsync('showSignatureHelp')",
    desc = "Update signature help on jump placeholder"
  })

  -- Apply codeAction to the selected region
  -- Example: `<leader>aap` for current paragraph
  local action_opts = { silent = true, nowait = true }
  keyset("x", "<leader>a", "<Plug>(coc-codeaction-selected)",
    vim.tbl_extend("force", action_opts, { desc = "Code action (selected)" }))
  keyset("n", "<leader>a", "<Plug>(coc-codeaction-selected)",
    vim.tbl_extend("force", action_opts, { desc = "Code action (line)" }))

  -- Code actions at different scopes
  keyset("n", "<leader>ac", "<Plug>(coc-codeaction-cursor)",
    vim.tbl_extend("force", action_opts, { desc = "Code action (cursor)" }))
  keyset("n", "<leader>as", "<Plug>(coc-codeaction-source)",
    vim.tbl_extend("force", action_opts, { desc = "Code action (source)" }))
  keyset("n", "<leader>qf", "<Plug>(coc-fix-current)", vim.tbl_extend("force", action_opts, { desc = "Quick fix" }))

  -- Refactor actions
  keyset("n", "<leader>rf", "<Plug>(coc-codeaction-refactor)", { silent = true, desc = "Refactor" })
  keyset("x", "<leader>rr", "<Plug>(coc-codeaction-refactor-selected)", { silent = true, desc = "Refactor selected" })
  keyset("n", "<leader>rr", "<Plug>(coc-codeaction-refactor-selected)", { silent = true, desc = "Refactor" })

  -- Code lens
  keyset("n", "<leader>cl", "<Plug>(coc-codelens-action)",
    vim.tbl_extend("force", action_opts, { desc = "Code lens action" }))


  -- -- Map function and class text objects
  -- -- NOTE: Requires 'textDocument.documentSymbol' support from the language server
  -- これは TreeSitter の textobj 対応に移行したので、不要
  -- local textobj_opts = { silent = true, nowait = true }
  -- keyset("x", "if", "<Plug>(coc-funcobj-i)", vim.tbl_extend("force", textobj_opts, { desc = "Inner function" }))
  -- keyset("o", "if", "<Plug>(coc-funcobj-i)", vim.tbl_extend("force", textobj_opts, { desc = "Inner function" }))
  -- keyset("x", "af", "<Plug>(coc-funcobj-a)", vim.tbl_extend("force", textobj_opts, { desc = "Around function" }))
  -- keyset("o", "af", "<Plug>(coc-funcobj-a)", vim.tbl_extend("force", textobj_opts, { desc = "Around function" }))
  -- keyset("x", "ic", "<Plug>(coc-classobj-i)", vim.tbl_extend("force", textobj_opts, { desc = "Inner class" }))
  -- keyset("o", "ic", "<Plug>(coc-classobj-i)", vim.tbl_extend("force", textobj_opts, { desc = "Inner class" }))
  -- keyset("x", "ac", "<Plug>(coc-classobj-a)", vim.tbl_extend("force", textobj_opts, { desc = "Around class" }))
  -- keyset("o", "ac", "<Plug>(coc-classobj-a)", vim.tbl_extend("force", textobj_opts, { desc = "Around class" }))


  -- Remap <C-f> and <C-b> to scroll float windows/popups
  ---@diagnostic disable-next-line: redefined-local
  local opts = { silent = true, nowait = true, expr = true }
  keyset("n", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
  keyset("n", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
  keyset("i", "<C-f>",
    'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
  keyset("i", "<C-b>",
    'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
  keyset("v", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
  keyset("v", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)

  -- Use CTRL-S for selections ranges
  -- Requires 'textDocument/selectionRange' support of language server
  keyset("n", "<C-s>", "<Plug>(coc-range-select)", { silent = true, desc = "Range select" })
  keyset("x", "<C-s>", "<Plug>(coc-range-select)", { silent = true, desc = "Extend range select" })

  -- Add `:Format` command to format current buffer
  vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})

  -- " Add `:Fold` command to fold current buffer
  vim.api.nvim_create_user_command("Fold", "call CocAction('fold', <f-args>)", { nargs = '?' })

  -- Add `:OR` command for organize imports of the current buffer
  vim.api.nvim_create_user_command("OR", "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})

  -- Add (Neo)Vim's native statusline support
  -- NOTE: Please see `:h coc-status` for integrations with external plugins that
  -- provide custom statusline: lightline.vim, vim-airline
  vim.opt.statusline:prepend("%{coc#status()}%{get(b:,'coc_current_function','')}")

  -- Mappings for CoCList
  -- code actions and coc stuff
  ---@diagnostic disable-next-line: redefined-local
  local list_opts = { silent = true, nowait = true }
  keyset("n", "<localleader>a", ":<C-u>CocList diagnostics<cr>",
    vim.tbl_extend("force", list_opts, { desc = "Show diagnostics" }))
  keyset("n", "<localleader>e", ":<C-u>CocList extensions<cr>",
    vim.tbl_extend("force", list_opts, { desc = "Manage extensions" }))
  keyset("n", "<localleader>c", ":<C-u>CocList commands<cr>",
    vim.tbl_extend("force", list_opts, { desc = "Show commands" }))
  keyset("n", "<localleader>o", ":<C-u>CocList outline<cr>",
    vim.tbl_extend("force", list_opts, { desc = "Document outline" }))
  keyset("n", "<localleader>s", ":<C-u>CocList -I symbols<cr>",
    vim.tbl_extend("force", list_opts, { desc = "Workspace symbols" }))
  keyset("n", "<localleader>j", ":<C-u>CocNext<cr>", vim.tbl_extend("force", list_opts, { desc = "Next item" }))
  keyset("n", "<localleader>k", ":<C-u>CocPrev<cr>", vim.tbl_extend("force", list_opts, { desc = "Previous item" }))
  keyset("n", "<localleader>p", ":<C-u>CocListResume<cr>", vim.tbl_extend("force", list_opts, { desc = "Resume list" }))
  keyset("n", "<localleader>m", ":<C-u>CocList marketplace<cr>",
    vim.tbl_extend("force", list_opts, { desc = "Marketplace" }))


  -- " Use <C-j> for jump to next placeholder, it's default of coc.nvim
  -- let g:coc_snippet_next = '<c-j>'
  -- " let g:coc_snippet_next = '<tab>'
  --
  -- " Use <C-k> for jump to previous placeholder, it's default of coc.nvim
  -- let g:coc_snippet_prev = '<c-k>'
  --
  -- " Use <C-j> for both expand and jump (make expand higher priority.)
  -- imap <C-l> <Plug>(coc-snippets-expand-jump)
  --
  -- " Use <leader>x for convert visual selected code to snippet
  -- xmap <leader>x  <Plug>(coc-convert-snippet)
end

return {
  {
    "neoclide/coc.nvim",
    branch = "release",
    event = { "BufReadPre", "BufNewFile" },
    cmd = {
      "CocInstall", "CocUninstall", "CocUpdate", "CocUpdateSync",
      "CocList", "CocNext", "CocPrev", "CocAction", "Format", "Fold", "OR"
    },
    config = coc_setup,
    dependencies = {
      'SirVer/ultisnips'
    }
  }
}
