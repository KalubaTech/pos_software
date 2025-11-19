# Microsoft Store Submission Guide for Dynamos POS

This guide walks you through the complete process of submitting your app to the Microsoft Store using the MSIX package.

## Prerequisites

✅ **Completed:**
- [x] Shorebird initialized (`shorebird init`)
- [x] MSIX package configured in `pubspec.yaml`
- [x] App icons ready (`windows/runner/resources/app_icon.png`)

⏳ **In Progress:**
- [ ] Shorebird Windows release build

📋 **To Do:**
- [ ] Microsoft Partner Center account setup
- [ ] MSIX package creation
- [ ] Store listing preparation
- [ ] Submission to Microsoft Store

---

## Step 1: Complete the Current Build

The Shorebird build is currently running:
```bash
shorebird release windows
```

This will create a release build with OTA (Over-The-Air) update capabilities in:
```
build/windows/x64/runner/Release/
```

**Wait for this to complete before proceeding.**

---

## Step 2: Create the MSIX Package

Once the Shorebird build completes, run:

```bash
flutter pub run msix:create
```

This will:
- Package your Windows app into an MSIX file
- Use the configuration from `pubspec.yaml` under `msix_config`
- Create the package in: `build/windows/x64/runner/Release/*.msix`

### Expected Output:
```
Building MSIX package...
✓ Created MSIX package successfully
📦 Location: build/windows/x64/runner/Release/pos_software.msix
```

---

## Step 3: Microsoft Partner Center Setup

### 3.1 Create a Microsoft Partner Center Account

1. **Visit:** https://partner.microsoft.com/dashboard
2. **Sign up** with a Microsoft account
3. **Choose account type:**
   - **Individual**: $19 one-time fee
   - **Company**: $99 one-time fee (recommended for business apps)
4. **Complete registration** and verification process

### 3.2 Reserve Your App Name

1. Go to **Dashboard** → **Apps and games** → **New product**
2. Click **MSIX or PWA app**
3. **Reserve name:** `Dynamos POS`
4. Click **Reserve product name**

This gives you:
- Unique app identity
- Reserved name for 3 months
- Publisher ID and App Identity information

### 3.3 Get Your Publisher Information

After reserving the app name:

1. Go to **Product management** → **Product Identity**
2. Copy these values:

```yaml
Package Identity Name: [Copy this value]
Publisher: CN=[Your Publisher ID]
Publisher Display Name: [Your company name]
```

### 3.4 Update Your Configuration

Update `pubspec.yaml` with the actual values from Partner Center:

```yaml
msix_config:
  identity_name: YourPublisherPrefix.DynamosPOS
  publisher: CN=YOUR-ACTUAL-PUBLISHER-ID-HERE
  publisher_display_name: Your Actual Publisher Name
```

Then **rebuild the MSIX:**
```bash
flutter pub run msix:create
```

---

## Step 4: Prepare Store Listing Assets

### 4.1 Required Screenshots

Microsoft Store requires screenshots in specific sizes:

**Desktop Screenshots (Required):**
- **1920x1080** or **1366x768** pixels
- PNG or JPEG format
- At least **1 screenshot**, maximum **10**

**Recommended Screenshots to Take:**
1. Dashboard view with sales analytics
2. Inventory management screen
3. Point of Sale transaction screen
4. Customer management interface
5. Reports and analytics view
6. Settings/configuration screen

### 4.2 Store Logo Images

You already have icons, but Microsoft Store needs specific sizes:

**Required:**
- **Store Logo**: 300x300 pixels (minimum 50x50)
- **App Tile Icons**: Multiple sizes for different display contexts

**Current Icon Location:**
- `assets/dynamos_pos_logo_plain.png`
- `assets/dynamos-icon.png`
- `windows/runner/resources/app_icon.png`

**Create additional sizes if needed:**
- 44x44, 50x50, 71x71, 150x150, 310x150, 310x310 pixels

### 4.3 Promotional Images (Optional but Recommended)

- **Hero Image**: 1920x1080 pixels
- **Featured Tile**: 846x468 pixels
- Used for promotional features in the Store

---

## Step 5: Create Store Listing

### 5.1 Product Description

Go to **Store listings** and fill in:

**App Name:**
```
Dynamos POS
```

**Short Description (200 characters max):**
```
Professional Point of Sale system with inventory management, sales analytics, and multi-device sync. Perfect for retail stores and service businesses.
```

**Full Description (10,000 characters max):**

```markdown
# Dynamos POS - Complete Business Management Solution

Transform your business operations with Dynamos POS, a comprehensive Point of Sale system designed for modern businesses.

## 🚀 KEY FEATURES

### Point of Sale
• Fast and intuitive checkout process
• Product search with barcode scanning
• Multiple payment methods support
• Real-time cart management
• Customer information capture

### Inventory Management
• Complete product catalog management
• Stock level tracking and alerts
• Bulk product import/export (CSV)
• Product variants and categories
• Image support for products

### Sales Analytics
• Real-time sales dashboard
• Detailed transaction reports
• Revenue tracking and trends
• Top-selling products analysis
• Customer purchase history

### Customer Management
• Comprehensive customer database
• Purchase history tracking
• Customer loyalty programs
• Contact management
• Export customer data

### Receipt Printing
• Professional receipt design
• Support for thermal printers
• Bluetooth printer connectivity
• Network printer support
• Customizable receipt templates

### Price Tag Designer
• Custom price tag templates
• Bulk printing capabilities
• Multiple tag sizes supported
• Product information display
• Professional layouts

### Multi-Business Support
• Manage multiple locations
• Separate business profiles
• Individual inventory per location
• Consolidated reporting

### Data Synchronization (Premium)
• Cloud backup and sync
• Real-time data updates
• Multi-device access
• Automatic background sync
• Transaction sync across devices

### Professional Interface
• Beautiful dark mode
• Intuitive navigation
• Responsive design
• Touch-friendly interface
• Customizable settings

## 💼 PERFECT FOR

• Retail stores
• Restaurants and cafes
• Service businesses
• Small to medium enterprises
• Multi-location businesses

## 🔒 SECURITY & RELIABILITY

• Secure data encryption
• Local database with cloud backup
• Offline-first architecture
• Works without internet
• Automatic data protection

## 📱 REQUIREMENTS

• Windows 10 version 1809 or higher
• 500 MB free disk space
• Internet connection (for sync features)

## 💎 PREMIUM FEATURES

Unlock advanced features with a premium subscription:
• Multi-device synchronization
• Cloud backup and restore
• Priority customer support
• Advanced analytics
• Team collaboration tools

## 📞 SUPPORT

Need help? We're here for you!
• Email: support@kaloo.tech
• Website: https://kaloo.tech
• Documentation: Included in app

---

Start managing your business more efficiently today with Dynamos POS!
```

### 5.2 Search Terms

Add relevant keywords (maximum 7):
```
POS, Point of Sale, Inventory, Sales, Retail, Business, Management
```

### 5.3 Categories

**Primary Category:** Business
**Secondary Category:** Productivity

### 5.4 Age Rating

- Select **Age 3+** (suitable for all ages)
- No mature content, violence, or adult themes

---

## Step 6: Privacy Policy

Microsoft requires a privacy policy URL. Create one at:

**Option 1: Use Free Privacy Policy Generator**
- Visit: https://www.privacypolicygenerator.info/
- Or: https://www.termsfeed.com/privacy-policy-generator/

**Option 2: Host on Your Website**
- Create a page at: `https://yourdomain.com/privacy-policy`

**Key Points to Include:**
- What data is collected (transaction data, customer info)
- How data is stored (locally and cloud sync)
- Data security measures
- User rights and data deletion
- Contact information

**Add to Store Listing:**
```
https://your-website.com/privacy-policy
```

---

## Step 7: Submission Package Upload

### 7.1 Upload MSIX Package

1. Go to **Packages** section
2. Click **Upload package**
3. **Browse** and select your MSIX file:
   ```
   build/windows/x64/runner/Release/pos_software.msix
   ```
4. **Upload** and wait for validation

### 7.2 Package Validation

Microsoft will automatically validate:
- ✅ Package integrity
- ✅ Manifest correctness
- ✅ Minimum Windows version compatibility
- ✅ Capabilities declared
- ✅ Code signing (done by Microsoft)

**If validation fails:**
- Check error messages
- Fix issues in `pubspec.yaml` → `msix_config`
- Rebuild MSIX: `flutter pub run msix:create`
- Upload again

---

## Step 8: Pricing and Availability

### 8.1 Markets

**Recommended:** Select all markets
- Or choose specific countries/regions
- Consider currency and language support

### 8.2 Pricing

**Options:**
1. **Free** - No cost to download
2. **Paid** - Set a price (e.g., $9.99)
3. **Freemium** - Free with in-app purchases

**Recommendation for Dynamos POS:**
- **Free** download
- **In-app subscription** for premium features
- This maximizes downloads and user base

### 8.3 Free Trial (If Paid)

- Offer a trial period (7, 15, or 30 days)
- Users can test before buying

---

## Step 9: System Requirements

Confirm the minimum requirements:

```yaml
Operating System: Windows 10 version 1809 (October 2018 Update) or higher
Architecture: x64
RAM: 4 GB recommended
Storage: 500 MB free space
Internet: Required for cloud sync (optional for basic features)
```

---

## Step 10: Submit for Certification

### 10.1 Pre-Submission Checklist

- [x] MSIX package uploaded and validated
- [ ] All store listing information complete
- [ ] Screenshots uploaded (at least 1)
- [ ] App description written
- [ ] Privacy policy URL provided
- [ ] Categories selected
- [ ] Age rating set
- [ ] Pricing configured
- [ ] Markets selected

### 10.2 Submit

1. Click **Submit for certification**
2. Microsoft will review your app (typically 24-48 hours)
3. You'll receive email notifications about status

### 10.3 Certification Process

**Microsoft checks:**
- ✅ Security and malware scan
- ✅ Content policy compliance
- ✅ Technical requirements
- ✅ Store listing accuracy
- ✅ Age rating appropriateness

**Timeline:**
- **Initial Review**: 24-48 hours
- **If issues found**: You'll get feedback to fix
- **Re-submission**: After fixing issues
- **Approval**: App goes live in Store

---

## Step 11: After Approval

### 11.1 Your App is Live!

Once approved:
- App appears in Microsoft Store
- Users can search and download
- Store page is publicly accessible

### 11.2 Store Link

Your app will be available at:
```
https://www.microsoft.com/store/apps/[your-app-id]
```

Share this link for marketing!

### 11.3 Updates with Shorebird

**For Minor Updates (Patches):**
```bash
shorebird patch windows
```
- Users get updates automatically
- No Store re-submission needed
- Works via Shorebird OTA

**For Major Updates:**
```bash
# Increment version in pubspec.yaml
version: 1.1.0+2

# Build new release
shorebird release windows

# Create new MSIX
flutter pub run msix:create

# Upload to Partner Center as update
```

---

## Step 12: Marketing Your App

### 12.1 Store Optimization

- Use relevant keywords in description
- Add quality screenshots
- Respond to user reviews
- Regular updates show active development

### 12.2 Promotional Campaigns

- Share Store link on social media
- Create demo videos
- Write blog posts
- Reach out to tech reviewers

### 12.3 Monitor Performance

**Partner Center Analytics:**
- Downloads and installs
- User ratings and reviews
- Acquisition channels
- Usage statistics
- Revenue (if paid/subscription)

---

## Troubleshooting

### Issue: MSIX build fails

**Solution:**
```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Try again
flutter pub run msix:create
```

### Issue: "Publisher not found" error

**Solution:**
- Ensure you've set up Partner Center account
- Update `publisher` in `msix_config` with actual value from Partner Center
- Must be in format: `CN=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`

### Issue: Package validation fails

**Solution:**
- Check minimum Windows version is 1809+
- Verify all capabilities are valid
- Ensure version format is correct (x.x.x.x)
- Check app icons exist and are correct format

### Issue: Certification rejected

**Solution:**
- Read the rejection feedback carefully
- Common issues:
  - Missing privacy policy
  - Inappropriate content rating
  - Store description accuracy
  - Security concerns
- Fix issues and resubmit

---

## Next Steps After This Build

1. ✅ **Wait for Shorebird build to complete** (currently running)
2. 📦 **Create MSIX package**: `flutter pub run msix:create`
3. 🏢 **Set up Microsoft Partner Center account**
4. 📝 **Reserve app name**: "Dynamos POS"
5. 🔑 **Get Publisher ID** and update `pubspec.yaml`
6. 🎨 **Prepare screenshots** (take 4-6 screenshots of app)
7. 📄 **Create privacy policy** (use generator or host on website)
8. 📤 **Upload MSIX** to Partner Center
9. ✍️ **Complete store listing** (description, images, pricing)
10. 🚀 **Submit for certification**

---

## Resources

**Microsoft Partner Center:**
- https://partner.microsoft.com/dashboard

**MSIX Documentation:**
- https://learn.microsoft.com/windows/msix/

**Flutter MSIX Package:**
- https://pub.dev/packages/msix

**Shorebird Documentation:**
- https://docs.shorebird.dev/

**App Screenshots Tool:**
- Use Windows Snipping Tool (Win + Shift + S)
- Or Greenshot for advanced screenshots

**Privacy Policy Generators:**
- https://www.privacypolicygenerator.info/
- https://www.termsfeed.com/privacy-policy-generator/

---

## Contact & Support

**For App Issues:**
- Email: support@kaloo.tech
- GitHub: https://github.com/KalubaTech

**For Store Submission Help:**
- Microsoft Partner Support
- Shorebird Community Discord

---

**Good luck with your Microsoft Store submission! 🚀**

Your app is well-configured and ready for the Store. Follow this guide step-by-step, and you'll have Dynamos POS live in the Microsoft Store soon!
