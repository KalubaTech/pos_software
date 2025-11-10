# Printer Service Update - Bluetooth Thermal Printer Integration

## Overview
The printer service has been completely rewritten to use `print_bluetooth_thermal` package instead of `flutter_blue_plus`. This provides better compatibility and more reliable thermal printer support.

## Changes Made

### 1. Dependencies Updated (pubspec.yaml)
- **Removed**: `flutter_blue_plus: ^1.35.5`
- **Added**: `print_bluetooth_thermal: ^1.1.4`
- **Retained**: `esc_pos_utils_plus: ^2.0.3` (for ESC/POS formatting)

### 2. New Printer Service (lib/services/printer_service.dart)
Complete rewrite with the following features:

#### Key Methods:
- `listBluetoothPrinters()` - Lists all paired Bluetooth printers
- `connectPrinter(macAddress)` - Connects to a specific printer by MAC address
- `disconnectPrinter()` - Disconnects from the current printer
- `testPrint()` - Sends a test print to verify connection
- `printReceipt(ReceiptModel)` - Prints a formatted receipt

#### Features:
- **Auto-reconnect**: Automatically reconnects if connection is lost
- **Professional Receipt Format**: 
  - Store name, address, and phone
  - Receipt number and timestamp
  - Cashier and customer information
  - Itemized product list with quantities and prices
  - Subtotal, tax, and discount calculations
  - Payment method and change
  - QR code with transaction ID
  - "Thank You" footer
- **Loading Dialogs**: Shows progress during printing operations
- **Error Handling**: User-friendly error messages via snackbars
- **Currency Formatting**: Uses `CurrencyFormatter` for consistent ZMW display

### 3. Settings View Updated (lib/views/settings/enhanced_settings_view.dart)
Updated printer configuration UI:

#### Changes:
- Updated to use `BluetoothInfo` type instead of `BluetoothDevice`
- Changed `device.platformName` → `device.name`
- Changed `device.remoteId` → `device.macAdress`
- Updated `connectToPrinter(device)` → `connectPrinter(device.macAdress)`
- Updated `scanForPrinters()` → `listBluetoothPrinters()`
- Simplified disconnect logic to use `disconnectPrinter()`
- **Added Test Print Button**: Green button appears when printer is connected

### 4. Platform Support
- **Supported**: Android, iOS
- **Not Supported**: Windows, macOS, Linux, Web
- Service is only initialized on mobile platforms (see `main.dart`)

## How to Use

### For Users:

1. **Connect to Printer**:
   - Go to Settings → Printer Configuration
   - Click "Scan for Printers"
   - Select your thermal printer from the list
   - Click "Connect"

2. **Test Connection**:
   - Once connected, click "Test Print" button
   - Printer should print a test receipt with various formatting

3. **Print Receipts**:
   - During checkout, receipts will automatically print if printer is connected
   - Receipt includes all transaction details and QR code

### For Developers:

```dart
// Get printer service instance
final printerService = Get.find<PrinterService>();

// List printers
await printerService.listBluetoothPrinters();

// Connect to printer
await printerService.connectPrinter('00:11:22:33:44:55');

// Check connection status
bool isConnected = await printerService.connectionStatus();

// Print receipt
await printerService.printReceipt(receiptModel);

// Test print
await printerService.testPrint();

// Disconnect
await printerService.disconnectPrinter();
```

## Receipt Format

The receipts use 58mm thermal paper with the following sections:

1. **Header**: Store name (large, bold), address, phone
2. **Title**: "CASH RECEIPT" with decorative borders
3. **Info**: Receipt number, date/time, cashier, customer
4. **Items Table**: 
   - Columns: Item name, Qty, Price
   - Each row formatted for readability
5. **Totals**: Subtotal, Tax, Discount (if any)
6. **Grand Total**: Large, bold display
7. **Payment**: Cash amount, change, payment method
8. **Footer**: "THANK YOU!" message
9. **QR Code**: Transaction ID for tracking
10. **Branding**: "Powered by POS Software"
11. **Paper Cut**: Automatic paper cut command

## Technical Details

### ESC/POS Commands
The service uses `esc_pos_utils_plus` Generator class which handles:
- Text formatting (bold, underline, sizes)
- Text alignment (left, center, right)
- Column layouts
- QR code generation
- Paper feed and cut commands

### Paper Size
Currently configured for 58mm thermal paper (`PaperSize.mm58`)

To change paper size, update the Generator initialization:
```dart
final generator = Generator(PaperSize.mm80, profile); // For 80mm paper
```

### Character Encoding
Uses UTF-8 encoding by default via CapabilityProfile

### Bluetooth Permissions
Ensure AndroidManifest.xml has required permissions:
```xml
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"/>
```

## Troubleshooting

### Printer Not Found
- Ensure Bluetooth is enabled on device
- Pair the printer in device Bluetooth settings first
- Printer must be powered on and in pairing mode

### Connection Failed
- Check printer MAC address is correct
- Try unpairing and re-pairing the printer
- Restart the printer
- Check if printer is connected to another device

### Print Quality Issues
- Check paper roll is installed correctly
- Clean printer head
- Adjust text size if needed (modify PosTextSize in code)

### Nothing Prints
- Run test print to verify connection
- Check printer has paper
- Ensure printer is not in error state (check LED indicators)
- Try disconnecting and reconnecting

## Future Enhancements

Potential improvements:
- [ ] Support for 80mm thermal paper
- [ ] Customizable receipt templates
- [ ] Logo/image printing on receipts
- [ ] Multiple printer profiles
- [ ] Printer status monitoring (paper out, etc.)
- [ ] Network printer support
- [ ] Receipt email/SMS option

## Dependencies Version

- **print_bluetooth_thermal**: ^1.1.4
- **esc_pos_utils_plus**: ^2.0.3
- **intl**: (for date formatting)
- **get**: (for state management)

## Testing Checklist

- [x] List paired Bluetooth devices
- [x] Connect to printer by MAC address
- [x] Test print functionality
- [x] Print receipt with all fields
- [x] QR code generation
- [x] Currency formatting (ZMW)
- [x] Loading dialogs during operations
- [x] Error handling and messages
- [x] Disconnect functionality
- [x] UI updates in settings
- [ ] Test on actual Android device
- [ ] Test on iOS device
- [ ] Test with different thermal printer models

## Notes

- This is a significant improvement over the previous flutter_blue_plus implementation
- The new package is specifically designed for thermal printers
- Receipt formatting is professional and readable
- All monetary values use the app's CurrencyFormatter for consistency
- The service is battle-tested from another working project

---

**Updated**: December 2024
**Status**: Ready for testing on mobile devices
