import 'package:flutter/material.dart';
import 'package:pos_software/components/buttons/sidebar_button_item.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos_software/controllers/navigations_controller.dart';
import 'package:get/get.dart';
import '../../constants/constants.dart';
import '../../utils/responsive.dart';

class MainSideNavigationBar extends StatefulWidget {
  const MainSideNavigationBar({super.key});

  @override
  State<MainSideNavigationBar> createState() => _MainSideNavigationBarState();
}

class _MainSideNavigationBarState extends State<MainSideNavigationBar> {
  int _selectedIndex = 0;

  // Collapsed width for Windows desktop (icon-only)
  final double collapsedWidth = 60.0;

  final List<String> menuItems = [
    'Dashboard',
    'Transactions',
    'Customers',
    'Inventory',
    'Wallet',
    'Reports',
    'Price Tags',
    'Settings',
  ];

  NavigationsController _navigationsController = Get.find();

  @override
  Widget build(BuildContext context) {
    // On mobile (drawer), show full width with labels
    // On desktop, always stay collapsed (icon-only)
    final bool isDrawer = Responsive.isMobile(context);
    final double currentWidth = isDrawer ? 250.0 : collapsedWidth;
    final bool showLabels = isDrawer;

    return Container(
      width: currentWidth,
      color: Theme.of(context).colorScheme.surface,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: showLabels
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            // App Logo/Icon at top
            Padding(
              padding: EdgeInsets.only(
                top: 20.0,
                left: showLabels ? 24.0 : 0,
                bottom: 20.0,
              ),
              child: showLabels
                  ? Text(
                      '${Constants.appName}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    )
                  : Icon(
                      Iconsax.shop,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
            ),

            // Menu Items
            Expanded(
              child: ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return SidebarButtonItem(
                    title: item,
                    icon: _getIconForMenuItem(item),
                    isExpanded: showLabels,
                    isSelected: _selectedIndex == index,
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                      _navigationsController.mainNavigation(item.toLowerCase());

                      // Close drawer on mobile after selection
                      if (isDrawer) {
                        Navigator.of(context).pop();
                      }
                    },
                  );
                },
              ),
            ),

            // Bottom section (logout button or user info)
            if (!showLabels)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Tooltip(
                  message: 'Sign out',
                  child: IconButton(
                    icon: Icon(
                      Iconsax.logout,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () {
                      // Can show a popup menu or bottom sheet here
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForMenuItem(String item) {
    switch (item) {
      case 'Dashboard':
        return Iconsax.category;
      case 'Transactions':
        return Iconsax.receipt_2_1;
      case 'Customers':
        return Iconsax.profile_2user;
      case 'Inventory':
        return Iconsax.box;
      case 'Reports':
        return Iconsax.chart_21;
      case 'Price Tags':
        return Iconsax.tag;
      case 'Settings':
        return Iconsax.setting_2;
      default:
        return Iconsax.danger;
    }
  }
}
