import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class AppearanceController extends GetxController {
  final _storage = GetStorage();

  // Theme Mode
  final themeMode = 'light'.obs; // light, dark, system
  final isDarkMode = false.obs;

  // Primary Color
  final primaryColor = 0xFF6200EE.obs; // Material Purple

  // Font Settings
  final fontSize = 'medium'.obs; // small, medium, large
  final fontFamily = 'default'.obs;

  // Layout Preferences
  final compactMode = false.obs;
  final showAnimations = true.obs;
  final gridColumns = 3.obs;

  // Color Presets
  final colorPresets = <String, int>{
    'Purple': 0xFF6200EE,
    'Blue': 0xFF2196F3,
    'Green': 0xFF4CAF50,
    'Orange': 0xFFFF9800,
    'Red': 0xFFF44336,
    'Teal': 0xFF009688,
    'Indigo': 0xFF3F51B5,
    'Pink': 0xFFE91E63,
  };

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  void loadSettings() {
    themeMode.value = _storage.read('theme_mode') ?? 'light';
    isDarkMode.value = themeMode.value == 'dark';
    primaryColor.value = _storage.read('primary_color') ?? 0xFF6200EE;
    fontSize.value = _storage.read('font_size') ?? 'medium';
    fontFamily.value = _storage.read('font_family') ?? 'default';
    compactMode.value = _storage.read('compact_mode') ?? false;
    showAnimations.value = _storage.read('show_animations') ?? true;
    gridColumns.value = _storage.read('grid_columns') ?? 3;
  }

  Future<void> saveSettings() async {
    await _storage.write('theme_mode', themeMode.value);
    await _storage.write('primary_color', primaryColor.value);
    await _storage.write('font_size', fontSize.value);
    await _storage.write('font_family', fontFamily.value);
    await _storage.write('compact_mode', compactMode.value);
    await _storage.write('show_animations', showAnimations.value);
    await _storage.write('grid_columns', gridColumns.value);

    Get.snackbar(
      'Success',
      'Appearance settings applied immediately',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
      backgroundColor: Color(primaryColor.value),
      colorText: Colors.white,
    );
  }

  void setThemeMode(String mode) {
    themeMode.value = mode;
    isDarkMode.value = mode == 'dark';
  }

  void setPrimaryColor(int color) {
    primaryColor.value = color;
  }

  void setFontSize(String size) {
    fontSize.value = size;
  }

  void resetToDefaults() {
    themeMode.value = 'light';
    isDarkMode.value = false;
    primaryColor.value = 0xFF6200EE;
    fontSize.value = 'medium';
    fontFamily.value = 'default';
    compactMode.value = false;
    showAnimations.value = true;
    gridColumns.value = 3;
  }

  // Get font size multiplier
  double get fontSizeMultiplier {
    switch (fontSize.value) {
      case 'small':
        return 0.9;
      case 'large':
        return 1.1;
      default:
        return 1.0;
    }
  }
}
