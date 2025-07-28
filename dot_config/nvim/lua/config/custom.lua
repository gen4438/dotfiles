-- User-specific customizations
-- This file is for personal settings that won't be overwritten during updates

-- The environment-specific setup has been moved to config.environment
-- You can add your personal customizations here

-- Example customizations (uncomment and modify as needed):

-- Personal preferences
-- vim.opt.relativenumber = true    -- Enable relative line numbers
-- vim.opt.wrap = true              -- Enable line wrapping
-- vim.opt.spell = true             -- Enable spell checking by default

-- Custom key mappings (that don't belong in the main keymaps file)
-- vim.keymap.set('n', '<leader>xx', ':echo "Custom mapping"<CR>', { desc = 'Custom command' })

-- Project-specific settings
-- vim.api.nvim_create_autocmd('BufRead', {
--   pattern = '*/my-project/*',
--   callback = function()
--     vim.opt_local.expandtab = false  -- Use tabs instead of spaces for this project
--   end,
-- })

-- Load any local configuration file if it exists
local local_config = vim.fn.stdpath("config") .. "/local.lua"
if vim.fn.filereadable(local_config) == 1 then
  dofile(local_config)
end
