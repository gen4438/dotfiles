local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- ファイル形式の検出
local fileTypeDetect = augroup("fileTypeDetect", { clear = true })

-- OpenSSH configuration
autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "ssh_config", "*/.ssh/config", "*/.ssh/config.d/*" },
  group = fileTypeDetect,
  command = "setfiletype sshconfig",
})

-- bash
autocmd({ "BufNewFile", "BufRead" }, {
  pattern = ".bash/*.d/*",
  group = fileTypeDetect,
  command = "setfiletype bash",
})

-- direnv
autocmd({ "BufNewFile", "BufRead" }, {
  pattern = ".envrc",
  group = fileTypeDetect,
  command = "setfiletype conf",
})

-- google apps script
autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.gs",
  group = fileTypeDetect,
  command = "setfiletype javascript",
})

-- ks as kag3
autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.ks",
  group = fileTypeDetect,
  command = "setfiletype kag3",
})

-- glsl
autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.glsl", "*.vert", "*.frag" },
  group = fileTypeDetect,
  command = "setfiletype glsl",
})
autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.glsl", "*.vert", "*.frag" },
  group = fileTypeDetect,
  command = "setlocal commentstring=//\\ %s",
})

-- solidworks macro
autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.swb",
  group = fileTypeDetect,
  command = "setfiletype vb",
})

-- cheat file
autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.cheat", "*.cht", "*.chx" },
  group = fileTypeDetect,
  command = "setfiletype text",
})

-- ファイルタイプごとの設定
local fileTypeConfig = augroup("fileTypeConfig", { clear = true })

-- インデント設定
autocmd("FileType", {
  pattern = "python",
  group = fileTypeConfig,
  command = "setlocal ts=4 textwidth=88 formatoptions+=mM",
})

autocmd("FileType", {
  pattern = { "tsv", "csv" },
  group = fileTypeConfig,
  command = "setlocal ts=8 noexpandtab",
})

autocmd("FileType", {
  pattern = "make",
  group = fileTypeConfig,
  command = "setlocal ts=4 noexpandtab",
})

autocmd("FileType", {
  pattern = "markdown",
  group = fileTypeConfig,
  command = "setlocal ts=2 sw=0",
})

-- markdown で改行時に bullets を挿入するために fo に r, o を追加
autocmd("BufEnter", {
  pattern = "*.md",
  group = fileTypeConfig,
  command = "setlocal fo+=r fo-=o",
})
autocmd("Filetype", {
  pattern = "markdown",
  group = fileTypeConfig,
  command = "setlocal fo+=r fo-=o",
})

autocmd("Filetype", {
  pattern = "markdown",
  group = fileTypeConfig,
  callback = function()
    -- Increase indent with <tab> in list
    vim.api.nvim_buf_set_keymap(0, "i", "<Tab>", "getline('.') =~# '^\\s*[*+-]\\s\\?' ? '<c-t>' : '<tab>'",
      { noremap = true, expr = true, silent = true })
    -- Decrease indent with <S-Tab> in list
    vim.api.nvim_buf_set_keymap(0, "i", "<S-Tab>", "getline('.') =~# '^\\s*[*+-]\\s\\?' ? '<c-d>' : '<s-tab>'",
      { noremap = true, expr = true, silent = true })
  end,
})

-- cjson （コメントアウトありのjson）に対応
autocmd("FileType", {
  pattern = "json",
  group = fileTypeConfig,
  command = "syntax match Comment +\\/\\/.\\+$+",
})

-- シンタックスハイライトのしきい値
autocmd("FileType", {
  pattern = { "markdown", "jsp", "asp", "php", "xml", "perl" },
  group = fileTypeConfig,
  command = "syntax sync minlines=500 maxlines=1000",
})

-- 巨大なcsv,tsvファイルを開いたときのシンタックスハイライトが重い
autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.{csv,tsv}",
  group = fileTypeConfig,
  callback = function()
    if vim.fn.line('$') > 5000 then
      vim.bo.filetype = 'txt'
    end
  end,
})

-- 色々と隠れるのを防ぐ
-- autocmd("FileType", {
--   pattern = "markdown",
--   group = fileTypeConfig,
--   command = "let g:indentLine_enabled=0 | set conceallevel=0",
-- })

-- markdown italic
autocmd("FileType", {
  pattern = "markdown",
  group = fileTypeConfig,
  command = "vnoremap <buffer> <c-i> :s/\\%V.*\\%V./*&*/<cr>",
})

-- markdown bold
autocmd("FileType", {
  pattern = "markdown",
  group = fileTypeConfig,
  command = "vnoremap <buffer> <c-b> :s/\\%V.*\\%V./**&**/<cr>",
})

-- -- markdown double width characters
-- autocmd("FileType", {
--   pattern = "markdown",
--   group = fileTypeConfig,
--   command = "setlocal ambiwidth=double",
-- })

-- autocmd("FileType", {
--   pattern = "json",
--   group = fileTypeConfig,
--   command = "nnoremap <buffer> <leader>jq :%!jq .<CR>",
-- })

-- autocmd("FileType", {
--   pattern = "xml",
--   group = fileTypeConfig,
--   command = "nnoremap <buffer> <leader>xml:%!xmllint --format -<CR>",
-- })
