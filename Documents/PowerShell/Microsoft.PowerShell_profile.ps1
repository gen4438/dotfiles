# Reuse the Windows PowerShell profile so pwsh and Windows PowerShell stay aligned.
$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'

$legacyProfile = Join-Path $HOME 'Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1'

if (Test-Path $legacyProfile) {
    . $legacyProfile
}
