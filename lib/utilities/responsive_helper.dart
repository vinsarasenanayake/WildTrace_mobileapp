import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isLandscape(context)) {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 16);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 20);
  }
  
  static int getGridCrossAxisCount(BuildContext context, {int portrait = 2}) {
    if (isLandscape(context)) {
      return portrait + 1;
    }
    return portrait;
  }
  
  static double getSpacing(BuildContext context, {double portrait = 16}) {
    if (isLandscape(context)) {
      return portrait * 0.75;
    }
    return portrait;
  }
  
  static double getGridChildAspectRatio(BuildContext context, {double portrait = 0.7}) {
    if (isLandscape(context)) {
      return portrait * 1.1;
    }
    return portrait;
  }
}
