# Printer Configuration Guide

## Overview
The POS system now supports printer configuration on **all platforms** including Windows, macOS, Linux, Web, Android, and iOS.

---

## 🖨️ Printer Configuration Options

### System Settings → Printer Configuration

This section is now available on **ALL platforms** and provides a universal way to configure your receipt printer.

---

## Configuration Steps

### 1. **Access Printer Configuration**
   - Navigate to: **Settings → System Tab**
   - Locate the **"Printer Configuration"** section

### 2. **Check Current Status**
   The status indicator shows:
   - 🟢 **Green**: Printer is configured
   - 🟠 **Orange**: No printer configured

### 3. **Add/Configure Printer**
   Click the **"Add Printer"** or **"Configure Printer"** button

### 4. **Fill in Printer Details**

#### **Printer Name** (Required)
   - Friendly name for your printer
   - Example: "Main Counter Printer", "Kitchen Printer", "Receipt Printer 1"

#### **Connection Type** (Required)
   Choose from:
   - **USB**: Direct USB connection
   - **Network**: TCP/IP network printer
   - **Bluetooth**: Bluetooth thermal printer

#### **Additional Fields** (Based on Connection Type)

##### For Network Printers:
   - **IP Address**: Printer's IP address (e.g., `192.168.1.100`)
   - **Port**: Network port (default: `9100` for most thermal printers)

##### For Bluetooth Printers:
   - **Bluetooth Address**: MAC address (e.g., `00:11:22:33:44:55`)
   - Find this in:
     - Windows: Bluetooth & Devices → View more devices → Right-click printer → Properties
     - Mac: System Preferences → Bluetooth → Advanced
     - Android/iOS: Use Bluetooth scanning feature

##### For USB Printers:
   - **Device Path** (Optional): 
     - Windows: `COM3`, `COM4`, etc.
     - Mac/Linux: `/dev/usb/lp0`, `/dev/ttyUSB0`, etc.

### 5. **Save Configuration**
   Click **"Save Configuration"** to store the settings

---

## Platform-Specific Features

### 🪟 Windows
- ✅ Full manual configuration support
- ✅ USB, Network, and Bluetooth printers
- ✅ Configuration saved to local storage
- ℹ️ Bluetooth address must be entered manually

### 🍎 macOS
- ✅ Full manual configuration support
- ✅ USB, Network, and Bluetooth printers
- ✅ Configuration saved to local storage
- ℹ️ Bluetooth address must be entered manually

### 🐧 Linux
- ✅ Full manual configuration support
- ✅ USB, Network, and Bluetooth printers
- ✅ Configuration saved to local storage

### 📱 Android & iOS
- ✅ Full manual configuration support
- ✅ **Bluetooth scanning feature** (automatic device discovery)
- ✅ USB, Network, and Bluetooth printers
- ✅ One-click connect to scanned devices

### 🌐 Web
- ✅ Network printer configuration
- ⚠️ USB and Bluetooth limited by browser capabilities
- ✅ Configuration saved to browser storage

---

## Connection Examples

### Example 1: USB Printer
```
Printer Name: Main Receipt Printer
Connection Type: USB
Device Path: COM3 (Windows) or /dev/usb/lp0 (Linux)
```

### Example 2: Network Printer
```
Printer Name: Counter Printer 1
Connection Type: Network
IP Address: 192.168.1.100
Port: 9100
```

### Example 3: Bluetooth Printer
```
Printer Name: Mobile Receipt Printer
Connection Type: Bluetooth
Bluetooth Address: 00:11:22:33:44:55
```

---

## How to Find Printer Information

### Finding IP Address (Network Printers)

#### Method 1: Print Configuration Page
1. Most printers can print a configuration page
2. Look for "Network Settings" or "TCP/IP" section
3. Note the IP address

#### Method 2: Router Admin Panel
1. Access your router's admin panel (usually `192.168.1.1`)
2. Look for "Connected Devices" or "DHCP Client List"
3. Find your printer by name or MAC address

#### Method 3: Printer Display (if available)
1. Navigate to Network Settings on printer
2. Look for IP Address display

### Finding Bluetooth Address

#### Windows:
1. Open **Settings → Bluetooth & devices**
2. Click **"View more devices"**
3. Find your printer
4. Right-click → **Properties**
5. Look for "Unique identifier" or "Address"

#### macOS:
1. Open **System Preferences → Bluetooth**
2. Option+Click on Bluetooth icon in menu bar
3. Find your printer in the list
4. Address will be shown

#### Android:
1. Open **Settings → Connected devices → Bluetooth**
2. Tap gear icon next to paired device
3. Address shown at bottom

#### iOS:
- iOS doesn't show Bluetooth addresses directly
- Use a third-party Bluetooth scanner app
- Or check printer documentation

### Finding USB Port (USB Printers)

#### Windows:
1. Open **Device Manager**
2. Expand **"Ports (COM & LPT)"**
3. Look for your printer (e.g., "USB Serial Port (COM3)")

#### macOS/Linux:
```bash
# List USB devices
ls /dev/tty*
ls /dev/usb/*

# Look for entries like:
# /dev/ttyUSB0
# /dev/usb/lp0
```

---

## Troubleshooting

### ❌ "Printer Not Responding"
- **Network**: Check IP address and port are correct
- **USB**: Verify device path and permissions
- **Bluetooth**: Ensure printer is paired and in range

### ❌ "Connection Failed"
- **Network**: Ping the IP address to test connectivity
- **Firewall**: Check if port 9100 is blocked
- **Bluetooth**: Re-pair the device

### ❌ "Configuration Not Saved"
- Check that all required fields are filled
- Ensure printer name is not empty
- Try refreshing the page/app

---

## Advanced Features

### Multiple Printers
You can configure different printers for different purposes:
- **System Settings → Printer Configuration**: Receipt printer for transactions
- **Business Settings → Receipt Printer**: Alternative receipt printer config
- **Price Tag Designer → Printer Management**: Label printers for price tags

### Default Printer
The printer configured in System Settings is used by default for transaction receipts.

### Testing Connection
After configuration, test the connection by:
1. Processing a test transaction
2. Using the print preview feature
3. Printing a test receipt from Business Settings

---

## Best Practices

### 🎯 Naming Convention
Use descriptive names:
- ✅ "Counter 1 Receipt Printer"
- ✅ "Kitchen Order Printer"
- ❌ "Printer" or "Test"

### 🔒 Network Security
For network printers:
- Use static IP addresses (not DHCP)
- Keep printers on internal network
- Use firewall rules to restrict access

### 📋 Documentation
Keep a record of:
- Printer make and model
- IP addresses or device paths
- Configuration date
- Bluetooth MAC addresses

### 🔄 Regular Testing
- Test print weekly
- Check connection after network changes
- Verify settings after system updates

---

## Technical Details

### Storage
- Configuration stored in **GetStorage** (local key-value storage)
- Persists across app restarts
- Backed up with app data

### Keys Stored
```dart
receipt_printer_name: String
receipt_printer_type: String (USB/Network/Bluetooth)
receipt_printer_address: String (IP or Bluetooth MAC)
receipt_printer_port: String (Port number for network)
```

### Controller
Managed by `BusinessSettingsController`:
- `.receiptPrinterName` - Observable string
- `.receiptPrinterType` - Observable string
- `.receiptPrinterAddress` - Observable string
- `.receiptPrinterPort` - Observable string

---

## Mobile Bluetooth Scanning (Android/iOS Only)

### Automatic Device Discovery
On mobile devices, you can:
1. Click **"Scan for Printers"**
2. Wait for Bluetooth devices to appear
3. Click **"Connect"** next to your printer
4. Configuration is saved automatically

### Requirements
- Bluetooth must be enabled
- Printer must be in pairing mode
- Location permission granted (Android)

---

## Printing Support

### Supported Printer Types
- ✅ ESC/POS thermal printers (58mm, 80mm)
- ✅ Star Micronics printers
- ✅ Epson TM series
- ✅ Any printer supporting ESC/POS commands

### Supported Formats
- Receipt printing (transactions)
- Custom receipt templates
- Logo printing (if configured)
- QR codes and barcodes
- Text formatting (bold, underline, alignment)

---

## Future Enhancements
- [ ] Auto-detect USB printers on Windows
- [ ] Network printer discovery (Bonjour/mDNS)
- [ ] Test print button in configuration dialog
- [ ] Print quality settings
- [ ] Multiple default printers per terminal
- [ ] Cloud printer support

---

*Last Updated: Universal printer configuration for all platforms*
