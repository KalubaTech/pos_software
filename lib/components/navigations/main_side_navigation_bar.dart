import 'package:flutter/material.dart';
import 'package:pos_software/components/buttons/sidebar_button_item.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos_software/controllers/navigations_controller.dart';
import 'package:pos_software/controllers/auth_controller.dart';
import 'package:pos_software/controllers/calculator_controller.dart';
import 'package:get/get.dart';
import '../../constants/constants.dart';
import '../../utils/responsive.dart';
import '../../views/auth/login_view.dart';

class MainSideNavigationBar extends StatefulWidget {
  const MainSideNavigationBar({super.key});

  @override
  State<MainSideNavigationBar> createState() => _MainSideNavigationBarState();
}

class _MainSideNavigationBarState extends State<MainSideNavigationBar> {
  // Collapsed width for Windows desktop (icon-only)
  final double collapsedWidth = 60.0;

  // Track if Tools section is expanded
  bool isToolsExpanded = false;

  // GlobalKey for Tools button to get its position
  final GlobalKey _toolsButtonKey = GlobalKey();

  final List<String> menuItems = [
    'Dashboard',
    'Transactions',
    'Online Orders',
    'Customers',
    'Inventory',
    'Wallet',
    'Reports',
    'Settings',
    'Tools', // Tools section at bottom
  ];

  // Sub-menu items for Tools
  final List<String> toolsSubMenu = [
    'Calculator',
    'Image Editor',
    'Price Tags',
  ];

  final NavigationsController _navigationsController = Get.find();

  // Get the selected index based on current navigation
  int _getSelectedIndex() {
    final currentPage = _navigationsController.currentMainNavigation.value
        .toLowerCase();
    final index = menuItems.indexWhere(
      (item) => item.toLowerCase() == currentPage,
    );
    return index >= 0 ? index : 0;
  }

  void _showToolsPopupMenu(BuildContext context) {
    // Find the Tools button position using the GlobalKey
    final RenderBox? renderBox =
        _toolsButtonKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + size.width,
        offset.dy,
        offset.dx + size.width + 200,
        offset.dy + size.height,
      ),
      items: toolsSubMenu.map((subItem) {
        return PopupMenuItem<String>(
          value: subItem,
          child: Row(
            children: [
              Icon(
                _getIconForMenuItem(subItem),
                size: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              Text(subItem),
            ],
          ),
        );
      }).toList(),
    ).then((selectedItem) {
      if (selectedItem != null) {
        // Handle the selected tool
        if (selectedItem == 'Calculator') {
          final calculatorController = Get.find<CalculatorController>();
          calculatorController.toggle();
        } else if (selectedItem == 'Price Tags') {
          _navigationsController.mainNavigation('price tags');
        } else {
          _navigationsController.mainNavigation(
            selectedItem.toLowerCase().replaceAll(' ', '_'),
          );
        }
      }
    });
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final authController = Get.find<AuthController>();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await authController.logout();
              Get.offAll(
                () => const LoginView(),
              ); // Navigate to login and clear stack
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

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
                left: showLabels ? 40.0 : 0,
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
              child: Obx(() {
                final selectedIndex = _getSelectedIndex();
                return ListView.builder(
                  itemCount:
                      menuItems.length +
                      (isToolsExpanded ? toolsSubMenu.length : 0),
                  itemBuilder: (context, index) {
                    // Check if we're in the Tools submenu range
                    final toolsIndex = menuItems.indexOf('Tools');

                    if (index <= toolsIndex) {
                      // Regular menu item before or at Tools
                      final item = menuItems[index];

                      // Special handling for Tools item
                      if (item == 'Tools') {
                        return Container(
                          key: _toolsButtonKey,
                          child: SidebarButtonItem(
                            title: item,
                            icon: _getIconForMenuItem(item),
                            isExpanded: showLabels,
                            isSelected:
                                false, // Never selected, just toggles submenu
                            trailingIcon: showLabels
                                ? (isToolsExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more)
                                : null,
                            onTap: () {
                              if (isDrawer) {
                                // On mobile/drawer: toggle inline expansion
                                setState(() {
                                  isToolsExpanded = !isToolsExpanded;
                                });
                              } else {
                                // On desktop: show popup menu
                                _showToolsPopupMenu(context);
                              }
                            },
                          ),
                        );
                      }

                      // Regular menu item
                      return SidebarButtonItem(
                        title: item,
                        icon: _getIconForMenuItem(item),
                        isExpanded: showLabels,
                        isSelected: selectedIndex == index,
                        onTap: () {
                          _navigationsController.mainNavigation(
                            item.toLowerCase(),
                          );

                          // Close drawer on mobile after selection
                          if (isDrawer) {
                            Navigator.of(context).pop();
                          }
                        },
                      );
                    } else if (index > toolsIndex &&
                        index <= toolsIndex + toolsSubMenu.length) {
                      // Tools submenu item
                      final subIndex = index - toolsIndex - 1;
                      final subItem = toolsSubMenu[subIndex];

                      return Padding(
                        padding: EdgeInsets.only(left: showLabels ? 20.0 : 0),
                        child: SidebarButtonItem(
                          title: subItem,
                          icon: _getIconForMenuItem(subItem),
                          isExpanded: showLabels,
                          isSelected:
                              _navigationsController.currentMainNavigation.value
                                  .toLowerCase() ==
                              subItem.toLowerCase().replaceAll(' ', '_'),
                          onTap: () {
                            // Special handling for Calculator - toggle visibility
                            if (subItem == 'Calculator') {
                              final calculatorController =
                                  Get.find<CalculatorController>();
                              calculatorController.toggle();

                              // Close drawer on mobile after selection
                              if (isDrawer) {
                                Navigator.of(context).pop();
                              }
                            } else {
                              // Special handling for Price Tags to use correct route
                              String route;
                              if (subItem == 'Price Tags') {
                                route =
                                    'price tags'; // Use space for the actual route
                              } else {
                                route = subItem.toLowerCase().replaceAll(
                                  ' ',
                                  '_',
                                );
                              }

                              _navigationsController.mainNavigation(route);

                              // Close drawer on mobile after selection
                              if (isDrawer) {
                                Navigator.of(context).pop();
                              }
                            }
                          },
                        ),
                      );
                    } else {
                      // Menu items after Tools section
                      final actualIndex =
                          index - (isToolsExpanded ? toolsSubMenu.length : 0);
                      final item = menuItems[actualIndex];

                      return SidebarButtonItem(
                        title: item,
                        icon: _getIconForMenuItem(item),
                        isExpanded: showLabels,
                        isSelected: selectedIndex == actualIndex,
                        onTap: () {
                          _navigationsController.mainNavigation(
                            item.toLowerCase(),
                          );

                          // Close drawer on mobile after selection
                          if (isDrawer) {
                            Navigator.of(context).pop();
                          }
                        },
                      );
                    }
                  },
                );
              }),
            ),

            // Bottom section (logout button)
            if (!showLabels)
              // Desktop collapsed mode: Icon only with tooltip
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Tooltip(
                  message: 'Sign out',
                  child: IconButton(
                    icon: Icon(
                      Iconsax.logout,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () => _showLogoutDialog(context),
                  ),
                ),
              ),

            if (showLabels)
              // Mobile drawer mode: Full ListTile with icon and label
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    Iconsax.logout,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Close drawer first
                    _showLogoutDialog(context);
                  },
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
      case 'Online Orders':
        return Iconsax.shopping_cart;
      case 'Customers':
        return Iconsax.profile_2user;
      case 'Inventory':
        return Iconsax.box;
      case 'Reports':
        return Iconsax.chart_21;
      case 'Price Tags':
        return Iconsax.tag;
      case 'Tools':
        return Iconsax.setting_4; // Tools icon
      case 'Calculator':
        return Iconsax.calculator;
      case 'Image Editor':
        return Iconsax.image;
      case 'Tag Label Editor':
        return Iconsax.edit;
      case 'Settings':
        return Iconsax.setting_2;
      default:
        return Iconsax.danger;
    }
  }
}
