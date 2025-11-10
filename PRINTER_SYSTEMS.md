# Printer Systems Documentation

This application has **two separate printer systems** for different purposes:

## 1. Receipt Printer (Transaction Receipts)
**Location:** Business Settings → Receipt Settings section  
**Purpose:** Printing transaction receipts at checkout  
**Controller:** `BusinessSettingsController`  
**Storage:** GetStorage (local key-value storage)

### Configuration Fields:
- **Printer Name**: Friendly name for the receipt printer
- **Connection Type**: USB, Network, or Bluetooth
- **IP Address**: For network printers (e.g., 192.168.1.100)
- **Port**: For network printers (default: 9100)
- **Bluetooth Address**: For Bluetooth printers (e.g., 00:11:22:33:44:55)

### Receipt Formatting Settings:
- Receipt header text
- Receipt footer text
- Receipt width (58mm or 80mm)
- Show logo on receipt
- Show tax breakdown

### Access:
Navigate to: **Settings → Business Settings → Scroll to Receipt Settings**

---

## 2. Label Printer (Price Tags)
**Location:** Price Tag Designer → Settings icon  
**Purpose:** Printing price tags and labels for products  
**Controller:** `PrinterController`  
**Storage:** SQLite database (printers table)

### Features:
- Full CRUD operations (Create, Read, Update, Delete)
- Multiple printer support
- Default printer selection
- Printer types: Thermal, Inkjet, Laser
- Connection types: USB, Network, Bluetooth

### Configuration Fields:
- Printer name
- Printer type (Thermal/Inkjet/Laser)
- Connection type (USB/Network/Bluetooth)
- Model
- Status (Active/Inactive)
- Default printer flag

### Access:
Navigate to: **Price Tag Designer → Settings Icon (top-right) → Printer Management**

---

## Key Differences

| Aspect | Receipt Printer | Label Printer |
|--------|----------------|---------------|
| **Purpose** | Transaction receipts | Price tags/labels |
| **Location** | Business Settings | Price Tag Designer |
| **Quantity** | Single printer | Multiple printers |
| **Storage** | GetStorage | SQLite database |
| **Controller** | BusinessSettingsController | PrinterController |
| **Management** | Simple configuration form | Full CRUD interface |

---

## Why Two Systems?

1. **Different Use Cases**: Receipt printers are used at checkout for customer receipts, while label printers are used for product labeling and price tags.

2. **Different Requirements**: 
   - Receipt printing needs system-wide configuration (one printer per store/terminal)
   - Label printing may require multiple printers for different label sizes/types

3. **Different Access Patterns**:
   - Receipt printer settings are rarely changed (system configuration)
   - Label printers may be managed frequently (different label templates need different printers)

4. **Separation of Concerns**: Keeps business settings focused on store-wide configurations while designer tools manage their own resources.

---

## Usage Guidelines

### For Receipt Printing:
1. Go to **Settings → Business Settings**
2. Scroll to **Receipt Settings** section
3. Configure your receipt printer in the **Receipt Printer Configuration** subsection
4. Select connection type (USB/Network/Bluetooth)
5. Enter connection details if needed (IP for network, MAC for Bluetooth)
6. Save settings

### For Label Printing:
1. Open **Price Tag Designer**
2. Click **Settings icon** (gear icon in top-right)
3. Click **Printer Management**
4. Add, edit, or remove label printers as needed
5. Set a default printer
6. Use the printer when printing price tags

---

## Implementation Notes

### Receipt Printer Storage Keys:
```dart
- 'receipt_printer_name'
- 'receipt_printer_type'
- 'receipt_printer_address'
- 'receipt_printer_port'
```

### Label Printer Database Table:
```sql
CREATE TABLE printers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  connection_type TEXT NOT NULL,
  model TEXT,
  status TEXT,
  is_default INTEGER DEFAULT 0,
  created_at TEXT
)
```

---

## Future Enhancements

### Receipt Printer:
- [ ] Test printer connection button
- [ ] Print test receipt
- [ ] Auto-detect USB printers
- [ ] Network printer discovery

### Label Printer:
- [ ] Printer templates/profiles
- [ ] Label size presets per printer
- [ ] Print queue management
- [ ] Batch printing optimization

---

*Last Updated: Implementation of separate receipt and label printer systems*
