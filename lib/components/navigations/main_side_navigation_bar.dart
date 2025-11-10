import 'package:flutter/material.dart';
import 'package:pos_software/components/buttons/sidebar_button_item.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos_software/controllers/navigations_controller.dart';
import 'package:get/get.dart';
import '../../constants/constants.dart';

class MainSideNavigationBar extends StatefulWidget {
  const MainSideNavigationBar({super.key});

  @override
  State<MainSideNavigationBar> createState() => _MainSideNavigationBarState();
}

class _MainSideNavigationBarState extends State<MainSideNavigationBar> {
  // Controls the sidebar width (expanded or collapsed)
  bool _isWidthExpanded = true;
  // Controls whether titles are shown. When false only icons are visible.
  bool _showTitles = true;
  int _selectedIndex = 0;

  final double expandedWidth = 230.0;
  final double collapsedWidth = 60.0;

  final List<String> menuItems = [
    'Dashboard',
    'Transactions',
    'Customers',
    'Inventory',
    'Reports',
    'Price Tags',
    'Settings',
  ];

  NavigationsController _navigationsController = Get.find();

  void _toggleTitles() {
    setState(() {
      _showTitles = !_showTitles;
      // if we hide titles make sure width is collapsed (icons-only)
      if (!_showTitles) _isWidthExpanded = false;
      // if we reveal titles expand width so titles can be shown
      if (_showTitles) _isWidthExpanded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentWidth = _isWidthExpanded ? expandedWidth : collapsedWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      width: currentWidth,
      color: Theme.of(context).colorScheme.surface,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: _showTitles
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 20.0,
                left: _showTitles ? 24.0 : 0,
                bottom: 20.0,
              ),
              child: _showTitles
                  ? Text(
                      '${Constants.appName}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    )
                  : const Icon(Iconsax.shop, size: 28),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return SidebarButtonItem(
                    title: item,
                    icon: _getIconForMenuItem(item),
                    isExpanded: _showTitles,
                    isSelected: _selectedIndex == index,
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                      _navigationsController.mainNavigation(item.toLowerCase());
                    },
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // collapse / expand width button
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: IconButton(
                    icon: Icon(
                      _isWidthExpanded
                          ? Iconsax.arrow_left_2
                          : Iconsax.arrow_right_3,
                    ),
                    onPressed: _toggleTitles,
                    tooltip: _isWidthExpanded ? 'Collapse Menu' : 'Expand Menu',
                  ),
                ),
                // hide / reveal titles button - when hidden only icons sho
              ],
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
