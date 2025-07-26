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

-- パーセントエンコード・デコード
command('UrlEncode', ':.!python -c \'import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read().strip()))\'', {})
command('UrlDecode', ':.!python -c \'import sys, urllib.parse; print(urllib.parse.unquote(sys.stdin.read().strip()))\'',
  {})

-- Unicodeエンコード・デコード
command('UnicodeEncode', ':.!python -c \'import sys; print(sys.stdin.read().strip().encode("unicode-escape").decode())\'',
  {})
command('UnicodeDecode',
  ':.!python -c \'import sys, codecs; print(codecs.decode(sys.stdin.read().strip(), "unicode-escape"))\'', {})

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

-- pandoc
command('PandocPPTX', function()
  vim.cmd('silent !pandoc -F mermaid-filter -s ' ..
    vim.fn.expand('%') .. ' -o ' .. vim.fn.expand('%:r') .. '.pptx --reference-doc=pandoc-template.pptx')
  vim.cmd('redraw!')
end, {})
