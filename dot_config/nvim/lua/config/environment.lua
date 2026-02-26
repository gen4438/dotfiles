-- Environment-specific configurations
-- This file handles platform-specific settings, external tool detection, and environment variables

local M = {}

-- Helper function to check if a command exists
local function command_exists(cmd)
  -- Use vim.fn.executable() which works cross-platform
  return vim.fn.executable(cmd) == 1
end

-- Helper function to get environment variable with fallback
local function get_env_or_default(env_var, default_value)
  return os.getenv(env_var) or default_value
end

-- Helper function to add directory to PATH if not already present
M.add_to_path = function(dir)
  if not dir or dir == '' then
    return
  end
  
  -- Ensure the directory exists
  if vim.fn.isdirectory(dir) == 0 then
    return
  end
  
  local path_sep = M.is_windows() and ';' or ':'
  local current_path = vim.env.PATH or ''
  
  -- Normalize directory separators for comparison
  local normalized_dir = dir:gsub('\\', '/')
  local paths = vim.split(current_path, path_sep)
  
  -- Check if directory is already in PATH
  for _, p in ipairs(paths) do
    if p:gsub('\\', '/'):lower() == normalized_dir:lower() then
      return -- Already in PATH
    end
  end
  
  -- Add to PATH
  vim.env.PATH = dir .. path_sep .. current_path
end

-- Python configuration
M.setup_python = function()
  if vim.fn.has('unix') == 1 then
    -- Try multiple common Python paths in order of preference
    local python_paths = {
      vim.fn.expand('$HOME/.local/share/nvim-venv/bin/python'),  -- venv (for systems without pyenv)
      vim.fn.expand('$HOME/.pyenv/versions/neovim3/bin/python'), -- pyenv
      vim.fn.expand('$HOME/.virtualenvs/neovim3/bin/python'),
      vim.fn.expand('$HOME/venv/neovim3/bin/python'),
    }
    
    for _, path in ipairs(python_paths) do
      if vim.fn.executable(path) == 1 then
        vim.g.python3_host_prog = path
        break
      end
    end
    
    -- If no specific neovim python found, let neovim find system python
    if not vim.g.python3_host_prog and command_exists('python3') then
      vim.g.python3_host_prog = vim.fn.exepath('python3')
    end
  elseif vim.fn.has('win32') == 1 then
    local win_python_paths = {
      vim.fn.expand('$HOME/venv_neovim/Scripts/python.exe'),
      vim.fn.expand('$HOME/AppData/Local/Programs/Python/Python*/python.exe'),
    }
    
    for _, path in ipairs(win_python_paths) do
      if vim.fn.executable(path) == 1 then
        vim.g.python3_host_prog = path
        break
      end
    end
  end
end

-- Node.js configuration
M.setup_nodejs = function()
  if M.is_windows() then
    -- Windows-specific Node.js detection
    -- Try nvm-windows first
    local nvm_home = vim.env.NVM_HOME
    if nvm_home then
      local nvm_symlink = nvm_home .. '\\nodejs\\node.exe'
      if vim.fn.executable(nvm_symlink) == 1 then
        vim.g.node_host_prog = nvm_symlink
        -- Also add npm global directory to PATH if using nvm
        local npm_path = nvm_home .. '\\nodejs'
        M.add_to_path(npm_path)
      end
    end
    
    -- Try fnm on Windows
    if command_exists('fnm') then
      local handle = io.popen('fnm exec --using default -- where node 2>NUL')
      if handle then
        local node_path = handle:read("*a")
        handle:close()
        if node_path and node_path:match("%S") then
          -- Take the first line if multiple paths are returned
          local first_path = node_path:match("^([^\r\n]+)")
          if first_path then
            vim.g.node_host_prog = first_path:gsub("%s+", "")
          end
        end
      end
    end
    
    -- Add npm global directory to PATH for Windows
    -- This ensures npm global packages (like tree-sitter-cli) are accessible
    local appdata = vim.env.APPDATA
    if appdata then
      local npm_global_path = appdata .. '\\npm'
      M.add_to_path(npm_global_path)
    end
  else
    -- Unix-like systems
    -- Try nvm first
    if command_exists('nvm') then
      local handle = io.popen('bash -c "source ~/.nvm/nvm.sh && nvm which current 2>/dev/null"')
      if handle then
        local node_path = handle:read("*a")
        handle:close()
        if node_path and node_path:match("%S") then
          vim.g.node_host_prog = node_path:gsub("%s+", "")
          return
        end
      end
    end
    
    -- Try fnm (Fast Node Manager)
    if command_exists('fnm') then
      local handle = io.popen('fnm exec --using default -- which node 2>/dev/null')
      if handle then
        local node_path = handle:read("*a")
        handle:close()
        if node_path and node_path:match("%S") then
          vim.g.node_host_prog = node_path:gsub("%s+", "")
          return
        end
      end
    end
  end
  
  -- Fallback to system node
  if command_exists('node') then
    vim.g.node_host_prog = vim.fn.exepath('node')
  end
end

-- Clipboard configuration for SSH/WSL environments
M.setup_clipboard = function()
  -- Only configure special clipboard for SSH or WSL environments without GUI
  if vim.fn.has("gui_running") == 1 then
    return
  end
  
  local is_ssh = vim.env.SSH_CONNECTION ~= nil
  local is_wsl = vim.env.WSL_DISTRO_NAME ~= nil
  local is_remote = is_ssh or is_wsl
  
  if is_remote then
    vim.opt.clipboard = "unnamedplus"
    
    -- Use OSC 52 sequences for clipboard in remote environments
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
end

-- Environment variables setup
M.setup_env_vars = function()
  -- Memo directory configuration
  if not vim.env.MEMO_DIR then
    local default_memo_dirs = {
      vim.fn.expand('~/Documents/my-notes'),
      vim.fn.expand('~/my-notes'),
      vim.fn.expand('~/Projects/my-notes'),
    }
    
    for _, dir in ipairs(default_memo_dirs) do
      if vim.fn.isdirectory(dir) == 1 then
        vim.env.MEMO_DIR = dir
        break
      end
    end
    
    -- If no existing directory found, use the first default
    if not vim.env.MEMO_DIR then
      vim.env.MEMO_DIR = default_memo_dirs[1]
    end
  end
  
  -- Set up other useful environment variables
  if not vim.env.EDITOR then
    vim.env.EDITOR = 'nvim'
  end
  
  if not vim.env.VISUAL then
    vim.env.VISUAL = 'nvim'
  end
end

-- Platform detection utilities
M.is_windows = function()
  return vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
end

M.is_mac = function()
  return vim.fn.has('macunix') == 1
end

M.is_linux = function()
  return vim.fn.has('unix') == 1 and not M.is_mac()
end

M.is_wsl = function()
  return vim.env.WSL_DISTRO_NAME ~= nil
end

M.is_ssh = function()
  return vim.env.SSH_CONNECTION ~= nil
end

-- Windows shell configuration
M.setup_windows_shell = function()
  if not M.is_windows() then
    return
  end
  
  -- Check for MSYS2 bash from Scoop installation path
  local scoop_msys_bash = vim.fn.expand('~/scoop/apps/msys2/current/usr/bin/bash.exe')
  local system_msys_bash = 'C:/msys64/usr/bin/bash.exe'
  
  if vim.fn.executable(scoop_msys_bash) == 1 then
    vim.opt.shell = scoop_msys_bash
    vim.opt.shellcmdflag = '-c'
    vim.opt.shellquote = ''
    vim.opt.shellxquote = ''
    -- Set SHELL environment variable for :terminal
    vim.env.SHELL = scoop_msys_bash
  elseif vim.fn.executable(system_msys_bash) == 1 then
    vim.opt.shell = system_msys_bash
    vim.opt.shellcmdflag = '-c'
    vim.opt.shellquote = ''
    vim.opt.shellxquote = ''
    -- Set SHELL environment variable for :terminal
    vim.env.SHELL = system_msys_bash
  -- Fallback to PowerShell
  elseif vim.fn.executable('pwsh') == 1 then
    vim.opt.shell = 'pwsh'
    vim.opt.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command'
    vim.opt.shellquote = ''
    vim.opt.shellxquote = ''
    vim.env.SHELL = 'pwsh'
  elseif vim.fn.executable('powershell') == 1 then
    vim.opt.shell = 'powershell'
    vim.opt.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command'
    vim.opt.shellquote = ''
    vim.opt.shellxquote = ''
    vim.env.SHELL = 'powershell'
  -- Final fallback to cmd
  else
    vim.opt.shell = 'cmd'
    vim.opt.shellcmdflag = '/c'
    vim.opt.shellquote = ''
    vim.opt.shellxquote = '"'
    vim.env.SHELL = 'cmd'
  end
end

-- Main setup function
M.setup = function()
  M.setup_python()
  M.setup_nodejs()
  M.setup_clipboard()
  M.setup_env_vars()
  M.setup_windows_shell()
end

return M