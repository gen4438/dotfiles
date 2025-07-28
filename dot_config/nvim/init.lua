-- Neovim configuration entry point
-- Loading order is important for proper initialization

-- Basic Vim functionality and settings
require("config.base")

-- Environment-specific setup (Python, Node.js, clipboard, etc.)
require("config.environment").setup()

-- Core editor options and behavior
require("config.options")

-- UI and visual configuration
require("config.ui").setup()

-- Auto commands and event handling
require("config.autocmds")

-- Key mappings and shortcuts
require("config.keymaps")

-- Custom user commands
require("config.commands")

-- File type detection and settings
require("config.filetypes")

-- Pre-plugin theme setup (fallback colorscheme)
require("config.colorscheme_pre")

-- Plugin management and loading
require("config.lazy")

-- Post-plugin setup (theme management, custom highlights)
require("config.colorscheme_post")

-- User customizations (loaded last to allow overrides)
require("config.custom")
