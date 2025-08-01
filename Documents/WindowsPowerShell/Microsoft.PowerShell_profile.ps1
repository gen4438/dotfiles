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