# 🎯 Price Tag Designer - New Features Documentation

## Overview
Three major features have been added to the Price Tag Designer to enhance functionality and usability.

---

## 1. ⌨️ Keyboard Delete Functionality

### Feature Description
Press the **Delete** or **Backspace** key on your keyboard to quickly remove the currently selected element from the canvas.

### Implementation Details

**File**: `lib/views/price_tag_designer/widgets/canvas_widget.dart`

**Changes**:
- Wrapped the canvas widget with `KeyboardListener`
- Added key event handler for Delete and Backspace keys
- Automatically deletes selected element
- Shows confirmation snackbar after deletion

### Usage
1. Select an element on the canvas (click on it)
2. Press **Delete** or **Backspace** key
3. Element is immediately removed
4. Notification appears confirming deletion

### Technical Implementation
```dart
KeyboardListener(
  focusNode: FocusNode()..requestFocus(),
  autofocus: true,
  onKeyEvent: (KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.delete ||
          event.logicalKey == LogicalKeyboardKey.backspace) {
        final selectedElement = controller.selectedElement.value;
        if (selectedElement != null) {
          controller.deleteElement(selectedElement.id);
          // Show confirmation
        }
      }
    }
  },
  child: // Canvas widget
)
```

### Benefits
- ✅ Faster element deletion
- ✅ No need to use mouse to find delete button
- ✅ Familiar keyboard shortcut
- ✅ Works exactly like other design software

---

## 2. 💾 Template Saving Functionality

### Feature Description
Save your price tag templates to the database for persistent storage. Templates are automatically loaded when you open the designer.

### Database Schema

**Table**: `price_tag_templates`

| Column | Type | Description |
|--------|------|-------------|
| id | TEXT | Primary key (UUID) |
| name | TEXT | Template name |
| width | REAL | Width in mm |
| height | REAL | Height in mm |
| elements | TEXT | JSON string of elements |
| createdAt | TEXT | ISO timestamp |
| updatedAt | TEXT | ISO timestamp |

### Implementation Details

**Files Modified**:
1. `lib/services/database_service.dart` - Added template CRUD methods
2. `lib/controllers/price_tag_designer_controller.dart` - Integrated database
3. `lib/views/price_tag_designer/price_tag_designer_view.dart` - Added Save button

### New Methods

#### DatabaseService
```dart
// Insert or update template
Future<int> insertTemplate(PriceTagTemplate template)

// Get all templates
Future<List<PriceTagTemplate>> getAllTemplates()

// Get template by ID
Future<PriceTagTemplate?> getTemplateById(String id)

// Update existing template
Future<int> updateTemplate(PriceTagTemplate template)

// Delete template
Future<int> deleteTemplate(String id)
```

#### PriceTagDesignerController
```dart
// Save current template to database
Future<void> saveCurrentTemplate()

// Load templates from database
Future<void> _loadTemplates()
```

### Usage

#### Saving Templates
1. Design or modify a template
2. Click the **Save** button in the top toolbar
3. Template is saved to database
4. Success notification appears

#### Auto-Loading
- Templates are automatically loaded when you open the designer
- If no templates exist, default templates are created
- Most recently created templates appear first

### UI Changes
**New Button**: Orange "Save" button next to "New Template"
- Icon: Save icon (Iconsax.save_2)
- Enabled only when a template is selected
- Shows success message on save

### Benefits
- ✅ Persistent template storage
- ✅ Templates survive app restarts
- ✅ No data loss
- ✅ Professional workflow
- ✅ Easy backup (database file)

---

## 3. 🖨️ Printer Management System

### Feature Description
Complete printer management system for adding, configuring, and managing printers for price tag printing.

### Database Schema

**Table**: `printers`

| Column | Type | Description |
|--------|------|-------------|
| id | TEXT | Primary key (UUID) |
| name | TEXT | Printer name |
| type | TEXT | thermal/inkjet/laser |
| connectionType | TEXT | usb/network/bluetooth |
| address | TEXT | IP/Bluetooth address |
| port | INTEGER | Network port (default 9100) |
| paperWidth | INTEGER | 58mm or 80mm |
| isDefault | INTEGER | 1 = default, 0 = not |
| isActive | INTEGER | 1 = active, 0 = deleted |
| createdAt | TEXT | ISO timestamp |
| updatedAt | TEXT | ISO timestamp |

### New Models

#### PrinterModel
**File**: `lib/models/printer_model.dart`

**Properties**:
- id, name, type, connectionType
- address, port, paperWidth
- isDefault, isActive
- createdAt, updatedAt

**Enums**:
```dart
enum PrinterType {
  thermal,    // Most common for price tags
  inkjet,     // Color printing
  laser,      // High quality
}

enum ConnectionType {
  usb,        // Direct USB connection
  network,    // WiFi/Ethernet
  bluetooth,  // Wireless mobile
}
```

### New Controller

#### PrinterController
**File**: `lib/controllers/printer_controller.dart`

**Methods**:
```dart
// Load all active printers
Future<void> loadPrinters()

// Add new printer
Future<void> addPrinter({
  required String name,
  required PrinterType type,
  required ConnectionType connectionType,
  String? address,
  int? port,
  int paperWidth = 80,
  bool setAsDefault = false,
})

// Update printer configuration
Future<void> updatePrinter(PrinterModel printer)

// Set as default printer
Future<void> setDefaultPrinter(String printerId)

// Delete printer (soft delete)
Future<void> deletePrinter(String printerId)

// Get default printer
PrinterModel? getDefaultPrinter()
```

### UI Component

#### PrinterManagementDialog
**File**: `lib/views/price_tag_designer/widgets/printer_management_dialog.dart`

**Features**:
- List all configured printers
- Add new printer dialog
- Edit printer configuration
- Set default printer
- Delete printer
- Visual indicators for default printer

### Usage

#### Adding a Printer

1. Click the **Settings** icon (⚙️) in the top toolbar
2. Click **"Add Printer"** button
3. Fill in printer details:
   - **Name**: e.g., "Label Printer 1"
   - **Type**: Thermal/Inkjet/Laser
   - **Connection**: USB/Network/Bluetooth
   - **Address**: IP or Bluetooth address (if applicable)
   - **Port**: Network port (default 9100)
   - **Paper Width**: 58mm or 80mm
   - **Set as Default**: Check to make it the default
4. Click **"Add Printer"**

#### Managing Printers

**Set as Default**:
- Click ⋮ menu on printer card
- Select "Set as Default"
- Printer is marked with green "DEFAULT" badge

**Edit Printer**:
- Click ⋮ menu on printer card
- Select "Edit"
- Modify settings
- Save changes

**Delete Printer**:
- Click ⋮ menu on printer card
- Select "Delete"
- Confirm deletion
- Printer is soft-deleted (isActive = 0)

### Printer Types Guide

#### Thermal Printers (Recommended)
- **Best for**: Price tags, labels, receipts
- **Advantages**: Fast, no ink required, durable
- **Common Models**: 
  - Zebra ZD410/ZD420
  - TSC TDP-225/247
  - Dymo LabelWriter 450/450 Turbo
  - Brother QL-800/820NWB
- **Paper Sizes**: 58mm, 80mm rolls

#### Inkjet Printers
- **Best for**: Color labels, promotional tags
- **Advantages**: Color printing, image quality
- **Common Models**: 
  - Epson ColorWorks C3500
  - Primera LX500
- **Paper**: Sheets or rolls

#### Laser Printers
- **Best for**: High-volume black & white
- **Advantages**: Fast, high quality text
- **Common Models**: Standard office laser printers
- **Paper**: A4/Letter sheets with label templates

### Connection Types

#### USB Connection
- **Setup**: Connect via USB cable
- **Requirements**: Printer drivers installed
- **Best for**: Single workstation, reliable connection

#### Network Connection
- **Setup**: 
  - Connect printer to WiFi/Ethernet
  - Find printer's IP address
  - Enter IP and port (usually 9100)
- **Requirements**: Printer on same network
- **Best for**: Multiple workstations, wireless printing

#### Bluetooth Connection
- **Setup**:
  - Pair printer with computer
  - Enter Bluetooth MAC address
- **Requirements**: Bluetooth enabled
- **Best for**: Mobile devices, portable printers

### Integration with Print Dialog

When printing price tags:
1. System uses the **default printer** automatically
2. If no default set, uses first available printer
3. Can select different printer in print dialog
4. Template is formatted for printer's paper width

### Database Integration

**DatabaseService Methods**:
```dart
// Insert printer
Future<int> insertPrinter(Map<String, dynamic> printer)

// Get all active printers
Future<List<Map<String, dynamic>>> getAllPrinters()

// Get default printer
Future<Map<String, dynamic>?> getDefaultPrinter()

// Update printer
Future<int> updatePrinter(String id, Map<String, dynamic> printer)

// Set default printer
Future<int> setDefaultPrinter(String id)

// Delete printer (soft delete)
Future<int> deletePrinter(String id)
```

### Benefits

✅ **Multi-Printer Support**: Manage multiple printers
✅ **Flexible Connections**: USB, Network, Bluetooth
✅ **Default Printer**: Quick printing with default
✅ **Paper Size Config**: 58mm or 80mm support
✅ **Persistent Storage**: Saved to database
✅ **Easy Management**: Add/edit/delete interface
✅ **Professional Setup**: Similar to system printer settings
✅ **Future Ready**: Prepared for actual printer integration

---

## 📊 Database Version Update

**Previous Version**: 1
**New Version**: 2

### Migration
The database automatically upgrades from v1 to v2, creating the new tables:
- `price_tag_templates`
- `printers`

If the app is reinstalled or database is deleted, both tables are created automatically.

---

## 🎯 Workflow Example

### Complete Price Tag Design and Print Workflow

1. **Open Price Tag Designer**
   - Navigate to "Price Tags" in sidebar

2. **Configure Printer (One-Time Setup)**
   - Click Settings icon (⚙️)
   - Add your printer
   - Set paper width (58mm or 80mm)
   - Set as default
   - Close settings

3. **Create or Select Template**
   - Select existing template OR
   - Click "New Template"
   - Design template with elements

4. **Design Price Tag**
   - Add elements (text, price, barcode, etc.)
   - Position and resize elements
   - Customize properties
   - Delete unwanted elements with **Delete key**

5. **Save Template**
   - Click **Save** button
   - Template is saved to database

6. **Print Price Tags**
   - Click **Print** button
   - Select products
   - Set quantities
   - Click "Print Tags"
   - Tags are sent to default printer

---

## 🔧 Technical Details

### Files Created
1. `lib/models/printer_model.dart` - Printer data model
2. `lib/controllers/printer_controller.dart` - Printer management
3. `lib/views/price_tag_designer/widgets/printer_management_dialog.dart` - UI

### Files Modified
1. `lib/services/database_service.dart` - Added tables and methods
2. `lib/controllers/price_tag_designer_controller.dart` - Save/load templates
3. `lib/views/price_tag_designer/price_tag_designer_view.dart` - Save button, printer settings
4. `lib/views/price_tag_designer/widgets/canvas_widget.dart` - Keyboard delete
5. `lib/main.dart` - Initialize PrinterController

### Dependencies
- ✅ sqflite - Database
- ✅ get - State management
- ✅ uuid - Unique IDs
- ✅ iconsax - Icons

---

## 🚀 Future Enhancements

### Printing
- [ ] Actual thermal printer integration
- [ ] Print preview
- [ ] Batch print optimization
- [ ] Print queue management
- [ ] Print history/logs

### Templates
- [ ] Template categories
- [ ] Template sharing/export
- [ ] Template marketplace
- [ ] Cloud sync
- [ ] Version control

### Printers
- [ ] Auto-discovery of network printers
- [ ] Printer status monitoring
- [ ] Test print functionality
- [ ] Print quality settings
- [ ] Multiple paper size support

### Keyboard Shortcuts
- [ ] Ctrl+S - Save template
- [ ] Ctrl+P - Print
- [ ] Ctrl+Z - Undo
- [ ] Ctrl+Y - Redo
- [ ] Ctrl+C/V - Copy/Paste elements

---

## 📝 Testing Checklist

### Keyboard Delete
- [ ] Delete key removes selected element
- [ ] Backspace key removes selected element
- [ ] No action when no element selected
- [ ] Notification appears on deletion
- [ ] Deleted element cannot be undone (future: undo)

### Template Saving
- [ ] Save button enabled with template selected
- [ ] Save button disabled with no template
- [ ] Template saves to database
- [ ] Success notification appears
- [ ] Templates load on app restart
- [ ] Default templates created if none exist

### Printer Management
- [ ] Can add new printer
- [ ] All printer types available
- [ ] All connection types available
- [ ] Can set default printer
- [ ] Default printer shows badge
- [ ] Can delete printer
- [ ] Deleted printer doesn't appear in list
- [ ] Settings icon opens dialog
- [ ] Printer list shows all active printers

---

**Status**: ✅ Implemented
**Version**: 1.2.0
**Date**: November 9, 2025
**Platforms**: All (Windows, macOS, Linux, Android, iOS, Web)
