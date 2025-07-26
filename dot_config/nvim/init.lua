require("config.base")
require("config.custom")
require("config.autocmds")
require("config.options")
require("config.keymaps")
require("config.commands")
require("config.filetypes")
require("config.colorscheme_pre")

-- gui
if vim.fn.has("gui_running") == 1 then
  require("config.gui")
end

require("config.lazy")

-- カラーの上書き
require("config.colorscheme_post")
