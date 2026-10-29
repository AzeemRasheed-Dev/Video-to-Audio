// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'app_tokens.dart';

// class AppTheme {
//   const AppTheme._();

//   // ==========================================
//   // 1. DARK THEME (Main & Recommended for Media)
//   // ==========================================
//   static ThemeData dark() {
//     final scheme = ColorScheme.fromSeed(
//       brightness: Brightness.dark,
//       seedColor: AppTokens.primaryDark,
//     ).copyWith(
//       brightness: Brightness.dark,
//       primary: AppTokens.primaryDark,
//       onPrimary: Colors.white,
//       secondary: AppTokens.cta,
//       onSecondary: Colors.black,
//       error: AppTokens.red,
//       onError: Colors.white,
//       surface: AppTokens.darkCard,
//       onSurface: AppTokens.darkText,
//       outline: AppTokens.darkBorder,
//     );

//     return _baseTheme(scheme).copyWith(
//       scaffoldBackgroundColor: AppTokens.darkBackground,
//       cardColor: AppTokens.darkCard,
//       dividerColor: AppTokens.darkBorder,
      
//       // Progress Bar / Indicator Styling
//       progressIndicatorTheme: const ProgressIndicatorThemeData(
//         color: AppTokens.primaryDark,
//         linearTrackColor: AppTokens.secondryDarkDark,
//       ),

//       // Bottom Sheet
//       bottomSheetTheme: const BottomSheetThemeData(
//         backgroundColor: AppTokens.darkCard,
//         modalBackgroundColor: AppTokens.darkCard,
//         surfaceTintColor: Colors.transparent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radiusCard)),
//         ),
//       ),
//     );
//   }

//   // ==========================================
//   // 2. LIGHT THEME
//   // ==========================================
//   static ThemeData light() {
//     final scheme = ColorScheme.fromSeed(
//       brightness: Brightness.light,
//       seedColor: AppTokens.primaryLight,
//     ).copyWith(
//       brightness: Brightness.light,
//       primary: AppTokens.primaryLight,
//       onPrimary: Colors.white,
//       secondary: AppTokens.cta,
//       onSecondary: Colors.black,
//       error: AppTokens.red,
//       onError: Colors.white,
//       surface: AppTokens.lightCard,
//       onSurface: AppTokens.lightText,
//       outline: AppTokens.lightBorder,
//     );

//     return _baseTheme(scheme).copyWith(
//       scaffoldBackgroundColor: AppTokens.lightBackground,
//       cardColor: AppTokens.lightCard,
//       dividerColor: AppTokens.lightBorder,

//       progressIndicatorTheme: const ProgressIndicatorThemeData(
//         color: AppTokens.primaryLight,
//         linearTrackColor: AppTokens.secondryLight,
//       ),

//       bottomSheetTheme: const BottomSheetThemeData(
//         backgroundColor: AppTokens.lightCard,
//         modalBackgroundColor: AppTokens.lightCard,
//         surfaceTintColor: Colors.transparent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radiusCard)),
//         ),
//       ),
//     );
//   }

//   // ==========================================
//   // 3. BASE THEME (Common Component Styles)
//   // ==========================================
//   static ThemeData _baseTheme(ColorScheme colorScheme) {
//     final textTheme = GoogleFonts.dmSansTextTheme().apply(
//       bodyColor: colorScheme.onSurface,
//       displayColor: colorScheme.onSurface,
//     );

//     final inputBorder = OutlineInputBorder(
//       borderRadius: BorderRadius.circular(AppTokens.radiusInput),
//       borderSide: BorderSide(
//         color: colorScheme.outline.withValues(alpha: 0.35),
//       ),
//     );

//     return ThemeData(
//       useMaterial3: true,
//       colorScheme: colorScheme,
//       textTheme: textTheme,

//       // App Bar
//       appBarTheme: AppBarTheme(
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         surfaceTintColor: Colors.transparent,
//         foregroundColor: colorScheme.onSurface,
//         titleTextStyle: textTheme.titleLarge?.copyWith(
//           color: colorScheme.onSurface,
//           fontSize: 20,
//           fontWeight: FontWeight.w700,
//         ),
//       ),

//       // Cards (Clean, sleek, border outline)
//       cardTheme: CardThemeData(
//         color: colorScheme.surface,
//         elevation: 0,
//         margin: EdgeInsets.zero,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppTokens.radiusCard),
//           side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5), width: 1),
//         ),
//       ),

//       // Filled Button (Convert / Primary Action)
//       filledButtonTheme: FilledButtonThemeData(
//         style: FilledButton.styleFrom(
//           backgroundColor: colorScheme.primary,
//           foregroundColor: colorScheme.onPrimary,
//           minimumSize: const Size(double.infinity, AppTokens.buttonHeight),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(AppTokens.radiusButton),
//           ),
//           textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//           elevation: 0,
//         ),
//       ),

//       // Outlined Button (Pick / Save secondary action)
//       outlinedButtonTheme: OutlinedButtonThemeData(
//         style: OutlinedButton.styleFrom(
//           foregroundColor: colorScheme.onSurface,
//           minimumSize: const Size(double.infinity, AppTokens.buttonHeight),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(AppTokens.radiusButton),
//           ),
//           side: BorderSide(color: colorScheme.outline, width: 1.2),
//           textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
//         ),
//       ),

//       // Inputs (Agar user file ka custom naam rakhna chahay)
//       inputDecorationTheme: InputDecorationTheme(
//         isDense: true,
//         filled: true,
//         fillColor: colorScheme.surface,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: AppTokens.s16,
//           vertical: AppTokens.s12,
//         ),
//         border: inputBorder,
//         enabledBorder: inputBorder,
//         focusedBorder: inputBorder.copyWith(
//           borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
//         ),
//       ),
//     );
//   }
// }import 'package:flutter/material.dart';



import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_tokens.dart';

class AppTheme {
  const AppTheme._();

  // ============================================================================
  // 1. DARK THEME (Table Colors: #141C19, #202C26, #F4F7F3, #93C9AF, etc.)
  // ============================================================================
  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      // Accent / Primary button (#93C9AF)
      primary: AppTokens.darkAccent,
      // Primary button text (#141C19)
      onPrimary: AppTokens.darkBtnText,
      // Cards / surfaces (#202C26)
      surface: AppTokens.darkCard,
      // Primary text (#F4F7F3)
      onSurface: AppTokens.darkText,
      // Secondary text (#AAB8AF)
      onSurfaceVariant: AppTokens.darkMuted,
      // Borders / dividers (#35463C)
      outline: AppTokens.darkBorder,
      outlineVariant: AppTokens.darkBorder,
      // Errors
      error: AppTokens.red,
      onError: Colors.white,
      secondary: AppTokens.darkAccent,
      onSecondary: AppTokens.darkBtnText,
    );

    return _baseTheme(scheme).copyWith(
      scaffoldBackgroundColor: AppTokens.darkBackground, // #141C19
      cardColor: AppTokens.darkCard,                     // #202C26
      dividerColor: AppTokens.darkBorder,                // #35463C

      // Progress Bar / Indicator Styling (Screenshot ke mutabiq)
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppTokens.darkAccent,           // #93C9AF
        linearTrackColor: AppTokens.darkCard,  // #202C26
        linearMinHeight: 6,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppTokens.darkCard,
        modalBackgroundColor: AppTokens.darkCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radiusCard)),
        ),
      ),
    );
  }

  // ============================================================================
  // 2. LIGHT THEME (Table Colors: #F8F9F5, #E9EFE7, #182721, #266653, etc.)
  // ============================================================================
  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      // Accent / Primary button (#266653)
      primary: AppTokens.lightAccent,
      // Primary button text (#FFFFFF)
      onPrimary: AppTokens.lightBtnText,
      // Cards / surfaces (#E9EFE7)
      surface: AppTokens.lightCard,
      // Primary text (#182721)
      onSurface: AppTokens.lightText,
      // Secondary text (#66736C)
      onSurfaceVariant: AppTokens.lightMuted,
      // Borders / dividers (#DCE2DA)
      outline: AppTokens.lightBorder,
      outlineVariant: AppTokens.lightBorder,
      // Errors
      error: AppTokens.red,
      onError: Colors.white,
      secondary: AppTokens.lightAccent,
      onSecondary: AppTokens.lightBtnText,
    );

    return _baseTheme(scheme).copyWith(
      scaffoldBackgroundColor: AppTokens.lightBackground, // #F8F9F5
      cardColor: AppTokens.lightCard,                     // #E9EFE7
      dividerColor: AppTokens.lightBorder,                // #DCE2DA

      // Progress Bar / Indicator Styling (Screenshot ke mutabiq)
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppTokens.lightAccent,          // #266653
        linearTrackColor: AppTokens.lightCard, // #E9EFE7
        linearMinHeight: 6,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppTokens.lightCard,
        modalBackgroundColor: AppTokens.lightCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radiusCard)),
        ),
      ),
    );
  }

  // ============================================================================
  // 3. BASE THEME (Common Styling & Component Defaults)
  // ============================================================================
  static ThemeData _baseTheme(ColorScheme colorScheme) {
    final textTheme = GoogleFonts.dmSansTextTheme().apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTokens.radiusInput),
      borderSide: BorderSide(
        color: colorScheme.outline,
        width: 1,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Cards Theme (Figma jaisa clean border aur surface)
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
          side: BorderSide(color: colorScheme.outline, width: 1),
        ),
      ),

      // Filled Button Theme (Primary Accent Button)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,       // Light: #266653, Dark: #93C9AF
          foregroundColor: colorScheme.onPrimary,     // Light: #FFFFFF, Dark: #141C19
          minimumSize: const Size(double.infinity, AppTokens.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusButton),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          elevation: 0,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(double.infinity, AppTokens.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusButton),
          ),
          side: BorderSide(color: colorScheme.outline, width: 1.2),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.s16,
          vertical: AppTokens.s12,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }
}