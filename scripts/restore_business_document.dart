// Emergency script to restore corrupted business documents
// Run immediately: dart run scripts/restore_business_document.dart

import 'package:firedart/firedart.dart';
import 'dart:io';

void main() async {
  print('╔════════════════════════════════════════════════════════════╗');
  print('║  🚨 EMERGENCY: Business Document Restoration Script       ║');
  print('║  Restores corrupted business documents from backups        ║');
  print('╚════════════════════════════════════════════════════════════╝');
  print('');

  try {
    // Initialize Firestore
    final projectId =
        Platform.environment['FIREBASE_PROJECT_ID'] ?? 'your-project-id';
    final apiKey = Platform.environment['FIREBASE_API_KEY'] ?? 'your-api-key';

    if (projectId == 'your-project-id' || apiKey == 'your-api-key') {
      print('❌ ERROR: Firebase credentials not configured!');
      print('');
      print('Set environment variables:');
      print('  export FIREBASE_PROJECT_ID=your-project-id');
      print('  export FIREBASE_API_KEY=your-api-key');
      exit(1);
    }

    Firestore.initialize(projectId);
    FirebaseAuth.initialize(apiKey, VolatileStore());

    print('✅ Connected to Firebase\n');

    await restoreCorruptedBusinesses();
  } catch (e) {
    print('❌ ERROR: $e');
    exit(1);
  }
}

Future<void> restoreCorruptedBusinesses() async {
  final firestore = Firestore.instance;

  print('🔍 Scanning for corrupted business documents...\n');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  // Get all businesses
  final businesses = await firestore.collection('businesses').get();

  int corrupted = 0;
  int restored = 0;
  int errors = 0;

  // Required fields for a valid business
  final requiredFields = [
    'id',
    'name',
    'email',
    'phone',
    'address',
    'status',
    'admin_id',
    'created_at',
  ];

  for (var businessDoc in businesses) {
    final businessId = businessDoc.id;
    final businessData = businessDoc.map;

    // Check if business is corrupted (missing required fields)
    final missingFields = requiredFields
        .where((field) => !businessData.containsKey(field))
        .toList();

    if (missingFields.isEmpty) {
      // Business is fine
      continue;
    }

    // Business is corrupted!
    corrupted++;
    final businessName = businessData['name'] ?? 'Unknown';

    print('🚨 CORRUPTED: $businessName ($businessId)');
    print('   Missing fields: ${missingFields.join(', ')}');
    print('   Available fields: ${businessData.keys.join(', ')}');
    print('');
    print('   🔧 Attempting restoration from business_registrations...');

    try {
      // Try to restore from business_registrations
      final registrationDoc = await firestore
          .collection('business_registrations')
          .document(businessId)
          .get();

      if (registrationDoc.map.isEmpty) {
        print('   ❌ No backup found in business_registrations!');
        print('   ⚠️  Cannot restore - manual intervention required');
        errors++;
        print('');
        continue;
      }

      final fullData = registrationDoc.map;
      print('   ✅ Found backup data');

      // Check current online_store_enabled value (preserve if it exists)
      final currentOnlineStore = businessData['online_store_enabled'];

      // If no value exists, check settings
      bool onlineStoreValue = currentOnlineStore ?? false;

      if (currentOnlineStore == null) {
        print('   📋 Checking business_settings for online_store_enabled...');

        final settingsDocs = await firestore
            .collection('businesses/$businessId/business_settings')
            .get();

        if (settingsDocs.isNotEmpty) {
          final settings = settingsDocs.first.map;
          onlineStoreValue = settings['onlineStoreEnabled'] ?? false;
          print('   📋 Settings show: $onlineStoreValue');
        }
      } else {
        print(
          '   📋 Preserving existing online_store_enabled: $currentOnlineStore',
        );
      }

      // Build complete business document
      final completeData = <String, dynamic>{
        'id': fullData['id'],
        'name': fullData['name'],
        'email': fullData['email'],
        'phone': fullData['phone'],
        'address': fullData['address'],
        'status': fullData['status'] ?? 'active',
        'admin_id': fullData['admin_id'],
        'created_at':
            fullData['created_at'] ?? DateTime.now().toIso8601String(),
        'online_store_enabled': onlineStoreValue,
      };

      // Add optional fields if they exist
      if (fullData.containsKey('business_type')) {
        completeData['business_type'] = fullData['business_type'];
      }
      if (fullData.containsKey('city')) {
        completeData['city'] = fullData['city'];
      }
      if (fullData.containsKey('country')) {
        completeData['country'] = fullData['country'];
      }
      if (fullData.containsKey('latitude')) {
        completeData['latitude'] = fullData['latitude'];
      }
      if (fullData.containsKey('longitude')) {
        completeData['longitude'] = fullData['longitude'];
      }

      print('   💾 Restoring complete document...');

      // Replace the corrupted document
      await firestore
          .collection('businesses')
          .document(businessId)
          .set(completeData);

      print('   ✅ RESTORED successfully!');
      print('   📦 Restored fields: ${completeData.keys.length}');
      restored++;
    } catch (e) {
      print('   ❌ Restoration failed: $e');
      errors++;
    }

    print('');
  }

  // Summary
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📊 RESTORATION SUMMARY');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('Total Businesses Scanned:  ${businesses.length}');
  print('Corrupted Businesses:      $corrupted');
  print('Successfully Restored:     $restored');
  print('Restoration Errors:        $errors');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  print('');

  if (restored > 0) {
    print('✅ SUCCESS: $restored businesses restored from backup!');
    print('');
    print('Next Steps:');
    print('  1. Test Dynamos Market frontend');
    print('  2. Verify businesses load correctly');
    print('  3. Check that online_store_enabled field is preserved');
  }

  if (corrupted == 0) {
    print('✅ ALL CLEAR: No corrupted businesses found!');
  }

  if (errors > 0) {
    print('');
    print('⚠️  WARNING: $errors businesses could not be restored');
    print('   These require manual intervention in Firebase Console');
  }
}
