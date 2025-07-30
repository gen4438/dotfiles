-- Windows用 Neovim 設定リダイレクト
-- ~/.config/nvim/init.lua の内容を読み込むためのリダイレクトファイル

local config_path = vim.fn.expand("~/.config/nvim")

-- ~/.config/nvim ディレクトリが存在するかチェック
if vim.fn.isdirectory(config_path) == 1 then
    -- runtimepathに ~/.config/nvim を追加
    vim.opt.runtimepath:prepend(config_path)
    
    -- Luaのpackage.pathに ~/.config/nvim/lua を追加
    local lua_path = config_path .. "/lua"
    if vim.fn.isdirectory(lua_path) == 1 then
        package.path = lua_path .. "/?.lua;" .. lua_path .. "/?/init.lua;" .. package.path
    end
    
    -- ~/.config/nvim/init.lua を実行
    local init_file = config_path .. "/init.lua"
    if vim.fn.filereadable(init_file) == 1 then
        dofile(init_file)
    else
        vim.notify("init.lua not found at " .. init_file, vim.log.levels.ERROR)
    end
else
    vim.notify("Neovim config directory not found at " .. config_path, vim.log.levels.ERROR)
    vim.notify("Please ensure ~/.config/nvim is properly set up", vim.log.levels.WARN)
end