# Vacuum installer for Windows
# Usage: irm https://raw.githubusercontent.com/gastigonzalez1999/vacuum/main/install.ps1 | iex

$ErrorActionPreference = "Stop"
$Repo = "gastigonzalez1999/vacuum"

# Detect architecture
$Arch = if ($env:PROCESSOR_ARCHITECTURE -match "ARM64") { "arm64" } else { "x86_64" }
$Asset = "vacuum-windows-${Arch}.zip"
$Url = "https://github.com/${Repo}/releases/latest/download/${Asset}"

# Fallback to x86_64 if arm64 not available
if ($Arch -eq "arm64") {
    try {
        $null = Invoke-WebRequest -Uri $Url -Method Head -UseBasicParsing -ErrorAction Stop
    } catch {
        $Arch = "x86_64"
        $Asset = "vacuum-windows-x86_64.zip"
        $Url = "https://github.com/${Repo}/releases/latest/download/${Asset}"
    }
}

Write-Host "Downloading vacuum for Windows ${Arch}..."
$TempZip = "$env:TEMP\vacuum.zip"
Invoke-WebRequest -Uri $Url -OutFile $TempZip -UseBasicParsing

$TempDir = "$env:TEMP\vacuum-extract"
if (Test-Path $TempDir) { Remove-Item -Recurse -Force $TempDir }
Expand-Archive -Path $TempZip -DestinationPath $TempDir -Force
Remove-Item $TempZip

# Install to user's local bin
$InstallDir = "$env:LOCALAPPDATA\Programs\vacuum"
$BinDir = "$env:LOCALAPPDATA\bin"
if (-not (Test-Path $BinDir)) {
    $BinDir = $InstallDir
}
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null

$Exe = Get-ChildItem -Path $TempDir -Filter "vacuum*.exe" -Recurse | Select-Object -First 1
if ($Exe) {
    Copy-Item $Exe.FullName -Destination "$BinDir\vacuum.exe" -Force
} else {
    # Zip might have vacuum.exe at root
    $ExePath = Join-Path $TempDir "vacuum.exe"
    if (Test-Path $ExePath) {
        Copy-Item $ExePath -Destination "$BinDir\vacuum.exe" -Force
    } else {
        Write-Error "Could not find vacuum.exe in archive"
    }
}

Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue

Write-Host "Installed to $BinDir\vacuum.exe"

# Add to PATH if not already
$CurrentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($CurrentPath -notlike "*$BinDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$BinDir;$CurrentPath", "User")
    Write-Host ""
    Write-Host "Added $BinDir to PATH. Restart your terminal or run:"
    Write-Host "  `$env:Path = `"$BinDir;`$env:Path`""
}

Write-Host ""
Write-Host "vacuum installed successfully!"
Write-Host "Run 'vacuum --help' to get started."
