local keymap = vim.api.nvim_set_keymap
local command = vim.api.nvim_create_user_command

-- mapping一覧をファイルに保存
local function maps_save()
  local input = vim.fn.input('Save to: ', vim.fn.expand('~/vim_key_mappings.txt'), 'file')
  local file = vim.fn.fnameescape(vim.fn.iconv(input, vim.o.encoding, vim.o.termencoding))
  if file ~= '' then
    vim.cmd('redir! > ' .. file .. ' | silent verbose map | redir END')
  end
end
command('DumpKeymaps', maps_save, {})

-- 文字幅変更
command('AmbiguousCharWidthDouble', 'set ambiwidth=double', {})
command('AmbiguousCharWidthSingle', 'set ambiwidth=single', {})

-- rootで保存 / Save as root
if vim.fn.has('unix') == 1 then
  command('SaveAsRoot', 'w !sudo tee >/dev/null %', {})
elseif vim.fn.has('win32') == 1 then
  -- Windows implementation using PowerShell with elevation
  vim.api.nvim_create_user_command('SaveAsRoot', function()
    local filepath = vim.fn.expand('%:p')
    if filepath == '' then
      vim.notify('No file to save', vim.log.levels.ERROR)
      return
    end
    
    -- Convert MSYS2 path to Windows path if necessary
    if filepath:match('^/[a-zA-Z]/') then
      -- Convert /c/path to C:\path format
      filepath = filepath:gsub('^/([a-zA-Z])/', '%1:\\'):gsub('/', '\\')
    end
    
    -- Function to escape PowerShell special characters
    local function ps_escape(str)
      -- Escape backticks, quotes, and dollar signs for PowerShell
      return str:gsub('`', '``'):gsub('"', '`"'):gsub('%$', '`$')
    end
    
    -- Check for critical system files
    local critical_paths = {
      'C:\\Windows\\System32\\config',
      'C:\\Windows\\System32\\drivers',
      'C:\\bootmgr',
      'C:\\pagefile.sys',
    }
    
    for _, critical in ipairs(critical_paths) do
      if filepath:lower():find(critical:lower(), 1, true) then
        local confirm = vim.fn.confirm(
          'WARNING: Modifying system critical file. Continue?',
          '&Yes\n&No', 2
        )
        if confirm ~= 1 then
          vim.notify('Operation cancelled', vim.log.levels.WARN)
          return
        end
        break
      end
    end
    
    -- Save buffer to a temporary file
    local tempfile = vim.fn.tempname()
    
    -- Main operation wrapped in pcall for proper cleanup
    local success, err = pcall(function()
      vim.cmd('write! ' .. tempfile)
      
      -- Convert temp file path if necessary
      if tempfile:match('^/[a-zA-Z]/') then
        tempfile = tempfile:gsub('^/([a-zA-Z])/', '%1:\\'):gsub('/', '\\')
      end
      
      -- Properly escape paths for PowerShell
      local escaped_tempfile = ps_escape(tempfile)
      local escaped_filepath = ps_escape(filepath)
      
      -- Create PowerShell script to copy with elevation
      local ps_script = string.format([[
        Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command "Copy-Item -Path ''%s'' -Destination ''%s'' -Force"' -Wait
      ]], escaped_tempfile, escaped_filepath)
      
      -- Save current shell settings
      local original_shell = vim.o.shell
      local original_shellcmdflag = vim.o.shellcmdflag
      local original_shellquote = vim.o.shellquote
      local original_shellxquote = vim.o.shellxquote
      
      -- Temporarily switch to PowerShell
      vim.o.shell = 'powershell'
      vim.o.shellcmdflag = '-NoProfile -ExecutionPolicy Bypass -Command'
      vim.o.shellquote = ''
      vim.o.shellxquote = ''
      
      -- Execute the PowerShell script
      local result = vim.fn.system(ps_script)
      
      -- Restore original shell settings
      vim.o.shell = original_shell
      vim.o.shellcmdflag = original_shellcmdflag
      vim.o.shellquote = original_shellquote
      vim.o.shellxquote = original_shellxquote
      
      -- Check if successful
      if vim.v.shell_error == 0 then
        vim.notify('File saved with administrator privileges', vim.log.levels.INFO)
        -- Reload the file to update the buffer
        vim.cmd('edit!')
      else
        error('Failed to save with administrator privileges: ' .. result)
      end
    end)
    
    -- Always clean up temp file
    if vim.fn.filereadable(tempfile) == 1 then
      vim.fn.delete(tempfile)
    end
    
    -- Report error if operation failed
    if not success then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end, {})
end

-- jsonを整形
command('JQ', '%!jq .', {})

-- xmlを整形
command('XML', '%!xmllint --format --recover -', {})

-- hex
command('HexEncode', '%!xxd', {})
command('HexDecode', '%!xxd -r', {})

-- URL encoding/decoding
command('UrlEncode', function()
  local python_cmd = 'python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read().strip()))"'
  local success, _ = pcall(vim.cmd, ':.!' .. python_cmd)
  if not success then
    vim.notify('URL encoding failed. Make sure python3 is installed.', vim.log.levels.ERROR)
  end
end, { desc = 'URL encode current line' })

command('UrlDecode', function()
  local python_cmd = 'python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.stdin.read().strip()))"'
  local success, _ = pcall(vim.cmd, ':.!' .. python_cmd)
  if not success then
    vim.notify('URL decoding failed. Make sure python3 is installed.', vim.log.levels.ERROR)
  end
end, { desc = 'URL decode current line' })

-- Unicode encoding/decoding
command('UnicodeEncode', function()
  local python_cmd = 'python3 -c "import sys; print(sys.stdin.read().strip().encode(\\"unicode-escape\\").decode())"'
  local success, _ = pcall(vim.cmd, ':.!' .. python_cmd)
  if not success then
    vim.notify('Unicode encoding failed. Make sure python3 is installed.', vim.log.levels.ERROR)
  end
end, { desc = 'Unicode encode current line' })

command('UnicodeDecode', function()
  local python_cmd = 'python3 -c "import sys, codecs; print(codecs.decode(sys.stdin.read().strip(), \\"unicode-escape\\"))"'
  local success, _ = pcall(vim.cmd, ':.!' .. python_cmd)
  if not success then
    vim.notify('Unicode decoding failed. Make sure python3 is installed.', vim.log.levels.ERROR)
  end
end, { desc = 'Unicode decode current line' })

-- クリップボード有効
local function clipboard_enable()
  if vim.fn.has('clipboard') == 0 then
    print("Clipboard is not supported.")
    return
  end
  if vim.fn.has('unnamedplus') == 1 then
    vim.opt.clipboard = "unnamed,unnamedplus"
  else
    vim.opt.clipboard = "unnamed"
  end
  print("Clipboard is now enabled.")
end

-- クリップボード無効
local function clipboard_disable()
  vim.opt.clipboard = ""
  print("Clipboard is now disabled.")
end

command('EnableClipboard', clipboard_enable, {})
command('DisableClipboard', clipboard_disable, {})

keymap('n', '<leader>ce', ':EnableClipboard<cr>', { noremap = true, silent = true })
keymap('n', '<leader>cd', ':DisableClipboard<cr>', { noremap = true, silent = true })

-- クリップボードのトグル
local function clipboard_toggle()
  if vim.o.clipboard:match('unnamed') then
    vim.o.clipboard = ''
  else
    if vim.fn.has('unnamedplus') == 1 then
      vim.o.clipboard = 'unnamedplus,unnamed'
    else
      vim.o.clipboard = 'unnamed'
    end
  end
end
command('ClipboardToggle', clipboard_toggle, {})

-- VSCodeで開く
command('OpenInVSCode', function()
  vim.cmd('silent !code --goto "' .. vim.fn.expand('%') .. ':' .. vim.fn.line('.') .. ':' .. vim.fn.col('.') .. '"')
  vim.cmd('redraw!')
end, {})

command('OpenCwdInVSCode', function()
  vim.cmd('silent !code "' ..
    vim.fn.getcwd() .. '" --goto "' .. vim.fn.expand('%') .. ':' .. vim.fn.line('.') .. ':' .. vim.fn.col('.') .. '"')
  vim.cmd('redraw!')
end, {})
keymap('n', '<leader>vs', ':silent OpenCwdInVSCode<CR>', { noremap = true })

-- gitlab
command('GitLabIssueCreate', '!lab issue create', {})
keymap('n', '<leader>gic', ':GitLabIssueCreate<CR>', { noremap = true })

-- Document conversion with Pandoc
command('PandocPPTX', function()
  local input_file = vim.fn.expand('%')
  local output_file = vim.fn.expand('%:r') .. '.pptx'

  if input_file == '' then
    vim.notify('No file to convert', vim.log.levels.WARN)
    return
  end

  local cmd = string.format(
    'pandoc -F mermaid-filter -s %s -o %s --reference-doc=pandoc-template.pptx',
    vim.fn.shellescape(input_file),
    vim.fn.shellescape(output_file)
  )

  vim.fn.system(cmd)

  if vim.v.shell_error == 0 then
    vim.notify('Successfully converted to ' .. output_file)
  else
    vim.notify('Pandoc conversion failed. Check that pandoc and mermaid-filter are installed.', vim.log.levels.ERROR)
  end
end, { desc = 'Convert current file to PowerPoint using Pandoc' })

-- Additional utility commands

-- Reload configuration
command('ReloadConfig', function()
  -- Clear loaded modules
  for name, _ in pairs(package.loaded) do
    if name:match('^config') then
      package.loaded[name] = nil
    end
  end

  -- Reload init.lua
  dofile(vim.env.MYVIMRC)
  vim.notify('Configuration reloaded')
end, { desc = 'Reload Neovim configuration' })

-- Show highlight group under cursor
command('ShowHighlight', function()
  local line = vim.fn.line('.')
  local col = vim.fn.col('.') - 1 -- 0-indexed for nvim_get_hl_id_at_pos
  
  local highlights = {}
  
  -- Try to get TreeSitter highlight (modern method)
  local ok, ts_hl = pcall(vim.treesitter.get_captures_at_cursor, 0)
  if ok and ts_hl and #ts_hl > 0 then
    for _, capture in ipairs(ts_hl) do
      table.insert(highlights, string.format('TreeSitter: @%s', capture))
    end
  end
  
  -- Try to get traditional syntax highlight
  local synID = vim.fn.synID(line, col + 1, 1) -- synID uses 1-indexed
  local synIDName = vim.fn.synIDattr(synID, 'name')
  
  if synIDName ~= '' then
    local synIDTrans = vim.fn.synIDtrans(synID)
    local synIDTransName = vim.fn.synIDattr(synIDTrans, 'name')
    
    local syntax_info = string.format('Syntax: %s', synIDName)
    if synIDTransName ~= synIDName then
      syntax_info = syntax_info .. string.format(' -> %s', synIDTransName)
    end
    table.insert(highlights, syntax_info)
  end
  
  -- Try to get semantic tokens (LSP)
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  for _, client in ipairs(clients) do
    if client.server_capabilities.semanticTokensProvider then
      table.insert(highlights, string.format('LSP: %s (semantic tokens available)', client.name))
      break
    end
  end
  
  if #highlights == 0 then
    vim.notify('No highlight information at cursor position')
  else
    vim.notify(table.concat(highlights, '\n'))
  end
end, { desc = 'Show highlight group under cursor' })

-- Toggle spell checking
command('ToggleSpell', function()
  vim.opt_local.spell = not vim.opt_local.spell:get()
  local status = vim.opt_local.spell:get() and 'enabled' or 'disabled'
  vim.notify('Spell checking ' .. status)
end, { desc = 'Toggle spell checking' })
