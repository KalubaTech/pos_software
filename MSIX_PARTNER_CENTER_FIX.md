# Fixing Microsoft Partner Center MSIX Upload Errors

## Errors You're Seeing

❌ **Error 1: Invalid package publisher name**
```
Invalid package publisher name: CN=Msix Testing, O=Msix Testing Corporation...
Expected: CN=6C8EDE9F-2E47-49E3-B93C-97CDD74A456A
```

❌ **Error 2: Invalid package family name**
```
Invalid package family name: KalooTechnologies.DynamosPOS_fxkeb4dgdm144
Expected: KalooTechnologies.DynamosPOS_f2xb7xmhtr0x4
```

❌ **Error 3: Restricted capabilities warning**
```
Package acceptance validation warning: The following restricted capabilities 
require approval: documentsLibrary, runFullTrust
```

❌ **Error 4: Duplicate package version**
```
All packages must be uniquely identified. You have two packages with 
version 1.0.0.0 with different contents.
```

---

## Solution: Get Correct Values from Partner Center

### Step 1: Get Your Actual Publisher ID and Package Identity

1. **Login to Partner Center:**
   - Go to: https://partner.microsoft.com/dashboard
   - Sign in with your account

2. **Navigate to Your App:**
   - Click on your app "Dynamos POS"
   - Go to **Product management** → **Product Identity**

3. **Copy These EXACT Values:**

   You'll see something like this:
   ```
   Package/Identity/Name: KalooTechnologies.DynamosPOS
   Package/Identity/Publisher: CN=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
   Package/Properties/PublisherDisplayName: Kaloo Technologies
   Package Family Name: KalooTechnologies.DynamosPOS_f2xb7xmhtr0x4
   ```

   **Copy these exact values!** Don't use the placeholder ones.

---

## Step 2: Update Your pubspec.yaml

Open `pubspec.yaml` and update the `msix_config` section with the EXACT values from Partner Center:

```yaml
msix_config:
  display_name: Dynamos POS
  publisher_display_name: [EXACT VALUE FROM PARTNER CENTER]
  identity_name: [EXACT VALUE FROM PARTNER CENTER - usually KalooTechnologies.DynamosPOS]
  
  # INCREMENT THIS - Changed from 1.0.0.0 to 1.0.1.0
  msix_version: 1.0.1.0
  
  # EXACT PUBLISHER ID FROM PARTNER CENTER
  publisher: [EXACT CN=... VALUE FROM PARTNER CENTER]
  
  # ADD THIS LINE - The package family name suffix from Partner Center
  package_identity_name: [EXACT PACKAGE FAMILY NAME FROM PARTNER CENTER]
  
  logo_path: windows/runner/resources/app_icon.png
  
  # REMOVED documentsLibrary - it requires special approval
  capabilities: internetClient,internetClientServer,privateNetworkClientServer,removableStorage,bluetooth
  
  languages: en-us
  architecture: x64
```

### Example (with your actual values):

```yaml
msix_config:
  display_name: Dynamos POS
  publisher_display_name: Kaloo Technologies
  identity_name: KalooTechnologies.DynamosPOS
  msix_version: 1.0.1.0
  
  # Replace with YOUR actual value from Partner Center
  publisher: CN=6C8EDE9F-2E47-49E3-B93C-97CDD74A456A
  
  # Replace with YOUR actual package family name from Partner Center
  package_identity_name: KalooTechnologies.DynamosPOS_f2xb7xmhtr0x4
  
  logo_path: windows/runner/resources/app_icon.png
  capabilities: internetClient,internetClientServer,privateNetworkClientServer,removableStorage,bluetooth
  languages: en-us
  architecture: x64
```

---

## Step 3: Fix Restricted Capabilities

### Option A: Remove Restricted Capabilities (Recommended)

I've already removed `documentsLibrary` from your config. Your app will still work, but:
- ❌ Cannot access user's Documents library directly
- ✅ Can still use file picker to let users choose files
- ✅ Can save to app's own storage location
- ✅ Can use removableStorage for external drives

**Most POS apps don't need `documentsLibrary` because:**
- You can use file picker dialogs (no special permission needed)
- App has its own storage location
- Can export to Downloads folder

### Option B: Request Approval for Restricted Capabilities

If you REALLY need `documentsLibrary`:

1. In Partner Center, go to **App management** → **Advanced options**
2. Request approval for restricted capabilities
3. Explain why you need access to Documents library
4. Wait for Microsoft approval (can take 1-2 weeks)

**For Dynamos POS, you DON'T need this!** Use file picker instead.

---

## Step 4: Delete Old Package from Submission

Before uploading the new package:

1. In Partner Center, go to your current submission
2. Find the old package(s) listed
3. Click the **X** or **Remove** button next to each old package
4. Click **Save**

This removes the duplicate packages so you can upload the new one.

---

## Step 5: Rebuild MSIX with Correct Configuration

Now rebuild the MSIX with the corrected configuration:

```powershell
# Clean previous build
flutter clean

# Get dependencies
flutter pub get

# Build Windows app
flutter build windows --release

# Create MSIX with corrected configuration
dart run msix:create
```

---

## Step 6: Verify the New MSIX

Before uploading, verify your MSIX has the correct values:

```powershell
# Extract and check package manifest (optional)
cd build\windows\x64\runner\Release

# The new MSIX should be: pos_software.msix
# Size will be slightly different from the old one
```

---

## Step 7: Upload New Package to Partner Center

1. Go to your submission in Partner Center
2. Navigate to **Packages** section
3. **Remove all old packages** (if you haven't already)
4. Click **Upload new package**
5. Select: `build\windows\x64\runner\Release\pos_software.msix`
6. Wait for upload and validation

### Expected Result:
✅ Package uploaded successfully  
✅ No publisher mismatch errors  
✅ No package family name errors  
✅ No restricted capability warnings (if you removed documentsLibrary)  
✅ Package passes validation  

---

## Step 8: Complete Submission

Once the package validates successfully:

1. ✅ Check all other sections are complete:
   - Store listings
   - Pricing and availability
   - Properties
   - Age ratings
   - Notes for certification

2. Click **Submit to the Store**

3. Wait for certification (24-48 hours)

---

## Common Questions

### Q: Why does the package family name have a suffix like "_f2xb7xmhtr0x4"?

**A:** Microsoft generates this unique suffix when you reserve your app name. It ensures your app package is globally unique. You MUST use the exact suffix that Partner Center shows.

### Q: Can I change the publisher after submitting?

**A:** No, the publisher is tied to your Partner Center account. It must match exactly.

### Q: What if my Partner Center shows a different publisher format?

**A:** Copy it EXACTLY as shown. It might be:
- Simple: `CN=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`
- Or complex: `CN=YourName, O=YourCompany, L=City, S=State, C=Country`

Use whatever Partner Center shows, character-for-character.

### Q: Why increment the version to 1.0.1.0?

**A:** You had a duplicate package with version 1.0.0.0. Microsoft requires each upload to have a unique version number. Always increment when re-uploading.

### Q: Will removing documentsLibrary break my app?

**A:** No! Your app can still:
- Use file picker dialogs (user chooses files)
- Read/write to app's own storage
- Export to Downloads folder
- Access removable storage (USB drives)

Most apps don't need `documentsLibrary` - it's only for apps that need to browse the entire Documents folder without user interaction.

---

## Quick Checklist

Before rebuilding and re-uploading:

- [ ] Logged into Microsoft Partner Center
- [ ] Navigated to Product Identity page
- [ ] Copied exact Publisher value
- [ ] Copied exact Package Family Name
- [ ] Updated `pubspec.yaml` with correct values
- [ ] Incremented version to 1.0.1.0
- [ ] Removed `documentsLibrary` capability (or requested approval)
- [ ] Deleted old packages from submission
- [ ] Ran `flutter clean`
- [ ] Ran `dart run msix:create`
- [ ] New MSIX file created successfully
- [ ] Ready to upload to Partner Center

---

## Commands to Run (In Order)

```powershell
# 1. Clean project
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Build Windows app
flutter build windows --release

# 4. Create MSIX (this will use updated pubspec.yaml)
dart run msix:create

# 5. The new MSIX will be at:
# build\windows\x64\runner\Release\pos_software.msix
```

---

## If You Still Get Errors

### Error: "Package validation failed"
- Double-check you copied values EXACTLY from Partner Center
- Ensure no extra spaces or characters
- Verify version was incremented

### Error: "Publisher doesn't match"
- Go back to Partner Center Product Identity
- Copy the Publisher value again (might have copied wrong)
- Make sure you're in the correct app (not a different app)

### Error: "Restricted capabilities"
- If you removed `documentsLibrary` but still see error, clear browser cache
- Delete old packages from submission completely
- Upload only the new package

---

## Need Help?

**Partner Center Support:**
- https://partner.microsoft.com/support

**Where to Find Product Identity:**
1. Partner Center Dashboard
2. Your App → "Dynamos POS"
3. Left sidebar → Product management → Product Identity
4. Copy all values from this page

---

**After fixing and re-uploading, you should see:**
✅ Package accepted  
✅ Validation passed  
✅ Ready to submit  

**Then you can click "Submit to the Store" and wait for approval!** 🚀
