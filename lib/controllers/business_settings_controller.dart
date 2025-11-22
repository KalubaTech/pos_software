import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'product_controller.dart';
import '../services/firedart_sync_service.dart';

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

  // Receipt Printer Settings
  final receiptPrinterName = ''.obs;
  final receiptPrinterType = 'USB'.obs; // USB, Network, Bluetooth
  final receiptPrinterAddress =
      ''.obs; // IP address for network, device address for Bluetooth
  final receiptPrinterPort = '9100'.obs; // Port for network printers

  // Operating Hours
  final openingTime = '09:00'.obs;
  final closingTime = '21:00'.obs;
  final operatingDays = <String>[].obs;

  // Payment Methods
  final acceptCash = true.obs;
  final acceptCard = true.obs;
  final acceptMobile = true.obs;

  // Online Store Settings
  final onlineStoreEnabled = false.obs;
  final onlineProductCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    loadFromFirestore(); // Also load from cloud
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

    // Load Receipt Printer Settings
    receiptPrinterName.value = _storage.read('receipt_printer_name') ?? '';
    receiptPrinterType.value = _storage.read('receipt_printer_type') ?? 'USB';
    receiptPrinterAddress.value =
        _storage.read('receipt_printer_address') ?? '';
    receiptPrinterPort.value = _storage.read('receipt_printer_port') ?? '9100';

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

    // Load Online Store Settings
    onlineStoreEnabled.value = _storage.read('online_store_enabled') ?? false;
    _updateOnlineProductCount();
  }

  void _updateOnlineProductCount() {
    // This will be updated when ProductController is integrated
    // For now, set to 0
    try {
      final productController = Get.find<ProductController>();
      final count = productController.products
          .where((p) => p.listedOnline)
          .length;
      onlineProductCount.value = count;
    } catch (e) {
      onlineProductCount.value = 0;
    }
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

    // Save Receipt Printer Settings
    await _storage.write('receipt_printer_name', receiptPrinterName.value);
    await _storage.write('receipt_printer_type', receiptPrinterType.value);
    await _storage.write(
      'receipt_printer_address',
      receiptPrinterAddress.value,
    );
    await _storage.write('receipt_printer_port', receiptPrinterPort.value);

    // Save Operating Hours
    await _storage.write('opening_time', openingTime.value);
    await _storage.write('closing_time', closingTime.value);
    await _storage.write('operating_days', operatingDays);

    // Save Payment Methods
    await _storage.write('accept_cash', acceptCash.value);
    await _storage.write('accept_card', acceptCard.value);
    await _storage.write('accept_mobile', acceptMobile.value);

    // Save Online Store Settings
    await _storage.write('online_store_enabled', onlineStoreEnabled.value);

    // Sync to Firestore
    await _syncToFirestore();

    Get.snackbar(
      'Success',
      'Business settings saved successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  /// Sync all settings to Firestore
  Future<void> _syncToFirestore() async {
    try {
      final syncService = Get.find<FiredartSyncService>();
      if (syncService.businessId == null) {
        print('⚠️ No business ID available for sync');
        return;
      }

      // Prepare settings map
      final settingsMap = {
        'storeName': storeName.value,
        'storeAddress': storeAddress.value,
        'storePhone': storePhone.value,
        'storeEmail': storeEmail.value,
        'storeTaxId': storeTaxId.value,
        'taxEnabled': taxEnabled.value,
        'taxRate': taxRate.value,
        'taxName': taxName.value,
        'includeTaxInPrice': includeTaxInPrice.value,
        'currency': currency.value,
        'currencySymbol': currencySymbol.value,
        'currencyPosition': currencyPosition.value,
        'receiptHeader': receiptHeader.value,
        'receiptFooter': receiptFooter.value,
        'showLogo': showLogo.value,
        'showTaxBreakdown': showTaxBreakdown.value,
        'receiptWidth': receiptWidth.value,
        'openingTime': openingTime.value,
        'closingTime': closingTime.value,
        'operatingDays': operatingDays.toList(),
        'acceptCash': acceptCash.value,
        'acceptCard': acceptCard.value,
        'acceptMobile': acceptMobile.value,
      };

      // Update business document with embedded settings
      await syncService.updateCloud('businesses', syncService.businessId!, {
        'settings': settingsMap,
        'updated_at': DateTime.now().toIso8601String(),
      }, isTopLevel: true);

      print('✅ Settings synced to Firestore successfully');
    } catch (e) {
      print('⚠️ Could not sync settings to Firestore: $e');
      // Not a critical error, settings are saved locally
    }
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
    receiptPrinterName.value = '';
    receiptPrinterType.value = 'USB';
    receiptPrinterAddress.value = '';
    receiptPrinterPort.value = '9100';
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
    onlineStoreEnabled.value = false;
  }

  // Online Store Methods
  Future<void> toggleOnlineStore(bool value) async {
    onlineStoreEnabled.value = value;
    await _storage.write('online_store_enabled', value);

    // Update product count
    _updateOnlineProductCount();

    // Update the business document with online_store_enabled field
    try {
      final syncService = Get.find<FiredartSyncService>();
      if (syncService.businessId != null) {
        // Use updateCloud for partial update (preserves all other fields)
        await syncService.updateCloud('businesses', syncService.businessId!, {
          'online_store_enabled': value,
          'updated_at': DateTime.now().toIso8601String(),
        }, isTopLevel: true);
        print('✅ Business document updated: online_store_enabled = $value');
      }
    } catch (e) {
      print('⚠️ Could not update online store setting: $e');
    }

    Get.snackbar(
      value ? 'Online Store Enabled' : 'Online Store Disabled',
      value
          ? 'Your products can now be listed online'
          : 'Online store has been disabled',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  void updateOnlineProductCount(int count) {
    onlineProductCount.value = count;
  }

  /// Load settings from Firestore
  Future<void> loadFromFirestore() async {
    try {
      print('🔄 Loading business settings from Firestore...');

      // Try to get FiredartSyncService
      final syncService = Get.find<FiredartSyncService>();
      if (syncService.businessId == null) {
        print('⚠️ No business ID available yet');
        return;
      }

      // Get business document (settings are embedded, not in subcollection)
      final businessDoc = await syncService.getDocument(
        'businesses',
        syncService.businessId!,
      );

      if (businessDoc == null) {
        print('⚠️ Business document not found in Firestore');
        return;
      }

      // Extract embedded settings
      final settings = businessDoc['settings'] as Map<String, dynamic>?;

      if (settings == null) {
        print('⚠️ No settings found in business document');
        return;
      }

      print('✅ Found embedded settings in business document');

      // Update all settings from cloud (embedded settings)
      if (settings.containsKey('storeName')) {
        storeName.value = settings['storeName'] ?? storeName.value;
        await _storage.write('store_name', storeName.value);
      }
      if (settings.containsKey('storeAddress')) {
        storeAddress.value = settings['storeAddress'] ?? storeAddress.value;
        await _storage.write('store_address', storeAddress.value);
      }
      if (settings.containsKey('storePhone')) {
        storePhone.value = settings['storePhone'] ?? storePhone.value;
        await _storage.write('store_phone', storePhone.value);
      }
      if (settings.containsKey('storeEmail')) {
        storeEmail.value = settings['storeEmail'] ?? storeEmail.value;
        await _storage.write('store_email', storeEmail.value);
      }
      if (settings.containsKey('storeTaxId')) {
        storeTaxId.value = settings['storeTaxId'] ?? storeTaxId.value;
        await _storage.write('store_tax_id', storeTaxId.value);
      }

      // Tax settings
      if (settings.containsKey('taxEnabled') ||
          settings.containsKey('tax_enabled')) {
        taxEnabled.value =
            settings['taxEnabled'] ??
            settings['tax_enabled'] ??
            taxEnabled.value;
        await _storage.write('tax_enabled', taxEnabled.value);
      }
      if (settings.containsKey('taxRate') || settings.containsKey('tax_rate')) {
        final rate = settings['taxRate'] ?? settings['tax_rate'];
        taxRate.value = (rate as num?)?.toDouble() ?? taxRate.value;
        await _storage.write('tax_rate', taxRate.value);
      }
      if (settings.containsKey('taxName') || settings.containsKey('tax_name')) {
        taxName.value =
            settings['taxName'] ?? settings['tax_name'] ?? taxName.value;
        await _storage.write('tax_name', taxName.value);
      }

      // Currency settings
      if (settings.containsKey('currency')) {
        currency.value = settings['currency'] ?? currency.value;
        await _storage.write('currency', currency.value);
      }
      if (settings.containsKey('currencySymbol') ||
          settings.containsKey('currency_symbol')) {
        currencySymbol.value =
            settings['currencySymbol'] ??
            settings['currency_symbol'] ??
            currencySymbol.value;
        await _storage.write('currency_symbol', currencySymbol.value);
      }

      // Receipt settings
      if (settings.containsKey('receiptHeader') ||
          settings.containsKey('receipt_header')) {
        receiptHeader.value =
            settings['receiptHeader'] ??
            settings['receipt_header'] ??
            receiptHeader.value;
        await _storage.write('receipt_header', receiptHeader.value);
      }
      if (settings.containsKey('receiptFooter') ||
          settings.containsKey('receipt_footer')) {
        receiptFooter.value =
            settings['receiptFooter'] ??
            settings['receipt_footer'] ??
            receiptFooter.value;
        await _storage.write('receipt_footer', receiptFooter.value);
      }

      // Payment Methods
      if (settings.containsKey('acceptCash') ||
          settings.containsKey('accept_cash')) {
        acceptCash.value =
            settings['acceptCash'] ??
            settings['accept_cash'] ??
            acceptCash.value;
        await _storage.write('accept_cash', acceptCash.value);
      }
      if (settings.containsKey('acceptCard') ||
          settings.containsKey('accept_card')) {
        acceptCard.value =
            settings['acceptCard'] ??
            settings['accept_card'] ??
            acceptCard.value;
        await _storage.write('accept_card', acceptCard.value);
      }
      if (settings.containsKey('acceptMobile') ||
          settings.containsKey('accept_mobile')) {
        acceptMobile.value =
            settings['acceptMobile'] ??
            settings['accept_mobile'] ??
            acceptMobile.value;
        await _storage.write('accept_mobile', acceptMobile.value);
      }

      print(
        '✅ Business settings loaded from embedded model and synced to local storage',
      );
    } catch (e) {
      print('⚠️ Could not load settings from Firestore: $e');
      // Not a critical error, use local defaults
    }
  }
}
