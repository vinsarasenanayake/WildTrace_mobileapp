import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Check if the device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  // Get padding based on orientation
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isLandscape(context)) {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 16);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 20);
  }
  
  // Get grid columns based on orientation
  static int getGridCrossAxisCount(BuildContext context, {int portrait = 2}) {
    if (isLandscape(context)) {
      return portrait + 1;
    }
    return portrait;
  }
  
  // Get spacing based on orientation
  static double getSpacing(BuildContext context, {double portrait = 16}) {
    if (isLandscape(context)) {
      return portrait * 0.75;
    }
    return portrait;
  }
  
  // Get grid aspect ratio based on orientation
  static double getGridChildAspectRatio(BuildContext context, {double portrait = 0.7}) {
    if (isLandscape(context)) {
      return portrait * 1.1;
    }
    return portrait;
  }
}
