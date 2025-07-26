-- 24bit color in TUI
vim.opt.termguicolors = true

local colorscheme_name = "industry"
-- local colorscheme_name = "vim"

local ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme_name)
if not ok then
  vim.cmd('colorscheme default')
  vim.o.background = 'dark'
end
