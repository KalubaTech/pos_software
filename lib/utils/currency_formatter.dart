import 'package:get/get.dart';
import '../controllers/business_settings_controller.dart';

class CurrencyFormatter {
  static String format(double amount) {
    try {
      final settings = Get.find<BusinessSettingsController>();
      final symbol = settings.currencySymbol.value;
      final position = settings.currencyPosition.value;
      final formattedAmount = amount.toStringAsFixed(2);

      if (position == 'before') {
        return '$symbol$formattedAmount';
      } else {
        return '$formattedAmount$symbol';
      }
    } catch (e) {
      // Fallback if controller not found
      return 'K${amount.toStringAsFixed(2)}';
    }
  }

  static String formatWithCurrency(double amount) {
    try {
      final settings = Get.find<BusinessSettingsController>();
      final symbol = settings.currencySymbol.value;
      final currency = settings.currency.value;
      final formattedAmount = amount.toStringAsFixed(2);

      return '$symbol$formattedAmount $currency';
    } catch (e) {
      return 'K${amount.toStringAsFixed(2)} ZMW';
    }
  }
}
