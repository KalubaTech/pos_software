import 'package:flutter/material.dart';
import 'package:pos_software/components/navigations/main_side_navigation_bar.dart';
import 'package:pos_software/components/sync_status_indicator.dart'; // Re-enabled with Firedart!
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'controllers/navigations_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/appearance_controller.dart';
import 'models/cashier_model.dart';
import 'views/dashboard/dashboard_view.dart';
import 'views/transactions/transactions_view.dart';
import 'views/customers/customers_view.dart';
import 'views/inventory/enhanced_inventory_view.dart';
import 'views/reports/reports_view.dart';
import 'views/price_tag_designer/price_tag_designer_view.dart';
import 'views/settings/enhanced_settings_view.dart';
import 'views/wallet/wallet_dashboard_view.dart';
import 'utils/colors.dart';
import 'utils/responsive.dart';

class PageAnchor extends StatelessWidget {
  const PageAnchor({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final NavigationsController navController = Get.find();
    final AppearanceController appearanceController = Get.find();

    // Track back button press for double-back-to-exit
    DateTime? lastBackPressTime;

    return Obx(() {
      final isDark = appearanceController.isDarkMode.value;

      return WillPopScope(
        onWillPop: () async {
          final now = DateTime.now();

          // If last back press was within 2 seconds, allow exit
          if (lastBackPressTime != null &&
              now.difference(lastBackPressTime!) < Duration(seconds: 2)) {
            return true; // Allow app to close
          }

          // First back press - show message and prevent exit
          lastBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
            ),
          );
          return false; // Prevent app from closing
        },
        child: Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],

          // Mobile: Show drawer button in AppBar
          appBar: context.isMobile
              ? AppBar(
                  backgroundColor: AppColors.getSurfaceColor(isDark),
                  elevation: 0,
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: Icon(
                        Iconsax.menu,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  title: Obx(() {
                    final currentPage =
                        navController.currentMainNavigation.value;
                    return Text(
                      '${currentPage.capitalize}',
                      style: TextStyle(
                        color: AppColors.getTextPrimary(isDark),
                        fontSize: Responsive.fontSize(
                          context,
                          mobile: 18,
                          tablet: 20,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }),
                  actions: [
                    // Sync status indicator - Now using Firedart (works on Windows!)
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SyncStatusIndicator(
                        showLabel: false,
                        iconSize: 20,
                        compact: true,
                      ),
                    ),
                    // User menu button on mobile
                    IconButton(
                      icon: Icon(
                        Iconsax.user,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                      onPressed: () =>
                          _showUserMenu(context, authController, isDark),
                    ),
                  ],
                )
              : null,

          // Mobile: Drawer, Desktop: None (sidebar is permanent)
          drawer: context.isMobile
              ? Drawer(
                  backgroundColor: AppColors.getSurfaceColor(isDark),
                  child: SafeArea(child: MainSideNavigationBar()),
                )
              : null,

          // Main content
          body: SafeArea(
            // Safe area only on mobile platforms
            top: Responsive.isMobilePlatform,
            bottom: Responsive.isMobilePlatform,
            child: Row(
              children: [
                // Desktop: Permanent collapsed sidebar (icon-only)
                if (context.isDesktop)
                  Container(
                    width: 60, // Fixed collapsed width for icon-only sidebar
                    decoration: BoxDecoration(
                      color: AppColors.getSurfaceColor(isDark),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 10,
                          offset: Offset(2, 0),
                        ),
                      ],
                    ),
                    child: MainSideNavigationBar(),
                  ),

                // Main page content
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
        ),
      );
    });
  }

  void _showUserMenu(
    BuildContext context,
    AuthController authController,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.getSurfaceColor(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              final cashier = authController.currentCashier.value;
              if (cashier == null) return SizedBox();

              return Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor:
                        (isDark ? AppColors.darkPrimary : AppColors.primary)
                            .withOpacity(0.2),
                    child: Text(
                      cashier.name[0].toUpperCase(),
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    cashier.name,
                    style: TextStyle(
                      color: AppColors.getTextPrimary(isDark),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    cashier.role.displayName.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.getTextSecondary(isDark),
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            }),
            SizedBox(height: 24),
            Divider(color: AppColors.getDivider(isDark)),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Iconsax.logout, color: Colors.red),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Get.back();
                _showLogoutDialog(authController, isDark);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(AuthController authController, bool isDark) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.getSurfaceColor(isDark),
        title: Text(
          'Logout',
          style: TextStyle(color: AppColors.getTextPrimary(isDark)),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.getTextSecondary(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppColors.darkPrimary : AppColors.primary,
              ),
            ),
          ),
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
      case 'wallet':
        return WalletDashboardView();
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
