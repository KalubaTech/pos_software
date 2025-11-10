# Printer Auto-Save & Auto-Connect Feature

## Overview

The printer system now automatically saves and reconnects to your PT-260 printer, eliminating the need to search for it every time.

## How It Works

### 1. **Automatic Connection on Selection**
When you select a printer from the dropdown:
- ✅ Automatically connects to the printer
- ✅ Saves the printer MAC address to persistent storage
- ✅ Shows connection status notifications

### 2. **Persistent Storage**
Your printer selection is saved using GetStorage:
- **Storage Key**: `'saved_printer_mac'`
- **Stored Value**: Bluetooth MAC address (e.g., `86:67:7a:05:49:97`)
- **Persistence**: Survives app restarts and device reboots

### 3. **Auto-Reconnect on App Start**
When you open the app or print dialog:
- System checks for saved printer MAC
- If found, automatically attempts to reconnect
- Pre-selects the saved printer in dropdown
- Silently reconnects in background

### 4. **Auto-Connect Before Printing**
When you click "Print Tags" or "Test Print":
- Checks if printer is still connected
- If disconnected, automatically reconnects using saved MAC
- Proceeds with printing seamlessly

## User Experience Flow

### First Time Use:
1. User opens Print Dialog
2. Clicks "Scan for Printers" if list is empty
3. Selects their PT-260 from dropdown
4. **System automatically connects and saves**
5. "Connected" badge appears
6. Ready to print!

### Subsequent Uses:
1. User opens Print Dialog
2. **Printer is already selected and connected**
3. No scanning or selection needed
4. Click "Print Tags" and go!

## Where Saving Happens

### 1. **On Dropdown Selection** (NEW!)
```dart
onChanged: (mac) async {
  // Connect to printer
  await printerService.connectPrinter(mac);
  // ↑ This automatically saves the MAC address
}
```

### 2. **On Manual Connection**
```dart
printerService.connectPrinter(macAddress)
// ↓ Calls _savePrinterMac() internally
```

### 3. **On Successful Print**
If disconnected, reconnects using saved MAC before printing

## Visual Indicators

### Dropdown Display:
- **Connected Printer**: Shows green "CONNECTED" badge
- **Saved Printer**: Pre-selected in dropdown
- **Other Printers**: Gray icon, selectable

### Notifications:
- **Connecting**: Blue snackbar - "Connecting to [printer name]..."
- **Connected**: Green snackbar - "Printer connected and saved" ✓
- **Failed**: Orange snackbar - "Could not connect to printer"

## Code Locations

### PrinterService (lib/services/printer_service.dart)
```dart
// Save MAC to storage
void _savePrinterMac(String macAddress) {
  _storage.write('saved_printer_mac', macAddress);
  savedPrinterMac.value = macAddress;
}

// Load MAC from storage on app start
void _loadSavedPrinter() {
  final savedMac = _storage.read('saved_printer_mac');
  if (savedMac != null) {
    savedPrinterMac.value = savedMac;
  }
}

// Connect and save
Future<bool> connectPrinter(String macAddress) async {
  final result = await PrintBluetoothThermal.connect(...);
  if (result) {
    _savePrinterMac(macAddress); // ← Saves here
  }
  return result;
}
```

### Print Dialog (lib/views/price_tag_designer/widgets/print_dialog_widget.dart)
```dart
// Dropdown onChange handler
onChanged: (mac) async {
  // Connect and save automatically
  await printerService.connectPrinter(mac);
}

// Load saved printer on dialog open
Future<void> _loadPrinters() async {
  await printerService.listBluetoothPrinters();
  // ↑ Automatically reconnects to saved printer
}
```

## Benefits

### ✅ **No Repetitive Scanning**
- Scan once, use forever
- No need to search for printer every time

### ✅ **Faster Workflow**
- Open dialog → Print
- No configuration steps

### ✅ **Seamless Reconnection**
- Disconnected? Automatically reconnects
- Connection issues handled transparently

### ✅ **User-Friendly**
- Visual feedback with notifications
- Connected status clearly shown
- One-click printer selection

## Troubleshooting

### Issue: Printer not auto-connecting

**Check:**
1. Printer is powered on
2. Bluetooth is enabled on device
3. Printer is within range
4. No other device is connected to printer

**Solution:**
- Click "Scan for Printers"
- Reselect your printer from dropdown
- Will reconnect and save again

### Issue: Wrong printer auto-connecting

**Solution:**
- Open Print Dialog
- Select correct printer from dropdown
- System will save the new selection

### Issue: Want to forget saved printer

**Option 1**: Select different printer from dropdown
**Option 2**: Clear app data (removes saved MAC)

## Storage Details

### GetStorage Instance:
- **Package**: `get_storage`
- **File**: `.storage` in app data directory
- **Format**: JSON key-value pairs
- **Key**: `saved_printer_mac`
- **Example Value**: `"86:67:7a:05:49:97"`

### Persistence:
- ✅ Survives app restart
- ✅ Survives device reboot
- ✅ Survives hot reload
- ❌ Cleared on app uninstall
- ❌ Cleared on "Clear app data"

## Testing the Feature

### Test 1: First Connection
1. Open Print Dialog (no printer saved)
2. Select PT-260 from dropdown
3. ✅ Should show "Connecting..." then "Connected and saved"
4. ✅ "CONNECTED" badge appears

### Test 2: App Restart
1. Close and reopen app
2. Open Print Dialog
3. ✅ PT-260 should be pre-selected
4. ✅ Should reconnect automatically

### Test 3: Printing
1. Select products
2. Click "Print Tags"
3. ✅ Should print without asking for printer
4. ✅ Should reconnect if disconnected

### Test 4: Connection Lost
1. Turn off printer
2. Click "Print Tags"
3. ✅ Should attempt reconnection
4. ✅ Should show appropriate error if fails

## Future Enhancements

### Possible Additions:
- [ ] Save multiple printers with nicknames
- [ ] Remember printer per template
- [ ] Printer connection health monitoring
- [ ] Auto-switch to backup printer on failure
- [ ] Printer usage statistics

## Summary

Your PT-260 printer is now **"sticky"** - once connected, it stays connected and remembered. The system handles all connection management automatically, giving you a seamless printing experience!

### Key Actions:
1. **First time**: Select printer from dropdown
2. **System**: Connects and saves automatically
3. **Every time after**: Opens ready to print
4. **If disconnected**: Reconnects automatically

**Result**: Print in one click, every time! 🎉
