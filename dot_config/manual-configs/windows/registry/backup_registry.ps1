# Registry Full Backup Script

param(
    [string]$BackupPath = "$env:USERPROFILE\Documents\registry_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
)

Write-Host "Creating backup: $BackupPath" -ForegroundColor Green
New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null

Write-Host "Backing up entire HKEY_CURRENT_USER..." -ForegroundColor Yellow
reg export "HKEY_CURRENT_USER" "$BackupPath\HKEY_CURRENT_USER.reg" /y

# Create restoration script
$RestoreScript = @"
# Registry Restoration Script - Generated $(Get-Date)
Write-Host "Restoring HKEY_CURRENT_USER from backup..." -ForegroundColor Green
reg import "$BackupPath\HKEY_CURRENT_USER.reg" /reg:64
Write-Host "Restore completed. Restart required." -ForegroundColor Green
"@

$RestoreScript | Out-File -FilePath "$BackupPath\restore_backup.ps1" -Encoding UTF8

Write-Host "Backup completed: $BackupPath" -ForegroundColor Green