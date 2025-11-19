# Testing Your MSIX Package Locally

Before submitting to Microsoft Store, you can test your MSIX package locally.

## Prerequisites

- Windows 10 version 1809 or higher
- Developer mode enabled (for self-signed packages)

## Enable Developer Mode

1. Open **Settings** → **Update & Security** → **For developers**
2. Turn on **Developer Mode**
3. Click **Yes** when prompted

## Install MSIX Locally

### Method 1: Double-Click Install (Easiest)

1. Navigate to the MSIX file:
   ```
   build\windows\x64\runner\Release\pos_software.msix
   ```

2. **Double-click** the file

3. Click **Install**

4. Wait for installation to complete

5. Find app in Start Menu: "Dynamos POS"

### Method 2: PowerShell Install

```powershell
# Navigate to project root
cd C:\pos_software

# Install the MSIX package
Add-AppxPackage -Path "build\windows\x64\runner\Release\pos_software.msix"
```

## Verify Installation

```powershell
# List installed apps matching "Dynamos"
Get-AppxPackage -Name "*Dynamos*"

# Or check all your installed packages
Get-AppxPackage -Name "*KalooTechnologies*"
```

**Expected Output:**
```
Name              : KalooTechnologies.DynamosPOS
Publisher         : CN=6C8EDE9F-2E47-49E3-B93C-97CDD74A456A
Architecture      : X64
ResourceId        : 
Version           : 1.0.0.0
PackageFullName   : KalooTechnologies.DynamosPOS_1.0.0.0_x64__xxxxx
InstallLocation   : C:\Program Files\WindowsApps\...
IsFramework       : False
```

## Launch the App

### From Start Menu
1. Press **Windows key**
2. Type "**Dynamos POS**"
3. Click the app to launch

### From PowerShell
```powershell
# Launch using protocol (if configured)
start shell:appsFolder\KalooTechnologies.DynamosPOS_xxxxx!App
```

## Uninstall MSIX Package

### Method 1: Windows Settings
1. **Settings** → **Apps** → **Apps & features**
2. Search for "**Dynamos POS**"
3. Click **Uninstall**

### Method 2: PowerShell
```powershell
# Remove by name
Get-AppxPackage -Name "*DynamosPOS*" | Remove-AppxPackage

# Or use full package name
Remove-AppxPackage -Package "KalooTechnologies.DynamosPOS_1.0.0.0_x64__xxxxx"
```

## Testing Checklist

Test these features after installing:

### Functionality
- [ ] App launches successfully
- [ ] No crash on startup
- [ ] All navigation works
- [ ] Can create/view products
- [ ] Can add items to cart
- [ ] Can complete transaction
- [ ] Can view reports
- [ ] Settings are accessible
- [ ] Dark mode toggle works

### UI/UX
- [ ] App icon displays correctly in Start Menu
- [ ] Window title shows "Dynamos POS"
- [ ] All fonts render properly
- [ ] Images and icons load
- [ ] Responsive layout works
- [ ] No UI overflows or errors

### Permissions
- [ ] Internet connectivity (if applicable)
- [ ] File system access (for CSV import/export)
- [ ] Bluetooth (for printer connectivity)
- [ ] Local database creation

### Data Persistence
- [ ] Create sample data
- [ ] Close app
- [ ] Reopen app
- [ ] Verify data is still there

### Performance
- [ ] App starts quickly (< 5 seconds)
- [ ] Navigation is smooth
- [ ] No lag when loading products
- [ ] Search is responsive
- [ ] Reports load quickly

## Common Issues

### Issue: "This app cannot be installed"
**Cause:** Developer mode not enabled  
**Solution:** Enable Developer Mode in Windows Settings

### Issue: "Package signature invalid"
**Cause:** Self-signed certificate not trusted  
**Solution:** For testing, this is expected. For Store submission, Microsoft signs it.

### Issue: App doesn't appear in Start Menu
**Solution:** 
```powershell
# Check if installed
Get-AppxPackage -Name "*DynamosPOS*"

# If installed but not showing, try:
Get-StartApps | Where-Object {$_.Name -like "*Dynamos*"}
```

### Issue: "App installed but won't launch"
**Solution:**
1. Check Event Viewer: **Windows Logs** → **Application**
2. Look for errors from "AppXDeployment-Server"
3. Check compatibility requirements

## Update the Package

After making changes:

```bash
# 1. Rebuild with Shorebird
shorebird release windows

# 2. Recreate MSIX
flutter pub run msix:create

# 3. Uninstall old version
Get-AppxPackage -Name "*DynamosPOS*" | Remove-AppxPackage

# 4. Install new version
Add-AppxPackage -Path "build\windows\x64\runner\Release\pos_software.msix"
```

## Debugging

### View App Data Location

```powershell
# Find package install location
(Get-AppxPackage -Name "*DynamosPOS*").InstallLocation

# View app data
$env:LOCALAPPDATA\Packages\KalooTechnologies.DynamosPOS_xxxxx
```

### Check App Logs

Look in:
```
C:\Users\YourName\AppData\Local\Packages\KalooTechnologies.DynamosPOS_xxxxx\LocalState
```

### Enable Verbose Logging

```powershell
# Enable debug mode for MSIX
$env:MSIX_DEBUG = "1"
```

## Production vs Test Differences

| Aspect | Local Testing | Microsoft Store |
|--------|---------------|-----------------|
| **Signing** | Self-signed | Microsoft signed |
| **Trust** | Developer mode required | Trusted by default |
| **Updates** | Manual reinstall | Automatic updates |
| **Distribution** | Manual file sharing | Store download |
| **Analytics** | None | Full analytics |
| **Revenue** | N/A | Payment processing |

## Next Steps

Once local testing is complete:

1. ✅ Verified app installs correctly
2. ✅ All features work as expected
3. ✅ No crashes or errors
4. 📤 **Ready to upload to Microsoft Partner Center**

Follow the **MICROSOFT_STORE_SUBMISSION_GUIDE.md** for submission steps!

---

**Tips:**
- Test on a clean Windows installation if possible
- Try both install and uninstall flows
- Test with different Windows versions (10, 11)
- Check different screen resolutions
- Test with and without internet connection

**Good luck with testing! 🧪**
