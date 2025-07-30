-- Neovim options configuration

local vim_state_dir = vim.fn.stdpath("state")

-- File handling and encoding
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'
vim.opt.fileencodings = { 'ucs-bom', 'utf-8', 'sjis', 'cp932', 'iso-2022-jp-3', 'iso-2022-jp', 'euc-jp', 'eucjp-ms', 'euc-jisx0213' }
vim.opt.fileformats = { 'unix', 'dos', 'mac' }
vim.opt.fileformat = 'unix'
vim.opt.bomb = false
vim.opt.fixeol = false

-- Buffer and file management
vim.opt.hidden = true      -- Allow switching buffers without saving
vim.opt.autoread = true    -- Auto-read changed files
vim.opt.autowrite = false  -- Don't auto-write files

-- Backup and swap configuration
vim.opt.backup = true
vim.opt.writebackup = true
vim.opt.backupdir = vim_state_dir .. "/backup"
vim.opt.swapfile = true
vim.opt.directory = vim_state_dir .. "/swap"
vim.opt.undofile = true
vim.opt.undodir = vim_state_dir .. "/undo"

-- Create directories if they don't exist
vim.fn.mkdir(vim.opt.backupdir:get()[1], "p")
vim.fn.mkdir(vim.opt.directory:get()[1], "p")
vim.fn.mkdir(vim.opt.undodir:get()[1], "p")

-- Clipboard configuration (basic, extended in environment.lua)
if vim.fn.has('clipboard') == 1 then
  vim.opt.clipboard = { 'unnamedplus', 'unnamed' }
end

-- Performance and responsiveness
vim.opt.updatetime = 300        -- Faster completion and diagnostics
vim.opt.timeoutlen = 2000        -- Shorter timeout for key sequences (was 5000)
vim.opt.ttimeoutlen = 10        -- Faster key code timeout (was 100)
vim.opt.lazyredraw = false      -- Don't redraw during macros (can cause issues with modern plugins)
vim.opt.ttyfast = true          -- Fast terminal connection

-- Completion settings
vim.opt.completeopt = { 'menuone', 'noselect', 'noinsert' }
vim.opt.pumheight = 10          -- Limit popup menu height
vim.opt.pumblend = 10           -- Popup menu transparency

-- Text editing and indentation
vim.opt.tabstop = 2             -- Display width of tab character
vim.opt.shiftwidth = 2          -- Width for autoindent (0 = use tabstop value)
vim.opt.softtabstop = -1        -- Use shiftwidth value (-1)
vim.opt.expandtab = true        -- Use spaces instead of tabs
vim.opt.smarttab = true         -- Smart tab behavior
vim.opt.autoindent = true       -- Copy indent from current line
vim.opt.smartindent = true      -- Smart indenting for C-like languages
vim.opt.cindent = false         -- Don't use C indenting

-- Text formatting
vim.opt.textwidth = 0           -- No automatic text wrapping
vim.opt.wrapmargin = 0          -- No wrap margin
vim.opt.wrap = false            -- Don't wrap long lines
vim.opt.linebreak = true        -- Break at word boundaries when wrap is on
vim.opt.breakindent = true      -- Maintain indent when wrapping
vim.opt.showbreak = "↪ "        -- Show character for wrapped lines
vim.opt.formatoptions = "jcroql" -- Format options: j(remove comment leaders), c(auto-wrap comments), r(insert comment leader), o(insert comment leader), q(format with gq), l(don't break long lines)

-- Search and replace
vim.opt.ignorecase = true       -- Case insensitive search
vim.opt.smartcase = true        -- Case sensitive if uppercase chars present
vim.opt.incsearch = true        -- Show matches while typing
vim.opt.hlsearch = true         -- Highlight search results
vim.opt.wrapscan = true         -- Wrap around when searching
vim.opt.gdefault = false        -- Don't use global flag by default in substitute

-- Interface and display (moved most to ui.lua, keeping essential ones)
vim.opt.mouse = 'a'             -- Enable mouse in all modes
vim.opt.mousemodel = 'popup'    -- Right click shows popup
vim.opt.startofline = false     -- Don't move cursor to line start with some commands

-- History and undo
vim.opt.history = 10000         -- Command history size
vim.opt.undolevels = 10000      -- Maximum undo levels

-- Wild menu (command completion)
vim.opt.wildmenu = true         -- Enhanced command completion
vim.opt.wildmode = { 'longest:full', 'full' }  -- Complete longest common string, then each full match
vim.opt.wildignore = {
  '*.o', '*.obj', '*.so', '*.a', '*.lib', '*.dylib',  -- Compiled files
  '*.exe', '*.dll', '*.class',                         -- Executables
  '*.swp', '*.swo', '*~',                             -- Temp files
  '*.pyc', '*.pyo', '__pycache__',                    -- Python
  '*.zip', '*.tar.gz', '*.tar.bz2', '*.rar',          -- Archives
  'node_modules', '.npm',                             -- Node.js
  '.DS_Store', 'Thumbs.db',                           -- OS files
  '*.min.js', '*.min.css',                            -- Minified files
}
vim.opt.wildignorecase = true   -- Ignore case in file completion

-- Spelling
vim.opt.spell = false           -- Disable spell check by default
vim.opt.spelllang = { 'en', 'cjk' }  -- English and CJK languages
vim.opt.spelloptions = { 'camel' }    -- Check camelCase words

-- Session management
vim.opt.sessionoptions = { 'buffers', 'curdir', 'help', 'tabpages', 'winsize', 'terminal' }

-- External tools
vim.opt.dictionary = '/usr/share/dict/words'
vim.opt.thesaurus = '/usr/share/mythes/th_en_US_v2.dat'

-- Backspace behavior
vim.opt.backspace = { 'indent', 'eol', 'start' }

-- Number formats for increment/decrement
vim.opt.nrformats = { 'bin', 'hex', 'alpha' }  -- Support binary, hex, and alpha

-- Buffer switching behavior
vim.opt.switchbuf = { 'useopen', 'usetab' }    -- Switch to existing window/tab if available

-- Help system
vim.opt.helplang = { 'ja', 'en' }  -- Japanese first, then English
vim.opt.helpheight = 30            -- Reasonable help window height (was 1000)

-- Modeline support
vim.opt.modeline = true            -- Enable modeline support
vim.opt.modelines = 5              -- Check first/last 5 lines for modelines

-- Diff options
vim.opt.diffopt:append({
  'internal',           -- Use internal diff algorithm
  'filler',            -- Show filler lines
  'closeoff',          -- Close diff when one buffer is closed
  'hiddenoff',         -- Don't use diff mode for hidden buffers
  'algorithm:patience', -- Use patience diff algorithm
  'iwhite',            -- Ignore whitespace changes
  'vertical',          -- Start diff in vertical split
})

-- Disable some default plugins for better performance
vim.g.loaded_gzip = 0
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_matchit = 0
vim.g.loaded_matchparen = 0
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_netrw = 1           -- We use neo-tree instead
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1
vim.g.loaded_netrwFileHandlers = 1

-- Disable vim distribution example files
vim.g.no_gvimrc_example = 1
vim.g.no_vimrc_example = 1

-- Security: disable modeline execution for enhanced security
vim.opt.secure = true
