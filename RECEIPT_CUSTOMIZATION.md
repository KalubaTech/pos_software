# Receipt Customization Updates

## Changes Made

### 1. Store Name from Business Settings
**Previous Behavior:**
- Receipt used hardcoded store name from `receipt.storeName`
- Store information was passed directly from receipt model

**New Behavior:**
- Receipt now reads store name from **Business Settings**
- Dynamically uses `businessSettings.storeName.value`
- Store address and phone also pulled from business settings
- Ensures consistency across the application

**Code Changes:**
```dart
// Old code:
bytes += generator.text(
  receipt.storeName.toUpperCase(),
  styles: PosStyles(...)
);

// New code:
final businessSettings = Get.find<BusinessSettingsController>();
bytes += generator.text(
  businessSettings.storeName.value.toUpperCase(),
  styles: PosStyles(...)
);
```

### 2. Branded Footer
**Previous:**
```
Powered by POS Software
```

**New:**
```
Powered by Dynamos POS
```

**Visual Enhancement:**
- Changed to smaller font (PosFontType.fontB)
- Better branding
- More professional appearance

---

## Receipt Layout

### Complete Receipt Structure:

```
┌──────────────────────────────────┐
│                                  │
│      [STORE NAME FROM            │
│       BUSINESS SETTINGS]         │
│                                  │
│      Store Address Line          │
│      Phone: +260 XXX XXXX        │
│                                  │
│ *********************************│
│                                  │
│        CASH RECEIPT              │
│                                  │
│ *********************************│
│                                  │
│ Receipt #: REC-2025-001          │
│ Date: 10/11/2025 14:30           │
│ Cashier: John Doe                │
│                                  │
│ Item              Qty    Price   │
│ -----------------------------    │
│ Product 1          2     K50.00  │
│ Product 2          1     K30.00  │
│ -----------------------------    │
│                                  │
│ Subtotal:                K80.00  │
│ Tax:                     K8.00   │
│ Discount:               -K5.00   │
│ -----------------------------    │
│                                  │
│ TOTAL:                  K83.00   │
│                                  │
│ Cash:                   K100.00  │
│ Change:                 K17.00   │
│ Payment:                CASH     │
│ -----------------------------    │
│                                  │
│        THANK YOU!                │
│                                  │
│      [QR CODE]                   │
│                                  │
│  Powered by Dynamos POS          │
│                                  │
└──────────────────────────────────┘
```

---

## Benefits

### 1. Centralized Store Information
- ✅ Store name changes in one place (Business Settings)
- ✅ Automatically reflects on all receipts
- ✅ No need to update code for store changes
- ✅ Consistent branding across all prints

### 2. Professional Branding
- ✅ Clear "Dynamos POS" branding
- ✅ Builds brand recognition
- ✅ Professional appearance
- ✅ Smaller, subtle footer text

### 3. Easy Configuration
- ✅ Store info configured in: **Settings → Business → Store Information**
- ✅ Changes apply immediately
- ✅ No code changes required for updates

---

## How to Update Store Information

### 1. Access Business Settings
```
Navigate to: Settings → Business Tab
```

### 2. Update Store Information Section
- **Store Name**: Your business name (e.g., "Dynamos Supermarket")
- **Store Address**: Full address for receipts
- **Store Phone**: Contact number
- **Tax ID**: Optional tax identification number
- **Store Logo**: Optional logo upload

### 3. Save Settings
- Click **Save Settings** button
- Changes apply immediately to new receipts

### 4. Test Receipt
- Process a test transaction
- Print receipt
- Verify store name appears correctly
- Check footer shows "Powered by Dynamos POS"

---

## Technical Implementation

### File Modified:
`lib/services/printer_service.dart`

### Changes:

#### 1. Import Added:
```dart
import '../controllers/business_settings_controller.dart';
```

#### 2. Store Header Updated:
```dart
// Get business settings
final businessSettings = Get.find<BusinessSettingsController>();

// Use settings values
bytes += generator.text(
  businessSettings.storeName.value.toUpperCase(),
  styles: PosStyles(
    align: PosAlign.center,
    bold: true,
    height: PosTextSize.size2,
    width: PosTextSize.size2,
  ),
);
bytes += generator.text(
  businessSettings.storeAddress.value,
  styles: PosStyles(align: PosAlign.center),
);
bytes += generator.text(
  'Phone: ${businessSettings.storePhone.value}',
  styles: PosStyles(align: PosAlign.center),
);
```

#### 3. Footer Updated:
```dart
bytes += generator.text(
  'Powered by Dynamos POS',
  styles: PosStyles(
    align: PosAlign.center,
    fontType: PosFontType.fontB,  // Smaller font
  ),
);
```

---

## Receipt Sections Breakdown

### Header Section:
- ✅ Store Name (from Business Settings) - **LARGE, BOLD**
- ✅ Store Address (from Business Settings)
- ✅ Store Phone (from Business Settings)

### Receipt Title:
- ✅ Decorative stars
- ✅ "CASH RECEIPT" text
- ✅ Decorative stars

### Transaction Details:
- ✅ Receipt number
- ✅ Date and time
- ✅ Cashier name
- ✅ Customer name (if provided)

### Items Section:
- ✅ Column headers (Item, Qty, Price)
- ✅ List of purchased items
- ✅ Quantity and individual prices

### Totals Section:
- ✅ Subtotal
- ✅ Tax amount
- ✅ Discount (if applicable)
- ✅ **TOTAL** (large, bold)

### Payment Section:
- ✅ Cash received
- ✅ Change given
- ✅ Payment method

### Footer Section:
- ✅ "THANK YOU!" message
- ✅ QR Code (transaction ID)
- ✅ **"Powered by Dynamos POS"** branding

---

## Printer Compatibility

### Supported Receipt Widths:
- ✅ 58mm thermal printers (default)
- ✅ 80mm thermal printers
- ✅ ESC/POS compatible printers

### Font Sizes Used:
- **Store Name**: Size 2x2 (large)
- **Receipt Title**: Size 2x2 (large)
- **Total Amount**: Size 2x2 (large)
- **Thank You**: Size 2x2 (large)
- **Regular Text**: Size 1x1 (normal)
- **Footer**: Font B (small)

---

## Testing Checklist

After making changes, test the following:

### Store Name Display:
- [ ] Store name appears at top of receipt
- [ ] Name is in UPPERCASE
- [ ] Name is large and bold
- [ ] Matches Business Settings exactly

### Store Contact Info:
- [ ] Address displays correctly
- [ ] Phone number displays correctly
- [ ] All info centered and readable

### Footer Branding:
- [ ] "Powered by Dynamos POS" appears at bottom
- [ ] Text is centered
- [ ] Text is smaller than main content
- [ ] Appears after QR code

### Overall Receipt:
- [ ] All sections print correctly
- [ ] No formatting issues
- [ ] Text alignment correct
- [ ] QR code scannable
- [ ] Receipt cuts properly

---

## Customization Options

### Future Enhancements:
- [ ] Custom footer messages from settings
- [ ] Multiple language support
- [ ] Receipt templates
- [ ] Logo printing
- [ ] Custom receipt colors
- [ ] Social media links
- [ ] Website URL
- [ ] Promotional messages

---

## Configuration Examples

### Example 1: Restaurant
```
Store Name: Dynamos Restaurant
Address: 123 Main Street, Lusaka
Phone: +260 123 456 789
Footer: Powered by Dynamos POS
```

### Example 2: Retail Store
```
Store Name: Dynamos Supermarket
Address: Plot 456, Cairo Road
Phone: +260 987 654 321
Footer: Powered by Dynamos POS
```

### Example 3: Coffee Shop
```
Store Name: Dynamos Coffee
Address: 789 Independence Ave
Phone: +260 555 123 456
Footer: Powered by Dynamos POS
```

---

## Troubleshooting

### Store name doesn't appear:
**Solution:**
1. Check Business Settings has store name filled
2. Verify `BusinessSettingsController` is initialized
3. Restart the app if needed

### Old store name still showing:
**Solution:**
1. Update store name in Business Settings
2. Click Save
3. Print new receipt (old receipts keep original data)

### Footer not showing:
**Solution:**
1. Check printer has enough paper
2. Verify receipt cuts at correct position
3. Test with different printer if issue persists

---

## Related Documentation

- `SETTINGS_OVERVIEW.md` - Business Settings guide
- `PRINTER_CONFIGURATION_GUIDE.md` - Printer setup
- `BLUETOOTH_PRINTER_SCANNING.md` - Bluetooth setup

---

*Last Updated: Receipt branding and store name integration from Business Settings*
