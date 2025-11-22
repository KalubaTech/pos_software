// Quick check script to verify online_store_enabled field status
// Run with: dart run scripts/check_online_store_fields.dart

import 'package:firedart/firedart.dart';
import 'dart:io';

void main() async {
  print('╔════════════════════════════════════════════════════════════╗');
  print('║  Online Store Field Verification Script                   ║');
  print('║  Checks which businesses have online_store_enabled field  ║');
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

    await checkFields();
  } catch (e) {
    print('❌ ERROR: $e');
    exit(1);
  }
}

Future<void> checkFields() async {
  final firestore = Firestore.instance;

  print('📥 Fetching all businesses...\n');

  final businesses = await firestore.collection('businesses').get();

  if (businesses.isEmpty) {
    print('⚠️  No businesses found');
    return;
  }

  print('Found ${businesses.length} businesses\n');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  int withField = 0;
  int withoutField = 0;
  int onlineEnabled = 0;

  List<Map<String, dynamic>> missingField = [];
  List<Map<String, dynamic>> onlineStores = [];

  for (var doc in businesses) {
    final id = doc.id;
    final data = doc.map;
    final name = data['name'] ?? 'Unknown';
    final hasField = data.containsKey('online_store_enabled');
    final fieldValue = data['online_store_enabled'];

    print('📊 $name ($id)');

    if (hasField) {
      print('   ✅ Field exists: $fieldValue');
      withField++;

      if (fieldValue == true) {
        print('   🌐 ONLINE STORE ENABLED');
        onlineEnabled++;
        onlineStores.add({'id': id, 'name': name});
      }
    } else {
      print('   ❌ Field missing!');
      withoutField++;
      missingField.add({'id': id, 'name': name});
    }

    print('');
  }

  // Summary
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📊 VERIFICATION SUMMARY');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('Total Businesses:           ${businesses.length}');
  print('Have Field:                 $withField');
  print('Missing Field:              $withoutField');
  print('Online Store Enabled:       $onlineEnabled');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  if (missingField.isNotEmpty) {
    print('');
    print('⚠️  BUSINESSES MISSING FIELD:');
    for (var business in missingField) {
      print('   - ${business['name']} (${business['id']})');
    }
    print('');
    print('💡 Run fix script: dart run scripts/fix_online_store_field.dart');
  }

  if (onlineStores.isNotEmpty) {
    print('');
    print('🌐 ONLINE STORES (should appear in Dynamos Market):');
    for (var business in onlineStores) {
      print('   - ${business['name']} (${business['id']})');
    }
  }

  print('');

  if (withoutField == 0) {
    print('✅ SUCCESS: All businesses have the field!');
  } else {
    print('⚠️  ACTION REQUIRED: $withoutField businesses need the field added');
  }
}
