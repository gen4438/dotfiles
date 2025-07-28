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

-- rootで保存
command('SaveAsRoot', 'w !sudo tee >/dev/null %', {})

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
