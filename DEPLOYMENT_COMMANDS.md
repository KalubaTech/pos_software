# 🚀 Microsoft Store Deployment - Command Reference

Quick reference for all commands needed to deploy Dynamos POS to Microsoft Store.

---

## 📦 Installation

### Install MSIX Package
```bash
flutter pub add msix
flutter pub get
```

---

## 🏗️ Building

### Clean Build Environment
```bash
flutter clean
flutter pub get
```

### Build Windows Release
```bash
flutter build windows --release
```

### Create MSIX Package (Local Testing)
```bash
dart run msix:create
```

### Create MSIX Package (Microsoft Store)
```bash
dart run msix:create --store
```

### Create MSIX with Custom Version
```bash
dart run msix:create --store --version 1.0.1.0
```

### Create MSIX with All Options
```bash
dart run msix:create ^
  --store ^
  --display-name "Dynamos POS" ^
  --publisher-display-name "Kaluba Technologies" ^
  --version 1.0.0.0 ^
  --architecture x64
```

---

## 🧪 Local Testing

### Install MSIX Package Locally
```powershell
# Method 1: Double-click the .msix file
# Location: build\windows\x64\runner\Release\pos_software.msix

# Method 2: PowerShell command
Add-AppxPackage -Path "build\windows\x64\runner\Release\pos_software.msix"
```

### Enable Developer Mode (First Time Only)
```
Settings → Update & Security → For developers → Developer Mode → ON
```

### View Installed Package Info
```powershell
Get-AppxPackage *dynamospos*
```

### Uninstall Test Package
```powershell
Get-AppxPackage *dynamospos* | Remove-AppxPackage
```

### View All Installed MSIX Packages
```powershell
Get-AppxPackage | Select-Object Name, Version
```

---

## 🔍 Validation & Debugging

### Run Windows App Certification Kit
```bash
# Download and install WACK first from:
# https://developer.microsoft.com/en-us/windows/downloads/app-certification-kit/

# Then run:
"C:\Program Files (x86)\Windows Kits\10\App Certification Kit\appcert.exe" "build\windows\x64\runner\Release\pos_software.msix"
```

### View Package Details
```powershell
Get-AppxPackageManifest -Package "build\windows\x64\runner\Release\pos_software.msix"
```

### Check App Logs
```powershell
# View Windows Event Viewer logs
eventvwr.msc

# Or use PowerShell
Get-EventLog -LogName Application -Source "pos_software" -Newest 50
```

---

## 🔄 Version Management

### Update Version in pubspec.yaml
```yaml
# App version (Flutter)
version: 1.0.1+2  # Increment build number

# MSIX version (Windows)
msix_config:
  msix_version: 1.0.1.0  # Must be higher than previous
```

### Automatic Version Increment (PowerShell Script)
```powershell
# Save as increment_version.ps1
$pubspec = Get-Content "pubspec.yaml"
$pubspec = $pubspec -replace "msix_version: (\d+)\.(\d+)\.(\d+)\.(\d+)", {
    $major = $matches[1]
    $minor = $matches[2]
    $build = [int]$matches[3] + 1
    $revision = $matches[4]
    "msix_version: $major.$minor.$build.$revision"
}
$pubspec | Set-Content "pubspec.yaml"
Write-Host "Version incremented successfully"
```

---

## 🎨 Icon Generation

### Using ImageMagick (if installed)
```bash
# Install ImageMagick first: https://imagemagick.org/

# Create all required sizes from source icon
magick convert app_icon.png -resize 44x44 app_icon_44x44.png
magick convert app_icon.png -resize 50x50 app_icon_50x50.png
magick convert app_icon.png -resize 71x71 app_icon_71x71.png
magick convert app_icon.png -resize 150x150 app_icon_150x150.png
magick convert app_icon.png -resize 310x150 app_icon_310x150.png
magick convert app_icon.png -resize 310x310 app_icon_310x310.png
```

### Online Icon Generators
- https://appicon.co/
- https://easyappicon.com/
- https://www.img2go.com/resize-image

---

## 📊 Information Gathering

### Get App Package Information
```powershell
# View current MSIX package details
$package = Get-AppxPackage -Path "build\windows\x64\runner\Release\pos_software.msix"
$package | Format-List Name, Version, Architecture, Publisher
```

### Check Package Size
```powershell
$size = (Get-Item "build\windows\x64\runner\Release\pos_software.msix").Length / 1MB
Write-Host "Package size: $($size.ToString('0.00')) MB"
```

### List Package Capabilities
```powershell
$manifest = Get-AppxPackageManifest -Path "build\windows\x64\runner\Release\pos_software.msix"
$manifest.Package.Capabilities
```

---

## 🗂️ File Management

### Clean Build Artifacts
```bash
# Remove build folder
flutter clean

# Remove specific folders (PowerShell)
Remove-Item -Recurse -Force build\
Remove-Item -Recurse -Force .dart_tool\
```

### Backup Current Build
```powershell
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupDir = "builds_backup\build_$timestamp"
New-Item -ItemType Directory -Path $backupDir
Copy-Item "build\windows\x64\runner\Release\pos_software.msix" -Destination $backupDir
Write-Host "Backup created: $backupDir"
```

---

## 🔐 Certificate Management (Local Testing Only)

### Generate Self-Signed Certificate (for testing)
```powershell
# Generate certificate
New-SelfSignedCertificate -Type Custom -Subject "CN=KalubaTechnologies" `
    -KeyUsage DigitalSignature -FriendlyName "Dynamos POS Test Cert" `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}")
```

### Export Certificate
```powershell
$cert = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object {$_.Subject -match "KalubaTechnologies"}
Export-Certificate -Cert $cert -FilePath "test_cert.cer"
```

### Install Certificate to Trusted Root
```powershell
Import-Certificate -FilePath "test_cert.cer" -CertStoreLocation Cert:\LocalMachine\Root
```

### Sign MSIX Package (for local testing)
```bash
dart run msix:create --certificate-path "C:\path\to\cert.pfx" --certificate-password "password"
```

> ⚠️ **Note:** For Microsoft Store submission, DO NOT sign the package. Microsoft will sign it for you.

---

## 🌐 Environment Variables (Optional)

### Set Flutter Path
```powershell
$env:PATH += ";C:\flutter\bin"
```

### Set MSIX Build Path
```powershell
$env:MSIX_OUTPUT_PATH = "build\windows\x64\runner\Release"
```

---

## 📝 Quick Build Scripts

### Create build_for_store.bat
```batch
@echo off
echo ========================================
echo Building Dynamos POS for Microsoft Store
echo ========================================
echo.

echo [1/4] Cleaning previous builds...
flutter clean
if %errorlevel% neq 0 goto error

echo [2/4] Getting dependencies...
flutter pub get
if %errorlevel% neq 0 goto error

echo [3/4] Building Windows release...
flutter build windows --release
if %errorlevel% neq 0 goto error

echo [4/4] Creating MSIX package...
dart run msix:create --store
if %errorlevel% neq 0 goto error

echo.
echo ========================================
echo ✅ Build completed successfully!
echo ========================================
echo Package location: build\windows\x64\runner\Release\pos_software.msix
echo.
goto end

:error
echo.
echo ========================================
echo ❌ Build failed!
echo ========================================
exit /b 1

:end
pause
```

### Create build_and_test.bat
```batch
@echo off
echo Building and installing for local testing...

call flutter clean
call flutter pub get
call flutter build windows --release
call dart run msix:create

echo.
echo Installing package...
powershell -Command "Add-AppxPackage -Path 'build\windows\x64\runner\Release\pos_software.msix'"

echo.
echo Package installed! Check your Start Menu.
pause
```

### Create increment_and_build.ps1
```powershell
# PowerShell script to increment version and build

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Increment Version & Build for Store" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Read current version
$pubspec = Get-Content "pubspec.yaml" -Raw
if ($pubspec -match "msix_version:\s*(\d+)\.(\d+)\.(\d+)\.(\d+)") {
    $major = [int]$matches[1]
    $minor = [int]$matches[2]
    $build = [int]$matches[3]
    $revision = [int]$matches[4]
    
    Write-Host "`nCurrent version: $major.$minor.$build.$revision" -ForegroundColor Yellow
    
    # Increment build number
    $build++
    $newVersion = "$major.$minor.$build.$revision"
    
    Write-Host "New version: $newVersion" -ForegroundColor Green
    
    # Update pubspec.yaml
    $pubspec = $pubspec -replace "msix_version:\s*\d+\.\d+\.\d+\.\d+", "msix_version: $newVersion"
    $pubspec | Set-Content "pubspec.yaml"
    
    Write-Host "`n✅ Version updated successfully!" -ForegroundColor Green
}

# Build
Write-Host "`nBuilding application..." -ForegroundColor Cyan
flutter clean
flutter pub get
flutter build windows --release
dart run msix:create --store

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "✅ Build completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nPackage: build\windows\x64\runner\Release\pos_software.msix"
```

---

## 🔗 Useful Links

### Official Documentation
```
Flutter Windows Deployment:
https://docs.flutter.dev/deployment/windows

MSIX Package (pub.dev):
https://pub.dev/packages/msix

Microsoft Partner Center:
https://partner.microsoft.com/dashboard

Windows App Certification Kit:
https://developer.microsoft.com/en-us/windows/downloads/app-certification-kit/
```

### Microsoft Store Policies
```
App Policies:
https://learn.microsoft.com/en-us/windows/apps/publish/store-policies

Content Policies:
https://www.microsoft.com/en-us/legal/intellectualproperty/copyright

Age Ratings:
https://www.globalratings.com/
```

---

## 🆘 Troubleshooting Commands

### Check Flutter Doctor
```bash
flutter doctor -v
```

### Verify Windows SDK
```bash
flutter doctor --verbose | findstr "Windows"
```

### Check MSIX Package Installation
```bash
dart pub global list
```

### Reinstall MSIX Package
```bash
flutter pub remove msix
flutter pub add msix
flutter pub get
```

### Clear Flutter Cache
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

### Check Dart Version
```bash
dart --version
```

---

## 📦 Package Locations

```
Source Code:
c:\pos_software\

Built App:
c:\pos_software\build\windows\x64\runner\Release\

MSIX Package:
c:\pos_software\build\windows\x64\runner\Release\pos_software.msix

App Assets:
c:\pos_software\windows\runner\resources\

Configuration:
c:\pos_software\pubspec.yaml
c:\pos_software\windows\runner\Runner.rc
c:\pos_software\windows\CMakeLists.txt
```

---

## ⚡ One-Liner Commands

### Complete Build Pipeline
```bash
flutter clean && flutter pub get && flutter build windows --release && dart run msix:create --store
```

### Quick Rebuild
```bash
flutter build windows --release && dart run msix:create
```

### Test Install
```powershell
Get-AppxPackage *dynamospos* | Remove-AppxPackage; Add-AppxPackage -Path "build\windows\x64\runner\Release\pos_software.msix"
```

### Version Check
```bash
flutter --version && dart --version
```

---

## 📊 Package Info Quick Reference

```yaml
App Name: Dynamos POS
Package Name: pos_software
Identity Name: com.kalootech.DynamosPOS
Publisher: CN=Kaluba Technologies
Version Format: Major.Minor.Build.Revision
Current Version: 1.0.0.0
Architecture: x64
Target OS: Windows 10 (17763.0) or higher
```

---

## ✅ Pre-Submission Command Checklist

Run these commands before submitting to Microsoft Store:

```bash
# 1. Clean
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Build release
flutter build windows --release

# 4. Create MSIX for Store
dart run msix:create --store

# 5. Verify package exists
dir build\windows\x64\runner\Release\pos_software.msix

# 6. Check package size
powershell -Command "(Get-Item 'build\windows\x64\runner\Release\pos_software.msix').Length / 1MB"

# 7. Done! Ready to upload to Partner Center
```

---

**Quick Reference Version:** 1.0  
**Last Updated:** November 15, 2025  
**App:** Dynamos POS

---

**Save this file for easy access to all deployment commands!**
