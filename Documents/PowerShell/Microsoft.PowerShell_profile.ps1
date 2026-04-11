# Reuse the Windows PowerShell profile so pwsh and Windows PowerShell stay aligned.
# Shared profile lives in WindowsPowerShell; both shells source the same file.
$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'

$sharedProfile = Join-Path $HOME 'Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1'

if (Test-Path $sharedProfile) {
    . $sharedProfile
}
