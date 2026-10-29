// import 'package:flutter/material.dart';

// enum DeviceType { smallPhone, phone, largePhone, tablet }

// class AppTokens {
//   static bool isDark(BuildContext context) {
//     return Theme.of(context).brightness == Brightness.dark;
//   }

//   const AppTokens._();

//   // Light theme main colors
//   static const Color primaryLight = Color(0xFF202226);
//   static const Color secondryLight = Color(0xffE1EBF4);
//   static const Color secondryDark = Color(0xff888D9C);

//   // Dark theme main colors (best contrast)
//   static const Color primaryDark = Color(
//     0xFF4F8CFF,
//   ); // Soft blue accent for highlight
//   static const Color secondryLightDark = Color(
//     0xFFB0B3B8,
//   ); // Light grey for secondary
//   static const Color secondryDarkDark = Color(0xFF23272F); // Deep background

//   // For backward compatibility, use light theme colors as default
//   static Color primaryT(bool isDark) => isDark ? primaryDark : primaryLight;
//   static Color secondrylightT(bool isDark) =>
//       isDark ? secondryLightDark : secondryLight;
//   static Color secondrydarkT(bool isDark) =>
//       isDark ? secondryDarkDark : secondryDark;
//   static const Color primary = primaryLight;
//   static const Color secondrylight = secondryLight;
//   static const Color secondrydark = secondryDark;
//   static const Color cta = Color(0xFFF0C417);
//   static const Color red = Color(0xFFFF6B6B);
//   static const Color green = Color(0xFF4CAF50);
//   static const Color lightBackground = Color(0xFFFFFFFF);
//   static const Color lightCard = Color(0xFFFFFFFF);
//   static const Color lightText = Color(0xFF1A1A1A);
//   static const Color lightMuted = Color(0xFF6B7280);
//   static const Color lightBorder = Color(0xFFE5E5E5);
//   static const Color transparent = Color(0x00000000);
//   static const Color white = Color(0xFFFFFFFF);
//   static const Color black = Color(0xFF000000);
//   // Updated dark theme backgrounds for better harmony
//   static const Color darkBackground = Color(
//     0xff181A20,
//   ); // Deep dark, less harsh
//   static const Color darkCard = Color(0xff23272F); // Matches secondryDarkDark
//   static const Color darkText = Color(0xFFF5F5F5);
//   static const Color darkMuted = Color(0xFFA1A1AA);
//   static const Color darkBorder = Color(0xFF303030);
//   static const Color darkSecondry = secondryDarkDark;

//   static const double radiusCard = 24;
//   static const double radiusInput = 8;
//   static const double radiusChip = 14;
//   static const double radiusButton = 10;

//   static const double buttonHeight = 52;
//   static const double inputHeight = 48;
//   static const double chipHeight = 32;

//   static const double s4 = 4;
//   static const double s8 = 8;
//   static const double s10 = 10;
//   static const double s12 = 12;
//   static const double s16 = 16;
//   static const double s20 = 20;
//   static const double s24 = 24;
//   static const double s28 = 28;
//   static const double s30 = 30;
//   static const double s32 = 32;
//   static const double s40 = 40;
//   static const double s60 = 60;

//   static DeviceType deviceType(double width) {
//     if (width < 360) return DeviceType.smallPhone;
//     if (width < 430) return DeviceType.phone;
//     if (width < 600) return DeviceType.largePhone;
//     return DeviceType.tablet;
//   }

//   static EdgeInsets screenPadding(double width) {
//     final type = deviceType(width);
//     switch (type) {
//       case DeviceType.smallPhone:
//       case DeviceType.phone:
//         return const EdgeInsets.symmetric(horizontal: s16);
//       case DeviceType.largePhone:
//         return const EdgeInsets.symmetric(horizontal: 20);
//       case DeviceType.tablet:
//         return const EdgeInsets.symmetric(horizontal: 28);
//     }
//   }

//   static int categoryGridColumns(double width) {
//     final type = deviceType(width);
//     switch (type) {
//       case DeviceType.smallPhone:
//       case DeviceType.phone:
//         return 2;
//       case DeviceType.largePhone:
//         return 3;
//       case DeviceType.tablet:
//         return 4;
//     }
//   }

//   static double h1(double width) {
//     return deviceType(width) == DeviceType.smallPhone ? 26 : 28;
//   }

//   static double body(double width) {
//     return deviceType(width) == DeviceType.smallPhone ? 13 : 14;
//   }
// }
import 'package:flutter/material.dart';

enum DeviceType { smallPhone, phone, largePhone, tablet }

class AppTokens {
  const AppTokens._();

  // Helper: Current context dark hai ya light
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // ============================================================================
  // 1. EXACT NEW COLOR SCHEME (From your Table)
  // ============================================================================

  // --- LIGHT MODE (Table Values) ---
  static const Color lightBackground = Color(0xFFF8F9F5); // Background
  static const Color lightCard = Color(0xFFE9EFE7); // Cards / surfaces
  static const Color lightText = Color(0xFF182721); // Primary text
  static const Color lightMuted = Color(0xFF66736C); // Secondary text
  static const Color lightAccent = Color(0xFF266653); // Accent / primary button
  static const Color lightBtnText = Color(0xFFFFFFFF); // Primary button text
  static const Color lightBorder = Color(0xFFDCE2DA); // Borders / dividers

  // --- DARK MODE (Table Values) ---
  static const Color darkBackground = Color(0xFF141C19); // Background
  static const Color darkCard = Color(0xFF202C26); // Cards / surfaces
  static const Color darkText = Color(0xFFF4F7F3); // Primary text
  static const Color darkMuted = Color(0xFFAAB8AF); // Secondary text
  static const Color darkAccent = Color(0xFF93C9AF); // Accent / primary button
  static const Color darkBtnText = Color(0xFF141C19); // Primary button text
  static const Color darkBorder = Color(0xFF35463C); // Borders / dividers

  // --- GENERAL UTILITY COLORS ---
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
  static const Color red = Color(0xFFFF5252);
  static const Color green = Color(0xFF4CAF50);
  static const Color cta = Color(0xFF266653);

  // ============================================================================
  // 2. THEME-AWARE HELPERS (Direct UI Element Mapping)
  // ============================================================================
  static Color bg(bool isDark) => isDark ? darkBackground : lightBackground;
  static Color card(bool isDark) => isDark ? darkCard : lightCard;
  static Color text(bool isDark) => isDark ? darkText : lightText;
  static Color textSecondary(bool isDark) => isDark ? darkMuted : lightMuted;
  static Color accent(bool isDark) => isDark ? darkAccent : lightAccent;
  static Color buttonText(bool isDark) => isDark ? darkBtnText : lightBtnText;
  static Color border(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color btnText(bool isDark) => isDark ? darkBtnText : lightBtnText;

  // Backward compatibility getters
  static Color primaryT(bool isDark) => accent(isDark);
  static Color secondrylightT(bool isDark) => card(isDark);
  static Color secondrydarkT(bool isDark) => border(isDark);

  static const Color primaryLight = lightAccent;
  static const Color secondryLight = lightCard;
  static const Color secondryDark = lightMuted;
  static const Color primaryDark = darkAccent;
  static const Color secondryLightDark = darkMuted;
  static const Color secondryDarkDark = darkCard;
  static const Color darkSecondry = darkCard;

  static const Color primary = lightAccent;
  static const Color secondrylight = lightCard;
  static const Color secondrydark = lightMuted;

  // ============================================================================
  // 3. RADII & COMPONENT SIZES
  // ============================================================================
  static const double radiusCard = 24;
  static const double radiusInput = 8;
  static const double radiusChip = 14;
  static const double radiusButton = 10;
  static const double radiusPill = 999;

  static const double buttonHeight = 52;
  static const double inputHeight = 48;
  static const double chipHeight = 32;

  // Spacing Tokens
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s30 = 30;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s60 = 60;

  // ============================================================================
  // 4. RESPONSIVENESS & ADAPTIVE SIZING
  // ============================================================================
  static DeviceType deviceType(double width) {
    if (width < 360) return DeviceType.smallPhone;
    if (width < 430) return DeviceType.phone;
    if (width < 600) return DeviceType.largePhone;
    return DeviceType.tablet;
  }

  static EdgeInsets screenPadding(double width) {
    final type = deviceType(width);
    switch (type) {
      case DeviceType.smallPhone:
      case DeviceType.phone:
        return const EdgeInsets.symmetric(horizontal: s16);
      case DeviceType.largePhone:
        return const EdgeInsets.symmetric(horizontal: 20);
      case DeviceType.tablet:
        return const EdgeInsets.symmetric(horizontal: 28);
    }
  }

  static int categoryGridColumns(double width) {
    final type = deviceType(width);
    switch (type) {
      case DeviceType.smallPhone:
      case DeviceType.phone:
        return 2;
      case DeviceType.largePhone:
        return 3;
      case DeviceType.tablet:
        return 4;
    }
  }

  // Typography Scale
  static double h1(double width) {
    return deviceType(width) == DeviceType.smallPhone ? 24 : 28;
  }

  static double h2(double width) {
    return deviceType(width) == DeviceType.smallPhone ? 18 : 20;
  }

  static double body(double width) {
    return deviceType(width) == DeviceType.smallPhone ? 13 : 14;
  }

  static double caption(double width) {
    return deviceType(width) == DeviceType.smallPhone ? 11 : 12;
  }
}

extension AppContextExt on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  double get screenWidth => MediaQuery.sizeOf(this).width;
}
