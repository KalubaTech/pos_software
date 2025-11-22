import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../services/firedart_sync_service.dart';
import '../services/database_service.dart';
import '../services/wallet_database_service.dart';
import '../services/image_sync_service.dart';
import '../services/subscription_service.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';
import '../models/client_model.dart';
import '../models/price_tag_template_model.dart';
import '../models/wallet_model.dart';
import '../models/subscription_model.dart';
import 'product_controller.dart';
import 'customer_controller.dart';
import 'business_settings_controller.dart';

/// Universal sync controller that handles ALL data synchronization
class UniversalSyncController extends GetxController {
  final FiredartSyncService _syncService = Get.find<FiredartSyncService>();
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final ImageSyncService _imageSyncService = Get.put(ImageSyncService());
  WalletDatabaseService? _walletDbService;
  SubscriptionService? _subscriptionService;
  BusinessSettingsController? _businessSettingsController;

  final isSyncing = false.obs;
  final lastFullSync = Rx<DateTime?>(null);
  final syncProgress = 0.0.obs;
  final syncStatus = ''.obs;

  /// Platform detection for conditional stream handling
  bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  bool get isDesktop => !kIsWeb && Platform.isWindows;

  // Stream getters for mobile platforms to use with StreamBuilder
  // These expose raw Firestore streams for real-time reactive UI updates

  /// Stream of products from Firestore (for mobile)
  Stream<List<Map<String, dynamic>>> get productsStream =>
      _syncService.listenToCollection('products');

  /// Stream of transactions from Firestore (for mobile)
  Stream<List<Map<String, dynamic>>> get transactionsStream =>
      _syncService.listenToCollection('transactions');

  /// Stream of customers from Firestore (for mobile)
  Stream<List<Map<String, dynamic>>> get customersStream =>
      _syncService.listenToCollection('customers');

  /// Stream of wallets from Firestore (for mobile)
  Stream<List<Map<String, dynamic>>> get walletsStream =>
      _syncService.listenToCollection('wallets');

  /// Stream of subscriptions from Firestore (for mobile)
  Stream<List<Map<String, dynamic>>> get subscriptionsStream =>
      _syncService.listenToCollection('subscriptions');

  /// Stream of business settings from Firestore (for mobile)
  Stream<List<Map<String, dynamic>>> get businessSettingsStream =>
      _syncService.listenToCollection(
        'cashiers',
      ); // Changed from business_settings to cashiers
  // TODO: Settings are now embedded in business document, not a subcollection
  // This stream should be removed or changed to listen to business document

  /// Stream of price tag templates from Firestore (for mobile)
  Stream<List<Map<String, dynamic>>> get priceTagTemplatesStream =>
      _syncService.listenToCollection('price_tag_templates');

  /// Stream of cashiers from Firestore (for mobile)
  Stream<List<Map<String, dynamic>>> get cashiersStream =>
      _syncService.listenToCollection('cashiers');

  @override
  void onInit() {
    super.onInit();
    try {
      _walletDbService = Get.find<WalletDatabaseService>();
    } catch (e) {
      print('⚠️ WalletDatabaseService not available');
    }

    try {
      _subscriptionService = Get.find<SubscriptionService>();
    } catch (e) {
      print('⚠️ SubscriptionService not available');
    }

    try {
      _businessSettingsController = Get.find<BusinessSettingsController>();
    } catch (e) {
      print('⚠️ BusinessSettingsController not available');
    }

    // Start listening to all cloud collections
    _startListeningToAllCollections();

    // Perform initial sync after a delay (let app initialize)
    Future.delayed(Duration(seconds: 3), () {
      performFullSync();
    });
  }

  /// Perform full bidirectional sync of all data
  Future<void> performFullSync() async {
    if (isSyncing.value) {
      print('⚠️ Sync already in progress');
      return;
    }

    try {
      isSyncing.value = true;
      syncProgress.value = 0.0;
      print('🔄 Starting full sync...');

      // FIRST: Pull data from cloud to local
      print('⬇️ STEP 1: Pulling data from cloud...');
      await _pullDataFromCloud();
      syncProgress.value = 0.5;

      // SECOND: Push local data to cloud
      print('⬆️ STEP 2: Pushing local data to cloud...');
      await _pushDataToCloud();
      syncProgress.value = 1.0;

      lastFullSync.value = DateTime.now();
      syncStatus.value = 'Sync completed successfully';
      print('✅ Full sync completed!');

      Get.snackbar(
        '✅ Sync Complete',
        'All data synchronized successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      syncStatus.value = 'Sync failed: $e';
      print('❌ Sync error: $e');
      Get.snackbar(
        '❌ Sync Error',
        'Failed to sync: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSyncing.value = false;
    }
  }

  /// Pull all data from cloud to local database
  Future<void> _pullDataFromCloud() async {
    try {
      print('⬇️ Pulling data from cloud...');

      // Pull products
      syncStatus.value = 'Downloading products...';
      final cloudProducts = await _syncService.getCollectionData('products');
      print('📥 Found ${cloudProducts.length} products in cloud');
      if (cloudProducts.isNotEmpty) {
        await _syncProductsFromCloud(cloudProducts);
      }

      // Pull transactions
      syncStatus.value = 'Downloading transactions...';
      final cloudTransactions = await _syncService.getCollectionData(
        'transactions',
      );
      print('📥 Found ${cloudTransactions.length} transactions in cloud');
      if (cloudTransactions.isNotEmpty) {
        await _syncTransactionsFromCloud(cloudTransactions);
      }

      // Pull customers
      syncStatus.value = 'Downloading customers...';
      final cloudCustomers = await _syncService.getCollectionData('customers');
      print('📥 Found ${cloudCustomers.length} customers in cloud');
      if (cloudCustomers.isNotEmpty) {
        await _syncCustomersFromCloud(cloudCustomers);
      }

      // Pull price tag templates
      syncStatus.value = 'Downloading templates...';
      final cloudTemplates = await _syncService.getCollectionData(
        'price_tag_templates',
      );
      print('📥 Found ${cloudTemplates.length} templates in cloud');
      if (cloudTemplates.isNotEmpty) {
        await _syncTemplatesFromCloud(cloudTemplates);
      }

      // Pull cashiers
      syncStatus.value = 'Downloading cashiers...';
      final cloudCashiers = await _syncService.getCollectionData('cashiers');
      print('📥 Found ${cloudCashiers.length} cashiers in cloud');
      if (cloudCashiers.isNotEmpty) {
        await _syncCashiersFromCloud(cloudCashiers);
      }

      // Pull business settings
      if (_businessSettingsController != null) {
        syncStatus.value = 'Downloading business settings...';
        final cloudSettings = await _syncService.getCollectionData(
          'business_settings',
        );
        print('📥 Found ${cloudSettings.length} business settings in cloud');
        if (cloudSettings.isNotEmpty) {
          await _syncBusinessSettingsFromCloud(cloudSettings);
        }
      }

      // Pull wallets
      if (_walletDbService != null) {
        syncStatus.value = 'Downloading wallets...';
        final cloudWallets = await _syncService.getCollectionData('wallets');
        print('📥 Found ${cloudWallets.length} wallets in cloud');
        if (cloudWallets.isNotEmpty) {
          await _syncWalletsFromCloud(cloudWallets);
        }
      }

      // Pull subscriptions
      if (_subscriptionService != null) {
        syncStatus.value = 'Downloading subscriptions...';
        final cloudSubscriptions = await _syncService.getCollectionData(
          'subscriptions',
        );
        print('📥 Found ${cloudSubscriptions.length} subscriptions in cloud');
        if (cloudSubscriptions.isNotEmpty) {
          await _syncSubscriptionsFromCloud(cloudSubscriptions);
        }
      }

      print('✅ Cloud data pull completed');
    } catch (e) {
      print('❌ Error pulling data from cloud: $e');
      throw e;
    }
  }

  /// Push all local data to cloud
  Future<void> _pushDataToCloud() async {
    try {
      print('⬆️ Pushing local data to cloud...');

      // Sync all data types
      await _syncProducts();
      await _syncTransactions();
      await _syncCustomers();
      await _syncPriceTagTemplates();
      await _syncCashiers();

      if (_walletDbService != null) {
        await _syncWallets();
      }

      if (_subscriptionService != null) {
        await _syncSubscriptions();
      }

      if (_businessSettingsController != null) {
        await _syncBusinessSettings();
      }

      print('✅ Local data push completed');
    } catch (e) {
      print('❌ Error pushing data to cloud: $e');
      throw e;
    }
  }

  /// Sync products bidirectionally (DEPRECATED - now split into pull and push)
  Future<void> _syncProducts() async {
    syncStatus.value = 'Syncing products...';
    print('📦 Syncing products...');

    try {
      // Get local products
      final localProducts = await _dbService.getAllProducts();
      print('📱 Local products: ${localProducts.length}');

      // Push local products to cloud
      for (var product in localProducts) {
        print('📤 Preparing to push: ${product.name}');
        print('   - Product ID: ${product.id}');
        print(
          '   - Has variants: ${product.variants != null && product.variants!.isNotEmpty}',
        );
        print('   - Variants count: ${product.variants?.length ?? 0}');
        print('   - listedOnline: ${product.listedOnline}');

        // Upload image if it's local
        String imageUrl = product.imageUrl;
        if (_imageSyncService.isLocalImage(imageUrl)) {
          print('📸 Uploading image for product: ${product.name}');
          final remoteUrl = await _imageSyncService.uploadImage(imageUrl);
          if (remoteUrl != null) {
            imageUrl = remoteUrl;
            // Update product with remote image URL
            final updatedProduct = product.copyWith(imageUrl: imageUrl);
            await _dbService.updateProduct(updatedProduct);
            print('✅ Image uploaded and product updated');
          }
        }

        // Prepare product data with updated image URL
        final productData = product.copyWith(imageUrl: imageUrl).toJson();

        print(
          '   - Product JSON has ${(productData['variants'] as List?)?.length ?? 0} variants',
        );
        if (productData['variants'] != null) {
          print('   - Variants in JSON: ${productData['variants']}');
        }

        await _syncService.pushToCloud('products', product.id, productData);
      }
      print('☁️ Pushed ${localProducts.length} products to cloud');
    } catch (e) {
      print('❌ Error syncing products: $e');
    }
  }

  /// Sync transactions bidirectionally
  Future<void> _syncTransactions() async {
    syncStatus.value = 'Syncing transactions...';
    print('🧾 Syncing transactions...');

    try {
      // Get local transactions
      final localTransactions = await _dbService.getAllTransactions();
      print('📱 Local transactions: ${localTransactions.length}');

      // Push local transactions to cloud
      for (var transaction in localTransactions) {
        await _syncService.pushToCloud(
          'transactions',
          transaction.id,
          transaction.toJson(),
        );
      }
      print('☁️ Pushed ${localTransactions.length} transactions to cloud');
    } catch (e) {
      print('❌ Error syncing transactions: $e');
    }
  }

  /// Sync customers bidirectionally
  Future<void> _syncCustomers() async {
    syncStatus.value = 'Syncing customers...';
    print('👥 Syncing customers...');

    try {
      // Get local customers
      final localCustomers = await _dbService.getAllCustomers();
      print('📱 Local customers: ${localCustomers.length}');

      // Push local customers to cloud
      for (var customer in localCustomers) {
        await _syncService.pushToCloud(
          'customers',
          customer.id,
          customer.toJson(),
        );
      }
      print('☁️ Pushed ${localCustomers.length} customers to cloud');
    } catch (e) {
      print('❌ Error syncing customers: $e');
    }
  }

  /// Sync price tag templates
  Future<void> _syncPriceTagTemplates() async {
    syncStatus.value = 'Syncing templates...';
    print('🏷️ Syncing price tag templates...');

    try {
      // Get local templates
      final localTemplates = await _dbService.getAllTemplates();
      print('📱 Local templates: ${localTemplates.length}');

      // Push local templates to cloud
      for (var template in localTemplates) {
        await _syncService.pushToCloud(
          'price_tag_templates',
          template.id,
          template.toJson(),
        );
      }
      print('☁️ Pushed ${localTemplates.length} templates to cloud');
    } catch (e) {
      print('❌ Error syncing templates: $e');
    }
  }

  /// Sync cashiers
  Future<void> _syncCashiers() async {
    syncStatus.value = 'Syncing cashiers...';
    print('👤 Syncing cashiers...');

    try {
      // Get local cashiers
      final localCashiers = await _dbService.getAllCashiers();
      print('📱 Local cashiers: ${localCashiers.length}');

      // Push local cashiers to cloud
      for (var cashierMap in localCashiers) {
        final id = cashierMap['id'] as String;
        await _syncService.pushToCloud('cashiers', id, cashierMap);
      }
      print('☁️ Pushed ${localCashiers.length} cashiers to cloud');
    } catch (e) {
      print('❌ Error syncing cashiers: $e');
    }
  }

  /// Sync wallets and wallet transactions
  /// Sync wallets bidirectionally
  Future<void> _syncWallets() async {
    if (_walletDbService == null) return;

    syncStatus.value = 'Syncing wallets...';
    print('💰 Syncing wallets...');

    try {
      // Get all local wallets
      final localWallets = await _walletDbService!.getAllWallets();

      print('📤 Found ${localWallets.length} local wallets to sync');

      // Push each wallet to cloud
      for (var wallet in localWallets) {
        try {
          await _syncService.pushToCloud(
            'wallets',
            wallet.businessId,
            wallet.toJson(),
          );
          print('☁️ Wallet synced for business: ${wallet.businessName}');
        } catch (e) {
          print('❌ Failed to sync wallet ${wallet.businessId}: $e');
        }
      }

      print('✅ Wallets sync complete');
    } catch (e) {
      print('❌ Error syncing wallets: $e');
    }
  }

  /// Sync subscriptions bidirectionally
  Future<void> _syncSubscriptions() async {
    if (_subscriptionService == null) return;

    syncStatus.value = 'Syncing subscriptions...';
    print('👑 Syncing subscriptions...');

    try {
      // Get current subscription
      final currentSub = _subscriptionService!.currentSubscription.value;

      if (currentSub != null) {
        // Push current subscription to cloud
        await _syncService.pushToCloud(
          'subscriptions',
          currentSub.id,
          currentSub.toJson(),
        );
        print('☁️ Subscription synced: ${currentSub.planName}');
      } else {
        print('⚠️ No active subscription to sync');
      }

      print('✅ Subscription sync complete');
    } catch (e) {
      print('❌ Error syncing subscription: $e');
    }
  }

  /// Sync business settings bidirectionally
  Future<void> _syncBusinessSettings() async {
    if (_businessSettingsController == null) return;

    // DISABLED: Settings are now embedded in business document, not a subcollection
    // The business_settings_controller.dart handles settings updates via updateCloud()
    // to the main business document's 'settings' field
    print(
      'ℹ️ Business settings sync skipped - settings are embedded in business document',
    );
    return;

    /* DISABLED CODE - Settings now embedded in business document
    syncStatus.value = 'Syncing business settings...';
    print('⚙️ Syncing business settings...');

    try {
      // FIRST: Pull settings from cloud
      print('⬇️ Pulling business settings from cloud...');
      final cloudSettings = await _syncService.getCollectionData(
        'business_settings',
      );

      if (cloudSettings.isNotEmpty) {
        await _syncBusinessSettingsFromCloud(cloudSettings);
        print('☁️ Business settings synced from cloud');
      } else {
        print(
          '⚠️ No business settings found in cloud, will push local defaults',
        );
      }

      // THEN: Push current local settings to cloud
      final settings = {
        // Store Information
        'storeName': _businessSettingsController!.storeName.value,
        'storeAddress': _businessSettingsController!.storeAddress.value,
        'storePhone': _businessSettingsController!.storePhone.value,
        'storeEmail': _businessSettingsController!.storeEmail.value,
        'storeTaxId': _businessSettingsController!.storeTaxId.value,
        'storeLogo': _businessSettingsController!.storeLogo.value,

        // Tax Configuration
        'taxEnabled': _businessSettingsController!.taxEnabled.value,
        'taxRate': _businessSettingsController!.taxRate.value,
        'taxName': _businessSettingsController!.taxName.value,
        'includeTaxInPrice':
            _businessSettingsController!.includeTaxInPrice.value,

        // Currency Settings
        'currency': _businessSettingsController!.currency.value,
        'currencySymbol': _businessSettingsController!.currencySymbol.value,
        'currencyPosition': _businessSettingsController!.currencyPosition.value,

        // Receipt Settings
        'receiptHeader': _businessSettingsController!.receiptHeader.value,
        'receiptFooter': _businessSettingsController!.receiptFooter.value,
        'showLogo': _businessSettingsController!.showLogo.value,
        'showTaxBreakdown': _businessSettingsController!.showTaxBreakdown.value,
        'receiptWidth': _businessSettingsController!.receiptWidth.value,

        // Receipt Printer Settings
        'receiptPrinterName':
            _businessSettingsController!.receiptPrinterName.value,
        'receiptPrinterType':
            _businessSettingsController!.receiptPrinterType.value,
        'receiptPrinterAddress':
            _businessSettingsController!.receiptPrinterAddress.value,
        'receiptPrinterPort':
            _businessSettingsController!.receiptPrinterPort.value,

        // Operating Hours
        'openingTime': _businessSettingsController!.openingTime.value,
        'closingTime': _businessSettingsController!.closingTime.value,
        'operatingDays': _businessSettingsController!.operatingDays.toList(),

        // Payment Methods
        'acceptCash': _businessSettingsController!.acceptCash.value,
        'acceptCard': _businessSettingsController!.acceptCard.value,
        'acceptMobile': _businessSettingsController!.acceptMobile.value,

        // Online Store Settings
        'onlineStoreEnabled':
            _businessSettingsController!.onlineStoreEnabled.value,
        'onlineProductCount':
            _businessSettingsController!.onlineProductCount.value,

        // Metadata
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      // Use businessId or a fixed key for settings
      final businessId = _syncService.businessId ?? 'default_business';

      await _syncService.pushToCloud('business_settings', businessId, settings);

      print('☁️ Business settings synced for: $businessId');
      print('✅ Business settings sync complete');
    } catch (e) {
      print('❌ Error syncing business settings: $e');
    }
    */
  }

  /// Start listening to all cloud collections
  void _startListeningToAllCollections() {
    // On desktop platforms, use callback-based listeners
    // On mobile, views will use the stream getters directly with StreamBuilder
    if (isDesktop) {
      print('💻 Desktop detected: Setting up callback-based listeners');
      _listenToProducts();
      _listenToTransactions();
      _listenToCustomers();
      _listenToPriceTagTemplates();
      _listenToCashiers();
      if (_walletDbService != null) {
        _listenToWallets();
      }
      if (_subscriptionService != null) {
        _listenToSubscriptions();
      }
      if (_businessSettingsController != null) {
        _listenToBusinessSettings();
      }
    } else if (isMobile) {
      print('📱 Mobile detected: Stream getters available for StreamBuilder');
      print(
        'ℹ️ Mobile views should use UniversalSyncController stream getters:',
      );
      print('   - productsStream');
      print('   - transactionsStream');
      print('   - customersStream');
      print('   - walletsStream');
      print('   - subscriptionsStream');
      print('   - businessSettingsStream');
      print('   - priceTagTemplatesStream');
      print('   - cashiersStream');
    }
  }

  /// Listen to cloud products and update local
  void _listenToProducts() {
    try {
      _syncService.listenToCollection('products').listen((cloudProducts) {
        print('📥 Received ${cloudProducts.length} products from cloud');

        _syncProductsFromCloud(cloudProducts);
      });
      print('👂 Listening to cloud products');
    } catch (e) {
      print('❌ Failed to listen to products: $e');
    }
  }

  /// Sync products from cloud to local DB
  Future<void> _syncProductsFromCloud(
    List<Map<String, dynamic>> cloudProducts,
  ) async {
    try {
      for (var productData in cloudProducts) {
        try {
          print('📦 Processing product from cloud: ${productData['name']}');
          print('   - Product ID: ${productData['id']}');
          print('   - Has variants: ${productData['variants'] != null}');
          if (productData['variants'] != null) {
            print(
              '   - Variants count: ${(productData['variants'] as List).length}',
            );
            print('   - Variants data: ${productData['variants']}');
          }
          print('   - listedOnline: ${productData['listedOnline']}');

          final product = ProductModel.fromJson(productData);
          print('   - Parsed product successfully');
          print(
            '   - Product has ${product.variants?.length ?? 0} variants after parsing',
          );

          // Check if exists locally
          final localProducts = await _dbService.getAllProducts();
          final exists = localProducts.any((p) => p.id == product.id);

          if (exists) {
            print('   - Updating existing product in local DB');
            await _dbService.updateProduct(product);
            print(
              '🔄 Updated local product: ${product.name} (variants: ${product.variants?.length ?? 0})',
            );
          } else {
            print('   - Inserting new product to local DB');
            await _dbService.insertProduct(product);
            print(
              '➕ Added product from cloud: ${product.name} (variants: ${product.variants?.length ?? 0})',
            );
          }
        } catch (e, stackTrace) {
          print('❌ Error processing cloud product: $e');
          print('Stack trace: $stackTrace');
          print('Product data: $productData');
        }
      }

      // Refresh ProductController to update UI
      try {
        final productController = Get.find<ProductController>();
        await productController.fetchProducts();
        print('🔄 Product list refreshed');
      } catch (e) {
        print('⚠️ ProductController not available');
      }
    } catch (e) {
      print('❌ Error syncing products from cloud: $e');
    }
  }

  /// Listen to cloud transactions
  void _listenToTransactions() {
    try {
      _syncService.listenToCollection('transactions').listen((
        cloudTransactions,
      ) {
        print(
          '📥 Received ${cloudTransactions.length} transactions from cloud',
        );

        _syncTransactionsFromCloud(cloudTransactions);
      });
      print('� Listening to cloud transactions');
    } catch (e) {
      print('❌ Failed to listen to transactions: $e');
    }
  }

  /// Sync transactions from cloud to local DB
  Future<void> _syncTransactionsFromCloud(
    List<Map<String, dynamic>> cloudTransactions,
  ) async {
    try {
      for (var transactionData in cloudTransactions) {
        try {
          final transaction = TransactionModel.fromJson(transactionData);

          // Check if exists locally
          final localTransactions = await _dbService.getAllTransactions();
          final exists = localTransactions.any((t) => t.id == transaction.id);

          if (!exists) {
            await _dbService.insertTransaction(transaction);
            print('➕ Added transaction from cloud: ${transaction.id}');
          }
          // Transactions are immutable, no updates needed
        } catch (e) {
          print('❌ Error processing cloud transaction: $e');
        }
      }

      // Refresh TransactionController if available
      try {
        // Note: You may need to add TransactionController.fetchTransactions()
        print('🔄 Transactions synced to local DB');
      } catch (e) {
        print('⚠️ TransactionController not available');
      }
    } catch (e) {
      print('❌ Error syncing transactions from cloud: $e');
    }
  }

  /// Listen to cloud customers
  void _listenToCustomers() {
    try {
      _syncService.listenToCollection('customers').listen((cloudCustomers) {
        print('📥 Received ${cloudCustomers.length} customers from cloud');

        _syncCustomersFromCloud(cloudCustomers);
      });
      print('👂 Listening to cloud customers');
    } catch (e) {
      print('❌ Failed to listen to customers: $e');
    }
  }

  /// Sync customers from cloud to local DB
  Future<void> _syncCustomersFromCloud(
    List<Map<String, dynamic>> cloudCustomers,
  ) async {
    try {
      for (var customerData in cloudCustomers) {
        try {
          final customer = ClientModel.fromJson(customerData);

          // Check if exists locally
          final localCustomers = await _dbService.getAllCustomers();
          final exists = localCustomers.any((c) => c.id == customer.id);

          if (exists) {
            await _dbService.updateCustomer(customer);
            print('🔄 Updated local customer: ${customer.name}');
          } else {
            await _dbService.insertCustomer(customer);
            print('➕ Added customer from cloud: ${customer.name}');
          }
        } catch (e) {
          print('❌ Error processing cloud customer: $e');
        }
      }

      // Refresh CustomerController to update UI
      try {
        final customerController = Get.find<CustomerController>();
        await customerController.fetchCustomers();
        print('🔄 Customer list refreshed');
      } catch (e) {
        print('⚠️ CustomerController not available');
      }
    } catch (e) {
      print('❌ Error syncing customers from cloud: $e');
    }
  }

  /// Listen to cloud price tag templates
  void _listenToPriceTagTemplates() {
    try {
      _syncService.listenToCollection('price_tag_templates').listen((
        cloudTemplates,
      ) {
        print('📥 Received ${cloudTemplates.length} templates from cloud');

        _syncTemplatesFromCloud(cloudTemplates);
      });
      print('👂 Listening to cloud price tag templates');
    } catch (e) {
      print('❌ Failed to listen to templates: $e');
    }
  }

  /// Sync templates from cloud to local DB
  Future<void> _syncTemplatesFromCloud(
    List<Map<String, dynamic>> cloudTemplates,
  ) async {
    try {
      for (var templateData in cloudTemplates) {
        try {
          final template = PriceTagTemplate.fromJson(templateData);

          // Check if exists locally
          final localTemplates = await _dbService.getAllTemplates();
          final exists = localTemplates.any((t) => t.id == template.id);

          if (exists) {
            await _dbService.updateTemplate(template);
            print('🔄 Updated local template: ${template.name}');
          } else {
            await _dbService.insertTemplate(template);
            print('➕ Added template from cloud: ${template.name}');
          }
        } catch (e) {
          print('❌ Error processing cloud template: $e');
        }
      }
      print('� Templates synced to local DB');
    } catch (e) {
      print('❌ Error syncing templates from cloud: $e');
    }
  }

  /// Listen to cloud cashiers
  void _listenToCashiers() {
    try {
      _syncService.listenToCollection('cashiers').listen((cloudCashiers) {
        print('📥 Received ${cloudCashiers.length} cashiers from cloud');

        _syncCashiersFromCloud(cloudCashiers);
      });
      print('👂 Listening to cloud cashiers');
    } catch (e) {
      print('❌ Failed to listen to cashiers: $e');
    }
  }

  /// Sync cashiers from cloud to local DB
  Future<void> _syncCashiersFromCloud(
    List<Map<String, dynamic>> cloudCashiers,
  ) async {
    try {
      for (var cashierData in cloudCashiers) {
        try {
          final id = cashierData['id'] as String;

          // Check if exists locally
          final localCashiers = await _dbService.getAllCashiers();
          final exists = localCashiers.any((c) => c['id'] == id);

          if (exists) {
            await _dbService.updateCashier(id, cashierData);
            print('🔄 Updated local cashier: ${cashierData['name']}');
          } else {
            await _dbService.insertCashier(cashierData);
            print('➕ Added cashier from cloud: ${cashierData['name']}');
          }
        } catch (e) {
          print('❌ Error processing cloud cashier: $e');
        }
      }
      print('� Cashiers synced to local DB');
    } catch (e) {
      print('❌ Error syncing cashiers from cloud: $e');
    }
  }

  /// Listen to cloud wallets
  void _listenToWallets() {
    if (_walletDbService == null) return;

    try {
      _syncService.listenToCollection('wallets').listen((cloudWallets) {
        print('📥 Received ${cloudWallets.length} wallets from cloud');
        _syncWalletsFromCloud(cloudWallets);
      });
      print('👂 Listening to cloud wallets');
    } catch (e) {
      print('❌ Failed to listen to wallets: $e');
    }
  }

  /// Sync wallets from cloud to local
  Future<void> _syncWalletsFromCloud(
    List<Map<String, dynamic>> cloudWallets,
  ) async {
    if (_walletDbService == null) return;

    try {
      for (var walletData in cloudWallets) {
        try {
          // Parse wallet from cloud data
          final wallet = WalletModel.fromJson(walletData);

          // Check if wallet exists locally
          final localWallet = await _walletDbService!.getWalletByBusinessId(
            wallet.businessId,
          );

          if (localWallet != null) {
            // Update existing wallet
            final updatedWallet = wallet.copyWith(id: localWallet.id);
            await _walletDbService!.updateWallet(updatedWallet);
            print('🔄 Updated wallet for business: ${wallet.businessName}');
          } else {
            // Create new wallet
            await _walletDbService!.createWallet(wallet);
            print('➕ Added wallet from cloud: ${wallet.businessName}');
          }
        } catch (e) {
          print('❌ Error processing cloud wallet: $e');
        }
      }
      print('✅ Wallets synced to local');
    } catch (e) {
      print('❌ Error syncing wallets from cloud: $e');
    }
  }

  /// Sync a single product immediately
  Future<void> syncProduct(ProductModel product) async {
    try {
      print('🔄 Syncing single product: ${product.name}');
      print('   - Product ID: ${product.id}');
      print(
        '   - Has variants: ${product.variants != null && product.variants!.isNotEmpty}',
      );
      print('   - Variants count: ${product.variants?.length ?? 0}');
      print('   - listedOnline: ${product.listedOnline}');

      // Upload image if it's local
      String imageUrl = product.imageUrl;
      if (_imageSyncService.isLocalImage(imageUrl)) {
        print('📸 Uploading image for product: ${product.name}');
        final remoteUrl = await _imageSyncService.uploadImage(imageUrl);
        if (remoteUrl != null) {
          imageUrl = remoteUrl;
          // Update product with remote image URL in local DB
          final updatedProduct = product.copyWith(imageUrl: imageUrl);
          await _dbService.updateProduct(updatedProduct);
          print('✅ Image uploaded and product updated');
          product = updatedProduct; // Use updated product
        }
      }

      final productJson = product.toJson();
      print(
        '   - JSON has ${(productJson['variants'] as List?)?.length ?? 0} variants',
      );
      if (productJson['variants'] != null) {
        print('   - Variants in JSON: ${productJson['variants']}');
      }

      await _syncService.pushToCloud('products', product.id, productJson);
      print('☁️ Product ${product.name} synced to cloud');
    } catch (e, stackTrace) {
      print('❌ Failed to sync product: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Sync a single transaction immediately
  Future<void> syncTransaction(TransactionModel transaction) async {
    try {
      await _syncService.pushToCloud(
        'transactions',
        transaction.id,
        transaction.toJson(),
      );
      print('☁️ Transaction ${transaction.id} synced');
    } catch (e) {
      print('❌ Failed to sync transaction: $e');
    }
  }

  /// Sync a single customer immediately
  Future<void> syncCustomer(ClientModel customer) async {
    try {
      await _syncService.pushToCloud(
        'customers',
        customer.id,
        customer.toJson(),
      );
      print('☁️ Customer ${customer.name} synced');
    } catch (e) {
      print('❌ Failed to sync customer: $e');
    }
  }

  /// Delete a product from cloud
  Future<void> deleteProductFromCloud(String productId) async {
    try {
      await _syncService.deleteFromCloud('products', productId);
      print('🗑️ Product $productId deleted from cloud');
    } catch (e) {
      print('❌ Failed to delete product: $e');
    }
  }

  /// Delete a customer from cloud
  Future<void> deleteCustomerFromCloud(String customerId) async {
    try {
      await _syncService.deleteFromCloud('customers', customerId);
      print('🗑️ Customer $customerId deleted from cloud');
    } catch (e) {
      print('❌ Failed to delete customer: $e');
    }
  }

  /// Listen to cloud subscriptions
  void _listenToSubscriptions() {
    if (_subscriptionService == null) return;

    try {
      _syncService.listenToCollection('subscriptions').listen((cloudSubs) {
        print('📥 Received ${cloudSubs.length} subscriptions from cloud');
        _syncSubscriptionsFromCloud(cloudSubs);
      });
      print('👂 Listening to cloud subscriptions');
    } catch (e) {
      print('❌ Failed to listen to subscriptions: $e');
    }
  }

  /// Sync subscriptions from cloud to local
  Future<void> _syncSubscriptionsFromCloud(
    List<Map<String, dynamic>> cloudSubs,
  ) async {
    try {
      for (var subData in cloudSubs) {
        try {
          final subscription = SubscriptionModel.fromJson(subData);
          final currentSub = _subscriptionService!.currentSubscription.value;

          print(
            '🔍 Evaluating cloud subscription: ${subscription.planName} (${subscription.status.name}) - Business: ${subscription.businessId}',
          );
          print(
            '📱 Current local subscription: ${currentSub?.planName ?? "None"} (${currentSub?.status.name ?? "N/A"}) - Business: ${currentSub?.businessId ?? "N/A"}',
          );

          bool shouldUpdate = false;
          String reason = '';

          // Rule 1: No local subscription exists - accept any cloud subscription
          if (currentSub == null) {
            shouldUpdate = true;
            reason = 'No local subscription';
          }
          // Rule 2: Same subscription ID - always sync changes
          else if (subscription.id == currentSub.id) {
            shouldUpdate = true;
            reason = 'Same subscription ID - syncing updates';
          }
          // Rule 3: Cloud has PAID plan, local has FREE - ALWAYS update (ignore business ID mismatch)
          else if (subscription.plan != SubscriptionPlan.free &&
              currentSub.plan == SubscriptionPlan.free) {
            shouldUpdate = true;
            reason =
                'Cloud has paid plan, local is free (overriding business ID check)';
          }
          // Rule 4: Cloud has active paid subscription, local doesn't - ALWAYS update
          else if (subscription.plan != SubscriptionPlan.free &&
              subscription.status == SubscriptionStatus.active &&
              currentSub.status != SubscriptionStatus.active) {
            shouldUpdate = true;
            reason = 'Cloud has active paid plan, local is not active';
          }
          // Rule 5: Same business ID - check other criteria
          else if (subscription.businessId == currentSub.businessId) {
            // Cloud has active subscription, local doesn't
            if (subscription.status == SubscriptionStatus.active &&
                currentSub.status != SubscriptionStatus.active) {
              shouldUpdate = true;
              reason = 'Cloud is active, local is not (same business)';
            }
            // Cloud subscription is newer by creation date
            else if (subscription.createdAt.isAfter(currentSub.createdAt)) {
              shouldUpdate = true;
              reason = 'Cloud subscription is newer (same business)';
            }
            // Cloud subscription has later end date (renewed/extended)
            else if (subscription.status == SubscriptionStatus.active &&
                currentSub.status == SubscriptionStatus.active &&
                subscription.endDate.isAfter(currentSub.endDate)) {
              shouldUpdate = true;
              reason = 'Cloud subscription has later end date (same business)';
            }
          }
          // Rule 6: Different business ID with free plan - skip
          else if (subscription.businessId != currentSub.businessId &&
              subscription.plan == SubscriptionPlan.free) {
            shouldUpdate = false;
            reason = 'Different business ID with free plan - skipping';
          }

          if (shouldUpdate) {
            print('✅ Updating: $reason');
            await _subscriptionService!.saveSubscription(subscription);
            print(
              '🔄 Updated subscription from cloud: ${subscription.planName} (${subscription.status.name})',
            );
          } else {
            print(
              '⏭️ Skipped: ${reason.isEmpty ? "Local is current" : reason}',
            );
          }
        } catch (e) {
          print('❌ Error processing cloud subscription: $e');
        }
      }
      print('✅ Subscriptions synced to local');
    } catch (e) {
      print('❌ Error syncing subscriptions from cloud: $e');
    }
  }

  /// Listen to cloud business settings
  void _listenToBusinessSettings() {
    if (_businessSettingsController == null) return;

    // DISABLED: Settings are now embedded in business document, not a subcollection
    // The business_settings_controller handles settings via embedded model
    print(
      'ℹ️ Business settings listener skipped - settings are embedded in business document',
    );
    return;

    /* DISABLED CODE - Settings now embedded
    try {
      _syncService.listenToCollection('business_settings').listen((
        cloudSettings,
      ) {
        print(
          '📥 Received ${cloudSettings.length} business settings from cloud',
        );
        _syncBusinessSettingsFromCloud(cloudSettings);
      });
      print('👂 Listening to cloud business settings');
    } catch (e) {
      print('❌ Failed to listen to business settings: $e');
    }
    */
  }

  /// Sync business settings from cloud to local
  Future<void> _syncBusinessSettingsFromCloud(
    List<Map<String, dynamic>> cloudSettings,
  ) async {
    try {
      if (cloudSettings.isEmpty) {
        print('⚠️ No business settings found in cloud');
        return;
      }

      // Take the first settings document (should only be one per business)
      final settings = cloudSettings.first;

      // Update local settings
      if (settings.containsKey('storeName')) {
        _businessSettingsController!.storeName.value =
            settings['storeName'] ?? '';
      }
      if (settings.containsKey('storeAddress')) {
        _businessSettingsController!.storeAddress.value =
            settings['storeAddress'] ?? '';
      }
      if (settings.containsKey('storePhone')) {
        _businessSettingsController!.storePhone.value =
            settings['storePhone'] ?? '';
      }
      if (settings.containsKey('storeEmail')) {
        _businessSettingsController!.storeEmail.value =
            settings['storeEmail'] ?? '';
      }
      if (settings.containsKey('storeTaxId')) {
        _businessSettingsController!.storeTaxId.value =
            settings['storeTaxId'] ?? '';
      }
      if (settings.containsKey('storeLogo')) {
        _businessSettingsController!.storeLogo.value =
            settings['storeLogo'] ?? '';
      }

      // Tax Configuration
      if (settings.containsKey('taxEnabled')) {
        _businessSettingsController!.taxEnabled.value =
            settings['taxEnabled'] ?? true;
      }
      if (settings.containsKey('taxRate')) {
        _businessSettingsController!.taxRate.value =
            (settings['taxRate'] as num?)?.toDouble() ?? 0.0;
      }
      if (settings.containsKey('taxName')) {
        _businessSettingsController!.taxName.value =
            settings['taxName'] ?? 'VAT';
      }
      if (settings.containsKey('includeTaxInPrice')) {
        _businessSettingsController!.includeTaxInPrice.value =
            settings['includeTaxInPrice'] ?? false;
      }

      // Currency Settings
      if (settings.containsKey('currency')) {
        _businessSettingsController!.currency.value =
            settings['currency'] ?? 'ZMW';
      }
      if (settings.containsKey('currencySymbol')) {
        _businessSettingsController!.currencySymbol.value =
            settings['currencySymbol'] ?? 'K';
      }
      if (settings.containsKey('currencyPosition')) {
        _businessSettingsController!.currencyPosition.value =
            settings['currencyPosition'] ?? 'before';
      }

      // Receipt Settings
      if (settings.containsKey('receiptHeader')) {
        _businessSettingsController!.receiptHeader.value =
            settings['receiptHeader'] ?? '';
      }
      if (settings.containsKey('receiptFooter')) {
        _businessSettingsController!.receiptFooter.value =
            settings['receiptFooter'] ?? 'Thank you for your business!';
      }
      if (settings.containsKey('showLogo')) {
        _businessSettingsController!.showLogo.value =
            settings['showLogo'] ?? true;
      }
      if (settings.containsKey('showTaxBreakdown')) {
        _businessSettingsController!.showTaxBreakdown.value =
            settings['showTaxBreakdown'] ?? true;
      }
      if (settings.containsKey('receiptWidth')) {
        _businessSettingsController!.receiptWidth.value =
            settings['receiptWidth'] ?? 80;
      }

      // Receipt Printer Settings
      if (settings.containsKey('receiptPrinterName')) {
        _businessSettingsController!.receiptPrinterName.value =
            settings['receiptPrinterName'] ?? '';
      }
      if (settings.containsKey('receiptPrinterType')) {
        _businessSettingsController!.receiptPrinterType.value =
            settings['receiptPrinterType'] ?? 'USB';
      }
      if (settings.containsKey('receiptPrinterAddress')) {
        _businessSettingsController!.receiptPrinterAddress.value =
            settings['receiptPrinterAddress'] ?? '';
      }
      if (settings.containsKey('receiptPrinterPort')) {
        _businessSettingsController!.receiptPrinterPort.value =
            settings['receiptPrinterPort'] ?? '9100';
      }

      // Operating Hours
      if (settings.containsKey('openingTime')) {
        _businessSettingsController!.openingTime.value =
            settings['openingTime'] ?? '09:00';
      }
      if (settings.containsKey('closingTime')) {
        _businessSettingsController!.closingTime.value =
            settings['closingTime'] ?? '21:00';
      }
      if (settings.containsKey('operatingDays')) {
        _businessSettingsController!.operatingDays.value = List<String>.from(
          settings['operatingDays'] ??
              [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
              ],
        );
      }

      // Payment Methods
      if (settings.containsKey('acceptCash')) {
        _businessSettingsController!.acceptCash.value =
            settings['acceptCash'] ?? true;
      }
      if (settings.containsKey('acceptCard')) {
        _businessSettingsController!.acceptCard.value =
            settings['acceptCard'] ?? true;
      }
      if (settings.containsKey('acceptMobile')) {
        _businessSettingsController!.acceptMobile.value =
            settings['acceptMobile'] ?? true;
      }

      // Save to local storage
      await _businessSettingsController!.saveSettings();

      print('✅ Business settings synced from cloud');
    } catch (e) {
      print('❌ Error syncing business settings from cloud: $e');
    }
  }

  /// Sync wallet immediately when it's updated
  Future<void> syncWallet(WalletModel wallet) async {
    try {
      await _syncService.pushToCloud(
        'wallets',
        wallet.businessId,
        wallet.toJson(),
      );
      print('☁️ Wallet ${wallet.businessName} synced');
    } catch (e) {
      print('❌ Failed to sync wallet: $e');
    }
  }

  /// Sync subscription immediately when it's updated
  Future<void> syncSubscription(SubscriptionModel subscription) async {
    try {
      await _syncService.pushToCloud(
        'subscriptions',
        subscription.id,
        subscription.toJson(),
      );
      print('☁️ Subscription ${subscription.planName} synced to cloud');
    } catch (e) {
      print('❌ Failed to sync subscription: $e');
    }
  }

  /// Force pull subscriptions from cloud (manual sync)
  Future<void> forceSubscriptionSync() async {
    try {
      print('🔄 Forcing subscription sync from cloud...');

      // Temporarily store current subscription
      final currentSub = _subscriptionService?.currentSubscription.value;
      print(
        '📱 Current local: ${currentSub?.planName ?? "None"} (${currentSub?.status.name ?? "N/A"})',
      );

      // Fetch all subscriptions from cloud for this business
      final businessId = _syncService.businessId;
      if (businessId == null) {
        print('❌ No business ID available');
        return;
      }

      // Query Firestore for subscriptions matching this business
      final cloudSubs = await _syncService.getCollectionData('subscriptions');
      print('☁️ Found ${cloudSubs.length} total subscriptions in cloud');

      // Filter for this business
      final businessSubs = cloudSubs
          .where(
            (sub) =>
                sub['businessId'] == businessId ||
                sub['business_id'] == businessId,
          )
          .toList();

      print('☁️ Found ${businessSubs.length} subscriptions for this business');

      if (businessSubs.isEmpty) {
        print('⚠️ No subscriptions found in cloud for this business');
        // Push current subscription if it exists
        if (currentSub != null) {
          print('📤 Pushing current subscription to cloud...');
          await syncSubscription(currentSub);
        }
        return;
      }

      // Process cloud subscriptions
      await _syncSubscriptionsFromCloud(businessSubs);

      print('✅ Force sync complete');
    } catch (e) {
      print('❌ Error forcing subscription sync: $e');
    }
  }

  /// Sync business settings immediately when updated
  Future<void> syncBusinessSettingsNow() async {
    await _syncBusinessSettings();
  }
}
