# Dynamos POS - Point of Sale System

A modern, cross-platform Point of Sale (POS) software built with Flutter. This application provides a complete solution for managing sales, inventory, customers, and business analytics with a beautiful, intuitive interface.

## Features

### 🎯 Core Features
- **Dashboard**: Real-time sales overview with charts, key metrics, and recent transactions
- **Point of Sale**: Fast checkout interface with product catalog, cart management, and multiple payment methods
- **Customer Management**: Add, edit, and track customer information
- **Inventory Management**: Manage products with categories, pricing, and availability
- **Reports & Analytics**: Comprehensive sales reports with charts and insights
- **Settings**: Configure store information, tax rates, and application preferences

### 📊 Dashboard
- Today's sales and transaction count
- Monthly revenue tracking
- Total customers and products count
- 7-day sales trend chart
- Top 5 selling products
- Recent transactions list

### 🛒 POS System
- Product catalog with search and category filters
- Visual product cards with images
- Shopping cart with quantity management
- Customer selection for transactions
- Multiple payment methods (Cash, Card, Mobile, Other)
- Discount application
- Quick checkout process

### 👥 Customer Management
- Customer list with search functionality
- Add new customers with name, email, and phone
- Edit existing customer information
- Delete customers with confirmation
- Customer selection in POS

### 📦 Inventory
- Product list with search and filters
- Add new products with details and images
- Edit product information
- Delete products with confirmation
- Category-based organization
- Stock availability status

### 📈 Reports
- Sales trend visualization
- Revenue analytics
- Transaction history
- Category performance breakdown
- Average order value tracking
- Export capabilities (planned)

## Technology Stack

- **Framework**: Flutter 3.8.1+
- **State Management**: GetX
- **UI Components**: Material Design 3
- **Charts**: FL Chart
- **Icons**: Iconsax, Phosphor Icons
- **Fonts**: Google Fonts (Inter)
- **Data**: Dummy API Service (mock data)

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── page_anchor.dart                   # Main navigation hub
├── components/
│   ├── buttons/
│   │   └── sidebar_button_item.dart   # Sidebar navigation button
│   └── navigations/
│       └── main_side_navigation_bar.dart  # Main sidebar
├── constants/
│   └── constants.dart                 # App constants
├── controllers/
│   ├── navigations_controller.dart    # Navigation state
│   ├── dashboard_controller.dart      # Dashboard logic
│   ├── product_controller.dart        # Product management
│   ├── customer_controller.dart       # Customer management
│   ├── cart_controller.dart           # Shopping cart
│   └── transaction_controller.dart    # Transaction history
├── models/
│   ├── product_model.dart             # Product data model
│   ├── client_model.dart              # Customer data model
│   ├── user_model.dart                # User data model
│   ├── store_model.dart               # Store data model
│   ├── category_model.dart            # Category data model
│   ├── cart_item_model.dart           # Cart item model
│   └── transaction_model.dart         # Transaction model
├── services/
│   └── dummy_api_service.dart         # Mock API service
├── utils/
│   └── colors.dart                    # App color scheme
└── views/
    ├── dashboard/
    │   └── dashboard_view.dart        # Dashboard page
    ├── transactions/
    │   └── transactions_view.dart     # POS interface
    ├── customers/
    │   └── customers_view.dart        # Customer management
    ├── inventory/
    │   └── inventory_view.dart        # Product management
    ├── reports/
    │   └── reports_view.dart          # Analytics & reports
    └── settings/
        └── settings_view.dart         # Settings page
```

## Installation

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK
- Windows/macOS/Linux (Desktop support)
- Android/iOS development setup (for mobile)

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd pos_software
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   
   For Windows:
   ```bash
   flutter run -d windows
   ```
   
   For macOS:
   ```bash
   flutter run -d macos
   ```
   
   For Linux:
   ```bash
   flutter run -d linux
   ```
   
   For Web:
   ```bash
   flutter run -d chrome
   ```

## Usage

### Starting the App
1. Launch the application
2. The dashboard will load with overview statistics
3. Use the sidebar to navigate between different sections

### Making a Sale
1. Navigate to "Transactions" from the sidebar
2. Browse or search for products
3. Click on products to add them to the cart
4. Adjust quantities as needed
5. Optionally select a customer
6. Click "Checkout" and select payment method
7. Complete the transaction

### Managing Products
1. Navigate to "Inventory"
2. Click "Add Product" to create new products
3. Use search and filters to find products
4. Click the menu icon on any product to edit or delete

### Managing Customers
1. Navigate to "Customers"
2. Click "Add Customer" to create new entries
3. Search customers by name, email, or phone
4. Click the menu icon to edit or delete customers

### Viewing Reports
1. Navigate to "Reports"
2. View sales trends and analytics
3. Check top-selling products
4. Review recent transactions
5. Export data (feature coming soon)

## Dummy Data

The application uses a mock API service (`DummyApiService`) that provides:
- 12 sample products across 5 categories
- 8 sample customers
- 50 generated transactions from the last 30 days
- Realistic sales data for charts and analytics

All data is stored in-memory and persists only during the app session.

## Configuration

### Customizing the App

1. **App Name**: Edit `lib/constants/constants.dart`
   ```dart
   static const String appName = "Your POS Name";
   ```

2. **Colors**: Edit `lib/utils/colors.dart`
   ```dart
   static const Color primary = Color(0xFF009688);
   ```

3. **Tax Rate**: Modify in `lib/controllers/cart_controller.dart`
   ```dart
   double get tax => subtotal * 0.08; // Change 0.08 to your rate
   ```

## Features Overview

### ✅ Completed
- Dashboard with real-time metrics
- POS interface with cart management
- Customer CRUD operations
- Product/Inventory management
- Sales reports and analytics
- Settings page structure
- Dummy API with mock data
- Beautiful UI with Material Design 3

### 🚧 Coming Soon
- User authentication and roles
- Database integration (Firebase/SQLite)
- Print receipt functionality
- Barcode scanner support
- Multi-store management
- Advanced reporting with date ranges
- Data export (CSV, PDF)
- Backup and restore
- Cloud synchronization

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email contact@dynamospos.com or open an issue in the repository.

## Acknowledgments

- Flutter team for the amazing framework
- GetX for state management
- FL Chart for beautiful charts
- Iconsax for modern icons
- Google Fonts for typography

---

**Built with ❤️ using Flutter**
#   p o s _ s o f t w a r e  
 