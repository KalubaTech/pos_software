# Fix: "No Printer Selected" Issue After Selecting Saved Printer

## Problem

**Symptom:** When selecting a printer that was previously connected/saved, clicking "Print Tags" would show the error "No Printer Selected" even though a printer was clearly selected in the dropdown.

**Root Cause:** The `_loadPrinters()` method only looked at `connectedPrinter.value` to set the selected printer. Since we removed auto-connection to prevent the "disappearing printer" issue, `connectedPrinter.value` would be `null` until actual printing happens. This caused the saved printer to not be pre-selected in the UI state, even though it appeared selected in the dropdown.

## The Issue in Detail

### Code Flow (Broken):

1. User opens Print Dialog
2. `_loadPrinters()` is called
3. Checks `connectedPrinter.value` → `null` (no active connection)
4. Sets `selectedPrinter = null` and `selectedPrinterMac = null`
5. Dropdown shows saved printer (from `savedPrinterMac.value`) ✓
6. But internal state has `selectedPrinter = null` ✗
7. User clicks "Print Tags"
8. Check fails: `if (selectedPrinter == null)` → Shows error ✗

### The Disconnect:

```dart
// Dropdown value (visual)
dropdownValue = savedPrinterMac.value  ✓ "86:67:7a:05:49:97"

// Internal state (logic)
selectedPrinter = null                  ✗ null
selectedPrinterMac = null               ✗ null
```

**Result:** Dropdown shows printer selected, but code thinks nothing is selected!

## Solution

Enhanced `_loadPrinters()` to also check `savedPrinterMac.value` as a fallback when there's no active connection.

### Fixed Code:

```dart
Future<void> _loadPrinters() async {
  await printerService.listBluetoothPrinters();
  final available = printerService.availablePrinters;
  final connected = printerService.connectedPrinter.value;
  final savedMac = printerService.savedPrinterMac.value;  // ← NEW

  BluetoothInfo? newSelection;
  String? newMac;
  
  // First try to find connected printer
  if (connected != null) {
    final idx = available.indexWhere(
      (p) => p.macAdress == connected.macAdress,
    );
    if (idx >= 0) {
      newSelection = available[idx];
      newMac = newSelection.macAdress;
    }
  }
  
  // If no connected printer but have saved MAC, use that  ← NEW
  if (newSelection == null && savedMac.isNotEmpty) {
    final savedPrinter = available.firstWhereOrNull(
      (p) => p.macAdress == savedMac,
    );
    if (savedPrinter != null) {
      newSelection = savedPrinter;
      newMac = savedPrinter.macAdress;
    }
  }

  setState(() {
    selectedPrinter = newSelection;
    selectedPrinterMac = newMac;
  });
}
```

## How It Works Now

### Priority Order:

1. **First Priority:** Use currently connected printer (if any)
2. **Second Priority:** Use saved printer MAC (if no active connection)
3. **Fallback:** Set to null (no printer)

### Fixed Flow:

1. User opens Print Dialog
2. `_loadPrinters()` is called
3. Checks `connectedPrinter.value` → `null`
4. **NEW:** Checks `savedPrinterMac.value` → `"86:67:7a:05:49:97"`
5. **NEW:** Finds printer in available list
6. **NEW:** Sets `selectedPrinter` and `selectedPrinterMac` ✓
7. Dropdown shows saved printer ✓
8. Internal state matches dropdown ✓
9. User clicks "Print Tags"
10. Check passes: `selectedPrinter != null` ✓
11. Connects and prints successfully ✓

## Benefits

### ✅ Consistency
- **Dropdown value** and **internal state** now match
- Visual selection = Actual selection

### ✅ User Experience
- Select printer once → Works every time
- No confusing "No Printer Selected" errors
- Saved printer is truly "remembered"

### ✅ Stability
- Still no auto-connect on dialog open
- Still no auto-connect on dropdown selection
- Only connects when printing (stable behavior)

## Testing

### ✅ Test 1: First Time Selection
1. Open Print Dialog (no saved printer)
2. Select PT-260 from dropdown
3. Click "Print Tags"
4. **Expected:** Connects and prints ✓

### ✅ Test 2: Reopen with Saved Printer
1. Close and reopen Print Dialog
2. PT-260 is pre-selected
3. Click "Print Tags" (without re-selecting)
4. **Expected:** Connects and prints ✓ (This was broken before!)

### ✅ Test 3: Different Printer Selected
1. Open Print Dialog (PT-260 saved)
2. Select different printer from dropdown
3. Click "Print Tags"
4. **Expected:** Connects to new printer and prints ✓

### ✅ Test 4: Printer Already Connected
1. Connect to PT-260 from Settings
2. Open Print Dialog
3. PT-260 is pre-selected (already connected)
4. Click "Print Tags"
5. **Expected:** Uses existing connection and prints ✓

## Code Changes Summary

**File:** `lib/views/price_tag_designer/widgets/print_dialog_widget.dart`

**Changes:**
1. Added `final savedMac = printerService.savedPrinterMac.value;`
2. Added fallback logic to check `savedMac` if no connected printer
3. Searches available printers for saved MAC
4. Sets `selectedPrinter` and `selectedPrinterMac` accordingly

**Lines Modified:** Approximately lines 38-78 (the `_loadPrinters()` method)

## Before vs After

### Before (Broken):
```
Saved Printer: 86:67:7a:05:49:97 ✓
Connected: No

_loadPrinters() →
  connected = null
  selectedPrinter = null      ✗
  selectedPrinterMac = null   ✗

Dropdown shows: PT-260 ✓
Internal state: null ✗

Click Print → "No Printer Selected" ✗
```

### After (Fixed):
```
Saved Printer: 86:67:7a:05:49:97 ✓
Connected: No

_loadPrinters() →
  connected = null
  savedMac = "86:67:7a:05:49:97" ✓
  selectedPrinter = PT-260 ✓
  selectedPrinterMac = "86:67:7a:05:49:97" ✓

Dropdown shows: PT-260 ✓
Internal state: PT-260 ✓

Click Print → Connects and prints ✓
```

## Related Issues Fixed

This fix also resolves:
- ✅ Printer "forgetting" issue between dialog opens
- ✅ Need to reselect printer every time
- ✅ Inconsistent UI state
- ✅ Confusing user experience

## Summary

**Problem:** Saved printer not being loaded into internal state  
**Cause:** Only checking `connectedPrinter.value`, ignoring `savedPrinterMac.value`  
**Solution:** Check both connected printer AND saved MAC as fallback  
**Result:** Saved printer is properly pre-selected and ready to print!

**The printer selection now persists correctly across dialog opens without requiring auto-connection!** 🎉
