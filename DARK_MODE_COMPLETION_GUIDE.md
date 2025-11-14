# Dark Mode Implementation Completion Guide

## Overview
This guide documents the dark mode completion for Settings, Inventory, and Price Tag Designer pages.

## Dark Mode Strategy

### Key Principles
1. Use `AppearanceController` to detect dark mode state
2. Use `AppColors` utility methods:
   - `getSurfaceColor(isDark)` for backgrounds
   - `getTextPrimary(isDark)` for main text
   - `getTextSecondary(isDark)` for secondary text
   - `getDivider(isDark)` for borders/dividers
3. Wrap main content with `Obx(() { final isDark = appearanceController.isDarkMode.value; ... })`

## Files to Update

### ✅ Completed Files
1. `lib/views/price_tag_designer/price_tag_designer_view.dart` - Already has dark mode support

### 🔄 Files Needing Updates

#### 1. Settings Pages

**lib/views/settings/enhanced_settings_view.dart**
- Status: Partially implemented (header done)
- Need to update:
  - `_buildPrinterSection` - add `isDark` parameter
  - `_buildPrinterUnavailableSection` - add `isDark` parameter
  - `_buildCashierSection` - add `isDark` parameter
  - `_buildSectionCard` - add `isDark` parameter
  - All dialog methods - add dark mode support
  - Pass `isDark` through all method calls

**lib/views/settings/business_settings_view.dart**
- Status: No dark mode
- Changes needed:
  - Wrap with `Obx` to get isDark
  - Update `Scaffold` backgroundColor
  - Update `_buildHeader` colors
  - Update all `Card` widgets
  - Update all `TextField` decorations
  - Update `Container` colors
  - Update text colors

**lib/views/settings/appearance_settings_view.dart**
- Status: No dark mode (ironic!)
- Changes needed: Same as business_settings_view.dart

#### 2. Inventory Page

**lib/views/inventory/enhanced_inventory_view.dart**
- Status: No dark mode
- Changes needed:
  - Wrap with `Obx` to get isDark
  - Update `Scaffold` backgroundColor
  - Update `_buildHeader` colors
  - Update `_buildQuickStats` card colors
  - Update `_buildProductCard` colors
  - Update all dialog backgrounds
  - Update text colors throughout

#### 3. Price Tag Designer Widgets

**lib/views/price_tag_designer/widgets/toolbar_widget.dart**
- Add dark mode support to toolbar background and buttons

**lib/views/price_tag_designer/widgets/template_list_widget.dart**
- Add dark mode support to list items and backgrounds

**lib/views/price_tag_designer/widgets/properties_panel_widget.dart**
- Add dark mode support to panel and form elements

**lib/views/price_tag_designer/widgets/canvas_widget.dart**
- Canvas stays white (represents paper), but surrounding UI needs dark mode

**lib/views/price_tag_designer/widgets/print_dialog_widget.dart**
- Add dark mode support to dialog

**lib/views/price_tag_designer/widgets/printer_management_dialog.dart**
- Add dark mode support to dialog

## Implementation Pattern

### Example Pattern for Views

```dart
@override
Widget build(BuildContext context) {
  final appearanceController = Get.find<AppearanceController>();

  return Obx(() {
    final isDark = appearanceController.isDarkMode.value;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(isDark),
          // ... rest of the widgets, passing isDark
        ],
      ),
    );
  });
}

Widget _buildHeader(bool isDark) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.getSurfaceColor(isDark),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
          blurRadius: 10,
        ),
      ],
    ),
    child: Text(
      'Title',
      style: TextStyle(color: AppColors.getTextPrimary(isDark)),
    ),
  );
}
```

### Example Pattern for Cards

```dart
Widget _buildCard(bool isDark) {
  return Card(
    color: AppColors.getSurfaceColor(isDark),
    elevation: isDark ? 8 : 2,
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Title',
            style: TextStyle(
              color: AppColors.getTextPrimary(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Subtitle',
            style: TextStyle(
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
        ],
      ),
    ),
  );
}
```

### Example Pattern for TextFields

```dart
TextField(
  style: TextStyle(color: AppColors.getTextPrimary(isDark)),
  decoration: InputDecoration(
    labelText: 'Label',
    labelStyle: TextStyle(color: AppColors.getTextSecondary(isDark)),
    filled: true,
    fillColor: isDark ? AppColors.darkSurfaceVariant : Colors.grey[50],
    border: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.getDivider(isDark)),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.getDivider(isDark)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: isDark ? AppColors.darkPrimary : AppColors.primary,
      ),
    ),
  ),
)
```

### Example Pattern for Dialogs

```dart
Get.dialog(
  AlertDialog(
    backgroundColor: AppColors.getSurfaceColor(isDark),
    title: Text(
      'Dialog Title',
      style: TextStyle(color: AppColors.getTextPrimary(isDark)),
    ),
    content: Text(
      'Dialog content',
      style: TextStyle(color: AppColors.getTextSecondary(isDark)),
    ),
    actions: [
      TextButton(
        child: Text('Cancel'),
        onPressed: () => Get.back(),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
        ),
        child: Text('Confirm'),
        onPressed: () {},
      ),
    ],
  ),
);
```

## Color Reference

### Light Theme
- Background: `Colors.grey[50]`
- Surface (Cards): `Colors.white`
- Primary: `AppColors.primary` (Teal)
- Text Primary: `Colors.black`
- Text Secondary: `Colors.grey[600]`
- Divider: `Colors.grey[200]`

### Dark Theme  
- Background: `AppColors.darkBackground` (#0F0F0F)
- Surface (Cards): `AppColors.darkSurface` (#1C1C1E)
- Surface Variant: `AppColors.darkSurfaceVariant` (#2C2C2E)
- Primary: `AppColors.darkPrimary` (#26D0CE)
- Text Primary: `AppColors.darkTextPrimary` (#FFFFFF)
- Text Secondary: `AppColors.darkTextSecondary` (#B0B0B0)
- Text Tertiary: `AppColors.darkTextTertiary` (#808080)
- Divider: `AppColors.darkDivider` (#2C2C2E)

## Testing Checklist

After implementing dark mode, test:
- [ ] Toggle dark mode in Appearance Settings
- [ ] Check Settings page (all 3 tabs)
- [ ] Check Inventory page
- [ ] Check Price Tag Designer page and all its widgets
- [ ] Verify text readability in both modes
- [ ] Verify all dialogs render correctly
- [ ] Verify all buttons have proper contrast
- [ ] Verify dividers are visible
- [ ] Verify form inputs are readable

## Notes

- The canvas in Price Tag Designer should remain white (represents paper)
- Status badges (green/red/orange) should maintain their colors in both modes
- Icons can use subtle opacity adjustments for dark mode
- Shadows should be stronger in dark mode (alpha: 0.3 vs 0.05)

