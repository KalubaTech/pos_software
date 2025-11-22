// Script to add missing online_store_enabled field to existing businesses
// Run with: dart run scripts/fix_online_store_field.dart

import 'package:firedart/firedart.dart';
import 'dart:io';

void main() async {
  print('╔════════════════════════════════════════════════════════════╗');
  print('║  Online Store Field Fix Script                            ║');
  print('║  Adds missing online_store_enabled field to businesses    ║');
  print('╚════════════════════════════════════════════════════════════╝');
  print('');

  // Initialize Firestore (requires project setup)
  print('⚙️  Initializing Firestore connection...');

  try {
    // Note: Replace with your Firebase project ID and API key
    final projectId =
        Platform.environment['FIREBASE_PROJECT_ID'] ?? 'your-project-id';
    final apiKey = Platform.environment['FIREBASE_API_KEY'] ?? 'your-api-key';

    if (projectId == 'your-project-id' || apiKey == 'your-api-key') {
      print('❌ ERROR: Firebase credentials not configured!');
      print('');
      print('Please set environment variables:');
      print('  FIREBASE_PROJECT_ID=your-project-id');
      print('  FIREBASE_API_KEY=your-api-key');
      print('');
      print('Or edit this script and replace the placeholders.');
      exit(1);
    }

    Firestore.initialize(projectId);
    FirebaseAuth.initialize(apiKey, VolatileStore());

    print('✅ Connected to Firebase project: $projectId\n');

    await fixOnlineStoreField();
  } catch (e) {
    print('❌ ERROR: $e');
    print('');
    print('Make sure you have:');
    print('  1. Added firedart to pubspec.yaml');
    print('  2. Set correct Firebase credentials');
    print('  3. Enabled Firestore in Firebase Console');
    exit(1);
  }
}

Future<void> fixOnlineStoreField() async {
  final firestore = Firestore.instance;

  print('🔧 Starting field fix process...\n');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  try {
    // Get all businesses
    print('📥 Fetching all businesses...');
    final businesses = await firestore.collection('businesses').get();
    print('✅ Found ${businesses.length} businesses\n');

    if (businesses.isEmpty) {
      print('⚠️  No businesses found in Firestore');
      return;
    }

    int fixed = 0;
    int alreadyHasField = 0;
    int errors = 0;

    // Process each business
    for (var businessDoc in businesses) {
      final businessId = businessDoc.id;
      final businessData = businessDoc.map;
      final businessName = businessData['name'] ?? 'Unknown';

      print('📊 Processing: $businessName ($businessId)');

      // Check if field already exists
      if (businessData.containsKey('online_store_enabled')) {
        final currentValue = businessData['online_store_enabled'];
        print('   ✅ Field exists: $currentValue');
        alreadyHasField++;
        print('');
        continue;
      }

      print('   ⚠️  Field missing! Checking settings...');

      try {
        // Check settings to determine value
        final settingsDocs = await firestore
            .collection('businesses/$businessId/business_settings')
            .get();

        bool onlineStoreValue = false;

        if (settingsDocs.isNotEmpty) {
          final settings = settingsDocs.first.map;
          onlineStoreValue = settings['onlineStoreEnabled'] ?? false;
          print('   📋 Settings show onlineStoreEnabled: $onlineStoreValue');
        } else {
          print('   ⚠️  No settings found, using default: false');
        }

        // Update business document
        print('   🔧 Adding field online_store_enabled: $onlineStoreValue');
        await firestore.collection('businesses').document(businessId).update({
          'online_store_enabled': onlineStoreValue,
        });

        print('   ✅ Successfully updated!');
        fixed++;
      } catch (e) {
        print('   ❌ Error updating: $e');
        errors++;
      }

      print('');
    }

    // Print summary
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📊 SUMMARY REPORT');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('Total Businesses Scanned: ${businesses.length}');
    print('Already Had Field:        $alreadyHasField');
    print('Fixed:                    $fixed');
    print('Errors:                   $errors');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (fixed > 0) {
      print('');
      print('✅ SUCCESS: $fixed businesses updated');
      print('');
      print('Next Steps:');
      print('  1. Verify businesses in Firebase Console');
      print('  2. Test Dynamos Market frontend');
      print('  3. Monitor for any issues');
    }

    if (errors > 0) {
      print('');
      print('⚠️  WARNING: $errors businesses had errors');
      print('   Check logs above for details');
    }
  } catch (e) {
    print('❌ FATAL ERROR: $e');
    print('');
    print('Script aborted. No changes made.');
    exit(1);
  }
}
