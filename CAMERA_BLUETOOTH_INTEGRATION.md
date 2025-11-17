# Camera Barcode Scanner & Bluetooth Integration

## Overview
Integrated camera-based barcode scanning and Bluetooth permission handling for Android mobile devices.

## Features Implemented

### 1. Camera Barcode Scanner
- **Package**: `mobile_scanner: ^5.2.3`
- **Supported Formats**:
  - EAN-13, EAN-8
  - UPC-A, UPC-E
  - Code 128, Code 39
  - QR Code

#### Features:
- ✅ Real-time camera-based scanning
- ✅ Beautiful scanner UI with overlay guide
- ✅ Flash/torch toggle
- ✅ Auto-detect and close on successful scan
- ✅ Permission handling (requests camera access)
- ✅ Custom scan area with corner accents
- ✅ Dark semi-transparent overlay
- ✅ Instruction text at bottom

#### UI Components:
```dart
// Top bar: Close button + Title + Flash toggle
// Middle: Camera view with scan area overlay
// Bottom: Instructions
```

### 2. Bluetooth Permission Service
**File**: `lib/services/bluetooth_permission_service.dart`

#### Features:
- ✅ Check Bluetooth permissions (Android 12+ requires BLUETOOTH_SCAN & BLUETOOTH_CONNECT)
- ✅ Request permissions with proper error handling
- ✅ Detect when permissions are permanently denied
- ✅ Show dialog to open app settings
- ✅ Prompt user to enable Bluetooth if disabled
- ✅ Cross-platform support (Android/iOS detection)

#### Methods:
```dart
checkBluetoothPermissions()      // Check current permissions
requestBluetoothPermissions()    // Request permissions
ensureBluetoothEnabled()         // Check and request if needed
showBluetoothEnableDialog()      // Prompt to enable BT
checkBluetoothForPrinter()       // Pre-flight check for printer
```

### 3. Updated Barcode Scanner Service
**File**: `lib/services/barcode_scanner_service.dart`

#### Changes:
- ❌ Removed: Mock barcode scanning
- ✅ Added: Real camera-based scanning with `mobile_scanner`
- ✅ Added: Camera permission checking
- ✅ Added: Beautiful scanner dialog with custom UI
- ✅ Added: Permission settings dialog

#### Usage:
```dart
final scanner = Get.find<BarcodeScannerService>();
final barcode = await scanner.scanBarcode();

if (barcode != null) {
  final product = await scanner.findProductByBarcode(barcode);
  // Handle product...
}
```

### 4. Updated Printer Service
**File**: `lib/services/printer_service.dart`

#### Changes:
- ✅ Import `BluetoothPermissionService`
- ✅ Check Bluetooth permissions before scanning for printers
- ✅ Detect Bluetooth disabled errors
- ✅ Show enable dialog when Bluetooth is off
- ✅ Better error handling with specific messages

## Android Permissions (Already Configured)

### AndroidManifest.xml
```xml
<!-- Camera -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />

<!-- Bluetooth -->
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
```

## Dependencies Added

### pubspec.yaml
```yaml
dependencies:
  mobile_scanner: ^5.2.3  # Camera-based barcode scanner
  permission_handler: ^12.0.0+1  # Already present
```

## How to Use

### Scanning Barcodes in Inventory

1. **Open Inventory Screen**
2. **Tap the Scan Icon** (wherever you add it)
3. **Camera Opens** with scan guide
4. **Position Barcode** in the highlighted area
5. **Auto-Detect** - dialog closes automatically
6. **Product Loaded** - if found in database

### Adding Scan Button to Inventory

Example integration in product search/add dialog:

```dart
// In inventory view or product dialog
IconButton(
  icon: Icon(Iconsax.scan_barcode),
  onPressed: () async {
    final scanner = Get.find<BarcodeScannerService>();
    final barcode = await scanner.scanBarcode();
    
    if (barcode != null) {
      // Search for product
      final product = await scanner.findProductByBarcode(barcode);
      
      if (product != null) {
        // Show product details
        _showProductDetails(product);
      } else {
        Get.snackbar(
          'Not Found',
          'No product found with barcode: $barcode',
        );
      }
    }
  },
)
```

### Using Bluetooth Printer

1. **Go to Settings → Printer Configuration**
2. **Tap Scan for Printers**
3. **Permission Check** - automatically checks Bluetooth permissions
4. **If Bluetooth Off** - dialog appears: "Bluetooth is Off"
5. **User Taps "Open Settings"** - goes to device Bluetooth settings
6. **Enable Bluetooth** and return to app
7. **Tap Scan Again** - now shows available printers

## User Flow Diagrams

### Barcode Scanning Flow
```
User taps Scan
  ↓
Check Camera Permission
  ↓
├─ Granted → Open Camera Scanner
│   ↓
│   User scans barcode
│   ↓
│   Barcode detected
│   ↓
│   Dialog closes
│   ↓
│   Return barcode string
│
└─ Denied → Request Permission
    ↓
    ├─ Granted → Open Camera Scanner
    │
    └─ Denied → Show Settings Dialog
        ↓
        User opens app settings
        ↓
        Grants permission manually
```

### Bluetooth Printer Flow
```
User taps Scan for Printers
  ↓
Check Bluetooth Permissions
  ↓
├─ Granted → Scan for Devices
│   ↓
│   ├─ Success → Show Printers List
│   │
│   └─ Error: "Bluetooth disabled"
│       ↓
│       Show Enable Dialog
│       ↓
│       User opens settings
│       ↓
│       Enables Bluetooth
│
└─ Denied → Request Permissions
    ↓
    ├─ Granted → Scan for Devices
    │
    └─ Permanently Denied
        ↓
        Show Settings Dialog
```

## Testing Checklist

### Camera Scanner
- [ ] Open inventory, tap scan button
- [ ] Camera permission requested (first time)
- [ ] Grant permission → Camera opens
- [ ] Position barcode in scan area
- [ ] Barcode auto-detected and dialog closes
- [ ] Product found and displayed
- [ ] Flash toggle works
- [ ] Close button works
- [ ] Deny permission → Settings dialog shown

### Bluetooth Printer
- [ ] Open Settings → Printer Configuration
- [ ] Tap "Scan for Printers"
- [ ] Bluetooth permissions requested (first time)
- [ ] Grant → Scan shows printers
- [ ] Turn off Bluetooth → Tap scan
- [ ] "Bluetooth is Off" dialog appears
- [ ] Tap "Open Settings" → Goes to BT settings
- [ ] Enable Bluetooth → Return to app
- [ ] Scan again → Shows printers
- [ ] Connect to printer → Success

## Next Steps (Optional Enhancements)

1. **Add Scan Button to Inventory Header**
   - Quick access for product lookup
   - Badge showing last scanned code

2. **Batch Barcode Scanning**
   - Scan multiple products rapidly
   - Add to cart or inventory list

3. **Product Not Found → Quick Add**
   - If barcode not in DB, pre-fill barcode field
   - Quick create product dialog

4. **Barcode Generation for New Products**
   - Auto-generate EAN-13 barcodes
   - Print barcode labels via thermal printer

5. **Scanner Settings**
   - Choose preferred barcode formats
   - Enable/disable beep sound
   - Vibration on successful scan

6. **Bluetooth Auto-Connect**
   - Remember last printer
   - Auto-reconnect on app launch
   - Background connection monitoring

## Files Modified/Created

### Created:
1. `lib/services/bluetooth_permission_service.dart` - Bluetooth permission handler
2. `CAMERA_BLUETOOTH_INTEGRATION.md` - This documentation

### Modified:
1. `pubspec.yaml` - Added `mobile_scanner: ^5.2.3`
2. `lib/services/barcode_scanner_service.dart` - Real camera scanning
3. `lib/services/printer_service.dart` - Bluetooth permission checks
4. `lib/main.dart` - Initialize BluetoothPermissionService

### Already Present (No Changes Needed):
- `android/app/src/main/AndroidManifest.xml` - Permissions already configured

## Installation Steps

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run on Android device:**
   ```bash
   flutter run
   ```

3. **Test camera scanner:**
   - Navigate to inventory
   - Add scan button (see usage example)
   - Test with physical barcode

4. **Test Bluetooth:**
   - Go to Settings → Printer
   - Tap scan
   - Verify permission flow

## Troubleshooting

### Camera Not Working
- Check AndroidManifest has CAMERA permission
- Verify camera permission granted in app settings
- Try on physical device (emulator camera may not work)

### Bluetooth Scan Fails
- Ensure Bluetooth is enabled on device
- Check Android version (12+ has different permissions)
- Verify BLUETOOTH_SCAN and BLUETOOTH_CONNECT permissions granted
- Pair printer in device settings first

### "Permission Permanently Denied"
- User denied permission multiple times
- Must go to app settings manually
- Settings dialog automatically shown

## Platform Support

### ✅ Supported:
- Android (primary target)
- iOS (with appropriate permissions)

### ❌ Not Supported:
- Web (no camera/Bluetooth APIs)
- Desktop (Windows/macOS/Linux)

## Code Examples

### Quick Scan and Search
```dart
final scanner = Get.find<BarcodeScannerService>();

Future<void> quickScan() async {
  final barcode = await scanner.scanBarcode();
  
  if (barcode != null) {
    final product = await scanner.findProductByBarcode(barcode);
    
    if (product != null) {
      // Add to cart or show details
      print('Found: ${product.name}');
    } else {
      // Product not found
      Get.snackbar('Not Found', 'Barcode: $barcode');
    }
  }
}
```

### Check Bluetooth Before Printing
```dart
final bluetoothService = Get.find<BluetoothPermissionService>();
final printerService = Get.find<PrinterService>();

Future<void> printReceipt() async {
  // Check permissions first
  final canPrint = await bluetoothService.checkBluetoothForPrinter();
  
  if (!canPrint) {
    return; // Permission dialog shown automatically
  }
  
  // Proceed with printing
  await printerService.printReceipt(receiptData);
}
```

## Summary

✅ **Camera barcode scanner** - Real-time scanning with beautiful UI
✅ **Bluetooth permissions** - Proper Android 12+ permission handling  
✅ **Bluetooth state check** - Prompts user to enable if off
✅ **Permission dialogs** - User-friendly settings navigation
✅ **Error handling** - Graceful degradation and clear messages
✅ **Cross-platform** - Android/iOS support (with appropriate checks)

**Ready for Testing!** 🎉
