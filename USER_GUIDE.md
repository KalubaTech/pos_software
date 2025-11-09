# 🚀 Quick Start Guide - POS Software

## Installation

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run the Application
```bash
flutter run -d windows
```
Or select your target device in VS Code and press F5.

## First Launch

### Login Screen
When you first launch the app, you'll see the cashier login screen.

**Quick Login Options:**
- **Admin** - Click the Admin card or enter PIN: `1234`
- **John (Manager)** - Enter PIN: `1111`
- **Sarah (Cashier)** - Enter PIN: `2222`
- **Mike (Cashier)** - Enter PIN: `3333`

## Main Features Tour

### 1. Dashboard 📊
- Overview of today's sales
- Recent transactions
- Quick statistics
- Sales charts

### 2. POS/Transactions 🛒
**Process a Sale:**
1. Browse or search for products
2. Click product to add to cart
3. Adjust quantities using +/- buttons
4. Optional: Add customer
5. Click **"Checkout"** button

**Checkout Process:**
1. Select payment method (Cash/Card/Mobile/Other)
2. For cash payments: Enter amount received
3. System calculates change automatically
4. Toggle **"Print Receipt"** if printer is connected
5. Click **"Complete Payment"**
6. View success message with change (if cash)

**Barcode Scanning:**
1. Click floating **"Scan Barcode"** button (bottom right)
2. Mock scanner will add a random product
3. Product appears in cart instantly
4. For production: Replace with real barcode scanner

### 3. Customers 👥
- View all customers
- Search by name/email/phone
- Add new customers
- Edit customer details
- View customer purchase history

### 4. Inventory 📦
- Browse all products
- Search and filter by category
- Add new products
- Edit product details
- Update stock levels
- View low stock alerts

### 5. Reports 📈
- Sales reports
- Transaction history
- Customer analytics
- Product performance
- Date range filtering

### 6. Settings ⚙️

#### Printer Setup (All Roles)
1. Go to Settings → Printer Configuration
2. Click **"Scan for Printers"**
3. Wait for Bluetooth printers to appear
4. Click **"Connect"** on your printer
5. See connection status turn green
6. Receipts will now print automatically on checkout

**Disconnect Printer:**
- Click **"Disconnect"** button in Printer Configuration

#### Cashier Management (Admin Only)
**Add New Cashier:**
1. Go to Settings → Cashier Management
2. Click **"+"** icon
3. Enter full name
4. Enter 4-digit PIN
5. Select role (Admin/Manager/Cashier)
6. Click **"Add Cashier"**

**Edit Cashier:**
1. Click three-dot menu on cashier
2. Select **"Edit"**
3. Update name, role, or active status
4. Click **"Save Changes"**

**Delete Cashier:**
1. Click three-dot menu on cashier
2. Select **"Delete"**
3. Confirm deletion

**Status:**
- **Active (Green)**: Cashier can log in
- **Inactive (Gray)**: Cashier cannot log in

#### Other Settings
- Store information
- Tax rate
- Currency
- Receipt template
- Business hours
- Dark mode
- Theme color

## Cashier Roles & Permissions

### 🔴 Admin
- Full system access
- Manage cashiers (add/edit/delete)
- Configure all settings
- View all reports
- Process transactions

### 🟠 Manager
- Configure settings (except cashier management)
- View all reports
- Manage inventory
- Process transactions

### 🔵 Cashier
- Process transactions
- View products
- Add customers
- Basic operations only

## Top Navigation Bar

The top bar shows:
- **Current Cashier:** Avatar + Name
- **Role Badge:** Admin/Manager/Cashier
- **Logout Button:** Quick logout

**To Logout:**
1. Click **"Logout"** button in top right
2. Returns to login screen
3. Session cleared

## Tips & Tricks

### Faster Checkout
1. Use barcode scanner for quick product entry
2. Use quick login cards for fast cashier switching
3. Keep commonly used payment method selected

### Receipt Printing
- Connect printer once at start of day
- Printer stays connected until disconnected
- Print receipt option remembered per session

### Customer Management
- Use "Walk-in Customer" for quick sales
- Add regular customers to build database
- Search by any field (name/email/phone)

### Inventory
- Set low stock alerts
- Regular stock updates
- Use categories for quick filtering

## Keyboard Shortcuts

### POS Screen
- **Enter**: Focus search
- **Esc**: Clear cart
- **Ctrl+K**: Quick checkout (if cart has items)

### Login Screen
- **0-9**: Enter PIN digits
- **Backspace**: Delete last digit
- **Enter**: Submit PIN

## Troubleshooting

### Printer Not Connecting
1. Ensure Bluetooth is enabled on computer
2. Printer is in pairing mode
3. Printer is charged/powered on
4. Try scanning again
5. Restart app if needed

### Login Issues
1. Verify PIN is correct (4 digits)
2. Check if cashier is active (Admin only)
3. Clear GetStorage if persistent issues

### App Performance
1. Close unused tabs
2. Restart app daily
3. Clear old transaction data (Reports > Clear Old Data)

## Demo Data

### Products
- 12 pre-loaded products
- Various categories (Beverages, Food, Electronics, etc.)
- Realistic prices and stock levels

### Customers
- 8 sample customers
- Complete contact information
- Purchase history

### Transactions
- 50 pre-loaded transactions
- Various payment methods
- Different dates for reporting

## Support

For issues or questions:
1. Check this guide first
2. Review IMPLEMENTATION_SUMMARY.md
3. Check console for error messages
4. Review Flutter/Dart documentation

## Next Session Checklist

At start of day:
- [ ] Login with your cashier account
- [ ] Connect Bluetooth printer
- [ ] Check inventory levels
- [ ] Review pending transactions

At end of day:
- [ ] Print daily reports
- [ ] Review sales performance
- [ ] Update stock if needed
- [ ] Logout

---

**Enjoy your modern POS system! 🎉**
