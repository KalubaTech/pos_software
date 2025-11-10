# Settings System Overview

The POS software now has a comprehensive tabbed settings interface that matches your original design.

## Navigation Structure

**Access:** Navigate to Settings from the main navigation menu

The settings page uses a **TabController** with 3 tabs:

### 1. System Settings Tab 🔧
**Icon:** `Iconsax.setting_2`  
**Location:** First tab

#### Features:
- **Printer Configuration** (Bluetooth thermal printers)
  - Connection status indicator (green = connected, orange = not connected)
  - Scan for available Bluetooth printers
  - Connect/Disconnect functionality
  - Displays connected printer name
  - Beautiful card-based UI with visual status feedback

- **Cashier Management** (Admin only)
  - View all cashiers with role badges
  - Active/Inactive status indicators
  - Add new cashiers (Name, PIN, Role)
  - Edit existing cashiers (Name, Role, Active status)
  - Delete cashiers
  - Role colors:
    - 🔴 Admin = Red
    - 🟠 Manager = Orange
    - 🔵 Cashier = Blue

### 2. Business Settings Tab 🏪
**Icon:** `Iconsax.shop`  
**Location:** Second tab

#### Sections:
1. **Store Information**
   - Store name, address, phone, email
   - Tax ID
   - Store logo

2. **Tax Configuration**
   - Enable/disable tax
   - Tax rate
   - Tax name (VAT, GST, etc.)
   - Include tax in price option

3. **Currency Settings**
   - Currency selection (USD, EUR, GBP, ZMW, etc.)
   - Currency symbol
   - Symbol position (before/after)

4. **Receipt Settings**
   - Receipt header text
   - Receipt footer text
   - Receipt width (58mm/80mm)
   - Show logo option
   - Show tax breakdown option
   
   **Receipt Printer Configuration:**
   - Printer name
   - Connection type (USB/Network/Bluetooth)
   - IP Address (for network printers)
   - Port (for network printers)
   - Bluetooth address (for Bluetooth printers)
   - ⚠️ Note: This is separate from label printer

5. **Operating Hours**
   - Opening time
   - Closing time
   - Operating days selection

6. **Payment Methods**
   - Accept cash
   - Accept card
   - Accept mobile payments

### 3. Appearance Settings Tab 🎨
**Icon:** `Iconsax.brush_2`  
**Location:** Third tab

Customization options for UI appearance (theme, colors, etc.)

---

## Key Design Features

### 🎯 Consistent UI Elements
- **Header Section**: 
  - Large title (32px, bold)
  - Descriptive subtitle
  - Tab navigation bar
  - Clean white background with subtle shadow

- **Section Cards**:
  - Rounded corners (16px border radius)
  - Icon with colored background circle
  - Section title
  - Divider line
  - Content padding
  - Subtle shadow effect

- **Status Indicators**:
  - Color-coded badges (green/orange/grey)
  - Icon-based visual feedback
  - Rounded corner containers

### 🔄 Animations
Uses `animate_do` package:
- `FadeInUp` animations for sections
- Smooth transitions
- Professional polish

### 🎨 Color Scheme
- **Primary**: `AppColors.primary`
- **Success**: Green (#4CAF50)
- **Warning**: Orange (#FF9800)
- **Error**: Red (#F44336)
- **Info**: Blue (#2196F3)
- **Purple**: For cashier management (#9C27B0)

---

## Two Separate Printer Systems

### 1️⃣ Receipt Printer (System Settings → Printer Configuration)
- **Purpose**: Print transaction receipts at checkout
- **Type**: Bluetooth thermal printer
- **Management**: Simple connect/disconnect interface
- **Configuration**: Bluetooth MAC address pairing
- **Service**: `PrinterService` class
- **Storage**: GetStorage (in-memory, MAC address saved)

### 2️⃣ Label Printer (Business Settings → Receipt Printer Configuration)
- **Purpose**: Configure receipt printer for transaction receipts
- **Type**: USB/Network/Bluetooth thermal printer
- **Management**: Configuration form with connection details
- **Configuration**: Name, Type, IP/Port or Bluetooth address
- **Storage**: GetStorage (business settings)

### 3️⃣ Price Tag Printer (Price Tag Designer → Printer Management)
- **Purpose**: Print price tags and product labels
- **Type**: Thermal/Inkjet/Laser printer
- **Management**: Full CRUD interface with multiple printers
- **Configuration**: Name, Type, Model, Connection details
- **Controller**: `PrinterController` class
- **Storage**: SQLite database (`printers` table)

---

## File Structure

```
lib/views/settings/
├── enhanced_settings_view.dart      # Main tabbed settings interface
├── business_settings_view.dart      # Business configuration tab
└── appearance_settings_view.dart    # UI customization tab

lib/controllers/
├── business_settings_controller.dart  # Business settings state management
├── auth_controller.dart               # Cashier management
└── printer_controller.dart            # Label printer management

lib/services/
├── printer_service.dart              # Bluetooth thermal printer service
└── database_service.dart             # SQLite database for label printers

lib/models/
├── cashier_model.dart                # Cashier data model
└── printer_model.dart                # Label printer data model
```

---

## Permissions & Access Control

### System Settings Tab
- **Printer Configuration**: All users can view and manage
- **Cashier Management**: Admin only (role-based access control)

### Business Settings Tab
- All users can view
- Save/Reset: Admin/Manager only (recommended)

### Appearance Settings Tab
- All users can customize

---

## Usage Examples

### Adding a New Cashier (Admin)
1. Go to Settings → System tab
2. Scroll to Cashier Management
3. Click the + icon in the section header
4. Fill in:
   - Full name
   - 4-digit PIN
   - Role (Admin/Manager/Cashier)
5. Click "Add Cashier"

### Connecting Receipt Printer
1. Go to Settings → System tab
2. In Printer Configuration section
3. Click "Scan for Printers"
4. Select your printer from the list
5. Click "Connect"
6. Status indicator turns green

### Configuring Business Receipt Printer
1. Go to Settings → Business tab
2. Scroll to Receipt Settings section
3. Scroll down to "Receipt Printer Configuration"
4. Fill in printer details:
   - Printer name
   - Connection type
   - IP/Port (network) or Bluetooth address
5. Click Save at the top

### Managing Label Printers
1. Go to Price Tag Designer
2. Click Settings icon (gear) in top-right
3. Click "Printer Management"
4. Add/Edit/Delete label printers
5. Set default printer

---

## Technical Implementation

### State Management
- **GetX**: Reactive state management
- **Obx**: Observable widgets for real-time updates
- **Get.put()**: Dependency injection

### Storage
- **GetStorage**: Key-value storage for settings
- **SQLite**: Relational database for complex data

### Bluetooth Integration
- **Package**: `print_bluetooth_thermal`
- **Features**: 
  - Device scanning
  - Connection management
  - ESC/POS printing

### Animations
- **Package**: `animate_do`
- **Animations**: FadeInUp, smooth transitions

---

## Development Notes

### Adding New Settings
1. Add observable variable in controller
2. Add load/save/reset logic
3. Add UI widget in appropriate section
4. Use `Obx()` for reactive updates

### Best Practices
- Always use `Obx()` for reactive widgets
- Keep sections modular with `_build...()` methods
- Use consistent spacing (8, 12, 16, 24 pixels)
- Apply shadows to cards for depth
- Use icons for visual clarity
- Add snackbar feedback for actions

---

*Last Updated: System Settings restoration - matching original design*
