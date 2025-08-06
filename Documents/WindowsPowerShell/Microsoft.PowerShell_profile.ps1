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
