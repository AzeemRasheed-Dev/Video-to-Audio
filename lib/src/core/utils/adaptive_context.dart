import 'package:flutter/widgets.dart';
import '../theme/app_tokens.dart';

extension AdaptiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  DeviceType get deviceType => AppTokens.deviceType(screenWidth);
  EdgeInsets get pagePadding => AppTokens.screenPadding(screenWidth);
  int get categoryGridColumns => AppTokens.categoryGridColumns(screenWidth);

  bool get isTabletDevice => deviceType == DeviceType.tablet;
  bool get isSmallPhone => deviceType == DeviceType.smallPhone;
}