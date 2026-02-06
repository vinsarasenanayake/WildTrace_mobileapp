import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  // Get responsive padding based on orientation
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isLandscape(context)) {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 16);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 20);
  }
  
  // Get grid cross-axis count based on orientation
  static int getGridCrossAxisCount(BuildContext context, {int portrait = 2}) {
    if (isLandscape(context)) {
      return portrait + 1; // Add one more column in landscape
    }
    return portrait;
  }
  
  // Get responsive spacing
  static double getSpacing(BuildContext context, {double portrait = 16}) {
    if (isLandscape(context)) {
      return portrait * 0.75; // Slightly reduce spacing in landscape
    }
    return portrait;
  }
  
  // Get responsive child aspect ratio for grid items
  static double getGridChildAspectRatio(BuildContext context, {double portrait = 0.7}) {
    if (isLandscape(context)) {
      return portrait * 1.1; // Slightly wider cards in landscape
    }
    return portrait;
  }
}
