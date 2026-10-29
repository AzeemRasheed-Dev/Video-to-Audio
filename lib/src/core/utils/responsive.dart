
import 'package:flutter/material.dart';

class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

enum ScreenSize {
  small, // Mobile phones
  medium, // Tablets
  large, // Desktop
}

class Responsive {
  final BuildContext context;
  final MediaQueryData mediaQuery;

  Responsive(this.context) : mediaQuery = MediaQuery.of(context);

  double get width => mediaQuery.size.width;
  double get height => mediaQuery.size.height;

  ScreenSize get screenSize {
    if (width < Breakpoints.mobile) {
      return ScreenSize.small;
    } else if (width < Breakpoints.tablet) {
      return ScreenSize.medium;
    } else {
      return ScreenSize.large;
    }
  }

  bool get isMobile => screenSize == ScreenSize.small;
  bool get isTablet => screenSize == ScreenSize.medium;
  bool get isDesktop => screenSize == ScreenSize.large;

  T value<T>({required T mobile, T? tablet, T? desktop}) {
    switch (screenSize) {
      case ScreenSize.small:
        return mobile;
      case ScreenSize.medium:
        return tablet ?? mobile;
      case ScreenSize.large:
        return desktop ?? tablet ?? mobile;
    }
  }

  double widthPercent(double percent) => width * (percent / 100);
  double heightPercent(double percent) => height * (percent / 100);

  double fontSize(double baseSize) {
    return value<double>(
      mobile: baseSize,
      tablet: baseSize * 1.1,
      desktop: baseSize * 1.2,
    );
  }

  double spacing(double baseSpacing) {
    return value<double>(
      mobile: baseSpacing,
      tablet: baseSpacing * 1.2,
      desktop: baseSpacing * 1.5,
    );
  }
}

extension ResponsiveExtension on BuildContext {
  Responsive get responsive => Responsive(this);
}