-- 環境に合わせた設定

-- python3 のパスを指定
if vim.fn.has('unix') == 1 then
  vim.g.python3_host_prog = vim.fn.expand('$HOME/.pyenv/versions/neovim3/bin/python')
elseif vim.fn.has('win32') == 1 then
  vim.g.python3_host_prog = vim.fn.expand('$HOME/venv_neovim/Scripts/python.exe')
end

-- nvm コマンドが利用できるか確認
local function is_nvm_available()
  local handle = io.popen("command -v nvm")
  local result = handle:read("*a")
  handle:close()
  return result and result ~= ""
end

-- nvm を使って現在利用されている Node.js のパスを取得
local function get_nvm_node_path()
  local handle = io.popen("nvm which current")
  local result = handle:read("*a")
  handle:close()
  return result:gsub("%s+", "") -- 改行や空白を削除
end

if is_nvm_available() then
  local node_path = get_nvm_node_path()
  if node_path and node_path ~= "" then
    vim.g.node_host_prog = node_path
  end
end

-- メモディレクトリの設定
if os.getenv('MEMO_DIR') == nil then
  vim.env.MEMO_DIR = vim.fn.expand('~/Documents/my-notes')
end

if vim.fn.has("gui_running") == 0 and (vim.env.SSH_CONNECTION or vim.env.WSL_DISTRO_NAME) then
  vim.opt.clipboard = "unnamedplus"

  local function paste()
    return {
      vim.fn.split(vim.fn.getreg(""), "\n"),
      vim.fn.getregtype(""),
    }
  end

  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = paste,
      ["*"] = paste,
    },
  }
end
