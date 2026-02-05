import 'package:flutter/material.dart';
import '../../../main_wrapper.dart';

// brand logo widget
class WildTraceLogo extends StatelessWidget {
  final double height;
  final Color? iconColor;
  final VoidCallback? onTap;

  const WildTraceLogo({
    super.key,
    this.height = 80,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color effectiveIconColor = iconColor ?? (isDarkMode ? Colors.white : const Color(0xFF1B4332));

    return GestureDetector(
      onTap: onTap ?? () {
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (context) => MainWrapper()), 
          (route) => false
        );
      },
      child: Image.asset(
        'assets/images/logo.png',
        height: height,
        errorBuilder: (context, error, stackTrace) => 
          Icon(Icons.pets, color: effectiveIconColor, size: height * 0.75),
      ),
    );
  }
}
