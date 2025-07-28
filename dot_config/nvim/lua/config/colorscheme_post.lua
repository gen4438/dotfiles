-- Post-plugin theme setup
-- This file applies custom highlights and theme management after plugins load

local theme = require("config.theme")

-- Setup theme management commands and keymaps
theme.setup_commands()
theme.setup_keymaps()
theme.setup_autocmds()

-- Apply custom highlights for the current theme
theme.post_plugin_setup()
