-- Theme and colorscheme management
-- Unified theme handling with fallback support

local M = {}

-- Theme configuration
M.config = {
  -- Fallback theme for before plugins load
  fallback = "industry",

  -- Default theme (set by plugins)
  default = "catppuccin",

  -- Custom highlights that should persist across theme changes
  custom_highlights = {
    -- Search highlights with high visibility
    Search = { bg = "#e6e619", fg = "#000000" },
    CurSearch = { bg = "#e68019", fg = "#000000" },
    IncSearch = { bg = "#e68019", fg = "#000000" },
  }
}

-- Available themes (for completion and validation)
M.available_themes = {
  -- Active themes
  "catppuccin",
  "catppuccin-latte",
  "catppuccin-frappe",
  "catppuccin-macchiato",
  "catppuccin-mocha",

  -- Lazy-loaded themes
  "gruvbox",
  "tokyonight",
  "tokyonight-night",
  "tokyonight-storm",
  "tokyonight-day",
  "molokai",
  "vim-monokai-tasty",
  "nightfox",
  "nord",
  "monokai",
  "monokai-phoenix",
  "badwolf",
  "material",
  "solarized",
  "iceberg",
  "flatland",
  "railscasts",
  "jellybeans",
  "onedark",
  "codedark",

  -- Built-in themes
  "default",
  "blue",
  "darkblue",
  "delek",
  "desert",
  "elflord",
  "evening",
  "industry",
  "koehler",
  "morning",
  "murphy",
  "pablo",
  "peachpuff",
  "ron",
  "shine",
  "slate",
  "torte",
  "zellner",
}

-- Set up initial fallback theme
M.setup_fallback = function()
  vim.opt.termguicolors = true

  local ok, _ = pcall(vim.cmd.colorscheme, M.config.fallback)
  if not ok then
    vim.cmd.colorscheme("default")
    vim.opt.background = "dark"
  end
end

-- Apply custom highlights
M.apply_custom_highlights = function()
  for group, opts in pairs(M.config.custom_highlights) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

-- Set colorscheme with error handling
M.set_colorscheme = function(theme)
  if not theme or theme == "" then
    vim.notify("No theme specified", vim.log.levels.WARN)
    return false
  end

  local ok, err = pcall(vim.cmd.colorscheme, theme)
  if not ok then
    vim.notify(string.format("Failed to load theme '%s': %s", theme, err), vim.log.levels.ERROR)
    return false
  end

  -- Apply custom highlights after theme change
  vim.defer_fn(M.apply_custom_highlights, 100)

  vim.notify(string.format("Theme changed to: %s", theme))
  return true
end

-- Get current colorscheme
M.get_current_theme = function()
  return vim.g.colors_name or "unknown"
end

-- Theme switching with completion
M.switch_theme = function(theme)
  if not theme then
    -- Interactive theme selection
    vim.ui.select(M.available_themes, {
      prompt = "Select theme:",
      format_item = function(item)
        local current = M.get_current_theme()
        return item == current and item .. " (current)" or item
      end,
    }, function(choice)
      if choice then
        M.set_colorscheme(choice)
      end
    end)
  else
    M.set_colorscheme(theme)
  end
end

-- Cycle through favorite themes
M.favorite_themes = { "catppuccin", "gruvbox", "tokyonight", "nord" }
M.current_favorite_index = 1

M.cycle_favorites = function()
  M.current_favorite_index = (M.current_favorite_index % #M.favorite_themes) + 1
  local theme = M.favorite_themes[M.current_favorite_index]
  M.set_colorscheme(theme)
end

-- Toggle between light and dark variants
M.toggle_background = function()
  local current = M.get_current_theme()
  local theme_variants = {
    ["catppuccin-latte"] = "catppuccin-mocha",
    ["catppuccin-mocha"] = "catppuccin-latte",
    ["tokyonight-day"] = "tokyonight-night",
    ["tokyonight-night"] = "tokyonight-day",
    ["gruvbox"] = "gruvbox", -- Same theme, just toggle background
  }

  if theme_variants[current] then
    if current == "gruvbox" then
      -- Toggle background for gruvbox
      vim.opt.background = vim.opt.background:get() == "dark" and "light" or "dark"
    else
      M.set_colorscheme(theme_variants[current])
    end
  else
    -- Generic background toggle
    vim.opt.background = vim.opt.background:get() == "dark" and "light" or "dark"
  end
end

-- Create user commands for theme management
M.setup_commands = function()
  vim.api.nvim_create_user_command('Colors', function(opts)
    if opts.args ~= '' then
      M.set_colorscheme(opts.args)
    else
      M.switch_theme()
    end
  end, {
    nargs = '?',
    complete = function(arglead, cmdline, cursorpos)
      return vim.tbl_filter(function(theme)
        return vim.startswith(theme, arglead)
      end, M.available_themes)
    end,
    desc = 'Change colorscheme'
  })

  vim.api.nvim_create_user_command('ColorsCycle', M.cycle_favorites, {
    desc = 'Cycle through favorite themes'
  })

  vim.api.nvim_create_user_command('ColorsToggle', M.toggle_background, {
    desc = 'Toggle between light and dark themes'
  })

  vim.api.nvim_create_user_command('ColorsReset', function()
    M.set_colorscheme(M.config.default)
  end, {
    desc = 'Reset to default theme'
  })
end

-- Setup keymaps for theme management
M.setup_keymaps = function()
  vim.keymap.set('n', '<leader>tc', ':Colors<CR>', { desc = 'Choose colorscheme' })
  vim.keymap.set('n', '<leader>tn', M.cycle_favorites, { desc = 'Next favorite theme' })
  vim.keymap.set('n', '<leader>tt', M.toggle_background, { desc = 'Toggle light/dark theme' })
  vim.keymap.set('n', '<leader>tr', ':ColorsReset<CR>', { desc = 'Reset to default theme' })
end

-- Auto-apply custom highlights when colorscheme changes
M.setup_autocmds = function()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("ThemeManagement", { clear = true }),
    callback = function()
      -- Small delay to ensure theme is fully loaded
      vim.defer_fn(M.apply_custom_highlights, 50)
    end,
    desc = "Apply custom highlights after colorscheme change"
  })
end

-- Main setup function
M.setup = function()
  M.setup_fallback()
  M.setup_commands()
  M.setup_keymaps()
  M.setup_autocmds()
end

-- Function to call after plugins are loaded
M.post_plugin_setup = function()
  -- Apply custom highlights for the current theme
  M.apply_custom_highlights()
end

return M