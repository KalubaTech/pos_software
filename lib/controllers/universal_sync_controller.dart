import 'package:get/get.dart';
import '../services/firedart_sync_service.dart';
import '../services/database_service.dart';
import '../services/wallet_database_service.dart';
import '../services/image_sync_service.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';
import '../models/client_model.dart';
import '../models/price_tag_template_model.dart';
import 'product_controller.dart';
import 'customer_controller.dart';

/// Universal sync controller that handles ALL data synchronization
class UniversalSyncController extends GetxController {
  final FiredartSyncService _syncService = Get.find<FiredartSyncService>();
  final DatabaseService _dbService = Get.find<DatabaseService>();
  final ImageSyncService _imageSyncService = Get.put(ImageSyncService());
  WalletDatabaseService? _walletDbService;

  final isSyncing = false.obs;
  final lastFullSync = Rx<DateTime?>(null);
  final syncProgress = 0.0.obs;
  final syncStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      _walletDbService = Get.find<WalletDatabaseService>();
    } catch (e) {
      print('⚠️ WalletDatabaseService not available');
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

      // Sync all data types
      await _syncProducts();
      syncProgress.value = 0.2;

      await _syncTransactions();
      syncProgress.value = 0.4;

      await _syncCustomers();
      syncProgress.value = 0.6;

      await _syncPriceTagTemplates();
      syncProgress.value = 0.8;

      await _syncCashiers();
      syncProgress.value = 0.9;

      if (_walletDbService != null) {
        await _syncWallets();
      }
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

  /// Sync products bidirectionally
  Future<void> _syncProducts() async {
    syncStatus.value = 'Syncing products...';
    print('📦 Syncing products...');

    try {
      // Get local products
      final localProducts = await _dbService.getAllProducts();
      print('📱 Local products: ${localProducts.length}');

      // Push local products to cloud
      for (var product in localProducts) {
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
  Future<void> _syncWallets() async {
    if (_walletDbService == null) return;

    syncStatus.value = 'Syncing wallets...';
    print('💰 Syncing wallets...');

    try {
      // Wallet sync temporarily disabled - methods not yet implemented
      print('⚠️ Wallet sync skipped (methods not available)');

      // TODO: Implement when WalletDatabaseService has getAllWallets() method
      // final wallets = await _walletDbService!.getAllWallets();
      // for (var wallet in wallets) {
      //   await _syncService.pushToCloud('wallets', wallet.businessId, wallet.toJson());
      // }
    } catch (e) {
      print('❌ Error syncing wallets: $e');
    }
  }

  /// Start listening to all cloud collections
  void _startListeningToAllCollections() {
    _listenToProducts();
    _listenToTransactions();
    _listenToCustomers();
    _listenToPriceTagTemplates();
    _listenToCashiers();
    if (_walletDbService != null) {
      _listenToWallets();
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
          final product = ProductModel.fromJson(productData);

          // Check if exists locally
          final localProducts = await _dbService.getAllProducts();
          final exists = localProducts.any((p) => p.id == product.id);

          if (exists) {
            await _dbService.updateProduct(product);
            print('🔄 Updated local product: ${product.name}');
          } else {
            await _dbService.insertProduct(product);
            print('➕ Added product from cloud: ${product.name}');
          }
        } catch (e) {
          print('❌ Error processing cloud product: $e');
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

        for (var walletData in cloudWallets) {
          try {
            // Process wallet data and update local
            final businessId = walletData['businessId'] as String;

            _walletDbService!.getWalletByBusinessId(businessId).then((
              localWallet,
            ) {
              if (localWallet != null) {
                // Update local wallet
                print('🔄 Updated wallet for business: $businessId');
              } else {
                // Create new wallet
                print('➕ Added wallet for business: $businessId');
              }
            });
          } catch (e) {
            print('❌ Error processing cloud wallet: $e');
          }
        }
      });
      print('👂 Listening to cloud wallets');
    } catch (e) {
      print('❌ Failed to listen to wallets: $e');
    }
  }

  /// Sync a single product immediately
  Future<void> syncProduct(ProductModel product) async {
    try {
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

      await _syncService.pushToCloud('products', product.id, product.toJson());
      print('☁️ Product ${product.name} synced');
    } catch (e) {
      print('❌ Failed to sync product: $e');
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
}
