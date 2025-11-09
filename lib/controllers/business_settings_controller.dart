import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class BusinessSettingsController extends GetxController {
  final _storage = GetStorage();

  // Store Information
  final storeName = ''.obs;
  final storeAddress = ''.obs;
  final storePhone = ''.obs;
  final storeEmail = ''.obs;
  final storeTaxId = ''.obs;
  final storeLogo = ''.obs;

  // Tax Configuration
  final taxEnabled = true.obs;
  final taxRate = 0.0.obs;
  final taxName = 'VAT'.obs;
  final includeTaxInPrice = false.obs;

  // Currency Settings
  final currency = 'ZMW'.obs;
  final currencySymbol = 'K'.obs;
  final currencyPosition = 'before'.obs; // before or after

  // Receipt Settings
  final receiptHeader = ''.obs;
  final receiptFooter = 'Thank you for your business!'.obs;
  final showLogo = true.obs;
  final showTaxBreakdown = true.obs;
  final receiptWidth = 80.obs; // 80mm or 58mm

  // Operating Hours
  final openingTime = '09:00'.obs;
  final closingTime = '21:00'.obs;
  final operatingDays = <String>[].obs;

  // Payment Methods
  final acceptCash = true.obs;
  final acceptCard = true.obs;
  final acceptMobile = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  void loadSettings() {
    // Load Store Info
    storeName.value = _storage.read('store_name') ?? 'My Store';
    storeAddress.value = _storage.read('store_address') ?? '';
    storePhone.value = _storage.read('store_phone') ?? '';
    storeEmail.value = _storage.read('store_email') ?? '';
    storeTaxId.value = _storage.read('store_tax_id') ?? '';
    storeLogo.value = _storage.read('store_logo') ?? '';

    // Load Tax Config
    taxEnabled.value = _storage.read('tax_enabled') ?? true;
    taxRate.value = _storage.read('tax_rate') ?? 10.0;
    taxName.value = _storage.read('tax_name') ?? 'VAT';
    includeTaxInPrice.value = _storage.read('include_tax_in_price') ?? false;

    // Load Currency
    currency.value = _storage.read('currency') ?? 'ZMW';
    currencySymbol.value = _storage.read('currency_symbol') ?? 'K';
    currencyPosition.value = _storage.read('currency_position') ?? 'before';

    // Load Receipt Settings
    receiptHeader.value = _storage.read('receipt_header') ?? '';
    receiptFooter.value =
        _storage.read('receipt_footer') ?? 'Thank you for your business!';
    showLogo.value = _storage.read('show_logo') ?? true;
    showTaxBreakdown.value = _storage.read('show_tax_breakdown') ?? true;
    receiptWidth.value = _storage.read('receipt_width') ?? 80;

    // Load Operating Hours
    openingTime.value = _storage.read('opening_time') ?? '09:00';
    closingTime.value = _storage.read('closing_time') ?? '21:00';
    operatingDays.value = List<String>.from(
      _storage.read('operating_days') ??
          ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
    );

    // Load Payment Methods
    acceptCash.value = _storage.read('accept_cash') ?? true;
    acceptCard.value = _storage.read('accept_card') ?? true;
    acceptMobile.value = _storage.read('accept_mobile') ?? true;
  }

  Future<void> saveSettings() async {
    // Save Store Info
    await _storage.write('store_name', storeName.value);
    await _storage.write('store_address', storeAddress.value);
    await _storage.write('store_phone', storePhone.value);
    await _storage.write('store_email', storeEmail.value);
    await _storage.write('store_tax_id', storeTaxId.value);
    await _storage.write('store_logo', storeLogo.value);

    // Save Tax Config
    await _storage.write('tax_enabled', taxEnabled.value);
    await _storage.write('tax_rate', taxRate.value);
    await _storage.write('tax_name', taxName.value);
    await _storage.write('include_tax_in_price', includeTaxInPrice.value);

    // Save Currency
    await _storage.write('currency', currency.value);
    await _storage.write('currency_symbol', currencySymbol.value);
    await _storage.write('currency_position', currencyPosition.value);

    // Save Receipt Settings
    await _storage.write('receipt_header', receiptHeader.value);
    await _storage.write('receipt_footer', receiptFooter.value);
    await _storage.write('show_logo', showLogo.value);
    await _storage.write('show_tax_breakdown', showTaxBreakdown.value);
    await _storage.write('receipt_width', receiptWidth.value);

    // Save Operating Hours
    await _storage.write('opening_time', openingTime.value);
    await _storage.write('closing_time', closingTime.value);
    await _storage.write('operating_days', operatingDays);

    // Save Payment Methods
    await _storage.write('accept_cash', acceptCash.value);
    await _storage.write('accept_card', acceptCard.value);
    await _storage.write('accept_mobile', acceptMobile.value);

    Get.snackbar(
      'Success',
      'Business settings saved successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  void resetToDefaults() {
    storeName.value = 'My Store';
    storeAddress.value = '';
    storePhone.value = '';
    storeEmail.value = '';
    storeTaxId.value = '';
    taxEnabled.value = true;
    taxRate.value = 10.0;
    taxName.value = 'VAT';
    includeTaxInPrice.value = false;
    currency.value = 'ZMW';
    currencySymbol.value = 'K';
    currencyPosition.value = 'before';
    receiptHeader.value = '';
    receiptFooter.value = 'Thank you for your business!';
    showLogo.value = true;
    showTaxBreakdown.value = true;
    receiptWidth.value = 80;
    openingTime.value = '09:00';
    closingTime.value = '21:00';
    operatingDays.value = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    acceptCash.value = true;
    acceptCard.value = true;
    acceptMobile.value = true;
  }
}
