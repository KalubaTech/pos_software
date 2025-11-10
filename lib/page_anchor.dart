import 'package:flutter/material.dart';
import 'package:pos_software/components/navigations/main_side_navigation_bar.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'controllers/navigations_controller.dart';
import 'controllers/auth_controller.dart';
import 'views/dashboard/dashboard_view.dart';
import 'views/transactions/transactions_view.dart';
import 'views/customers/customers_view.dart';
import 'views/inventory/enhanced_inventory_view.dart';
import 'views/reports/reports_view.dart';
import 'views/price_tag_designer/price_tag_designer_view.dart';
import 'views/settings/enhanced_settings_view.dart';
import 'utils/colors.dart';

class PageAnchor extends StatelessWidget {
  const PageAnchor({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return Scaffold(
      body: Column(
        children: [
          // Top bar with cashier info
          /*  Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Obx(() {
                  final cashier = authController.currentCashier.value;
                  if (cashier == null) return SizedBox();

                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        child: Text(
                          cashier.name[0].toUpperCase(),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cashier.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            cashier.role.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 16),
                      IconButton(
                        icon: Icon(Iconsax.logout, size: 20),
                        onPressed: () => _showLogoutDialog(authController),
                        tooltip: 'Logout',
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),*/
          // Main content
          Expanded(
            child: Row(
              children: [
                MainSideNavigationBar(),
                Expanded(
                  child: GetBuilder<NavigationsController>(
                    builder: (item) {
                      String currentMainPage = item.currentMainNavigation.value;
                      return _getPageForRoute(currentMainPage);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _getPageForRoute(String route) {
    switch (route.toLowerCase()) {
      case 'dashboard':
        return DashboardView();
      case 'transactions':
        return TransactionsView();
      case 'customers':
        return CustomersView();
      case 'inventory':
        return EnhancedInventoryView();
      case 'reports':
        return ReportsView();
      case 'price tags':
        return PriceTagDesignerView();
      case 'settings':
        return EnhancedSettingsView();
      default:
        return DashboardView();
    }
  }
}
