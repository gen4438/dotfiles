# PowerShell Cursor Movement Optimization Profile
# All settings are non-default values for improved performance

# UTF-8 encoding for proper emoji display
# Ensure Windows Terminal is using CaskaydiaCove Nerd Font Mono for full emoji support
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

Import-Module PSReadLine

# Non-default PSReadLine settings for cursor movement optimization
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
# Set-PSReadLineOption -CompletionQueryItems 25

# Non-default key bindings for intelligent history search
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Tab to complete commands and arguments
Set-PSReadLineKeyHandler -Key Tab -Function Complete

# Ctrl+d to exit PowerShell
Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit

# ~/.ssh/config, ~/.ssh/config.d/*.conf から ssh ホスト名を取得する関数
function Get-SshHosts {
    $configFiles = @(
        "$HOME/.ssh/config"
    ) + (Get-ChildItem -Path "$HOME/.ssh/config.d" -Filter '*.conf' -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName })

    $hosts = @()
    foreach ($file in $configFiles) {
        if (Test-Path $file) {
            $lines = Get-Content $file | Where-Object { $_ -match '^\s*Host\s+' }
            foreach ($line in $lines) {
                $names = $line -replace '^\s*Host\s+', '' -split '\s+'
                foreach ($name in $names) {
                    if ($name -notmatch '[*?]') {  # ワイルドカードは除外
                        $hosts += $name
                    }
                }
            }
        }
    }
    $hosts | Sort-Object -Unique
}

Register-ArgumentCompleter -CommandName ssh -ParameterName 'ArgumentList' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    Get-SshHosts | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# Set up aliases for common commands
Set-Alias vi nvim
Set-Alias vim nvim

# 無変換キーが@として入力される問題への対処
# WindowsのIME設定でキーバインドをカスタマイズすることで解決可能
# PowerShellでキー入力をデバッグする関数
function Test-KeyInput {
    Write-Host "Press any key to see its details (Ctrl+C to exit):" -ForegroundColor Yellow
    while ($true) {
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Write-Host "KeyChar: '$($key.Character)' VirtualKeyCode: $($key.VirtualKeyCode) ControlKeyState: $($key.ControlKeyState)" -ForegroundColor Cyan
    }
}
