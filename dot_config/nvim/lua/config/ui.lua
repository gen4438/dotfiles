-- UI and visual configuration
-- This file handles all UI-related settings including colors, fonts, and visual elements

local M = {}

-- Font configuration for GUI
M.font = {
  family = "CaskaydiaCove Nerd Font",
  default_size = 14,
  current_size = 14,
}

-- Initialize font settings
M.setup_font = function()
  if vim.fn.has("gui_running") == 1 then
    vim.opt.guifont = string.format("%s:h%d", M.font.family, M.font.default_size)
    M.font.current_size = M.font.default_size
  end
end

-- Font size manipulation functions
M.change_font_size = function(delta)
  if vim.fn.has("gui_running") == 1 then
    M.font.current_size = math.max(6, M.font.current_size + delta)
    vim.opt.guifont = string.format("%s:h%d", M.font.family, M.font.current_size)
  end
end

M.reset_font_size = function()
  if vim.fn.has("gui_running") == 1 then
    M.font.current_size = M.font.default_size
    vim.opt.guifont = string.format("%s:h%d", M.font.family, M.font.default_size)
  end
end

-- Color and theme configuration
M.setup_colors = function()
  -- Enable 24-bit colors in terminal
  vim.opt.termguicolors = true
  
  -- Set up a fallback colorscheme before plugins load
  local fallback_colorscheme = "industry"
  local ok, _ = pcall(vim.cmd.colorscheme, fallback_colorscheme)
  if not ok then
    vim.cmd.colorscheme("default")
    vim.opt.background = "dark"
  end
end

-- Custom highlight groups that should be applied after colorscheme loads
M.setup_highlights = function()
  -- Define custom search highlights with better visibility
  local highlights = {
    -- Search highlights
    Search = { bg = "#e6e619", fg = "#000000" },
    CurSearch = { bg = "#e68019", fg = "#000000" },
    IncSearch = { bg = "#e68019", fg = "#000000" },
    
    -- Better diff colors (optional, can be removed if theme handles it well)
    -- DiffAdd = { bg = "#003300", fg = "#ffffff" },
    -- DiffChange = { bg = "#000033", fg = "#ffffff" },
    -- DiffDelete = { bg = "#330000", fg = "#ffffff" },
    -- DiffText = { bg = "#003333", fg = "#ffffff" },
  }
  
  for group, opts in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

-- Status line and UI element configuration
M.setup_ui_elements = function()
  -- Show line numbers
  vim.opt.number = true
  vim.opt.relativenumber = false -- Can be toggled with plugins
  
  -- Sign column settings
  vim.opt.signcolumn = "yes"
  
  -- Command line settings
  vim.opt.cmdheight = 2
  vim.opt.showcmd = true
  
  -- Status line settings
  vim.opt.laststatus = 2
  vim.opt.ruler = true
  
  -- Tab line settings
  vim.opt.showtabline = 2
  
  -- Window splitting behavior
  vim.opt.splitbelow = true
  vim.opt.splitright = true
  
  -- Scrolling behavior
  vim.opt.scrolloff = 5
  vim.opt.sidescrolloff = 8
  
  -- List characters for whitespace visibility
  vim.opt.listchars = {
    tab = "»-",
    extends = "»",
    precedes = "«",
    nbsp = "%",
    trail = "·",
  }
  
  -- Cursor settings
  vim.opt.cursorline = false -- Can be enabled per user preference
  vim.opt.cursorcolumn = false
  
  -- Visual selection settings
  vim.opt.virtualedit = "block"
  
  -- Matching parentheses
  vim.opt.showmatch = true
  vim.opt.matchtime = 3
  vim.opt.matchpairs:append({ "「:」", "『:』", "（:）", "【:】", "《:》", "〈:〉", "［:］", "':'", "\":\"" })
  
  -- Folding settings
  vim.opt.foldmethod = "indent"
  vim.opt.foldlevel = 99
  vim.opt.foldcolumn = "0"
  
  -- Disable bells
  vim.opt.belloff = "all"
  
  -- Better completion menu
  vim.opt.pumheight = 10 -- Limit popup menu height
  vim.opt.pumblend = 10  -- Slight transparency for popup menu
  
  -- Window title
  vim.opt.title = true
  vim.opt.titlestring = "%F"
  vim.opt.titleold = "Terminal"
end

-- Setup GUI-specific keymaps
M.setup_gui_keymaps = function()
  if vim.fn.has("gui_running") == 1 then
    -- Font size control
    vim.keymap.set('n', '<C-S-->', function() M.change_font_size(1) end, { desc = "Increase font size" })
    vim.keymap.set('n', '<C-->', function() M.change_font_size(-1) end, { desc = "Decrease font size" })
    vim.keymap.set('n', '<C-0>', M.reset_font_size, { desc = "Reset font size" })
    
    -- Alternative font size controls for different keyboards
    vim.keymap.set('n', '<C-ScrollWheelUp>', function() M.change_font_size(1) end, { desc = "Increase font size" })
    vim.keymap.set('n', '<C-ScrollWheelDown>', function() M.change_font_size(-1) end, { desc = "Decrease font size" })
  end
end

-- Toggle functions for UI elements
M.toggle_relative_numbers = function()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end

M.toggle_list_chars = function()
  vim.opt.list = not vim.opt.list:get()
end

M.toggle_cursor_line = function()
  vim.opt.cursorline = not vim.opt.cursorline:get()
end

M.toggle_wrap = function()
  vim.opt.wrap = not vim.opt.wrap:get()
end

-- Setup toggle keymaps
M.setup_toggle_keymaps = function()
  vim.keymap.set('n', '<leader>tn', M.toggle_relative_numbers, { desc = "Toggle relative numbers" })
  vim.keymap.set('n', '<leader>tl', M.toggle_list_chars, { desc = "Toggle list characters" })
  vim.keymap.set('n', '<leader>tc', M.toggle_cursor_line, { desc = "Toggle cursor line" })
  vim.keymap.set('n', '<leader>tw', M.toggle_wrap, { desc = "Toggle line wrap" })
  
  -- Alternative wrap toggle (keeping existing binding)
  vim.keymap.set('n', '<Space>w', ':setlocal wrap!<CR>', { desc = "Toggle wrap" })
end

-- Main setup function
M.setup = function()
  M.setup_colors()
  M.setup_font()
  M.setup_ui_elements()
  M.setup_gui_keymaps()
  M.setup_toggle_keymaps()
  
  -- Load local UI configuration if it exists
  -- This allows overriding font settings and other UI preferences
  local local_ui_config = vim.fn.stdpath("config") .. "ui.local.lua"
  if vim.fn.filereadable(local_ui_config) == 1 then
    dofile(local_ui_config)
  end
end

-- Function to apply highlights after colorscheme changes
M.apply_highlights = function()
  M.setup_highlights()
end

return M