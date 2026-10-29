import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/src/core/theme/fontsize.dart';

import '../utils/responsive.dart';


class AppTextStyles {
  static TextStyle displayLarge(BuildContext context) {
    final fontSize = Responsive(context).fontSize(FontSizes.displayLarge);
    return Theme.of(context).textTheme.displayLarge?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ) ??
        GoogleFonts.dmSans(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        );
  }

  static TextStyle displayMedium(BuildContext context) {
    final fontSize = Responsive(context).fontSize(FontSizes.displayMedium);
    return Theme.of(context).textTheme.displayMedium?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        ) ??
        GoogleFonts.dmSans(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        );
  }

  static TextStyle hero(BuildContext context) {
    final fontSize = Responsive(context).fontSize(FontSizes.hero);
    return Theme.of(context).textTheme.displayLarge?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ) ??
        GoogleFonts.dmSans(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        );
  }

  static TextStyle heading1(BuildContext context) {
    final fontSize = Responsive(context).fontSize(FontSizes.heading1);
    return Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ) ??
        GoogleFonts.dmSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        );
  }

  static TextStyle heading2(BuildContext context, {Color? color}) {
    final fontSize = Responsive(context).fontSize(FontSizes.heading2);
    final themeColor = color ?? Theme.of(context).colorScheme.onSurface;
    return Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: color ?? themeColor,
        ) ??
        GoogleFonts.dmSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: color ?? themeColor,
        );
  }

  static TextStyle heading3(BuildContext context, {Color? color}) {
    final fontSize = Responsive(context).fontSize(FontSizes.heading3);
    final themeColor = color ?? Theme.of(context).colorScheme.onSurface;
    return Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          color: color ?? themeColor,
        ) ??
        GoogleFonts.dmSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          color: color ?? themeColor,
        );
  }

  static TextStyle heading4(BuildContext context, {Color? color}) {
    final fontSize = Responsive(context).fontSize(FontSizes.heading4);
    final themeColor = color ?? Theme.of(context).colorScheme.onSurface;
    return Theme.of(context).textTheme.titleLarge?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          color: color ?? themeColor,
        ) ??
        GoogleFonts.dmSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          color: color ?? themeColor,
        );
  }

  static TextStyle bodyLarge(BuildContext context) {
    final fontSize = Responsive(context).fontSize(FontSizes.bodyLarge);
    return Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.15,
          height: 1.5,
        ) ??
        GoogleFonts.dmSans(
          fontSize: fontSize,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.15,
          height: 1.5,
        );
  }

  static TextStyle bodyMedium(BuildContext context) {
    final fontSize = Responsive(context).fontSize(FontSizes.bodyMedium);
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
          height: 1.5,
        ) ??
        GoogleFonts.dmSans(
          fontSize: fontSize,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
          height: 1.5,
        );
  }

  static TextStyle bodySmall(BuildContext context) {
    final fontSize = Responsive(context).fontSize(FontSizes.bodySmall);
    return Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.4,
          height: 1.4,
        ) ??
        GoogleFonts.dmSans(
          fontSize: fontSize,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.4,
          height: 1.4,
        );
  }

  static TextStyle labelLarge(BuildContext context) {
    final fontSize = Responsive(context).fontSize(FontSizes.labelLarge);
    return Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.2,
        ) ??
        GoogleFonts.dmSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.2,
        );
  }

  static TextStyle labelMedium(BuildContext context) {
    final fontSize = Responsive(context).fontSize(FontSizes.labelMedium);
    return Theme.of(context).textTheme.labelMedium?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ) ??
        GoogleFonts.dmSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        );
  }

  static TextStyle labelSmall(BuildContext context) {
    final fontSize = Responsive(context).fontSize(FontSizes.labelSmall);
    return Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ) ??
        GoogleFonts.dmSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        );
  }

  static TextStyle caption(BuildContext context) {
    final fontSize = Responsive(context).fontSize(FontSizes.caption);
    return Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.4,
        ) ??
        GoogleFonts.dmSans(
          fontSize: fontSize,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.4,
        );
  }

  static TextStyle overline(BuildContext context) {
    final fontSize = Responsive(context).fontSize(FontSizes.overline);
    return Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
        ) ??
        GoogleFonts.dmSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
        );
  }
}
