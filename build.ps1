# PS4 NAS Store (Brew Edition) - Automated PKG Builder
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

# 1. Paths & Environment
if (-not $env:OO_PS4_TOOLCHAIN) {
    $env:OO_PS4_TOOLCHAIN = "C:\OpenOrbis\PS4Toolchain"
}
$env:DOTNET_ROLL_FORWARD = "Major"
$pkgTool = "$($env:OO_PS4_TOOLCHAIN)\bin\windows\PkgTool.Core.exe"

$distDir = "$scriptDir\dist"
New-Item -ItemType Directory -Path $distDir -Force | Out-Null

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "   PS4 NAS Store (Brew Edition) - PKG Builder    " -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# 2. Update PARAM.SFO
Write-Host "`n[*] [1/3] Generating PARAM.SFO (Title: PS4 NAS Store)..." -ForegroundColor Yellow
$sfo = "$scriptDir\sce_sys\param.sfo"
if (Test-Path $sfo) { Remove-Item $sfo -Force }

& $pkgTool sfo_new $sfo
& $pkgTool sfo_setentry $sfo APP_TYPE --type Integer --maxsize 4 --value 1
& $pkgTool sfo_setentry $sfo APP_VER --type Utf8 --maxsize 8 --value "01.00"
& $pkgTool sfo_setentry $sfo ATTRIBUTE --type Integer --maxsize 4 --value 18
& $pkgTool sfo_setentry $sfo CATEGORY --type Utf8 --maxsize 4 --value "gde"
& $pkgTool sfo_setentry $sfo CONTENT_ID --type Utf8 --maxsize 48 --value "TX0000-BREW69420_00-BREWSTORE0000000"
& $pkgTool sfo_setentry $sfo DOWNLOAD_DATA_SIZE --type Integer --maxsize 4 --value 0
& $pkgTool sfo_setentry $sfo FORMAT --type Utf8 --maxsize 4 --value "obs"
& $pkgTool sfo_setentry $sfo PARENTAL_LEVEL --type Integer --maxsize 4 --value 1
& $pkgTool sfo_setentry $sfo SYSTEM_VER --type Integer --maxsize 4 --value 0
& $pkgTool sfo_setentry $sfo TITLE --type Utf8 --maxsize 128 --value "PS4 NAS Store"
& $pkgTool sfo_setentry $sfo TITLE_ID --type Utf8 --maxsize 12 --value "BREW69420"
& $pkgTool sfo_setentry $sfo VERSION --type Utf8 --maxsize 8 --value "01.00"

# 3. Build PKG
Write-Host "`n[*] [2/3] Building Fake PKG (fPKG)..." -ForegroundColor Yellow
Remove-Item "$distDir\*.pkg" -Force -ErrorAction SilentlyContinue

& $pkgTool pkg_build "remote_pkg_installer.gp4" $distDir
if ($LASTEXITCODE -ne 0) { throw "pkg_build failed" }

# 4. Validate PKG
Write-Host "`n[*] [3/3] Validating PKG package..." -ForegroundColor Yellow
$pkgFile = Get-ChildItem "$distDir\*.pkg" | Select-Object -First 1
if (-not $pkgFile) { throw "No PKG produced in dist" }

& $pkgTool pkg_validate $pkgFile.FullName

Write-Host "`n=================================================" -ForegroundColor Green
Write-Host "   BUILD SUCCESSFUL!                             " -ForegroundColor Green
Write-Host "   Package: $($pkgFile.Name)                     " -ForegroundColor Green
Write-Host "   Size:    $([math]::Round($pkgFile.Length / 1MB, 2)) MB ($($pkgFile.Length) bytes)" -ForegroundColor Green
Write-Host "   Path:    $($pkgFile.FullName)                 " -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
