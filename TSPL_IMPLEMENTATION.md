# TSPL Implementation for PT-260 Label Printer

## Summary

Successfully converted from **ESC/POS** commands to **TSPL** (TSC Printer Language) commands to support the PT-260 label printer.

## What Changed

### ❌ Removed: ESC/POS Implementation
- Removed `esc_pos_utils_plus` package dependency
- Deleted ESC/POS Generator and command generation
- Removed PosStyles, PosAlign, PosTextSize usage

### ✅ Added: TSPL Command Generation
- Direct TSPL command string generation
- Proper label sizing and positioning
- Support for all template elements in TSPL format

## TSPL Commands Used

### Label Setup
```
SIZE 60 mm, 40 mm          → Set label size (width x height)
GAP 2 mm, 0 mm             → Set gap between labels
DIRECTION 0                → Print direction (0=top to bottom)
REFERENCE 0,0              → Set reference point
DENSITY 8                  → Print density (0-15, higher = darker)
SET PRINTKEY OFF           → Disable print button
SET PEEL OFF               → Enable peel-off mode
CLS                        → Clear image buffer
```

### Drawing Commands
```
TEXT x,y,"font",rotation,x-scale,y-scale,"content"
→ Print text at position with scaling

BARCODE x,y,"type",height,readable,rotation,narrow,wide,"data"
→ Print barcode (EAN13, EAN8, 128, etc.)

QRCODE x,y,error_level,cell_size,mode,rotation,"data"
→ Print QR code

BAR x,y,width,height
→ Draw filled rectangle (for lines)

BOX x1,y1,x2,y2,thickness
→ Draw rectangle outline
```

### Print Command
```
PRINT 1,1                  → Print 1 label, 1 copy
```

## Coordinate System

- **Units**: Dots (not pixels or mm in commands, but we convert)
- **DPI**: 203 DPI (8 dots per mm)
- **Origin**: Top-left corner (0,0)
- **X-axis**: Left to right
- **Y-axis**: Top to bottom

## Conversion Formula

```dart
int dots = (millimeters * 8).toInt();
```

Example:
- 50mm width → 400 dots
- 30mm height → 240 dots

## Element Types Supported

| Element Type | TSPL Command | Notes |
|-------------|--------------|-------|
| **Text** | TEXT | Static text with font scaling |
| **Product Name** | TEXT | Dynamic product.name |
| **Price** | TEXT | Dynamic formatted price |
| **Barcode** | BARCODE | EAN13, EAN8, Code128 |
| **QR Code** | QRCODE | High error correction |
| **Line** | BAR | Horizontal line as filled bar |
| **Rectangle** | BOX | Outline box with thickness |

## Font Sizes

TSPL uses numeric font sizes (1-8):
- **1-2**: Small text
- **3-4**: Normal text
- **5-6**: Large text
- **7-8**: Extra large text

Conversion from template fontSize:
```dart
int fontHeight = element.fontSize ~/ 3;
if (fontHeight < 1) fontHeight = 1;
if (fontHeight > 8) fontHeight = 8;
```

## Barcode Support

Supported barcode types:
- **EAN13**: 13-digit barcodes
- **EAN8**: 8-digit barcodes
- **Code128**: Variable length (default)

Command format:
```
BARCODE 100,150,"EAN13",80,1,0,2,4,"1234567890123"
        │   │    │      │  │ │ │ │  │
        │   │    │      │  │ │ │ │  └─ Barcode data
        │   │    │      │  │ │ │ └──── Wide bar width
        │   │    │      │  │ │ └─────── Narrow bar width
        │   │    │      │  │ └────────── Rotation (0,90,180,270)
        │   │    │      │  └─────────────  Human readable (0=no, 1=yes)
        │   │    │      └────────────────── Height in dots
        │   │    └───────────────────────── Barcode type
        │   └────────────────────────────── Y position
        └────────────────────────────────── X position
```

## QR Code Support

Command format:
```
QRCODE 200,100,H,5,A,0,"https://example.com"
       │   │   │ │ │ │  │
       │   │   │ │ │ │  └─ QR code data
       │   │   │ │ │ └──── Rotation (0,90,180,270)
       │   │   │ │ └─────── Mode (A=auto, M=manual)
       │   │   │ └────────── Cell size (3-10)
       │   │   └─────────────  Error correction (L,M,Q,H)
       │   └─────────────────── Y position
       └─────────────────────── X position
```

## Testing

### Test Print Feature
A "Test Print" button is available in the print dialog that sends a simple TSPL test page with:
- "TEST PRINT" title (large font)
- "PT-260 Label Printer" subtitle
- Current timestamp
- Horizontal line
- "Using TSPL Commands" indicator

### Debug Output
The console will display:
```
Test print: XXX bytes
TSPL Commands: SIZE 60 mm, 40 mm...
Write result: true
```

## Template Element Rendering

The system now:
1. **Reads template elements** from your canvas design
2. **Sorts by zIndex** for proper layering
3. **Converts mm to dots** for positioning
4. **Generates TSPL commands** for each element
5. **Populates dynamic data** (product name, price, barcode)
6. **Sends to PT-260** via Bluetooth

## Example Generated Commands

For a simple price tag with product name, price, and barcode:

```
SIZE 60 mm, 40 mm
GAP 2 mm, 0 mm
DIRECTION 0
REFERENCE 0,0
DENSITY 8
SET PRINTKEY OFF
SET PEEL OFF
CLS
TEXT 100,50,"4",0,2,2,"Product Name"
TEXT 150,120,"5",0,3,3,"$19.99"
BARCODE 80,180,"EAN13",80,1,0,2,4,"1234567890123"
PRINT 1,1
```

## Troubleshooting

### Issue: Still not printing

**Possible causes:**
1. **Wrong label size** - Check your template size matches actual label
2. **Printer not in TSPL mode** - Some printers support multiple languages
3. **Buffer overflow** - Too much data in one command
4. **Invalid commands** - Syntax error in TSPL string

**Solutions:**
1. Try different label sizes in template designer
2. Reset printer to factory defaults
3. Reduce element count on template
4. Check console output for TSPL command strings

### Issue: Elements not positioned correctly

**Solutions:**
- Verify template dimensions match actual label size
- Check that elements fit within template bounds
- Remember: 8 dots per mm conversion factor

### Issue: Text not appearing

**Solutions:**
- Increase font size in template
- Check text color (should be black/dark)
- Verify text is within label bounds

### Issue: Barcode not scanning

**Solutions:**
- Increase barcode height (minimum 40 dots recommended)
- Ensure barcode data is valid (correct length for EAN)
- Try increasing narrow/wide bar widths

## Command Reference Links

- **TSPL Programming Manual**: [TSC TSPL/TSPL2 Programming](https://www.tscprinters.com/EN/Download/ProgrammingManual)
- **PT-260 Specifications**: Check manufacturer documentation
- **TSPL Command Set**: SIZE, GAP, TEXT, BARCODE, QRCODE, BOX, BAR, PRINT

## Next Steps

1. **Run Test Print** - Click the "Test Print" button
2. **Check Console** - Look for TSPL command output
3. **Verify Label Size** - Ensure template matches actual label dimensions
4. **Print Template** - Try printing with your designed template
5. **Adjust as needed** - Tweak density, font sizes, positioning

## Notes

- **Line endings**: All TSPL commands end with `\r\n` (CR+LF)
- **Case sensitive**: Command names must be uppercase
- **Quote strings**: Text and barcode data must be in quotes
- **No spaces in numbers**: Use `60` not `60 ` in numeric parameters
- **Print command required**: Always end with `PRINT 1,1`

## Success Indicators

✅ Console shows: `Test print: XXX bytes`  
✅ Console shows: `TSPL Commands: SIZE 60 mm...`  
✅ Console shows: `Write result: true`  
✅ PT-260 feeds a label  
✅ Content appears on label  

If you see all of these, the implementation is working! 🎉
