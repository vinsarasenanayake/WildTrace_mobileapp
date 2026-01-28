// ============================================================================
// IMPORTS
// ============================================================================
import 'package:flutter/material.dart';

// ============================================================================
// WILDTRACE LOGO WIDGET
// ============================================================================
class WildTraceLogo extends StatelessWidget {
  final double height;
  final Color? iconColor;

  const WildTraceLogo({
    super.key,
    this.height = 80,
    this.iconColor,
  });

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color effectiveIconColor = iconColor ?? (isDarkMode ? Colors.white : const Color(0xFF1B4332));

    return Image.asset(
      'assets/images/logo.png',
      height: height,
      errorBuilder: (context, error, stackTrace) => 
        Icon(Icons.pets, color: effectiveIconColor, size: height * 0.75),
    );
  }
}
