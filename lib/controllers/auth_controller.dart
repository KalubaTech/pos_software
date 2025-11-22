import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/cashier_model.dart';
import '../services/database_service.dart';
import '../services/firedart_sync_service.dart';
import '../services/business_service.dart';
import '../controllers/universal_sync_controller.dart';
import '../controllers/online_orders_controller.dart';

class AuthController extends GetxController {
  final GetStorage _storage = GetStorage();
  final DatabaseService _db = Get.find<DatabaseService>();

  var isAuthenticated = false.obs;
  var currentCashier = Rx<CashierModel?>(null);
  var cashiers = <CashierModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    await _initializeCashiers();
    _checkStoredSession();
  }

  Future<void> _initializeCashiers() async {
    isLoading.value = true;
    try {
      print('=== INITIALIZING CASHIERS ===');
      // Load cashiers from database
      final cashiersData = await _db.getAllCashiers();
      print('Cashiers from DB: ${cashiersData.length}');

      // If no cashiers exist, create default admin
      if (cashiersData.isEmpty) {
        print('No cashiers found, creating defaults...');
        await _createDefaultCashiers();
      } else {
        cashiers.value = cashiersData
            .map((data) => CashierModel.fromJson(data))
            .toList();
        print('Loaded cashiers:');
        for (var cashier in cashiers) {
          print(
            '  - ${cashier.name} (PIN: ${cashier.pin}, Active: ${cashier.isActive})',
          );
        }
      }
    } catch (e) {
      print('Error initializing cashiers: $e');
      // Fallback to default cashiers if database fails
      await _createDefaultCashiers();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _createDefaultCashiers() async {
    final defaultCashiers = [
      CashierModel(
        id: 'c1',
        name: 'Admin User',
        email: 'admin@dynamospos.com',
        pin: '1234',
        role: UserRole.admin,
        createdAt: DateTime.now().subtract(Duration(days: 365)),
        isActive: true,
        businessId: 'default_business_001', // Default testing business
      ),
      CashierModel(
        id: 'c2',
        name: 'John Cashier',
        email: 'john@dynamospos.com',
        pin: '1111',
        role: UserRole.cashier,
        createdAt: DateTime.now().subtract(Duration(days: 90)),
        isActive: true,
        businessId: 'default_business_001',
      ),
      CashierModel(
        id: 'c3',
        name: 'Sarah Manager',
        email: 'sarah@dynamospos.com',
        pin: '2222',
        role: UserRole.manager,
        createdAt: DateTime.now().subtract(Duration(days: 180)),
        isActive: true,
        businessId: 'default_business_001',
      ),
      CashierModel(
        id: 'c4',
        name: 'Mike Sales',
        email: 'mike@dynamospos.com',
        pin: '3333',
        role: UserRole.cashier,
        createdAt: DateTime.now().subtract(Duration(days: 60)),
        isActive: true,
        businessId: 'default_business_001',
      ),
    ];

    for (var cashier in defaultCashiers) {
      await _db.insertCashier(
        cashier.toSQLite(),
      ); // Use toSQLite() for database
    }

    cashiers.value = defaultCashiers;
  }

  void _checkStoredSession() {
    print('=== CHECKING STORED SESSION ===');
    final cashierId = _storage.read('currentCashierId');
    print('Stored cashier ID: $cashierId');
    if (cashierId != null) {
      final cashier = cashiers.firstWhereOrNull((c) => c.id == cashierId);
      if (cashier != null) {
        print('Found stored session for: ${cashier.name}');
        currentCashier.value = cashier;
        isAuthenticated.value = true;

        // Initialize business sync for stored session
        _initializeBusinessSync(cashier.businessId);
      } else {
        print('Stored cashier not found in loaded cashiers');
      }
    } else {
      print('No stored session found');
    }
  }

  /// Fetch cashier from Firestore by PIN or Email+PIN
  /// This is used as a fallback when cashier is not found in local database
  Future<CashierModel?> _fetchCashierFromFirestore(
    String emailOrPin,
    String? pin,
  ) async {
    try {
      print('🔍 Searching Firestore for cashier...');
      final syncService = Get.find<FiredartSyncService>();

      // Get all businesses from the businesses collection
      final businesses = await syncService.getTopLevelCollectionData(
        'businesses',
      );
      print('📊 Found ${businesses.length} businesses in Firestore');

      // Search through each business's cashiers subcollection
      for (var business in businesses) {
        final businessId = business['id'] as String;
        print(
          '🔍 Checking cashiers in business: ${business['name']} ($businessId)',
        );

        try {
          // Get all cashiers for this business using full path
          // We need to query Firestore directly since businessId isn't initialized yet
          final cashiersPath = 'businesses/$businessId/cashiers';
          final cashiersSnapshot = await syncService.firestore
              .collection(cashiersPath)
              .get();

          print(
            '   Found ${cashiersSnapshot.length} cashiers in this business',
          );

          for (var cashierDoc in cashiersSnapshot) {
            final cashierData = {'id': cashierDoc.id, ...cashierDoc.map};

            // Check if this is the cashier we're looking for
            bool matches = false;
            if (pin != null) {
              // Email + PIN mode
              matches =
                  cashierData['email'] == emailOrPin &&
                  cashierData['pin'] == pin;
            } else {
              // PIN only mode
              matches = cashierData['pin'] == emailOrPin;
            }

            if (matches) {
              print(
                '✅ Found matching cashier: ${cashierData['name']} in business $businessId',
              );

              try {
                // Debug: Print all fields
                print('📋 Raw cashier fields from Firestore:');
                cashierData.forEach((key, value) {
                  print('   $key: $value (${value?.runtimeType})');
                });

                // Normalize field names (Firestore uses snake_case, model uses camelCase)
                // Handle both formats for compatibility
                final createdAtStr =
                    cashierData['created_at'] ??
                    cashierData['createdAt'] ??
                    DateTime.now().toIso8601String();

                final lastLoginStr =
                    cashierData['last_login'] ?? cashierData['lastLogin'];

                final normalizedData = {
                  'id': cashierData['id'] as String? ?? 'MISSING_ID',
                  'name': cashierData['name'] as String? ?? 'MISSING_NAME',
                  'email': cashierData['email'] as String? ?? 'MISSING_EMAIL',
                  'pin': cashierData['pin'] as String? ?? 'MISSING_PIN',
                  'role': cashierData['role'] as String? ?? 'cashier',
                  'businessId':
                      (cashierData['business_id'] ??
                              cashierData['businessId'] ??
                              businessId)
                          as String,
                  'isActive':
                      cashierData['is_active'] ??
                      cashierData['isActive'] ??
                      true,
                  'createdAt': createdAtStr,
                  'lastLogin': lastLoginStr,
                  'profileImageUrl':
                      cashierData['photo'] ?? cashierData['profileImageUrl'],
                };

                print('📝 Normalized cashier data:');
                normalizedData.forEach((key, value) {
                  print('   $key: $value');
                });

                return CashierModel.fromJson(normalizedData);
              } catch (e, stackTrace) {
                print('❌ Error creating CashierModel: $e');
                print('   Stack trace: $stackTrace');
                // Don't throw, just continue to next cashier
                continue;
              }
            }
          }
        } catch (e) {
          print('⚠️ Error reading cashiers for business $businessId: $e');
          // Continue to next business
          continue;
        }
      }

      print('❌ No matching cashier found in any business');
      return null;
    } catch (e) {
      print('❌ Error fetching cashier from Firestore: $e');
      return null;
    }
  }

  Future<bool> login(String emailOrPin, {String? pin}) async {
    try {
      print('=== LOGIN ATTEMPT ===');
      print('Input: $emailOrPin');
      print('Cashiers count: ${cashiers.length}');

      CashierModel? cashier;

      // If pin parameter is provided, it's email+PIN login
      if (pin != null) {
        print('Login mode: Email + PIN');
        print('Email: $emailOrPin, PIN: $pin');

        // Query database for cashier with matching email and PIN
        final cashierData = await _db.getCashierByEmailAndPin(emailOrPin, pin);
        if (cashierData != null) {
          cashier = CashierModel.fromJson(cashierData);
          print('✅ Found cashier by email+PIN: ${cashier.name}');
        }
      } else {
        // PIN-only login (backward compatibility)
        print('Login mode: PIN only');
        print('PIN: $emailOrPin');

        final cashierData = await _db.getCashierByPin(emailOrPin);
        if (cashierData != null) {
          cashier = CashierModel.fromJson(cashierData);
          print('✅ Found cashier by PIN: ${cashier.name}');
        } else {
          // Fallback: Check in memory
          cashier = cashiers.firstWhereOrNull(
            (c) => c.pin == emailOrPin && c.isActive,
          );
          if (cashier != null) {
            print('✅ Found cashier in memory: ${cashier.name}');
          }
        }
      }

      if (cashier == null) {
        print('⚠️ Cashier not found in local database, checking Firestore...');
        // Try to fetch from Firestore as fallback
        cashier = await _fetchCashierFromFirestore(emailOrPin, pin);

        if (cashier != null) {
          print('✅ Found cashier in Firestore, syncing to local database...');
          // Sync to local database for future logins (use toSQLite for SQLite compatibility)
          await _db.insertCashier(cashier.toSQLite());
          // Add to memory
          cashiers.add(cashier);
        } else {
          print('❌ No cashier found in database or Firestore');
          return false;
        }
      }

      if (!cashier.isActive) {
        print('❌ Cashier account is inactive');
        return false;
      }

      // Update current cashier
      currentCashier.value = cashier.copyWith(lastLogin: DateTime.now());
      isAuthenticated.value = true;

      // Update last login in database
      await _db.updateCashierLastLogin(cashier.id, DateTime.now());

      // Store session
      await _storage.write('currentCashierId', cashier.id);

      print(
        '✅ Login successful! User: ${cashier.name}, Business: ${cashier.businessId ?? "default"}',
      );

      // Initialize business sync in background (non-blocking)
      _initializeBusinessSync(cashier.businessId);

      return true;
    } catch (e) {
      print('❌ Login error: $e');
      print('Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  /// Initialize business sync after successful login
  Future<void> _initializeBusinessSync(String? businessId) async {
    try {
      print('🔄 Initializing business sync...');

      // Determine business ID
      String finalBusinessId;

      if (businessId != null && businessId.isNotEmpty) {
        // User has a registered business
        finalBusinessId = businessId;
        print('📊 Using registered business: $businessId');

        // Load business details
        final businessService = Get.find<BusinessService>();
        await businessService.getBusinessById(businessId);
      } else {
        // No business assigned - use default for testing
        finalBusinessId = 'default_business_001';
        print('⚠️ No business assigned, using default: $finalBusinessId');

        // Create default business settings if needed
        await _createDefaultBusinessSettings();
      }

      // Store business ID
      await _storage.write('business_id', finalBusinessId);

      // Initialize sync service
      final syncService = Get.find<FiredartSyncService>();
      await syncService.initialize(finalBusinessId);
      print('✅ Sync service initialized for business: $finalBusinessId');

      // Re-initialize Online Orders Controller
      try {
        final onlineOrdersController = Get.find<OnlineOrdersController>();
        await onlineOrdersController.reinitialize(finalBusinessId);
        print('✅ Online Orders reinitialized for business: $finalBusinessId');
      } catch (e) {
        print('⚠️ Online Orders Controller error: $e');
      }

      // Start universal sync and WAIT for it to complete
      try {
        final universalSync = Get.find<UniversalSyncController>();
        print('🔄 Starting full data sync...');

        // Show loading indicator
        Get.snackbar(
          '🔄 Syncing Data',
          'Downloading business data from cloud...',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
          showProgressIndicator: true,
        );

        // AWAIT the sync to ensure data is loaded before proceeding
        await universalSync.performFullSync();
        print('✅ Full sync completed');
      } catch (e) {
        print('⚠️ Universal sync error: $e');
        Get.snackbar(
          '⚠️ Sync Warning',
          'Could not sync all data: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }

      print('🎉 Business sync initialization complete!');
    } catch (e) {
      print('❌ Error initializing business sync: $e');
      // Don't fail login if sync fails
    }
  }

  /// Create default business settings for testing
  Future<void> _createDefaultBusinessSettings() async {
    try {
      final businessService = Get.find<BusinessService>();
      final defaultBusiness = await businessService.getBusinessById(
        'default_business_001',
      );

      if (defaultBusiness == null) {
        print('📝 Creating default business for testing...');
        // The business will be created in Firestore when sync starts
      }
    } catch (e) {
      print('⚠️ Could not create default business: $e');
    }
  }

  Future<void> logout() async {
    currentCashier.value = null;
    isAuthenticated.value = false;
    await _storage.remove('currentCashierId');

    Get.snackbar(
      'Logged Out',
      'You have been logged out successfully',
      snackPosition: SnackPosition.TOP,
    );
  }

  Future<bool> addCashier(
    CashierModel cashier, {
    bool isFirstCashier = false,
  }) async {
    try {
      // Allow adding first cashier during business registration (when no cashiers exist)
      // Otherwise, require admin permission
      final isRegistrationFlow = cashiers.isEmpty || isFirstCashier;

      if (!isRegistrationFlow && !hasPermission(UserRole.admin)) {
        Get.snackbar(
          'Access Denied',
          'Only admins can add cashiers',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // Validate email uniqueness
      final isEmailUnique = await _db.isEmailUnique(cashier.email);
      if (!isEmailUnique) {
        Get.snackbar(
          'Error',
          'Email already exists. Please use a different email.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return false;
      }

      // Validate PIN uniqueness
      final isPinUnique = await _db.isPinUnique(cashier.pin);
      if (!isPinUnique) {
        Get.snackbar(
          'Error',
          'PIN already in use. Please use a different PIN.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return false;
      }

      // Save to database (use toSQLite for SQLite compatibility)
      final result = await _db.insertCashier(cashier.toSQLite());

      if (result > 0) {
        // Update local list
        cashiers.add(cashier);

        // Only show success message if not during registration flow
        if (!isRegistrationFlow) {
          Get.snackbar(
            'Success',
            'Cashier added successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add cashier: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> updateCashier(CashierModel cashier) async {
    try {
      if (!hasPermission(UserRole.admin)) {
        Get.snackbar(
          'Access Denied',
          'Only admins can update cashiers',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // Update in database
      final result = await _db.updateCashier(cashier.id, cashier.toJson());

      if (result > 0) {
        // Update local list
        final index = cashiers.indexWhere((c) => c.id == cashier.id);
        if (index != -1) {
          cashiers[index] = cashier;
        }
        Get.snackbar(
          'Success',
          'Cashier updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update cashier: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> deleteCashier(String id) async {
    try {
      if (!hasPermission(UserRole.admin)) {
        Get.snackbar(
          'Access Denied',
          'Only admins can delete cashiers',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      if (currentCashier.value?.id == id) {
        Get.snackbar(
          'Error',
          'Cannot delete currently logged in cashier',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // Delete from database
      final result = await _db.deleteCashier(id);

      if (result > 0) {
        // Remove from local list
        cashiers.removeWhere((c) => c.id == id);
        Get.snackbar(
          'Success',
          'Cashier deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete cashier: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  bool hasPermission(UserRole requiredRole) {
    if (currentCashier.value == null) return false;

    final currentRole = currentCashier.value!.role;

    switch (requiredRole) {
      case UserRole.admin:
        return currentRole == UserRole.admin;
      case UserRole.manager:
        return currentRole == UserRole.admin || currentRole == UserRole.manager;
      case UserRole.cashier:
        return true; // All roles can do cashier tasks
    }
  }

  String get currentCashierName => currentCashier.value?.name ?? 'Guest';
  String get currentCashierId => currentCashier.value?.id ?? '';
  UserRole? get currentRole => currentCashier.value?.role;
}
