-- Neovim configuration entry point
-- Loading order is important for proper initialization

-- VSCode統合の分岐処理
if vim.g.vscode then
  -- VSCode環境でも基本設定を共通化
  require("config.base")
  require("config.environment").setup()
  require("config.options")
  require("_vscode.config.autocmds-vscode") -- VSCode専用のautocmdsを読み込む
  require("_vscode.config.keymaps-vscode") -- VSCode専用のキーマップを読み込む
  -- require("config.commands")
  -- require("config.filetypes")
  require("config.colorscheme_pre")
  require("config.lazy")
  require("config.colorscheme_post")
  require("config.custom")
  require("_vscode.config.custom-vscode").setup()  -- VSCode固有の最適化を最後に実行
  return -- VSCode環境ではここで終了
end

-- 通常のNeovim環境での設定（VSCode以外）
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
