# install-wsl.ps1
# Run as Administrator in PowerShell
# Installs WSL2 + Ubuntu on Windows

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Fred Upgrade: WSL2 Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check for admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Please run this script as Administrator (right-click PowerShell → Run as Administrator)" -ForegroundColor Red
    exit 1
}

# Check Windows version
$build = [System.Environment]::OSVersion.Version.Build
if ($build -lt 19041) {
    Write-Host "ERROR: WSL2 requires Windows 10 version 2004 (build 19041) or later." -ForegroundColor Red
    Write-Host "Your build: $build" -ForegroundColor Red
    Write-Host "Please update Windows and try again." -ForegroundColor Yellow
    exit 1
}

Write-Host "Windows build $build detected. Good to go." -ForegroundColor Green
Write-Host ""

# Check if WSL is already installed
$wslInstalled = Get-Command wsl -ErrorAction SilentlyContinue
if ($wslInstalled) {
    $wslVersion = wsl --version 2>&1
    if ($wslVersion -match "WSL version") {
        Write-Host "WSL2 is already installed!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Checking for Ubuntu..." -ForegroundColor Yellow
        $distros = wsl --list --quiet 2>&1
        if ($distros -match "Ubuntu") {
            Write-Host "Ubuntu is already installed. Skip to Step 2." -ForegroundColor Green
            Write-Host ""
            Write-Host "Open Ubuntu from the Start menu or run: wsl" -ForegroundColor Cyan
            exit 0
        }
    }
}

Write-Host "Installing WSL2 and Ubuntu..." -ForegroundColor Yellow
Write-Host "This may take a few minutes. A reboot may be required." -ForegroundColor Yellow
Write-Host ""

# Install WSL with Ubuntu (default)
wsl --install -d Ubuntu

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  WSL2 + Ubuntu install initiated!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Reboot your computer if prompted" -ForegroundColor White
Write-Host "  2. Ubuntu will open and ask you to create a username/password" -ForegroundColor White
Write-Host "     (this is your Linux user — doesn't need to match Windows)" -ForegroundColor White
Write-Host "  3. Once inside Ubuntu, run:" -ForegroundColor White
Write-Host ""
Write-Host '     curl -fsSL https://raw.githubusercontent.com/buster-chachi/fred-upgrade/main/setup-linux.sh | bash' -ForegroundColor Yellow
Write-Host ""
