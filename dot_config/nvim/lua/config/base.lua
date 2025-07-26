-- Vim 本体の機能のデフォルト値を設定
vim.cmd('filetype plugin indent on')
vim.cmd('syntax enable')

-- https://github.com/neovim/neovim/pull/26347#issuecomment-1837508178
vim.treesitter.start = (function(wrapped)
  return function(bufnr, lang)
    lang = lang or vim.fn.getbufvar(bufnr or '', '&filetype')
    pcall(wrapped, bufnr, lang)
  end
end)(vim.treesitter.start)
