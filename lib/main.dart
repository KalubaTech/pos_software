import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pos_software/page_anchor.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pos_software/services/data_sync_service.dart';
import 'package:pos_software/services/subscription_service.dart';
import 'dart:io' show Platform;

import 'controllers/navigations_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/business_settings_controller.dart';
import 'controllers/appearance_controller.dart';
import 'controllers/price_tag_designer_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/printer_controller.dart';
import 'controllers/wallet_controller.dart';
import 'services/printer_service.dart';
import 'services/barcode_scanner_service.dart';
import 'services/bluetooth_permission_service.dart';
import 'services/image_storage_service.dart';
import 'services/database_service.dart';
import 'services/wallet_database_service.dart';
import 'views/auth/login_view.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

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
      final isDark = appearanceController.isDarkMode.value;
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

    return Obx(() {
      return authController.isAuthenticated.value ? PageAnchor() : LoginView();
    });
  }
}
