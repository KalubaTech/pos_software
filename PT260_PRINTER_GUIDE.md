# PT-260 Label Printer Configuration Guide

## Current Issue
The printer connects successfully (MAC: 86:67:7a:05:49:97) and finds the write characteristic, but nothing prints.

## Changes Made

### 1. Label Printer Initialization
Added PT-260 specific initialization commands:
- `ESC @` (0x1B, 0x40) - Initialize printer
- `ESC i a 0` - Select label mode
- `ESC i M 0` - Select auto cut mode

### 2. Dynamic Paper Size
The system now detects template width and uses appropriate paper size:
- Templates ≤58mm → PaperSize.mm58
- Templates ≤80mm → PaperSize.mm80

### 3. Label Ejection
Instead of just cut command, now uses:
- Form Feed (0x0C) to eject label
- Cut command for compatibility

### 4. Test Print Feature
Added a "Test Print" button that sends a simple test page with:
- "TEST PRINT" header
- Printer model name
- Current timestamp

## Troubleshooting Steps

### Step 1: Use Test Print
1. Open Print Dialog
2. Select your PT-260 printer
3. Click **"Test Print"** button (next to Cancel)
4. Check the console output for:
   - Number of bytes generated
   - First 30 bytes of data
   - Write result status

### Step 2: Check Console Output
Look for these debug messages:
```
Test print: XXX bytes
Bytes: [27, 64, 27, 105, ...]
Write result: true/false
```

### Step 3: Verify Printer Settings
Ensure your PT-260 is set to:
- **Label Mode** (not continuous paper mode)
- **Bluetooth enabled**
- **Sufficient label roll installed**
- **Power on and ready**

### Step 4: Common PT-260 Issues

#### Issue: Printer connected but no output
**Solution:**
- Check if printer is in sleep mode
- Press printer button to wake it up
- Ensure label roll is loaded correctly

#### Issue: Printer beeps but doesn't print
**Solution:**
- Label may be misaligned
- Check label sensor position
- Reload label roll

#### Issue: Partial prints
**Solution:**
- Battery low - charge the printer
- Label size mismatch - verify label width
- Increase delay between prints (currently 800ms)

### Step 5: Alternative Commands

If test print still doesn't work, we may need to try:

#### Option A: Remove Label-Specific Commands
Comment out these lines in `_generatePriceTag`:
```dart
// bytes += [0x1B, 0x69, 0x61, 0x00]; // ESC i a 0
// bytes += [0x1B, 0x69, 0x4D, 0x00]; // ESC i M 0
```

#### Option B: Use Different Paper Size
Try forcing PaperSize.mm80 for PT-260:
```dart
final generator = Generator(PaperSize.mm80, profile);
```

#### Option C: Add Status Check
Before printing, check printer status:
```dart
final status = await PrintBluetoothThermal.printerStatus;
print('Printer status: $status');
```

## PT-260 Specifications
- **Print Method:** Direct thermal
- **Print Width:** 20-60mm (typical 58mm)
- **Resolution:** 203 DPI
- **Interface:** Bluetooth 4.0
- **Label Size:** 20-60mm width, 15-100mm length
- **Command Set:** ESC/POS compatible

## Next Steps

1. **Run Test Print** and check console output
2. **Share the console output** with me:
   - Number of bytes
   - First 30 bytes array
   - Write result
   - Any error messages

3. Based on the output, we can:
   - Adjust initialization commands
   - Modify paper size settings
   - Change label ejection method
   - Add printer status checks

## Additional Resources

### PT-260 Command Reference
The PT-260 typically supports:
- Standard ESC/POS commands
- Label mode switching
- Auto-cut functionality
- Adjustable print density

### Debug Mode
To enable more detailed logging, check the terminal output when printing. The code now prints:
- Byte array length
- First 20 bytes of each print job
- Write operation results

## Contact
If the issue persists after trying test print, please provide:
1. Console output from test print
2. Any beeps or LED patterns from the printer
3. Whether the printer advances paper at all
4. Current label size being used
