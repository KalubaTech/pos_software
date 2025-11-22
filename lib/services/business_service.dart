import 'package:get/get.dart';
import '../models/business_model.dart';
import '../services/firedart_sync_service.dart';
import '../controllers/business_settings_controller.dart';
import 'package:get_storage/get_storage.dart';

/// Business service for managing business operations in Firestore
class BusinessService extends GetxController {
  final FiredartSyncService _syncService = Get.find<FiredartSyncService>();
  final GetStorage _storage = GetStorage();

  final currentBusiness = Rx<BusinessModel?>(null);
  final isLoading = false.obs;
  final error = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadStoredBusiness();
  }

  /// Load business from local storage
  Future<void> _loadStoredBusiness() async {
    try {
      final businessId = _storage.read('current_business_id');
      if (businessId != null) {
        print('📦 Loading stored business: $businessId');
        await getBusinessById(businessId);
      }
    } catch (e) {
      print('❌ Error loading stored business: $e');
    }
  }

  /// Register a new business with complete data
  Future<BusinessModel?> registerBusiness({
    String? businessId,
    required String name,
    String? businessType,
    required String email,
    required String phone,
    required String address,
    required String city, // Now REQUIRED
    required String country, // Now REQUIRED
    double? latitude,
    double? longitude,
    String? taxId,
    String? website,
    required String adminId,
    Map<String, dynamic>? adminCashierData,
    Map<String, dynamic>? settings, // Optional initial settings
  }) async {
    try {
      isLoading.value = true;
      error.value = null;

      print('🏢 Registering new business: $name');

      // Generate unique business ID
      final finalBusinessId =
          businessId ?? 'BUS_${DateTime.now().millisecondsSinceEpoch}';

      // Default settings if not provided
      final defaultSettings =
          settings ??
          {
            'currency': 'ZMW',
            'currency_symbol': 'K',
            'currency_position': 'before',
            'tax_enabled': true,
            'tax_rate': 16.0,
            'tax_name': 'VAT',
            'include_tax_in_price': true,
            'opening_time': '09:00',
            'closing_time': '21:00',
            'accept_cash': true,
            'accept_card': true,
            'accept_mobile': true,
            'receipt_header': 'Thank you for your purchase',
            'receipt_footer': 'Please visit again!',
            'receipt_show_logo': true,
          };

      // Create business model
      final business = BusinessModel(
        id: finalBusinessId,
        name: name,
        businessType: businessType,
        email: email,
        phone: phone,
        address: address,
        city: city,
        country: country,
        latitude: latitude,
        longitude: longitude,
        taxId: taxId,
        website: website,
        adminId: adminId,
        status: BusinessStatus.active,
        createdAt: DateTime.now(),
        settings: defaultSettings,
        onlineStoreEnabled: false,
      );

      // Prepare complete business document
      final businessDoc = business.toJson();
      businessDoc['updated_at'] = DateTime.now().toIso8601String();
      businessDoc['online_product_count'] = 0;

      // If admin cashier data provided, save to cashiers subcollection
      if (adminCashierData != null) {
        print('📝 Admin cashier will be saved to cashiers subcollection');
      }

      // Save to Firestore (SINGLE LOCATION ONLY - businesses collection)
      await _syncService.pushToCloud(
        'businesses',
        business.id,
        businessDoc,
        isTopLevel: true,
      );

      print('✅ Business registered successfully: ${business.id}');
      print('   📍 Location: $city, $country');
      if (latitude != null && longitude != null) {
        print('   🗺️  Coordinates: $latitude, $longitude');
      }

      // Save admin cashier to subcollection
      if (adminCashierData != null) {
        try {
          print('📝 Saving admin cashier to Firestore...');
          print('   Cashier ID: ${adminCashierData['id']}');
          print('   Cashier Name: ${adminCashierData['name']}');
          print('   Cashier PIN: ${adminCashierData['pin']}');
          print(
            '   Business ID: ${adminCashierData['businessId'] ?? adminCashierData['business_id']}',
          );

          // Initialize sync service with business ID first
          await _syncService.initialize(business.id);

          // Use 'cashiers' as collection name (not full path)
          // isTopLevel: false will prepend 'businesses/{businessId}/'
          await _syncService.pushToCloud(
            'cashiers', // Just the subcollection name
            adminCashierData['id'],
            adminCashierData,
            isTopLevel:
                false, // Will create: businesses/{businessId}/cashiers/{cashierId}
          );
          print('✅ Admin cashier saved to Firestore successfully');
        } catch (e) {
          print('❌ Error saving admin cashier to Firestore: $e');
          // Don't fail the entire registration if cashier sync fails
          // The cashier is already in SQLite
        }
      } else {
        print('⚠️ No admin cashier data provided');
      }

      // Store locally
      currentBusiness.value = business;
      await _storage.write('current_business_id', business.id);

      // Initialize BusinessSettingsController with registered business data
      try {
        if (Get.isRegistered<BusinessSettingsController>()) {
          final settingsController = Get.find<BusinessSettingsController>();
          print('📝 Initializing Business Settings with registration data...');

          // Store Information
          settingsController.storeName.value = business.name;
          settingsController.storeAddress.value = business.address;
          settingsController.storePhone.value = business.phone;
          settingsController.storeEmail.value = business.email;
          if (business.taxId != null) {
            settingsController.storeTaxId.value = business.taxId!;
          }

          // Extract settings from business model
          if (business.settings != null) {
            final settings = business.settings!;

            // Tax settings
            if (settings.containsKey('tax_enabled')) {
              settingsController.taxEnabled.value =
                  settings['tax_enabled'] ?? true;
            }
            if (settings.containsKey('tax_rate')) {
              settingsController.taxRate.value =
                  (settings['tax_rate'] as num?)?.toDouble() ?? 16.0;
            }
            if (settings.containsKey('tax_name')) {
              settingsController.taxName.value = settings['tax_name'] ?? 'VAT';
            }

            // Currency settings
            if (settings.containsKey('currency')) {
              settingsController.currency.value = settings['currency'] ?? 'ZMW';
            }
            if (settings.containsKey('currency_symbol')) {
              settingsController.currencySymbol.value =
                  settings['currency_symbol'] ?? 'K';
            }

            // Receipt settings
            if (settings.containsKey('receipt_header')) {
              settingsController.receiptHeader.value =
                  settings['receipt_header'] ?? '';
            }
            if (settings.containsKey('receipt_footer')) {
              settingsController.receiptFooter.value =
                  settings['receipt_footer'] ?? 'Thank you for your business!';
            }
          }

          // Online Store (top-level field, not in settings)
          settingsController.onlineStoreEnabled.value =
              business.onlineStoreEnabled;
          print('   📱 Online Store: ${business.onlineStoreEnabled}');

          // Save to GetStorage immediately (DON'T call saveSettings to avoid snackbar)
          await _storage.write(
            'store_name',
            settingsController.storeName.value,
          );
          await _storage.write(
            'store_address',
            settingsController.storeAddress.value,
          );
          await _storage.write(
            'store_phone',
            settingsController.storePhone.value,
          );
          await _storage.write(
            'store_email',
            settingsController.storeEmail.value,
          );
          await _storage.write(
            'store_tax_id',
            settingsController.storeTaxId.value,
          );
          await _storage.write(
            'tax_enabled',
            settingsController.taxEnabled.value,
          );
          await _storage.write('tax_rate', settingsController.taxRate.value);
          await _storage.write('tax_name', settingsController.taxName.value);
          await _storage.write('currency', settingsController.currency.value);
          await _storage.write(
            'currency_symbol',
            settingsController.currencySymbol.value,
          );
          await _storage.write(
            'receipt_header',
            settingsController.receiptHeader.value,
          );
          await _storage.write(
            'receipt_footer',
            settingsController.receiptFooter.value,
          );
          await _storage.write(
            'online_store_enabled',
            settingsController.onlineStoreEnabled.value,
          );

          print('✅ Business Settings initialized successfully');
        }
      } catch (e) {
        print('⚠️ Could not initialize BusinessSettingsController: $e');
        // Not critical, settings can be loaded later
      }

      return business;
    } catch (e) {
      print('❌ Error registering business: $e');
      error.value = 'Failed to register business: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get business by ID from businesses collection
  Future<BusinessModel?> getBusinessById(String businessId) async {
    try {
      isLoading.value = true;
      error.value = null;

      print('🔍 Fetching business: $businessId');

      // Get from businesses collection (single source of truth)
      final data = await _syncService.getDocument('businesses', businessId);

      if (data != null) {
        final business = BusinessModel.fromJson(data);
        currentBusiness.value = business;
        await _storage.write('current_business_id', business.id);
        print('✅ Business loaded: ${business.name} (${business.status.name})');
        print('   📍 Location: ${business.city}, ${business.country}');

        // Initialize BusinessSettingsController with loaded business data
        try {
          if (Get.isRegistered<BusinessSettingsController>()) {
            final settingsController = Get.find<BusinessSettingsController>();
            print('📝 Initializing Business Settings from loaded business...');

            // Store Information
            settingsController.storeName.value = business.name;
            settingsController.storeAddress.value = business.address;
            settingsController.storePhone.value = business.phone;
            settingsController.storeEmail.value = business.email;
            if (business.taxId != null) {
              settingsController.storeTaxId.value = business.taxId!;
            }

            // Extract settings from business model
            if (business.settings != null) {
              final settings = business.settings!;

              // Tax settings
              if (settings.containsKey('tax_enabled')) {
                settingsController.taxEnabled.value =
                    settings['tax_enabled'] ?? true;
              }
              if (settings.containsKey('tax_rate')) {
                settingsController.taxRate.value =
                    (settings['tax_rate'] as num?)?.toDouble() ?? 16.0;
              }
              if (settings.containsKey('tax_name')) {
                settingsController.taxName.value =
                    settings['tax_name'] ?? 'VAT';
              }

              // Currency settings
              if (settings.containsKey('currency')) {
                settingsController.currency.value =
                    settings['currency'] ?? 'ZMW';
              }
              if (settings.containsKey('currency_symbol')) {
                settingsController.currencySymbol.value =
                    settings['currency_symbol'] ?? 'K';
              }

              // Receipt settings
              if (settings.containsKey('receipt_header')) {
                settingsController.receiptHeader.value =
                    settings['receipt_header'] ?? '';
              }
              if (settings.containsKey('receipt_footer')) {
                settingsController.receiptFooter.value =
                    settings['receipt_footer'] ??
                    'Thank you for your business!';
              }
            }

            // Online Store (top-level field, not in settings)
            settingsController.onlineStoreEnabled.value =
                business.onlineStoreEnabled;
            print('   📱 Online Store: ${business.onlineStoreEnabled}');

            // Save to GetStorage (DON'T call saveSettings to avoid snackbar)
            await _storage.write(
              'store_name',
              settingsController.storeName.value,
            );
            await _storage.write(
              'store_address',
              settingsController.storeAddress.value,
            );
            await _storage.write(
              'store_phone',
              settingsController.storePhone.value,
            );
            await _storage.write(
              'store_email',
              settingsController.storeEmail.value,
            );
            await _storage.write(
              'store_tax_id',
              settingsController.storeTaxId.value,
            );
            await _storage.write(
              'tax_enabled',
              settingsController.taxEnabled.value,
            );
            await _storage.write('tax_rate', settingsController.taxRate.value);
            await _storage.write('tax_name', settingsController.taxName.value);
            await _storage.write('currency', settingsController.currency.value);
            await _storage.write(
              'currency_symbol',
              settingsController.currencySymbol.value,
            );
            await _storage.write(
              'receipt_header',
              settingsController.receiptHeader.value,
            );
            await _storage.write(
              'receipt_footer',
              settingsController.receiptFooter.value,
            );
            await _storage.write(
              'online_store_enabled',
              settingsController.onlineStoreEnabled.value,
            );

            print('✅ Business Settings initialized from loaded business');
          }
        } catch (e) {
          print('⚠️ Could not initialize BusinessSettingsController: $e');
          // Not critical, settings can be loaded later
        }

        return business;
      }

      print('⚠️ Business not found: $businessId');
      return null;
    } catch (e) {
      print('❌ Error fetching business: $e');
      error.value = 'Failed to fetch business: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Check business status (called periodically)
  Future<BusinessStatus?> checkBusinessStatus() async {
    if (currentBusiness.value == null) return null;

    try {
      final business = await getBusinessById(currentBusiness.value!.id);
      return business?.status;
    } catch (e) {
      print('❌ Error checking business status: $e');
      return null;
    }
  }

  /// Update business information
  Future<bool> updateBusiness(BusinessModel business) async {
    try {
      isLoading.value = true;
      error.value = null;

      print('📝 Updating business: ${business.id}');

      // Prepare update data
      final updateData = business.toJson();
      updateData['updated_at'] = DateTime.now().toIso8601String();

      // Update in Firestore (single location)
      await _syncService.updateCloud(
        'businesses',
        business.id,
        updateData,
        isTopLevel: true,
      );

      print('✅ Business updated successfully');
      currentBusiness.value = business;

      return true;
    } catch (e) {
      print('❌ Error updating business: $e');
      error.value = 'Failed to update business: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Approve business (Admin only)
  Future<bool> approveBusiness(String businessId, String adminId) async {
    try {
      print('✅ Approving business: $businessId');

      final business = await getBusinessById(businessId);
      if (business == null) return false;

      final approvedBusiness = business.copyWith(
        status: BusinessStatus.active,
        approvedAt: DateTime.now(),
        approvedBy: adminId,
      );

      // Update in Firestore
      await _syncService.pushToCloud(
        'business_registrations',
        businessId,
        approvedBusiness.toJson(),
        isTopLevel: true,
      );

      // Also set up the business in the main businesses collection
      // This allows the business to start syncing data
      await _syncService.pushToCloud('businesses', businessId, {
        'id': businessId,
        'name': business.name,
        'email': business.email,
        'status': 'active',
        'admin_id': business.adminId,
        'approved_at': DateTime.now().toIso8601String(),
        'approved_by': adminId,
      });

      // Sync admin cashier to the business's cashiers collection
      try {
        // Fetch registration document to get admin cashier data
        final registrationDoc = await _syncService.getDocument(
          'business_registrations',
          businessId,
        );

        if (registrationDoc != null &&
            registrationDoc['admin_cashier'] != null) {
          final adminCashierData =
              registrationDoc['admin_cashier'] as Map<String, dynamic>;

          // Initialize sync service with business ID temporarily
          await _syncService.initialize(businessId);

          // Push admin cashier to businesses/{businessId}/cashiers/
          await _syncService.pushToCloud(
            'cashiers',
            adminCashierData['id'],
            adminCashierData,
            isTopLevel:
                false, // This will put it under businesses/{businessId}/
          );

          print('✅ Admin cashier synced to businesses/$businessId/cashiers/');
        } else {
          print('⚠️ No admin cashier data found in registration');
        }
      } catch (e) {
        print('⚠️ Could not sync admin cashier: $e');
        // Don't fail the entire approval if cashier sync fails
      }

      print('✅ Business approved and activated: ${business.name}');

      // Update current business if it's the same
      if (currentBusiness.value?.id == businessId) {
        currentBusiness.value = approvedBusiness;
      }

      return true;
    } catch (e) {
      print('❌ Error approving business: $e');
      return false;
    }
  }

  /// Reject business (Admin only)
  Future<bool> rejectBusiness(String businessId, String reason) async {
    try {
      print('❌ Rejecting business: $businessId');

      final business = await getBusinessById(businessId);
      if (business == null) return false;

      final rejectedBusiness = business.copyWith(
        status: BusinessStatus.rejected,
        rejectionReason: reason,
      );

      await _syncService.pushToCloud(
        'business_registrations',
        businessId,
        rejectedBusiness.toJson(),
        isTopLevel: true,
      );

      print('❌ Business rejected: ${business.name}');

      // Update current business if it's the same
      if (currentBusiness.value?.id == businessId) {
        currentBusiness.value = rejectedBusiness;
      }

      return true;
    } catch (e) {
      print('❌ Error rejecting business: $e');
      return false;
    }
  }

  /// Suspend business (Admin only)
  Future<bool> suspendBusiness(String businessId) async {
    try {
      print('⏸️ Suspending business: $businessId');

      final business = await getBusinessById(businessId);
      if (business == null) return false;

      final suspendedBusiness = business.copyWith(
        status: BusinessStatus.inactive,
      );

      await _syncService.pushToCloud(
        'business_registrations',
        businessId,
        suspendedBusiness.toJson(),
        isTopLevel: true,
      );

      print('⏸️ Business suspended: ${business.name}');

      // Update current business if it's the same
      if (currentBusiness.value?.id == businessId) {
        currentBusiness.value = suspendedBusiness;
      }

      return true;
    } catch (e) {
      print('❌ Error suspending business: $e');
      return false;
    }
  }

  /// Reactivate business (Admin only)
  Future<bool> reactivateBusiness(String businessId) async {
    try {
      print('▶️ Reactivating business: $businessId');

      final business = await getBusinessById(businessId);
      if (business == null) return false;

      final reactivatedBusiness = business.copyWith(
        status: BusinessStatus.active,
      );

      await _syncService.pushToCloud(
        'business_registrations',
        businessId,
        reactivatedBusiness.toJson(),
        isTopLevel: true,
      );

      print('▶️ Business reactivated: ${business.name}');

      // Update current business if it's the same
      if (currentBusiness.value?.id == businessId) {
        currentBusiness.value = reactivatedBusiness;
      }

      return true;
    } catch (e) {
      print('❌ Error reactivating business: $e');
      return false;
    }
  }

  /// Get all pending businesses (Admin only)
  Future<List<BusinessModel>> getPendingBusinesses() async {
    try {
      print('📋 Fetching pending businesses...');

      final businesses = <BusinessModel>[];

      // This would require querying Firestore
      // For now, return empty list
      // In production, implement proper query

      return businesses;
    } catch (e) {
      print('❌ Error fetching pending businesses: $e');
      return [];
    }
  }

  /// Clear business data (logout)
  Future<void> clearBusiness() async {
    currentBusiness.value = null;
    await _storage.remove('current_business_id');
    print('🗑️ Business data cleared');
  }

  /// Getters
  bool get hasActiveBusiness =>
      currentBusiness.value != null &&
      currentBusiness.value!.status == BusinessStatus.active;

  bool get isBusinessPending =>
      currentBusiness.value != null &&
      currentBusiness.value!.status == BusinessStatus.pending;

  bool get isBusinessRejected =>
      currentBusiness.value != null &&
      currentBusiness.value!.status == BusinessStatus.rejected;

  bool get isBusinessInactive =>
      currentBusiness.value != null &&
      currentBusiness.value!.status == BusinessStatus.inactive;

  String? get businessId => currentBusiness.value?.id;
  String? get businessName => currentBusiness.value?.name;
}
