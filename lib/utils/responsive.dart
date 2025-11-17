import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Responsive utility class for building adaptive UIs across platforms
class Responsive {
  /// Device breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1600;

  /// Check if current device is mobile
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  /// Check if current device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Check if current device is desktop
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  /// Check if current device is large desktop
  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= largeDesktopBreakpoint;

  /// Check platform type
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  static bool get isWeb => kIsWeb;

  /// Check if running on mobile platform (Android/iOS)
  static bool get isMobilePlatform => isAndroid || isIOS;

  /// Check if running on desktop platform (Windows/Mac/Linux)
  static bool get isDesktopPlatform => isWindows || isMacOS || isLinux;

  /// Get device type as string
  static String getDeviceType(BuildContext context) {
    if (isMobile(context)) return 'mobile';
    if (isTablet(context)) return 'tablet';
    if (isLargeDesktop(context)) return 'large-desktop';
    return 'desktop';
  }

  /// Adaptive value based on screen size
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    if (isLargeDesktop(context) && largeDesktop != null) return largeDesktop;
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  /// Get responsive font size
  static double fontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return value(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.1,
      desktop: desktop ?? mobile * 1.2,
    );
  }

  /// Get responsive padding
  static EdgeInsets padding(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final padding = value(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.5,
      desktop: desktop ?? mobile * 2,
    );
    return EdgeInsets.all(padding);
  }

  /// Get responsive horizontal padding
  static EdgeInsets horizontalPadding(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final padding = value(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.5,
      desktop: desktop ?? mobile * 2,
    );
    return EdgeInsets.symmetric(horizontal: padding);
  }

  /// Get responsive vertical padding
  static EdgeInsets verticalPadding(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final padding = value(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.5,
      desktop: desktop ?? mobile * 2,
    );
    return EdgeInsets.symmetric(vertical: padding);
  }

  /// Get responsive spacing
  static double spacing(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return value(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.5,
      desktop: desktop ?? mobile * 2,
    );
  }

  /// Get responsive icon size
  static double iconSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return value(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.2,
      desktop: desktop ?? mobile * 1.4,
    );
  }

  /// Get responsive border radius
  static double borderRadius(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return value(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile,
      desktop: desktop ?? mobile,
    );
  }

  /// Get screen width
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Get screen height
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Get percentage of screen width
  static double widthPercent(BuildContext context, double percent) =>
      width(context) * (percent / 100);

  /// Get percentage of screen height
  static double heightPercent(BuildContext context, double percent) =>
      height(context) * (percent / 100);

  /// Get safe area padding
  static EdgeInsets safeArea(BuildContext context) =>
      MediaQuery.of(context).padding;

  /// Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) =>
      MediaQuery.of(context).viewInsets.bottom > 0;

  /// Get orientation
  static Orientation orientation(BuildContext context) =>
      MediaQuery.of(context).orientation;

  /// Check if landscape
  static bool isLandscape(BuildContext context) =>
      orientation(context) == Orientation.landscape;

  /// Check if portrait
  static bool isPortrait(BuildContext context) =>
      orientation(context) == Orientation.portrait;

  /// Get adaptive column count for grids
  static int gridColumns(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 3;
    if (isLargeDesktop(context)) return 6;
    return 4; // desktop
  }

  /// Get adaptive max width for content
  static double maxContentWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    if (isTablet(context)) return 800;
    if (isLargeDesktop(context)) return 1400;
    return 1200; // desktop
  }

  /// Build responsive widget
  static Widget builder({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
    Widget? largeDesktop,
  }) {
    if (isLargeDesktop(context) && largeDesktop != null) return largeDesktop;
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  /// Get responsive dialog width
  static double dialogWidth(BuildContext context) {
    return value(
      context,
      mobile: width(context) * 0.9,
      tablet: 600,
      desktop: 700,
    );
  }

  /// Get responsive card elevation
  static double cardElevation(BuildContext context) {
    return value(context, mobile: 2.0, tablet: 3.0, desktop: 4.0);
  }

  /// Get responsive app bar height
  static double appBarHeight(BuildContext context) {
    return value(context, mobile: 56.0, tablet: 64.0, desktop: 72.0);
  }

  /// Get responsive sidebar width
  static double sidebarWidth(BuildContext context) {
    return value(
      context,
      mobile: width(context) * 0.75, // Drawer on mobile
      tablet: 280,
      desktop: 320,
    );
  }

  /// Check if should show sidebar as drawer (mobile)
  static bool shouldUseDrawer(BuildContext context) => isMobile(context);

  /// Check if should show sidebar as permanent (desktop)
  static bool shouldUsePermanentSidebar(BuildContext context) =>
      isDesktop(context);

  /// Get text scale factor
  static double textScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }

  /// Get platform-specific padding for safe areas
  static EdgeInsets platformSafeArea(BuildContext context) {
    final safeArea = MediaQuery.of(context).padding;

    if (isMobilePlatform) {
      // Mobile needs more safe area handling
      return EdgeInsets.only(
        top: safeArea.top > 0 ? safeArea.top : 0,
        bottom: safeArea.bottom > 0 ? safeArea.bottom : 0,
        left: safeArea.left,
        right: safeArea.right,
      );
    }

    // Desktop doesn't need safe area padding
    return EdgeInsets.zero;
  }

  /// Get adaptive list item height
  static double listItemHeight(BuildContext context) {
    return value(context, mobile: 60.0, tablet: 72.0, desktop: 80.0);
  }

  /// Get adaptive button height
  static double buttonHeight(BuildContext context) {
    return value(context, mobile: 48.0, tablet: 52.0, desktop: 56.0);
  }

  /// Get adaptive button width
  static double buttonWidth(BuildContext context, {double multiplier = 1.0}) {
    return value(
      context,
      mobile: 120.0 * multiplier,
      tablet: 140.0 * multiplier,
      desktop: 160.0 * multiplier,
    );
  }

  /// Get adaptive dialog constraints
  static BoxConstraints dialogConstraints(BuildContext context) {
    return BoxConstraints(
      maxWidth: dialogWidth(context),
      maxHeight: height(context) * 0.9,
    );
  }

  /// Get adaptive card padding
  static EdgeInsets cardPadding(BuildContext context) {
    return padding(context, mobile: 16, tablet: 20, desktop: 24);
  }

  /// Get adaptive card margin
  static EdgeInsets cardMargin(BuildContext context) {
    return padding(context, mobile: 8, tablet: 12, desktop: 16);
  }

  /// Format for touch targets on mobile
  static double minTouchTarget(BuildContext context) {
    return isMobilePlatform ? 48.0 : 40.0;
  }

  /// Get adaptive layout direction
  static Axis layoutAxis(BuildContext context) {
    return isMobile(context) ? Axis.vertical : Axis.horizontal;
  }

  /// Wrap content with responsive constraints
  static Widget constrainedContent({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? maxContentWidth(context),
        ),
        child: child,
      ),
    );
  }

  /// Get adaptive CrossAxisCount for GridView
  static int getGridCrossAxisCount(
    BuildContext context, {
    int? mobile,
    int? tablet,
    int? desktop,
  }) {
    return value(
      context,
      mobile: mobile ?? 2,
      tablet: tablet ?? 3,
      desktop: desktop ?? 4,
    );
  }

  /// Get adaptive childAspectRatio for GridView
  static double getGridAspectRatio(BuildContext context) {
    return value(context, mobile: 0.75, tablet: 0.85, desktop: 1.0);
  }
}

/// Extension on BuildContext for easier access
extension ResponsiveContext on BuildContext {
  Responsive get responsive => Responsive();

  bool get isMobile => Responsive.isMobile(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isDesktop => Responsive.isDesktop(this);
  bool get isLargeDesktop => Responsive.isLargeDesktop(this);

  double get screenWidth => Responsive.width(this);
  double get screenHeight => Responsive.height(this);

  bool get isLandscape => Responsive.isLandscape(this);
  bool get isPortrait => Responsive.isPortrait(this);

  bool get isAndroid => Responsive.isAndroid;
  bool get isIOS => Responsive.isIOS;
  bool get isWindows => Responsive.isWindows;
  bool get isMobilePlatform => Responsive.isMobilePlatform;
  bool get isDesktopPlatform => Responsive.isDesktopPlatform;
}
