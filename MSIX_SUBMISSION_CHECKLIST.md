# MSIX Submission Checklist

Quick checklist for submitting Dynamos POS to Microsoft Store.

## ✅ Build Phase

- [x] Shorebird initialized
- [ ] Shorebird Windows release completed (⏳ **IN PROGRESS**)
- [ ] MSIX package created

**Commands:**
```bash
# Currently running:
shorebird release windows

# Next step (after above completes):
flutter pub run msix:create
```

---

## 📋 Microsoft Partner Center

- [ ] Partner Center account created
- [ ] Registration fee paid ($19 individual / $99 company)
- [ ] Account verified
- [ ] App name "Dynamos POS" reserved
- [ ] Publisher ID obtained
- [ ] `pubspec.yaml` updated with real Publisher ID

**Update Required in `pubspec.yaml`:**
```yaml
msix_config:
  identity_name: [Get from Partner Center]
  publisher: CN=[Get from Partner Center]
  publisher_display_name: [Your actual name]
```

---

## 🎨 Assets Required

### Screenshots (Windows Desktop)
- [ ] Screenshot 1: Dashboard / Main screen
- [ ] Screenshot 2: Inventory management
- [ ] Screenshot 3: POS transaction screen
- [ ] Screenshot 4: Reports/Analytics
- [ ] Screenshot 5: Settings/Configuration
- [ ] Screenshot 6: (Optional) Additional feature

**Requirements:**
- Size: 1920x1080 or 1366x768 pixels
- Format: PNG or JPEG
- Minimum: 1 screenshot
- Maximum: 10 screenshots

### App Icons (Already Have)
- [x] App icon PNG: `windows/runner/resources/app_icon.png`
- [x] Logo: `assets/dynamos_pos_logo_plain.png`

### Additional Sizes (Optional but Recommended)
- [ ] 44x44 px
- [ ] 50x50 px
- [ ] 71x71 px
- [ ] 150x150 px
- [ ] 310x150 px
- [ ] 310x310 px

---

## 📝 Store Listing Content

### Basic Information
- [x] App Name: **Dynamos POS**
- [x] Short Description (ready - 200 chars max)
- [x] Full Description (ready - see guide)
- [ ] Privacy Policy URL (must create)

### Categories
- [x] Primary: Business
- [x] Secondary: Productivity

### Search Terms (7 max)
- [x] POS
- [x] Point of Sale
- [x] Inventory
- [x] Sales
- [x] Retail
- [x] Business
- [x] Management

### Age Rating
- [x] Age 3+ (All ages)

### Pricing
- [ ] Free (recommended) ✅
- [ ] Paid
- [ ] Trial period (if paid)

### Markets
- [ ] Select markets (All recommended)

---

## 🔒 Privacy Policy

Choose one option:

### Option 1: Use Generator
- [ ] Visit https://www.privacypolicygenerator.info/
- [ ] Generate privacy policy for POS software
- [ ] Include: data collection, storage, security
- [ ] Download/copy the policy

### Option 2: Create Custom
- [ ] Draft privacy policy document
- [ ] Host on your website
- [ ] Get URL

**Items to Cover:**
- What data is collected
- How data is stored (local + cloud)
- Data security measures
- User rights
- Contact information

**Add URL to Store Listing:**
```
https://your-domain.com/privacy-policy
```

---

## 📦 Package Upload

- [ ] MSIX file created successfully
- [ ] File location: `build/windows/x64/runner/Release/pos_software.msix`
- [ ] File uploaded to Partner Center
- [ ] Package validation passed

**Common Validation Issues:**
- Publisher mismatch
- Invalid version format
- Missing capabilities
- Icon format issues

---

## ✍️ Store Submission

### Pre-Submission Final Check
- [ ] All store listing fields completed
- [ ] At least 1 screenshot uploaded
- [ ] Privacy policy URL added
- [ ] Age rating selected
- [ ] Pricing configured
- [ ] Markets selected
- [ ] Package uploaded and validated

### Submit
- [ ] Click "Submit for certification"
- [ ] Confirmation received

### Certification Timeline
- **Initial review**: 24-48 hours
- **Status updates**: Via email
- **Expected result**: Approval or feedback

---

## 🚀 Post-Submission

### If Approved
- [ ] App live in Microsoft Store
- [ ] Store link obtained
- [ ] Share on social media
- [ ] Update website with Store badge
- [ ] Monitor reviews and ratings

### If Rejected
- [ ] Read feedback carefully
- [ ] Fix issues mentioned
- [ ] Update MSIX if needed
- [ ] Resubmit

---

## 🔄 Future Updates

### Minor Updates (OTA via Shorebird)
```bash
shorebird patch windows
```
- No Store resubmission needed
- Users get automatic updates

### Major Updates (New MSIX)
```bash
# 1. Update version in pubspec.yaml
version: 1.1.0+2

# 2. Build new release
shorebird release windows

# 3. Create MSIX
flutter pub run msix:create

# 4. Upload to Partner Center as update
```

---

## 📞 Support Resources

**Microsoft:**
- Partner Center: https://partner.microsoft.com/dashboard
- MSIX Docs: https://learn.microsoft.com/windows/msix/
- Support: Partner Center → Support

**Shorebird:**
- Docs: https://docs.shorebird.dev/
- Discord: https://discord.gg/shorebird

**Flutter MSIX:**
- Package: https://pub.dev/packages/msix
- Issues: https://github.com/YehudaKremer/msix

---

## 🎯 Current Status

**Phase:** Build & Package Creation  
**Status:** ⏳ Waiting for Shorebird build to complete  
**Next Step:** Run `flutter pub run msix:create`

---

## Quick Command Reference

```bash
# Check build progress
# (Monitor the terminal where shorebird is running)

# After build completes, create MSIX:
flutter pub run msix:create

# Test MSIX locally:
# 1. Double-click the .msix file
# 2. Click "Install" to test locally

# If you make changes:
flutter pub get
flutter pub run msix:create

# View MSIX details:
Get-AppxPackage -Name "*DynamosPOS*"
```

---

**Remember:** The most important step is setting up Microsoft Partner Center and getting your actual Publisher ID. The placeholder in `pubspec.yaml` must be replaced with the real one from Partner Center before final submission!

**Good luck! 🚀**
