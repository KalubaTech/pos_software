# Microsoft Store Deployment Guide for Dynamos POS

## 📋 Prerequisites Checklist

Before you begin, ensure you have:

- [ ] **Microsoft Partner Center Account** ($19 one-time registration fee for individual developers)
  - Sign up at: https://partner.microsoft.com/dashboard
  
- [ ] **Windows 10/11 Development Machine**
  - Visual Studio 2019 or later (Community Edition is free)
  - Windows 10 SDK (10.0.17763.0 or higher)
  
- [ ] **Flutter SDK** (Already installed ✅)
  - Version 3.0 or higher with Windows support
  
- [ ] **App Assets Prepared**
  - App icons in various sizes
  - Screenshots for Store listing
  - Privacy policy URL
  - Support contact information

---

## 🎯 Step-by-Step Deployment Process

### Phase 1: Install Required Tools

#### 1.1 Install msix Package

Add the `msix` package to your `pubspec.yaml`:

```bash
flutter pub add msix
```

Or manually add to `pubspec.yaml`:
```yaml
dev_dependencies:
  msix: ^3.16.7  # Check for latest version
```

Then run:
```bash
flutter pub get
```

#### 1.2 Verify Flutter Windows Support

```bash
flutter doctor -v
```

Ensure Windows toolchain is properly configured.

---

### Phase 2: Prepare App Assets

#### 2.1 Create Required Icon Sizes

Microsoft Store requires icons in multiple sizes. Create these PNG files:

**Required Sizes:**
- `app_icon_44x44.png` - Small tile
- `app_icon_50x50.png` - Small tile (Scale 125%)
- `app_icon_71x71.png` - Medium tile
- `app_icon_150x150.png` - Medium tile (Square)
- `app_icon_310x150.png` - Wide tile
- `app_icon_310x310.png` - Large tile (Optional)

**Store Listing Assets:**
- `app_icon_1240x600.png` - Store Hero image
- Screenshots: At least 1 screenshot (1920x1080 recommended)

**Location:** `windows/runner/resources/`

You can use online tools like:
- https://appicon.co/
- https://easyappicon.com/
- Or use Photoshop/GIMP to resize

#### 2.2 Update App Icon

Your current icon is at: `windows/runner/resources/app_icon.ico`

Make sure you also have PNG versions for MSIX packaging.

---

### Phase 3: Configure MSIX Package

#### 3.1 Update pubspec.yaml

Add MSIX configuration to your `pubspec.yaml`:

```yaml
# Add this at the end of your pubspec.yaml file

msix_config:
  display_name: Dynamos POS
  publisher_display_name: Kaluba Technologies
  identity_name: com.kalootech.dynamospos
  msix_version: 1.0.0.0
  logo_path: windows\\runner\\resources\\app_icon.png
  
  # App capabilities - what permissions your app needs
  capabilities: internetClient,microphone,webcam,location,bluetooth
  
  # Languages supported
  languages: en-us
  
  # Architecture
  architecture: x64
  
  # App description
  description: |
    Dynamos POS - A powerful Point of Sale system for modern businesses.
    Features inventory management, sales tracking, receipt printing, and more.
  
  # Publisher info - This will be updated with your actual certificate info
  publisher: CN=KalubaTechnologies
  
  # Optional: File type associations
  # file_extension: .csv,.json
  
  # Optional: Protocol activation
  # protocol_activation: dynamospos
  
  # Store category
  # category: Business
```

#### 3.2 Update App Metadata in Runner.rc

The file `windows/runner/Runner.rc` contains version info. Update these fields:

- **CompanyName**: Your company name
- **FileDescription**: App description
- **LegalCopyright**: Copyright information
- **ProductName**: Product name

These are already set to:
- CompanyName: `com.kalootech`
- ProductName: `pos_software`

Consider updating to:
- CompanyName: `Kaluba Technologies`
- ProductName: `Dynamos POS`

---

### Phase 4: Build MSIX Package

#### 4.1 Clean Previous Builds

```bash
flutter clean
flutter pub get
```

#### 4.2 Build Windows Release

```bash
flutter build windows --release
```

This creates an optimized Windows build in:
`build/windows/x64/runner/Release/`

#### 4.3 Create MSIX Package

```bash
flutter pub run msix:create
```

Or use the shorthand:
```bash
dart run msix:create
```

**Options you can add:**
```bash
# Build with version number
dart run msix:create --version 1.0.1.0

# Build with custom name
dart run msix:create --display-name "Dynamos POS"

# Build and sign with certificate
dart run msix:create --certificate-path "C:\path\to\cert.pfx" --certificate-password "yourpassword"

# Build for Store submission (unsigned)
dart run msix:create --store
```

The MSIX package will be created in:
`build/windows/x64/runner/Release/pos_software.msix`

---

### Phase 5: Test MSIX Package Locally

#### 5.1 Install Test Certificate (First Time Only)

If testing unsigned package:

```powershell
# Run PowerShell as Administrator
Add-AppxPackage -Path "build\windows\x64\runner\Release\pos_software.msix" -DependencyPath "C:\path\to\dependencies"
```

For self-signed testing, you need to trust the certificate:

```powershell
# Extract certificate from MSIX
$cert = (Get-AuthenticodeSignature "build\windows\x64\runner\Release\pos_software.msix").SignerCertificate
# Install to Trusted Root
$cert | Export-Certificate -FilePath "test_cert.cer"
Import-Certificate -FilePath "test_cert.cer" -CertStoreLocation Cert:\LocalMachine\Root
```

#### 5.2 Install and Test

Double-click the `.msix` file to install, or use PowerShell:

```powershell
Add-AppxPackage -Path "build\windows\x64\runner\Release\pos_software.msix"
```

Test all features:
- [ ] App launches correctly
- [ ] All features work
- [ ] Database access
- [ ] File operations
- [ ] Printing functionality
- [ ] Network access

#### 5.3 Uninstall Test Version

```powershell
Get-AppxPackage *dynamospos* | Remove-AppxPackage
```

---

### Phase 6: Microsoft Partner Center Setup

#### 6.1 Create Microsoft Partner Center Account

1. Go to https://partner.microsoft.com/dashboard
2. Sign up for a developer account ($19 USD one-time fee)
3. Complete identity verification (may take 1-3 business days)
4. Accept the App Developer Agreement

#### 6.2 Reserve App Name

1. In Partner Center, go to **Apps and games**
2. Click **New product** → **MSIX or PWA app**
3. Enter your app name: **Dynamos POS**
4. Click **Reserve product name**
5. Note: Name reservation lasts 3 months

#### 6.3 Get App Identity Information

After reserving the name:

1. Go to **Product Identity** page
2. Copy these values:
   - **Package/Identity/Name**: e.g., `12345KalubaTech.DynamosPOS`
   - **Package/Identity/Publisher**: e.g., `CN=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`
   - **Package/Properties/PublisherDisplayName**: Your publisher name

3. Update your `pubspec.yaml` with these exact values:

```yaml
msix_config:
  identity_name: 12345KalubaTech.DynamosPOS  # From Partner Center
  publisher: CN=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX  # From Partner Center
  publisher_display_name: Kaluba Technologies  # From Partner Center
```

---

### Phase 7: Create Store Listing

#### 7.1 Fill Out Store Listing Information

In Partner Center, go to **Store listings** → **English (United States)**:

**Required Information:**

1. **Description** (At least 200 characters):
```
Dynamos POS is a comprehensive Point of Sale solution designed for modern businesses. Whether you run a retail store, restaurant, or service business, Dynamos POS provides everything you need to manage your operations efficiently.

KEY FEATURES:
• Comprehensive inventory management with stock tracking
• Real-time sales reports and analytics
• Customer management and loyalty programs
• Professional receipt printing (Thermal, Bluetooth, Network)
• Custom price tag designer and bulk printing
• Dark mode for comfortable use in any environment
• Multi-business support - manage multiple locations
• Offline-first design - works without internet
• Secure subscription management
• Beautiful, intuitive interface

PERFECT FOR:
✓ Retail stores
✓ Restaurants and cafes
✓ Service businesses
✓ Small to medium enterprises

Streamline your business operations with Dynamos POS - The professional POS system built for efficiency and growth.
```

2. **Screenshots** (At least 1, recommended 3-5):
   - 1920x1080 or 3840x2160
   - Show key features
   - No text overlay required

3. **App Icon** (Store logo):
   - 300x300 PNG
   - Already have: `windows/runner/resources/app_icon.png`

4. **Store Logos**:
   - 1:1 (Square): 300x300
   - 2:3 (Portrait): 300x450
   - 16:9 (Landscape): 1920x1080

5. **Additional Information**:
   - **Category**: Business
   - **Subcategory**: Finance (or Productivity)
   - **Privacy Policy URL**: Required! Create one at https://www.privacypolicygenerator.info/
   - **Support Contact**: Your email or website
   - **Copyright and trademark info**: © 2025 Kaluba Technologies

6. **Age Ratings**:
   - Answer questionnaire (likely: EVERYONE)

7. **System Requirements**:
   - Minimum: Windows 10 version 17763.0 or higher
   - Architecture: x64
   - Memory: 4 GB RAM (recommended)
   - DirectX: Version 11 or higher

#### 7.2 Pricing and Availability

1. **Markets**: Select all markets or specific countries
2. **Pricing**: 
   - Free (with in-app purchases for subscriptions)
   - Or set a one-time purchase price
3. **Free trial**: Optional 7-day or 30-day trial
4. **Release date**: Choose immediate or scheduled

---

### Phase 8: Build for Store Submission

#### 8.1 Update Version Number

In `pubspec.yaml`:
```yaml
version: 1.0.0+1  # Keep this
```

In `msix_config`:
```yaml
msix_version: 1.0.0.0  # MSIX format (must be increasing for updates)
```

#### 8.2 Build Final Store Package

```bash
# Clean build
flutter clean
flutter pub get

# Build release
flutter build windows --release

# Create MSIX for Store (unsigned - Microsoft will sign it)
dart run msix:create --store

# Or with all options:
dart run msix:create \
  --store \
  --display-name "Dynamos POS" \
  --publisher-display-name "Kaluba Technologies" \
  --version 1.0.0.0 \
  --architecture x64
```

#### 8.3 Verify Package

The MSIX package should be at:
`build/windows/x64/runner/Release/pos_software.msix`

**Check Package Details:**
```powershell
# View package info
Get-AppxPackage -Path "build\windows\x64\runner\Release\pos_software.msix"
```

**Package Size:**
- Typical Flutter Windows app: 20-50 MB
- Your app (with all features): ~30-60 MB

---

### Phase 9: Submit to Microsoft Store

#### 9.1 Upload Package

1. In Partner Center, go to your app
2. Click **Start your submission**
3. Go to **Packages** section
4. **Drag and drop** your `.msix` file
5. Wait for validation (automated checks)

**Validation Checks:**
- [ ] Package integrity
- [ ] Version number (must be higher than previous)
- [ ] Identity matches reservation
- [ ] No malware or policy violations
- [ ] Size limits (Maximum 25 GB)

#### 9.2 Complete Submission Checklist

Ensure all sections are complete:
- [ ] Pricing and availability
- [ ] Properties (Category, age ratings)
- [ ] Age ratings questionnaire
- [ ] Store listings (description, screenshots)
- [ ] Packages (uploaded and validated)
- [ ] Notes for certification (optional)

#### 9.3 Submit for Certification

1. Review all information
2. Click **Submit to the Store**
3. Certification process begins

**Certification Timeline:**
- Initial review: 1-3 business days
- If issues found: You'll get specific feedback
- If approved: App goes live automatically (or on scheduled date)

---

### Phase 10: Post-Submission

#### 10.1 Monitor Certification Status

Track progress in Partner Center:
- **In progress**: Microsoft is reviewing
- **Failed**: Fix issues and resubmit
- **In the Store**: Live and available!

#### 10.2 Common Certification Failures

**Issue: Missing Privacy Policy**
- Solution: Add privacy policy URL to Store listing

**Issue: Capability Not Declared**
- Solution: Add required capability to `msix_config`

**Issue: Crash on Launch**
- Solution: Test thoroughly before submission

**Issue: Missing Age Rating**
- Solution: Complete age ratings questionnaire

#### 10.3 After Approval

1. **Test in Store**:
   - Search for your app
   - Install from Store
   - Verify all features work

2. **Promote Your App**:
   - Get Store URL: `https://www.microsoft.com/store/apps/[your-app-id]`
   - Share on social media
   - Add "Download from Microsoft Store" badge to website

3. **Monitor Analytics**:
   - Installs and uninstalls
   - Ratings and reviews
   - Crash reports
   - User feedback

---

## 🔄 Updating Your App

### For Future Updates:

1. **Increment Version Numbers**:
```yaml
# pubspec.yaml
version: 1.0.1+2

# msix_config
msix_version: 1.0.1.0  # Must be higher than previous
```

2. **Build New Package**:
```bash
flutter clean
flutter build windows --release
dart run msix:create --store
```

3. **Submit Update**:
   - Go to Partner Center
   - Create new submission
   - Upload new package
   - Update "What's new in this version"
   - Submit

4. **Update Review**:
   - Typically faster than initial (few hours to 1 day)
   - Users auto-update via Microsoft Store

---

## 🛠️ Troubleshooting Common Issues

### Issue: "Publisher does not match certificate"

**Solution:**
Ensure `publisher` in `msix_config` exactly matches Partner Center value.

### Issue: "Package validation failed"

**Solution:**
Run package validation tool:
```bash
dart run msix:create --store --validate
```

### Issue: "App crashes on start"

**Solution:**
1. Test in Release mode: `flutter run --release`
2. Check for missing dependencies
3. Verify all assets are included

### Issue: "Missing capabilities"

**Solution:**
Add required capabilities to `msix_config`:
```yaml
capabilities: internetClient,documentsLibrary,removableStorage
```

### Issue: "Icon not showing in Store"

**Solution:**
- Use PNG (not ICO)
- Correct dimensions
- No transparency issues
- Under 2 MB file size

---

## 📱 Testing Checklist Before Submission

Test all these scenarios:

- [ ] Fresh install from MSIX
- [ ] App launches successfully
- [ ] All UI elements display correctly
- [ ] Database operations work
- [ ] File read/write operations
- [ ] Network requests succeed
- [ ] Bluetooth printing (if applicable)
- [ ] Subscription management
- [ ] Settings persistence
- [ ] Dark mode switching
- [ ] Multi-window support
- [ ] Uninstall and reinstall
- [ ] Windows 10 compatibility
- [ ] Windows 11 compatibility
- [ ] High DPI displays
- [ ] Keyboard navigation
- [ ] Accessibility features

---

## 💰 Store Fee Structure

- **Registration**: $19 USD (one-time, lifetime access)
- **Revenue Share**: 
  - Apps: Microsoft takes 15% (you keep 85%)
  - In-app purchases: Microsoft takes 15% (you keep 85%)
  - Enterprise B2B: Microsoft takes 15% (you keep 85%)

---

## 📚 Additional Resources

**Official Documentation:**
- Flutter Windows deployment: https://docs.flutter.dev/deployment/windows
- MSIX package: https://pub.dev/packages/msix
- Partner Center Guide: https://learn.microsoft.com/en-us/windows/apps/publish/

**Helpful Tools:**
- Windows App Certification Kit: https://developer.microsoft.com/en-us/windows/downloads/app-certification-kit/
- App Icon Generator: https://appicon.co/
- Privacy Policy Generator: https://www.privacypolicygenerator.info/

---

## ✅ Quick Command Reference

```bash
# Install MSIX package
flutter pub add msix

# Clean build
flutter clean && flutter pub get

# Build release
flutter build windows --release

# Create MSIX for testing
dart run msix:create

# Create MSIX for Store submission
dart run msix:create --store

# Create MSIX with specific version
dart run msix:create --store --version 1.0.1.0

# Install locally for testing
Add-AppxPackage -Path "build\windows\x64\runner\Release\pos_software.msix"

# Uninstall test version
Get-AppxPackage *dynamospos* | Remove-AppxPackage
```

---

## 🎉 Ready to Submit!

Follow this checklist:

1. ✅ Install msix package
2. ✅ Configure msix_config in pubspec.yaml
3. ✅ Create required app icons (multiple sizes)
4. ✅ Build and test MSIX locally
5. ✅ Create Partner Center account
6. ✅ Reserve app name
7. ✅ Complete Store listing
8. ✅ Build final Store package
9. ✅ Upload and submit
10. ✅ Wait for certification (1-3 days)
11. ✅ Celebrate launch! 🎊

---

**Good luck with your Microsoft Store submission!**

If you encounter issues, check the troubleshooting section or visit the Flutter Discord/Stack Overflow communities for help.

---

**Document Version:** 1.0  
**Last Updated:** November 15, 2025  
**App:** Dynamos POS by Kaluba Technologies
