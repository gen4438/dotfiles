local vim_state_dir = vim.fn.stdpath("state")

-- clipboard
if vim.fn.has('clipboard') == 1 then
  vim.o.clipboard = 'unnamedplus,unnamed'
end

-- Backup
vim.o.backupdir = vim_state_dir .. "/backup"
vim.o.backup = true
vim.o.writebackup = true

-- Swap
vim.o.swapfile = true

-- Undo
vim.o.undofile = true

-- エンコーディング
vim.o.encoding = 'utf-8'
vim.o.fileencoding = 'utf-8'
vim.o.fileencodings = 'ucs-bom,utf-8,sjis,cp932,iso-2022-jp-3,iso-2022-jp,euc-jp,eucjp-ms,euc-jisx0213'
vim.o.fileformats = 'unix,dos,mac'
vim.o.fileformat = 'unix'
vim.o.bomb = false

-- 保存されていないファイルがあるときでも別のファイルを開くことが出来る
vim.o.hidden = true
vim.o.autoread = true

-- その他の設定
vim.o.updatetime = 300
vim.o.switchbuf = 'useopen'
vim.o.showcmd = true
vim.o.spell = false
vim.o.spelllang = 'en,cjk'
vim.o.timeoutlen = 5000
vim.o.ttimeoutlen = 100
vim.o.completeopt = 'menuone,preview,noinsert,noselect'
vim.o.dictionary = '/usr/share/dict/words'
vim.o.thesaurus = '/usr/share/mythes/th_en_US_v2.dat'
vim.o.backspace = 'indent,eol,start'
vim.o.fixeol = false
vim.o.tabstop = 2
vim.o.softtabstop = 0
vim.o.shiftwidth = 0
vim.o.expandtab = true
vim.o.smarttab = true
vim.o.autoindent = true
vim.o.smartindent = false
vim.o.foldmethod = 'indent'
vim.o.foldlevel = 99
vim.o.foldcolumn = '0'
vim.o.wrap = false
vim.o.wrapmargin = 0
vim.o.textwidth = 0
vim.o.formatoptions = ''
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true
vim.o.wrapscan = true
vim.o.hlsearch = true
vim.o.ttyfast = true
vim.o.mouse = 'a'
vim.o.mousemodel = 'popup'
vim.o.infercase = true
vim.o.history = 10000
vim.o.listchars = 'tab:»-,extends:»,precedes:«,nbsp:%'
vim.o.showtabline = 2
vim.o.laststatus = 2
vim.o.ruler = true
vim.o.signcolumn = 'yes'
vim.o.number = true
vim.o.cmdheight = 2
vim.o.scrolloff = 5
vim.o.gcr = 'a:blinkon0'
vim.o.modeline = true
vim.o.modelines = 10
vim.o.title = true
vim.o.titleold = 'Terminal'
vim.o.titlestring = '%F'
vim.o.showmatch = true
vim.o.matchpairs = '(:),{:},[:],<:>,「:」,『:』,（:）,【:】,《:》,〈:〉,［:］,‘:’,“:”'
vim.o.matchtime = 3
vim.o.startofline = false
vim.o.virtualedit = 'block'
vim.o.belloff = 'all'
vim.o.nrformats = ''
vim.o.wildmenu = true
vim.o.wildmode = 'list:longest,full'
vim.o.wildignore = '*.o,*.obj,.git,*.rbc,*.pyc,__pycache__,*.so,*.swp,*.zip,*.db,*.sqlite'
vim.o.splitbelow = true
vim.o.splitright = true
vim.g.sesion_autoload = 'no'
vim.o.helplang = 'ja,en'
vim.o.helpheight = 1000
vim.g.no_gvimrc_example = 1
vim.g.no_vimrc_example = 1
vim.o.diffopt = 'foldcolumn:0,internal,filler,closeoff,algorithm:patience' -- algorithm: myers, minimal, patience, histogram
