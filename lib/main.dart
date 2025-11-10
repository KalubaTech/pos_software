import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pos_software/page_anchor.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io' show Platform;

import 'controllers/navigations_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/business_settings_controller.dart';
import 'controllers/appearance_controller.dart';
import 'controllers/price_tag_designer_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/printer_controller.dart';
import 'services/printer_service.dart';
import 'services/barcode_scanner_service.dart';
import 'services/image_storage_service.dart';
import 'services/database_service.dart';
import 'views/auth/login_view.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize DatabaseService first
  final dbService = Get.put(DatabaseService());
  await dbService.database; // Ensure database is initialized
  Get.put(ProductController());
  Get.put(NavigationsController());
  Get.put(AuthController());
  Get.put(BusinessSettingsController());
  Get.put(AppearanceController());
  Get.put(PrinterService());
  Get.put(ImageStorageService());
  Get.put(PriceTagDesignerController());
  Get.put(PrinterController());

  // Only initialize PrinterService on mobile platforms (print_bluetooth_thermal only supports Android/iOS)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    Get.put(PrinterService());
  }

  Get.put(BarcodeScannerService());

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
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: isDark ? Colors.white : Colors.black,
        displayColor: isDark ? Colors.white : Colors.black,
        fontSizeFactor: fontMultiplier,
      ),
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
