import 'package:flutter/material.dart';
import 'responsive.dart';

/// UI Constants for consistent design across the app
class UIConstants {
  UIConstants._();

  // ============================================
  // SPACING & PADDING
  // ============================================

  /// Standard spacing units (use these for consistency)
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing14 = 14.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;

  /// Get responsive padding for screen edges
  static EdgeInsets screenPadding(BuildContext context) {
    return Responsive.padding(
      context,
      mobile: spacing16,
      tablet: spacing20,
      desktop: spacing24,
    );
  }

  /// Get responsive padding for cards
  static EdgeInsets cardPadding(BuildContext context) {
    return Responsive.padding(
      context,
      mobile: spacing16,
      tablet: spacing20,
      desktop: spacing24,
    );
  }

  /// Get responsive padding for list items
  static EdgeInsets listItemPadding(BuildContext context) {
    return Responsive.value<EdgeInsets>(
      context,
      mobile: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing12,
      ),
      tablet: const EdgeInsets.symmetric(
        horizontal: spacing20,
        vertical: spacing16,
      ),
      desktop: const EdgeInsets.symmetric(
        horizontal: spacing24,
        vertical: spacing16,
      ),
    );
  }

  /// Get responsive spacing between items
  static double itemSpacing(BuildContext context) {
    return Responsive.spacing(
      context,
      mobile: spacing12,
      tablet: spacing16,
      desktop: spacing20,
    );
  }

  /// Get responsive section spacing
  static double sectionSpacing(BuildContext context) {
    return Responsive.spacing(
      context,
      mobile: spacing24,
      tablet: spacing32,
      desktop: spacing40,
    );
  }

  // ============================================
  // BORDER RADIUS
  // ============================================

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusCircle = 999.0;

  static BorderRadius borderRadiusSmall = BorderRadius.circular(radiusSmall);
  static BorderRadius borderRadiusMedium = BorderRadius.circular(radiusMedium);
  static BorderRadius borderRadiusLarge = BorderRadius.circular(radiusLarge);
  static BorderRadius borderRadiusXLarge = BorderRadius.circular(radiusXLarge);

  // ============================================
  // TYPOGRAPHY
  // ============================================

  /// Get responsive font sizes
  static double fontSizeCaption(BuildContext context) {
    return Responsive.fontSize(context, mobile: 12, tablet: 13, desktop: 14);
  }

  static double fontSizeBody(BuildContext context) {
    return Responsive.fontSize(context, mobile: 14, tablet: 15, desktop: 16);
  }

  static double fontSizeBodyLarge(BuildContext context) {
    return Responsive.fontSize(context, mobile: 16, tablet: 17, desktop: 18);
  }

  static double fontSizeSubtitle(BuildContext context) {
    return Responsive.fontSize(context, mobile: 16, tablet: 17, desktop: 18);
  }

  static double fontSizeTitle(BuildContext context) {
    return Responsive.fontSize(context, mobile: 18, tablet: 20, desktop: 22);
  }

  static double fontSizeHeadline(BuildContext context) {
    return Responsive.fontSize(context, mobile: 24, tablet: 28, desktop: 32);
  }

  static double fontSizeDisplay(BuildContext context) {
    return Responsive.fontSize(context, mobile: 32, tablet: 40, desktop: 48);
  }

  // ============================================
  // ICON SIZES
  // ============================================

  static double iconSizeSmall(BuildContext context) {
    return Responsive.iconSize(context, mobile: 16, tablet: 18, desktop: 20);
  }

  static double iconSizeMedium(BuildContext context) {
    return Responsive.iconSize(context, mobile: 20, tablet: 22, desktop: 24);
  }

  static double iconSizeLarge(BuildContext context) {
    return Responsive.iconSize(context, mobile: 24, tablet: 28, desktop: 32);
  }

  static double iconSizeXLarge(BuildContext context) {
    return Responsive.iconSize(context, mobile: 32, tablet: 40, desktop: 48);
  }

  // ============================================
  // BUTTON DIMENSIONS
  // ============================================

  static double buttonHeight(BuildContext context) {
    return Responsive.value<double>(
      context,
      mobile: 48.0,
      tablet: 52.0,
      desktop: 56.0,
    );
  }

  static double buttonHeightSmall(BuildContext context) {
    return Responsive.value<double>(
      context,
      mobile: 40.0,
      tablet: 44.0,
      desktop: 48.0,
    );
  }

  static double buttonHeightLarge(BuildContext context) {
    return Responsive.value<double>(
      context,
      mobile: 56.0,
      tablet: 60.0,
      desktop: 64.0,
    );
  }

  static EdgeInsets buttonPadding(BuildContext context) {
    return Responsive.value<EdgeInsets>(
      context,
      mobile: const EdgeInsets.symmetric(
        horizontal: spacing20,
        vertical: spacing12,
      ),
      tablet: const EdgeInsets.symmetric(
        horizontal: spacing24,
        vertical: spacing16,
      ),
      desktop: const EdgeInsets.symmetric(
        horizontal: spacing32,
        vertical: spacing16,
      ),
    );
  }

  // ============================================
  // INPUT FIELD DIMENSIONS
  // ============================================

  static double inputHeight(BuildContext context) {
    return Responsive.value<double>(
      context,
      mobile: 48.0,
      tablet: 52.0,
      desktop: 56.0,
    );
  }

  static EdgeInsets inputPadding(BuildContext context) {
    return Responsive.value<EdgeInsets>(
      context,
      mobile: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing12,
      ),
      tablet: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing14,
      ),
      desktop: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing16,
      ),
    );
  }

  // ============================================
  // CARD DIMENSIONS
  // ============================================

  static double cardElevation(BuildContext context, {bool isDark = false}) {
    if (isDark) {
      return Responsive.value<double>(
        context,
        mobile: 4.0,
        tablet: 6.0,
        desktop: 8.0,
      );
    }
    return Responsive.value<double>(
      context,
      mobile: 2.0,
      tablet: 3.0,
      desktop: 4.0,
    );
  }

  // ============================================
  // LIST ITEM DIMENSIONS
  // ============================================

  static double listItemHeight(BuildContext context) {
    return Responsive.value<double>(
      context,
      mobile: 72.0,
      tablet: 80.0,
      desktop: 88.0,
    );
  }

  static double listItemMinHeight(BuildContext context) {
    return Responsive.minTouchTarget(context);
  }

  // ============================================
  // APP BAR
  // ============================================

  static double appBarHeight(BuildContext context) {
    return Responsive.appBarHeight(context);
  }

  // ============================================
  // DIVIDER
  // ============================================

  static const double dividerThickness = 1.0;
  static const double dividerIndent = spacing16;

  // ============================================
  // GRID
  // ============================================

  static int gridCrossAxisCount(
    BuildContext context, {
    int? mobile,
    int? tablet,
    int? desktop,
  }) {
    return Responsive.getGridCrossAxisCount(
      context,
      mobile: mobile ?? 2,
      tablet: tablet ?? 3,
      desktop: desktop ?? 4,
    );
  }

  static double gridSpacing(BuildContext context) {
    return Responsive.spacing(
      context,
      mobile: spacing12,
      tablet: spacing16,
      desktop: spacing20,
    );
  }

  static double gridAspectRatio(BuildContext context) {
    return Responsive.getGridAspectRatio(context);
  }

  // ============================================
  // SHADOWS
  // ============================================

  static List<BoxShadow> cardShadow(
    BuildContext context, {
    bool isDark = false,
  }) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
        blurRadius: Responsive.value<double>(
          context,
          mobile: 8.0,
          tablet: 12.0,
          desktop: 16.0,
        ),
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> elevatedShadow(
    BuildContext context, {
    bool isDark = false,
  }) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
        blurRadius: Responsive.value<double>(
          context,
          mobile: 12.0,
          tablet: 16.0,
          desktop: 20.0,
        ),
        offset: const Offset(0, 4),
      ),
    ];
  }

  // ============================================
  // CONSTRAINTS
  // ============================================

  static BoxConstraints dialogConstraints(BuildContext context) {
    return Responsive.dialogConstraints(context);
  }

  static double maxContentWidth(BuildContext context) {
    return Responsive.maxContentWidth(context);
  }

  // ============================================
  // ANIMATION DURATIONS
  // ============================================

  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Create a standard SizedBox for vertical spacing
  static Widget verticalSpace(double height) => SizedBox(height: height);

  /// Create a standard SizedBox for horizontal spacing
  static Widget horizontalSpace(double width) => SizedBox(width: width);

  /// Create a responsive vertical spacer
  static Widget responsiveVerticalSpace(BuildContext context) {
    return SizedBox(height: itemSpacing(context));
  }

  /// Create a responsive horizontal spacer
  static Widget responsiveHorizontalSpace(BuildContext context) {
    return SizedBox(width: itemSpacing(context));
  }

  /// Create a responsive section spacer
  static Widget responsiveSectionSpace(BuildContext context) {
    return SizedBox(height: sectionSpacing(context));
  }

  /// Create a standard divider
  static Widget divider({Color? color, double? indent}) {
    return Divider(
      thickness: dividerThickness,
      indent: indent ?? dividerIndent,
      endIndent: indent ?? dividerIndent,
      color: color,
    );
  }

  /// Create a vertical divider
  static Widget verticalDivider({Color? color, double? indent}) {
    return VerticalDivider(
      thickness: dividerThickness,
      indent: indent ?? dividerIndent,
      endIndent: indent ?? dividerIndent,
      color: color,
    );
  }
}

/// Extension on BuildContext for easier access to UI constants
extension UIConstantsContext on BuildContext {
  // Quick access to common values
  EdgeInsets get screenPadding => UIConstants.screenPadding(this);
  EdgeInsets get cardPadding => UIConstants.cardPadding(this);
  EdgeInsets get listItemPadding => UIConstants.listItemPadding(this);

  double get itemSpacing => UIConstants.itemSpacing(this);
  double get sectionSpacing => UIConstants.sectionSpacing(this);

  // Font sizes
  double get fontSizeCaption => UIConstants.fontSizeCaption(this);
  double get fontSizeBody => UIConstants.fontSizeBody(this);
  double get fontSizeSubtitle => UIConstants.fontSizeSubtitle(this);
  double get fontSizeTitle => UIConstants.fontSizeTitle(this);
  double get fontSizeHeadline => UIConstants.fontSizeHeadline(this);
  double get fontSizeDisplay => UIConstants.fontSizeDisplay(this);

  // Icon sizes
  double get iconSizeSmall => UIConstants.iconSizeSmall(this);
  double get iconSizeMedium => UIConstants.iconSizeMedium(this);
  double get iconSizeLarge => UIConstants.iconSizeLarge(this);
  double get iconSizeXLarge => UIConstants.iconSizeXLarge(this);

  double get buttonHeight => UIConstants.buttonHeight(this);
}
