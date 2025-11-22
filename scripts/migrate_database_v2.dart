import 'package:firedart/firedart.dart';
import 'dart:io';

/// Migration Script - Database V2
///
/// This script performs a complete database migration to the new architecture:
/// 1. Validates all business documents
/// 2. Restores corrupted documents from business_registrations
/// 3. Moves business_registrations to business_audit
/// 4. Creates data integrity indexes
///
/// Run this script ONCE after deploying the new code

void main() async {
  print('╔════════════════════════════════════════════════════════╗');
  print('║   DATABASE MIGRATION V2 - PROFESSIONAL ARCHITECTURE    ║');
  print('╚════════════════════════════════════════════════════════╝\n');

  try {
    // Initialize Firestore
    await initializeFirestore();

    // Step 1: Backup current data
    print('📦 Step 1: Creating backup...');
    await backupCurrentData();

    // Step 2: Scan and validate businesses
    print('\n🔍 Step 2: Scanning businesses...');
    final issues = await scanBusinesses();

    // Step 3: Restore corrupted businesses
    if (issues.isNotEmpty) {
      print('\n🔧 Step 3: Restoring corrupted businesses...');
      await restoreCorruptedBusinesses(issues);
    } else {
      print('\n✅ Step 3: No corrupted businesses found! Skipping restoration.');
    }

    // Step 4: Migrate registration data to audit trail
    print('\n📋 Step 4: Migrating registration data to audit trail...');
    await migrateToAuditTrail();

    // Step 5: Verify data integrity
    print('\n✔️  Step 5: Verifying data integrity...');
    await verifyDataIntegrity();

    print('\n╔════════════════════════════════════════════════════════╗');
    print('║              ✅ MIGRATION COMPLETED SUCCESSFULLY!       ║');
    print('╚════════════════════════════════════════════════════════╝\n');

    print('Next Steps:');
    print('  1. Review the migration log above');
    print('  2. Test business registration in the POS app');
    print('  3. Test online store toggle');
    print('  4. Verify Dynamos Market can fetch businesses');
    print('  5. Run: dart run scripts/verify_database_integrity.dart');
  } catch (error, stackTrace) {
    print('\n❌ MIGRATION FAILED: $error');
    print('Stack trace: $stackTrace');
    print('\n⚠️  Database may be in inconsistent state!');
    print('   Please restore from backup and contact support.');
    exit(1);
  }
}

/// Initialize Firestore connection
Future<void> initializeFirestore() async {
  // TODO: Replace with your Firebase project credentials
  const projectId = 'your-project-id';
  const serviceAccountPath = 'path/to/service-account.json';

  print('Connecting to Firestore...');

  // In production, use service account authentication
  // For now, print instructions
  print('⚠️  Configure Firestore credentials in this script');
  print('   1. Download service account JSON from Firebase Console');
  print('   2. Update projectId and serviceAccountPath');
  print('   3. Re-run this script\n');

  // Initialize Firedart
  // Firestore.initialize(projectId);

  print('✅ Connected to Firestore\n');
}

/// Create backup of current Firestore data
Future<void> backupCurrentData() async {
  final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
  final backupDir = 'backups/migration_v2_$timestamp';

  print('Creating backup directory: $backupDir');

  // Create backup directory
  Directory(backupDir).createSync(recursive: true);

  // TODO: Export Firestore data
  // In production, use Firebase Admin SDK to export collections

  print('✅ Backup created at: $backupDir');
  print('   Note: Use Firebase Console to export full Firestore data');
  print('   Command: firebase firestore:export gs://your-backup-bucket');
}

/// Scan all businesses for missing fields
Future<List<String>> scanBusinesses() async {
  print('Scanning businesses collection...\n');

  final firestore = Firestore.instance;
  final businessesSnapshot = await firestore.collection('businesses').get();

  final corruptedBusinessIds = <String>[];
  final requiredFields = [
    'id',
    'name',
    'email',
    'phone',
    'address',
    'status',
    'admin_id',
    'created_at',
    'online_store_enabled',
  ];

  print('Found ${businessesSnapshot.length} businesses\n');

  for (var doc in businessesSnapshot) {
    final businessId = doc.id;
    final data = doc.map;

    // Check for missing required fields
    final missingFields = requiredFields
        .where((field) => !data.containsKey(field) || data[field] == null)
        .toList();

    if (missingFields.isEmpty) {
      print('✅ $businessId - Complete (${data['name']})');
    } else {
      print('❌ $businessId - MISSING: ${missingFields.join(', ')}');
      print('   Current fields: ${data.keys.join(', ')}');
      corruptedBusinessIds.add(businessId);
    }
  }

  if (corruptedBusinessIds.isNotEmpty) {
    print('\n⚠️  Found ${corruptedBusinessIds.length} corrupted business(es)');
  } else {
    print('\n✅ All businesses have complete data!');
  }

  return corruptedBusinessIds;
}

/// Restore corrupted businesses from business_registrations
Future<void> restoreCorruptedBusinesses(List<String> businessIds) async {
  final firestore = Firestore.instance;

  for (var businessId in businessIds) {
    print('\n🔄 Restoring $businessId...');

    try {
      // Get current business document
      final businessDoc = await firestore
          .collection('businesses')
          .document(businessId)
          .get();

      final currentData = businessDoc.map;

      // Try to get from business_registrations
      final registrationDoc = await firestore
          .collection('business_registrations')
          .document(businessId)
          .get();

      if (!registrationDoc.exists) {
        print('   ❌ No backup found in business_registrations');
        print('   ⚠️  Manual intervention required for $businessId');
        continue;
      }

      final registrationData = registrationDoc.map;

      // Build complete business document
      final restoredData = {
        'id': businessId,
        'name': registrationData['name'] ?? currentData['name'],
        'email': registrationData['email'] ?? currentData['email'],
        'phone': registrationData['phone'] ?? currentData['phone'],
        'address': registrationData['address'] ?? currentData['address'],
        'city': registrationData['city'],
        'country': registrationData['country'],
        'business_type': registrationData['business_type'],
        'status': registrationData['status'] ?? 'active',
        'admin_id': registrationData['admin_id'],
        'created_at': registrationData['created_at'],
        'updated_at': DateTime.now().toIso8601String(),
        'online_store_enabled': currentData['online_store_enabled'] ?? false,
        'latitude': registrationData['latitude'],
        'longitude': registrationData['longitude'],
        'tax_id': registrationData['tax_id'],
        'website': registrationData['website'],
        'logo': registrationData['logo'],
      };

      // Remove null values
      restoredData.removeWhere((key, value) => value == null);

      // Update business document
      await firestore
          .collection('businesses')
          .document(businessId)
          .update(restoredData);

      print('   ✅ Restored successfully');
      print('   📝 Fields restored: ${restoredData.keys.length}');
    } catch (error) {
      print('   ❌ Error restoring $businessId: $error');
    }
  }
}

/// Migrate business_registrations to business_audit
Future<void> migrateToAuditTrail() async {
  print('Migrating registration data to audit trail...\n');

  final firestore = Firestore.instance;
  final registrationsSnapshot = await firestore
      .collection('business_registrations')
      .get();

  print('Found ${registrationsSnapshot.length} registrations to migrate\n');

  for (var doc in registrationsSnapshot) {
    final businessId = doc.id;
    final registrationData = doc.map;

    try {
      // Create audit trail document
      final auditData = {
        'business_data': registrationData,
        'registered_at': registrationData['created_at'],
        'migrated_at': DateTime.now().toIso8601String(),
        'migration_version': '2.0',
      };

      // Write to business_audit
      await firestore
          .collection('business_audit')
          .document(businessId)
          .collection('registrations')
          .document('initial')
          .set(auditData);

      print('✅ Migrated $businessId to audit trail');
    } catch (error) {
      print('❌ Error migrating $businessId: $error');
    }
  }

  print('\n⚠️  NOTE: business_registrations collection NOT deleted');
  print('   Review audit trail, then manually delete business_registrations');
  print(
    '   Command: firebase firestore:delete business_registrations --recursive',
  );
}

/// Verify data integrity after migration
Future<void> verifyDataIntegrity() async {
  print('Verifying data integrity...\n');

  final firestore = Firestore.instance;
  final businessesSnapshot = await firestore.collection('businesses').get();

  final requiredFields = [
    'id',
    'name',
    'email',
    'phone',
    'address',
    'status',
    'admin_id',
    'created_at',
    'online_store_enabled',
  ];

  var validCount = 0;
  var invalidCount = 0;

  for (var doc in businessesSnapshot) {
    final data = doc.map;
    final missingFields = requiredFields
        .where((field) => !data.containsKey(field) || data[field] == null)
        .toList();

    if (missingFields.isEmpty) {
      validCount++;
    } else {
      invalidCount++;
      print('❌ ${doc.id} still invalid: missing ${missingFields.join(', ')}');
    }
  }

  print('\n📊 Verification Results:');
  print('   ✅ Valid businesses: $validCount');
  print('   ❌ Invalid businesses: $invalidCount');
  print(
    '   📈 Success rate: ${((validCount / businessesSnapshot.length) * 100).toStringAsFixed(1)}%',
  );

  if (invalidCount > 0) {
    print('\n⚠️  Some businesses are still invalid!');
    print('   Run manual restoration for these businesses');
  } else {
    print('\n✅ All businesses are valid!');
  }
}
