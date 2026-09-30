# PowerShell Cursor Movement Optimization Profile
# All settings are non-default values for improved performance

# WSL2 経由の起動時に WindowsPowerShell\Modules が PSModulePath に含まれない問題を修正
$_wpsMods = Join-Path $HOME 'Documents\WindowsPowerShell\Modules'
if ((Test-Path $_wpsMods) -and ($env:PSModulePath -notlike "*$_wpsMods*")) {
    $env:PSModulePath = $_wpsMods + ';' + $env:PSModulePath
}
Remove-Variable _wpsMods

# WSL2 経由の起動時に Git\bin が PATH に含まれない問題を修正 (bash.exe 等が必要)
# system32\bash.exe (WSL bash) より前に git-bash を配置する
foreach ($_gitBin in @(
    (Join-Path $HOME 'scoop\apps\git\current\bin'),
    'C:\Program Files\Git\bin'
)) {
    if ((Test-Path $_gitBin) -and ($env:PATH -notlike "*$_gitBin*")) {
        $env:PATH = $_gitBin + ';' + $env:PATH
        break
    }
}
Remove-Variable _gitBin -ErrorAction SilentlyContinue

# UTF-8 encoding settings for Japanese environment
# Fixes mojibake when interacting with external commands (git, ripgrep, etc.)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

Import-Module PSReadLine

# 外部ツールの init スクリプトをキャッシュして起動を高速化
# 実行ファイル (scoop shim の場合は実体) のパス/更新日時/サイズが変わったら再生成する
function Get-CachedInitScript {
    param([string]$Name, [scriptblock]$Generator)
    $cmd = Get-Command $Name -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $cmd) { return $null }
    $exe = $cmd.Source
    $shim = [System.IO.Path]::ChangeExtension($exe, '.shim')
    if ((Test-Path $shim) -and ((Get-Content $shim -Raw) -match 'path\s*=\s*"?([^"\r\n]+)')) {
        $exe = $Matches[1].Trim()
    }
    $item = Get-Item $exe -ErrorAction SilentlyContinue
    if (-not $item) { $item = Get-Item $cmd.Source }
    $key = "# cache-key: $($item.FullName)|$($item.LastWriteTimeUtc.Ticks)|$($item.Length)"
    $cacheDir = Join-Path $env:LOCALAPPDATA 'pwsh-init-cache'
    $cache = Join-Path $cacheDir "$Name.ps1"
    if (-not (Test-Path $cache) -or (Get-Content $cache -TotalCount 1) -ne $key) {
        New-Item -ItemType Directory -Force $cacheDir | Out-Null
        $script = & $Generator | Out-String
        if (-not $script) { return $null }
        Set-Content -Path $cache -Value ($key + "`n" + $script) -Encoding UTF8
    }
    return $cache
}

# Non-default PSReadLine settings for cursor movement optimization
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -HistorySearchCursorMovesToEnd

# Vi mode indicator in prompt
$ESC = [char]0x1b
Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler {
    param([string]$Mode)
    $e = [char]0x1b
    if ($Mode -eq 'Command') {
        # Save cursor, move to column 1, overwrite mode indicator, restore cursor
        Write-Host -NoNewline "$e[s$e[1 q$e[0G$e[32m[N]$e[0m$e[u"
    } else {
        Write-Host -NoNewline "$e[s$e[5 q$e[0G$e[36m[I]$e[0m$e[u"
    }
}
function prompt {
    $exitCode = $LASTEXITCODE
    $e = [char]0x1b
    $path = $executionContext.SessionState.Path.CurrentLocation.Path

    # psmux/tmux の pane_current_path 追跡用
    if ($env:TMUX) {
        # OS レベル CWD を同期 (PowerShell の Set-Location は更新しないため)
        # psmux は NtQueryInformationProcess で CWD を読むのでこれが必要
        [System.IO.Directory]::SetCurrentDirectory($path)

        if ($env:WSL_DISTRO_NAME) {
            # WSL2 tmux (byobu): OSC 7 で CWD を通知
            $oscPath = $path -replace '^([A-Za-z]):\\', '/mnt/$1/' -replace '\\', '/'
            $oscPath = $oscPath -creplace '/mnt/([A-Z])/', { '/mnt/' + $_.Groups[1].Value.ToLower() + '/' }
            Write-Host -NoNewline "$e]7;file://localhost$oscPath$e\\"
        }
    }

    $path = $path -replace "^$([regex]::Escape($HOME))", '~'
    $branch = git rev-parse --abbrev-ref HEAD 2>$null

    # Start with [I] (Insert mode) - ViModeChangeHandler overwrites this in-place
    $promptText = "$e[36m[I]$e[0m "
    $promptText += "$e[33m$path$e[0m"
    if ($branch) {
        $promptText += " $e[35m($branch)$e[0m"
    }
    $promptText += " > "
    $LASTEXITCODE = $exitCode
    return $promptText
}
# Set-PSReadLineOption -CompletionQueryItems 25

# Non-default key bindings for intelligent history search
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Tab to complete commands and arguments
Set-PSReadLineKeyHandler -Key Tab -Function Complete

# Ctrl+d to exit PowerShell
Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit

# Ctrl+r: atuin でコマンド履歴を検索 (フォールバック: fzf)
$_atuinInit = Get-CachedInitScript atuin { atuin init powershell --disable-up-arrow }
if ($_atuinInit) {
    # atuin init 内の `atuin uuid` プロセス起動 (~150ms) を省略するため事前にセッション ID を設定
    if (-not $env:ATUIN_SESSION -or $env:ATUIN_PID -ne $PID) {
        $env:ATUIN_SESSION = [guid]::NewGuid().ToString('N')
        $env:ATUIN_PID = $PID
    }
    . $_atuinInit
} elseif (Get-Command fzf -ErrorAction SilentlyContinue) {
    Set-PSReadLineKeyHandler -Key Ctrl+r -ScriptBlock {
        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

        $selected = [Microsoft.PowerShell.PSConsoleReadLine]::GetHistoryItems() |
            ForEach-Object { $_.CommandLine } |
            Where-Object { $_ -ne '' } |
            ForEach-Object -Begin { $seen = [System.Collections.Generic.HashSet[string]]::new() } -Process {
                if ($seen.Add($_)) { $_ }
            } |
            fzf --tac --no-sort --height 40% --reverse --query $line
        if ($selected) {
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selected)
        }
    }
}

# Ctrl+f: Everything + fzf でファイル検索し、選択結果をコマンドラインに挿入
if ((Get-Command es -ErrorAction SilentlyContinue) -and (Get-Command fzf -ErrorAction SilentlyContinue)) {
    Set-PSReadLineKeyHandler -Key Ctrl+f -ScriptBlock {
        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

        $selected = fzf --bind "change:reload:es -regex {q}" --phony --preview "type {}"
        if ($selected) {
            # スペースを含むパスはクォート
            if ($selected -match '\s') { $selected = "`"$selected`"" }
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selected)
        }
    }
}

# ~/.ssh/config, ~/.ssh/config.d/*.conf から ssh ホスト名を取得する関数
Register-ArgumentCompleter -CommandName ssh, scp, sftp -Native -ScriptBlock {
  param($wordToComplete, $commandAst, $cursorPosition)

  # ~/.ssh/config と ~/.ssh/config.d/*.conf からホスト名を取得
  $sshConfig = (Get-Content ~\.ssh\config, ~\.ssh\config.d\*.conf -ErrorAction SilentlyContinue).Trim() -replace '\s+', ' ' |
    Where-Object { $_ -ne "" }

  # Hostのグルーピング
  $sshConfigHostGroups = $sshConfig | Select-String -Pattern '^\s*Host\s+' -Context 0, $sshConfig.Count | 
    Select-Object Line, @{
        Name = 'DisplayPostContext'
        Expression = { $_.Context.DisplayPostContext }
    }

  # 入力補完格納用配列
  $autoCompleteList = New-Object System.Collections.ArrayList

  # toolTip用にHost項目に紐づくHostName,Userを取得
  foreach ($sshConfigHost in $sshConfigHostGroups) {
    # User 取得
    $user = $sshConfigHost.DisplayPostContext |
      Select-String -Pattern '^\s*User\s+' |
      Select-Object -First 1 |
      ForEach-Object { $_ -split '\s+' | Select-Object -Skip 1 -First 1 }

    # HostName 取得
    $hostName = $sshConfigHost.DisplayPostContext |
      Select-String -Pattern '^\s*HostName\s+' |
      Select-Object -First 1 |
      ForEach-Object { $_ -split '\s+' | Select-Object -Skip 1 -First 1 }

    # Host単位で入力補完を作成
    $sshConfigHost.line -split '\s+' | Select-Object -Skip 1 | ForEach-Object {
    $autoCompleteList += [pscustomobject]@{
        Host = $_
        toolTip = "$user@$hostName"
        }
    }
  }

  # [System.Management.Automation.CompletionResult]を生成
  $autoCompleteList | Where-Object { $_.Host -like "$wordToComplete*" } | ForEach-Object {
    $resultType = [System.Management.Automation.CompletionResultType]::ParameterValue
    # CompletionResult Class
    # completeText, listItemText, resultType, toolTip
    [System.Management.Automation.CompletionResult]::new($_.Host, $_.Host, $resultType, $_.toolTip)
  }
}

# Set up aliases for common commands
$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'

# 重い初期化はプロンプト表示後のアイドル時に 1 回だけ実行 (起動を高速化)
# - GITHUB_TOKEN: gh CLI の認証トークンを環境変数に設定
# - posh-git: git のタブ補完
$null = Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
    if (-not $env:GITHUB_TOKEN -and (Get-Command gh -ErrorAction SilentlyContinue)) {
        $env:GITHUB_TOKEN = (gh auth token -h github.com 2>$null)
    }
    Import-Module posh-git -Global -ErrorAction SilentlyContinue
}

Set-Alias vi nvim
Set-Alias vim nvim

# Navigation shortcuts
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }
function ..... { Set-Location ..\..\..\.. }
function cdgit { Set-Location (git rev-parse --show-toplevel) }
function mkcd { param([string]$Path) New-Item -ItemType Directory -Force $Path | Out-Null; Set-Location $Path }

# Git shortcuts
function g { git @args }
function gs { git status @args }
function ga { git add @args }
function gc { git commit @args }
function gp { git push @args }
function gd { git diff @args }
function gb { git branch @args }
function gco { git checkout @args }
function gl { git log @args }

# Directory listing
function ll { Get-ChildItem -Force @args }
function la { Get-ChildItem -Force -Name @args }

# Claude / Copilot
function claude-yolo { claude --allow-dangerously-skip-permissions @args }
function copilot-yolo { copilot --yolo @args }

# 無変換キーが@として入力される問題への対処
# WindowsのIME設定でキーバインドをカスタマイズすることで解決可能
# PowerShellでキー入力をデバッグする関数
# zoxide (smarter cd command)
$_zoxideInit = Get-CachedInitScript zoxide { zoxide init powershell }
if ($_zoxideInit) {
    . $_zoxideInit

    # z <tab> で fzf によるインタラクティブ選択
    if (Get-Command fzf -ErrorAction SilentlyContinue) {
        Register-ArgumentCompleter -CommandName z -Native -ScriptBlock {
            param($wordToComplete, $commandAst, $cursorPosition)
            $result = zoxide query -l 2>$null | fzf --height 40% --reverse --query $wordToComplete
            if ($result) {
                [System.Management.Automation.CompletionResult]::new($result, $result, 'ParameterValue', $result)
            }
        }
    }
}
Remove-Variable _atuinInit, _zoxideInit -ErrorAction SilentlyContinue

function Test-KeyInput {
    Write-Host "Press any key to see its details (Ctrl+C to exit):" -ForegroundColor Yellow
    while ($true) {
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Write-Host "KeyChar: '$($key.Character)' VirtualKeyCode: $($key.VirtualKeyCode) ControlKeyState: $($key.ControlKeyState)" -ForegroundColor Cyan
    }
}
