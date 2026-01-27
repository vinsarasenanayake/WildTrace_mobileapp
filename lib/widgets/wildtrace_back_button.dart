import 'package:flutter/material.dart';

class WildTraceBackButton extends StatelessWidget {
  final Color? iconColor;
  final VoidCallback? onTap;

  const WildTraceBackButton({
    super.key,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color effectiveIconColor = iconColor ?? (isDarkMode ? Colors.white : const Color(0xFF1B4332));

    return GestureDetector(
      onTap: onTap ?? () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.transparent,
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: effectiveIconColor,
          size: 20,
        ),
      ),
    );
  }
}
