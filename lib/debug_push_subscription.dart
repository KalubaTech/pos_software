import 'package:get/get.dart';
import 'services/subscription_service.dart';
import 'controllers/universal_sync_controller.dart';

/// Debug script to manually push subscription to cloud
/// Run this in DevTools console or add a button to call it
Future<void> debugPushSubscription() async {
  try {
    print('🔍 === DEBUG: Manual Subscription Push ===');

    // Get services
    final subscriptionService = Get.find<SubscriptionService>();
    final syncController = Get.find<UniversalSyncController>();

    // Check current subscription
    final currentSub = subscriptionService.currentSubscription.value;

    if (currentSub == null) {
      print('❌ No subscription found locally!');
      print('💡 Check GetStorage and SQLite database');
      return;
    }

    print('✅ Found local subscription:');
    print('   ID: ${currentSub.id}');
    print('   Business ID: ${currentSub.businessId}');
    print('   Plan: ${currentSub.planName}');
    print('   Status: ${currentSub.status.name}');
    print('   Start: ${currentSub.startDate}');
    print('   End: ${currentSub.endDate}');
    print('   Created: ${currentSub.createdAt}');

    // Try to push to cloud
    print('');
    print('📤 Pushing to cloud...');
    await syncController.syncSubscription(currentSub);

    print('');
    print('⏳ Waiting 3 seconds...');
    await Future.delayed(Duration(seconds: 3));

    // Force sync to verify
    print('');
    print('🔄 Force syncing to verify...');
    await syncController.forceSubscriptionSync();

    print('');
    print('✅ Debug push complete!');
    print('');
    print('📋 Next steps:');
    print(
      '1. Check Firebase Console: businesses/default_business_001/subscriptions',
    );
    print('2. You should see a document with ID: ${currentSub.id}');
    print('3. Open mobile app and wait 10 seconds');
    print('4. Or click the refresh button in Subscription view');
  } catch (e, stackTrace) {
    print('❌ Error in debug push: $e');
    print('Stack trace: $stackTrace');
  }
}

/// Quick check subscription status
void debugCheckSubscription() {
  try {
    print('🔍 === Subscription Status Check ===');

    final subscriptionService = Get.find<SubscriptionService>();
    final currentSub = subscriptionService.currentSubscription.value;

    if (currentSub == null) {
      print('❌ No subscription');
    } else {
      print('✅ ${currentSub.planName} (${currentSub.status.name})');
      print('   Expires: ${currentSub.endDate}');
      print('   Business: ${currentSub.businessId}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}
