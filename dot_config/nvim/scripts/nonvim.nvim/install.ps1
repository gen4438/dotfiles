$repos = @(
  "junegunn/fzf",
  "BurntSushi/ripgrep",
  "sharkdp/fd",
  "sharkdp/bat"
)

$installPath = "C:\bin"
# $installPath = "$HOME\bin"
$originalPath = Get-Location
$binary_error = ""

# リポジトリごとのバイナリ名のマッピング
$binaryNames = @{
  "junegunn/fzf"       = "fzf.exe";
  "BurntSushi/ripgrep" = "rg.exe";
  "sharkdp/fd"         = "fd.exe";
  "sharkdp/bat"        = "bat.exe";
  # 他のリポジトリも必要に応じて追加
}
Write-Host "binaryNames: $binaryNames"

function Get-PEHeader {
  param (
    [string]$binaryPath
  )
  $stream = [System.IO.File]::OpenRead($binaryPath)
  $reader = New-Object System.IO.BinaryReader($stream)
  $stream.Seek(0x3C, [System.IO.SeekOrigin]::Begin) | Out-Null
  $peHeaderOffset = $reader.ReadInt32()
  $stream.Seek($peHeaderOffset + 4, [System.IO.SeekOrigin]::Begin) | Out-Null
  $machineType = $reader.ReadUInt16()
  $stream.Close()
    
  switch ($machineType) {
    0x014c { return 'i686' }
    0x8664 { return 'x86_64' }
    default { return 'unknown' }
  }
}

function check_binary {
  param (
    [string]$binaryPath,
    [string]$expectedVersion,
    [string]$expectedArchitecture
  )
  Write-Host "  - Checking $binaryPath executable ... " -NoNewline
  $output = & $binaryPath --version 2>&1
  if (-not $?) {
    Write-Host "Error: $output"
    $binary_error = "Invalid binary"
  }
  else {
    $actualVersion = ($output -split ' ')[1]
    $actualArchitecture = Get-PEHeader -binaryPath $binaryPath
        
    if ($expectedVersion -ne $actualVersion) {
      Write-Host "$actualVersion != $expectedVersion"
      $binary_error = "Invalid version"
    }
    if ($expectedArchitecture -ne $actualArchitecture) {
      Write-Host "$actualArchitecture != $expectedArchitecture"
      $binary_error = "Invalid architecture"
    }
    else {
      Write-Host "$actualVersion ($actualArchitecture)"
      $binary_error = ""
      return 1
    }
  }
  # Write-Host "Removing $binaryPath"
  # Remove-Item $binaryPath
  return 0
}

function download {
  param (
    [string]$file,
    [string]$binaryPath,
    [string]$url,
    [string]$binaryName,
    [string]$expectedVersion,
    [string]$arch
  )
  Write-Host "Downloading $binaryPath ..."

  # debug で変数の中身を確認
  Write-Host "  - file: $file"
  Write-Host "  - binaryPath: $binaryPath"
  Write-Host "  - url: $url"
  Write-Host "  - binaryName: $binaryName"
  Write-Host "  - Architecture: $arch"

  if (Test-Path $binaryPath) {
    Write-Host "  - Already exists"
    if (check_binary -binaryPath $binaryPath -expectedVersion $expectedVersion -expectedArchitecture $arch) {
      return
    }
  }
  if (-not (Test-Path $installPath)) {
    md $installPath
  }
  if (-not $?) {
    $binary_error = "Failed to create bin directory"
    Write-Host $binary_error
    return
  }
  cd $installPath
  $temp = "$env:TMP\$file"
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  if ($PSVersionTable.PSVersion.Major -ge 3) {
    Invoke-WebRequest -Uri $url -OutFile $temp
  }
  else {
    (New-Object Net.WebClient).DownloadFile($url, $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("$temp"))
  }
  if ($?) {
    Write-Host "Extracting $temp to $installPath"
    (Microsoft.PowerShell.Archive\Expand-Archive -Path $temp -DestinationPath $installPath -Force); (Remove-Item $temp)
  }
  else {
    $binary_error = "Failed to download with powershell"
    Write-Host $binary_error
    return
  }
  $extractedPath = "$installPath\$($file -replace '.zip$', '')"
  Write-Host "Searching for $binaryName in $extractedPath"
  $extractedBinary = Get-ChildItem -Path $extractedPath -Recurse -Filter $binaryName | Select-Object -First 1
  if ($extractedBinary -eq $null) {
    $binary_error = "Executable not found in $extractedPath"
    Write-Host $binary_error
    return
  }
  Write-Host "Moving $extractedBinary to $installPath\$binaryName"
  Move-Item -Path $extractedBinary.FullName -Destination "$installPath\$binaryName" -Force
  Remove-Item -Recurse -Force $extractedPath
  echo y | icacls "$installPath\$binaryName" /grant Administrator:F ; check_binary -binaryPath "$installPath\$binaryName" -expectedVersion $expectedVersion -expectedArchitecture $arch >$null
}

function add_to_path {
  param (
    [string]$path
  )
  if (-not ($env:PATH -split ';' | Where-Object { $_ -eq $path })) {
    Write-Host "Adding $path to PATH"
    [System.Environment]::SetEnvironmentVariable('PATH', "$env:PATH;$path", [System.EnvironmentVariableTarget]::User)
    $profilePath = "$HOME\Documents\WindowsPowerShell\profile.ps1"
    if (-not (Test-Path $profilePath)) {
      New-Item -ItemType File -Path $profilePath -Force
    }
    Add-Content -Path $profilePath -Value "`$env:PATH += `";$path`""
  }
  else {
    Write-Host "$path is already in PATH"
  }
}

Write-Host "Repositories to process: $($repos -join ', ')"

foreach ($repo in $repos) {
  Write-Host ""
  Write-Host "Processing repository: $repo"
  $repoParts = $repo.Split('/')
  $owner = $repoParts[0]
  $repoName = $repoParts[1]
  $url = "https://api.github.com/repos/$owner/$repoName/releases/latest"
  $arch = if ([System.Environment]::Is64BitOperatingSystem) { 'x86_64|amd64' } else { 'i686' }

  Write-Host "Fetching latest release info for $repoName from $url"
  try {
    $response = Invoke-RestMethod -Uri $url -Headers @{ "User-Agent" = "PowerShell" }
  }
  catch {
    Write-Host "Error fetching release info: $_"
    continue
  }
  if ($response -eq $null) {
    Write-Host "Error: No response from $url"
    continue
  }
  $version = $response.tag_name.TrimStart('v')
  Write-Host "Latest version: $version"

  # Find the correct asset URL for Windows
  $asset = $response.assets | Where-Object { 
    $_.name -match 'windows|win' -and 
    $_.name -match '\.zip$' -and 
    $_.name -notmatch 'darwin' -and 
    ($_.name -match $arch)
  } | Select-Object -First 1

  if ($asset -ne $null) {
    $file = $asset.name
    $downloadUrl = $asset.browser_download_url
    Write-Host "Downloading from $downloadUrl"
        
    # バイナリ名をマッピングから取得
    $binaryName = ""
    $binaryName = $binaryNames["$owner/$repoName"]
    Write-Host "$binaryNames"
    Write-Host "$owner/$repoName"
    Write-Host "$binaryName"

    if (-not $binaryName) {
      $binaryName = "$repoName.exe"
    }
    $binaryPath = "$installPath\$binaryName"

    Write-Host "binaryName: $binaryName"
    Write-Host "binaryPath: $binaryPath"
    Write-Host "version: $version"
    download -file $file -binaryPath $binaryPath -url $downloadUrl -binaryName $binaryName -expectedVersion $version -arch $arch
  }
  else {
    Write-Host "Error: Could not find the Windows asset for $repoName"
  }
}

# Add $installPath to PATH if not already present
add_to_path -path $installPath

# Return to the original directory
Set-Location $originalPath

Write-Host "For more information, see: https://github.com"
