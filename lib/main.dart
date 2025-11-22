import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pos_software/page_anchor.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pos_software/services/data_sync_service.dart';
import 'package:pos_software/services/subscription_service.dart';
// Using Firedart instead of Firebase - Pure Dart, works on Windows!
import 'dart:io' show Platform;

import 'controllers/navigations_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/business_settings_controller.dart';
import 'controllers/appearance_controller.dart';
import 'controllers/price_tag_designer_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/customer_controller.dart';
import 'controllers/printer_controller.dart';
import 'controllers/wallet_controller.dart';
import 'controllers/universal_sync_controller.dart';
import 'controllers/calculator_controller.dart';
import 'services/printer_service.dart';
import 'services/barcode_scanner_service.dart';
import 'services/bluetooth_permission_service.dart';
import 'services/image_storage_service.dart';
import 'services/database_service.dart';
import 'services/wallet_database_service.dart';
import 'services/firedart_sync_service.dart'; // Pure Dart sync - works on Windows!
import 'services/business_service.dart';
import 'views/auth/login_view.dart';
import 'views/auth/business_registration_view.dart';
import 'models/business_model.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Using Firedart - Pure Dart implementation of Firestore
  // Works perfectly on Windows without C++ SDK issues!
  print('🔥 Using Firedart for cloud sync');

  // Initialize DatabaseService first
  final dbService = Get.put(DatabaseService());
  await dbService.database; // Ensure database is initialized

  // Initialize Wallet services with shared database
  final walletDbService = Get.put(
    WalletDatabaseService(await dbService.database),
  );
  await walletDbService.initializeTables();
  Get.put(WalletController(walletDbService));

  Get.put(ProductController());
  Get.put(CustomerController());
  Get.put(NavigationsController());
  Get.put(AuthController());
  Get.put(BusinessSettingsController());
  Get.put(AppearanceController());
  Get.put(PrinterService());
  Get.put(ImageStorageService());
  Get.put(PriceTagDesignerController());
  Get.put(PrinterController());
  Get.put(DataSyncService());
  Get.put(SubscriptionService());
  Get.put(CalculatorController()); // Initialize Calculator Controller
  // OnlineOrdersController will be initialized lazily when needed (it requires Firestore)

  // Initialize Firedart Sync Service - Pure Dart, works on Windows!
  Get.put(FiredartSyncService());
  print('🔄 Firedart sync service initialized (not connected yet)');

  // Initialize Universal Sync Controller
  Get.put(UniversalSyncController());
  print('🔄 Universal sync controller initialized');

  // Initialize Business Service
  Get.put(BusinessService());
  print('🏢 Business service initialized');

  // DON'T initialize sync here - will be done after login
  // The sync will be initialized with the actual business ID after successful login
  print('⏸️ Sync initialization delayed until after login');

  // Initialize Universal Sync Controller (but don't start syncing yet)
  Get.put(UniversalSyncController());
  print('🌍 Universal sync controller initialized (paused)');

  // Only initialize PrinterService on mobile platforms (print_bluetooth_thermal only supports Android/iOS)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    Get.put(PrinterService());
  }

  Get.put(BarcodeScannerService());
  Get.put(BluetoothPermissionService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appearanceController = Get.find<AppearanceController>();

    return Obx(() {
      // Reactive theme based on appearance settings
      final primaryColor = Color(appearanceController.primaryColor.value);
      final fontMultiplier = appearanceController.fontSizeMultiplier;

      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Dynamos - POS',
        themeMode: appearanceController.themeMode.value == 'dark'
            ? ThemeMode.dark
            : appearanceController.themeMode.value == 'light'
            ? ThemeMode.light
            : ThemeMode.system,
        theme: _buildTheme(primaryColor, false, fontMultiplier),
        darkTheme: _buildTheme(primaryColor, true, fontMultiplier),
        home: AuthWrapper(),
        // Define routes for navigation
        routes: {'/dashboard': (context) => PageAnchor()},
      );
    });
  }

  ThemeData _buildTheme(
    Color primaryColor,
    bool isDark,
    double fontMultiplier,
  ) {
    // Get the base text theme and apply Google Fonts
    final baseTextTheme = isDark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    // Apply Google Fonts without using .apply() to avoid null fontSize issues
    var textTheme = GoogleFonts.interTextTheme(baseTextTheme);

    // Manually scale font sizes if multiplier is not 1.0
    if (fontMultiplier != 1.0) {
      textTheme = TextTheme(
        displayLarge: textTheme.displayLarge?.copyWith(
          fontSize: (textTheme.displayLarge?.fontSize ?? 57) * fontMultiplier,
        ),
        displayMedium: textTheme.displayMedium?.copyWith(
          fontSize: (textTheme.displayMedium?.fontSize ?? 45) * fontMultiplier,
        ),
        displaySmall: textTheme.displaySmall?.copyWith(
          fontSize: (textTheme.displaySmall?.fontSize ?? 36) * fontMultiplier,
        ),
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontSize: (textTheme.headlineLarge?.fontSize ?? 32) * fontMultiplier,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontSize: (textTheme.headlineMedium?.fontSize ?? 28) * fontMultiplier,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontSize: (textTheme.headlineSmall?.fontSize ?? 24) * fontMultiplier,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontSize: (textTheme.titleLarge?.fontSize ?? 22) * fontMultiplier,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontSize: (textTheme.titleMedium?.fontSize ?? 16) * fontMultiplier,
        ),
        titleSmall: textTheme.titleSmall?.copyWith(
          fontSize: (textTheme.titleSmall?.fontSize ?? 14) * fontMultiplier,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          fontSize: (textTheme.bodyLarge?.fontSize ?? 16) * fontMultiplier,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          fontSize: (textTheme.bodyMedium?.fontSize ?? 14) * fontMultiplier,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          fontSize: (textTheme.bodySmall?.fontSize ?? 12) * fontMultiplier,
        ),
        labelLarge: textTheme.labelLarge?.copyWith(
          fontSize: (textTheme.labelLarge?.fontSize ?? 14) * fontMultiplier,
        ),
        labelMedium: textTheme.labelMedium?.copyWith(
          fontSize: (textTheme.labelMedium?.fontSize ?? 12) * fontMultiplier,
        ),
        labelSmall: textTheme.labelSmall?.copyWith(
          fontSize: (textTheme.labelSmall?.fontSize ?? 11) * fontMultiplier,
        ),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      textTheme: textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final BusinessService businessService = Get.find();

    return Obx(() {
      // If user is authenticated, go to main app
      if (authController.isAuthenticated.value) {
        return PageAnchor();
      }

      // Check if business is registered
      final business = businessService.currentBusiness.value;

      if (business == null) {
        // No business registered - show welcome screen with registration option
        return _buildWelcomeScreen(context);
      }

      // Business exists - check status
      switch (business.status) {
        case BusinessStatus.active:
          // Active business - show login
          return LoginView();
        case BusinessStatus.pending:
          // Pending approval - show pending screen
          return _buildPendingScreen(context, business);
        case BusinessStatus.inactive:
          // Suspended - show inactive screen
          return _buildInactiveScreen(context, business);
        case BusinessStatus.rejected:
          // Rejected - show rejection screen
          return _buildRejectedScreen(context, business);
      }
    });
  }

  Widget _buildWelcomeScreen(BuildContext context) {
    final appearanceController = Get.find<AppearanceController>();

    return Obx(() {
      final isDark = appearanceController.isDarkMode.value;

      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)]
                  : [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 30,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/dynamos_pos_logo_plain.png',
                        width: 80,
                      ),
                    ),
                    SizedBox(height: 40),

                    // Title
                    Text(
                      'Welcome to Dynamos POS',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Powerful point of sale system\nfor modern businesses',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 60),

                    // Register button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(() => BusinessRegistrationView());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF667eea),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.business, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Register Your Business',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Cashier Login button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          Get.to(() => LoginView());
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Cashier Login',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Features
                    _buildFeatureRow(Icons.inventory_2, 'Product Management'),
                    _buildFeatureRow(Icons.point_of_sale, 'Fast Checkout'),
                    _buildFeatureRow(Icons.analytics, 'Sales Analytics'),
                    _buildFeatureRow(Icons.cloud, 'Cloud Sync'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          SizedBox(width: 12),
          Text(text, style: TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildPendingScreen(BuildContext context, BusinessModel business) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange[400]!, Colors.orange[700]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pending_actions, size: 100, color: Colors.white),
                  SizedBox(height: 32),
                  Text(
                    'Application Under Review',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    business.name,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Your business registration is being reviewed by our team.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'You will receive a notification once your application is approved.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final businessService = Get.find<BusinessService>();
                      await businessService.checkBusinessStatus();
                    },
                    icon: Icon(Icons.refresh, color: Colors.white),
                    label: Text('Check Status'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white, width: 2),
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInactiveScreen(BuildContext context, BusinessModel business) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red[400]!, Colors.red[700]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.block, size: 100, color: Colors.white),
                  SizedBox(height: 32),
                  Text(
                    'Account Suspended',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    business.name,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Your business account has been suspended. Please contact Dynamos support for assistance.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Open support contact
                    },
                    icon: Icon(Icons.support_agent),
                    label: Text('Contact Support'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red[700],
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRejectedScreen(BuildContext context, BusinessModel business) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[700]!, Colors.grey[900]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel, size: 100, color: Colors.white),
                  SizedBox(height: 32),
                  Text(
                    'Application Rejected',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    business.name,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        if (business.rejectionReason != null) ...[
                          Text(
                            'Reason:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            business.rejectionReason!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                        ],
                        Text(
                          'Please contact support if you believe this was an error.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Get.to(() => BusinessRegistrationView());
                        },
                        icon: Icon(Icons.refresh, color: Colors.white),
                        label: Text('Reapply'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white, width: 2),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Contact support
                        },
                        icon: Icon(Icons.support_agent),
                        label: Text('Support'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.grey[900],
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
