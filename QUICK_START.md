# Quick Start Guide - Dynamos POS

## Installation & Running

### Windows
```powershell
# Navigate to project directory
cd c:\pos_software

# Get dependencies
flutter pub get

# Run on Windows
flutter run -d windows
```

### macOS
```bash
cd /path/to/pos_software
flutter pub get
flutter run -d macos
```

### Linux
```bash
cd /path/to/pos_software
flutter pub get
flutter run -d linux
```

### Web
```bash
flutter pub get
flutter run -d chrome
```

### Android/iOS
```bash
flutter pub get
flutter run  # Will prompt to select device
```

## First Time Setup

No setup required! The app comes with dummy data pre-loaded:
- 12 sample products
- 8 sample customers
- 50 generated transactions

## Quick Navigation

| Page | Shortcut | Description |
|------|----------|-------------|
| Dashboard | First icon (Grid) | Sales overview & analytics |
| Transactions | Receipt icon | POS/Checkout interface |
| Customers | People icon | Customer management |
| Inventory | Box icon | Product management |
| Reports | Chart icon | Sales reports & insights |
| Settings | Gear icon | App configuration |

## Common Tasks

### Make a Sale
1. Click **Transactions** (Receipt icon)
2. Click product cards to add to cart
3. Adjust quantities with +/- buttons
4. Click **Checkout**
5. Select payment method
6. Click **Complete**

### Add a Product
1. Go to **Inventory**
2. Click **+ Add Product** (bottom right)
3. Fill in:
   - Product Name
   - Description
   - Price
   - Category
   - Image URL
4. Click **Add Product**

### Add a Customer
1. Go to **Customers**
2. Click **+ Add Customer** (bottom right)
3. Fill in:
   - Name
   - Email
   - Phone Number
4. Click **Add Customer**

### View Sales Report
1. Go to **Dashboard** or **Reports**
2. Charts and stats load automatically
3. Scroll to see all metrics

## Features at a Glance

### Dashboard
- Today's Sales: Real-time revenue
- Monthly Sales: Current month total
- Customer Count: Total customers
- Product Count: Total inventory
- Sales Chart: 7-day trend
- Top Products: Best sellers
- Recent Transactions: Latest sales

### POS (Transactions)
- Product Grid: Visual catalog
- Search: Find products quickly
- Category Filter: Filter by type
- Cart: Item management
- Customer Select: Assign to transaction
- Discount: Apply discounts
- Payment Methods: Cash/Card/Mobile/Other

### Customers
- List View: All customers
- Search: By name/email/phone
- Add: Create new customers
- Edit: Update information
- Delete: Remove customers

### Inventory
- List View: All products
- Search: Find products
- Category Filter: By category
- Add: Create products
- Edit: Update details
- Delete: Remove products
- Status: Available/Out of Stock

### Reports
- Revenue Stats: Total & average
- Transaction Count: Monthly
- Sales Trend: Line chart
- Category Breakdown: Performance %
- Transaction List: Recent sales

### Settings
- Store Info: Name, address, contact
- Business: Tax rate, currency
- Appearance: Dark mode toggle
- Security: Password, 2FA
- Data: Backup, export, clear

## Tips & Tricks

1. **Quick Add to Cart**: Click any product card in Transactions view
2. **Search Everything**: Use search bars to quickly find items
3. **Filter Products**: Use category dropdown for faster browsing
4. **Customer Assignment**: Select customer before checkout for tracking
5. **Discount**: Apply discounts before completing checkout
6. **Dashboard Refresh**: Pull down or click Refresh button
7. **Sidebar Toggle**: Click arrow to collapse/expand sidebar

## Keyboard Shortcuts (Planned)

- `Ctrl+1`: Dashboard
- `Ctrl+2`: Transactions
- `Ctrl+3`: Customers
- `Ctrl+4`: Inventory
- `Ctrl+5`: Reports
- `Ctrl+,`: Settings
- `Esc`: Close dialogs
- `Enter`: Confirm actions

## Sample Data

### Products Available
- **Beverages**: Espresso ($3.50), Cappuccino ($4.50), Latte ($4.00), Green Tea ($2.50)
- **Food**: Croissant ($3.00), Sandwich ($6.50), Salad ($7.50), Burger ($8.99)
- **Electronics**: Wireless Mouse ($24.99), USB Cable ($12.99), Headphones ($79.99), Power Bank ($29.99)

### Sample Customers
- John Doe (john.doe@email.com)
- Jane Smith (jane.smith@email.com)
- Bob Johnson (bob.j@email.com)
- Alice Williams (alice.w@email.com)
- And 4 more...

## Troubleshooting

### App won't build
```bash
flutter clean
flutter pub get
flutter run
```

### Dependencies issue
```bash
flutter pub upgrade
```

### Platform not available
```bash
# Check available devices
flutter devices

# Enable platform
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop
flutter config --enable-web
```

### Hot reload not working
Press `r` in terminal or `R` for hot restart

## Development Mode

The app runs in debug mode by default. For production builds:

```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release

# Web
flutter build web --release

# Android
flutter build apk --release
# or
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Data Persistence

⚠️ **Important**: Current version uses in-memory data
- Data resets on app restart
- No persistence between sessions
- Perfect for testing/demo

To add persistence, integrate:
- SQLite for local storage
- Firebase for cloud storage
- REST API for backend

## Support

### Documentation
- README.md: Full project documentation
- PROJECT_SUMMARY.md: Technical overview
- This file: Quick start guide

### Issues
Report bugs or request features in the repository

### Contact
Email: contact@dynamospos.com

## What's Next?

### Learning More
1. Explore the Dashboard to understand metrics
2. Try making several sales in Transactions
3. Add your own products and customers
4. View how Reports update with new data

### Customizing
1. Change app name in `constants.dart`
2. Update colors in `colors.dart`
3. Modify tax rate in `cart_controller.dart`
4. Add your store logo and info

### Integrating Backend
1. Replace `DummyApiService` with real API
2. Add authentication
3. Implement data persistence
4. Configure payment gateways

---

**Ready to go! Start with the Dashboard and explore from there.** 🚀
