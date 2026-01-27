import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final Color? actionColor;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionPressed,
    this.actionColor = const Color(0xFF2ECC71),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.grey.shade500,
          ),
        ),
        if (actionLabel != null && onActionPressed != null)
          TextButton.icon(
            onPressed: onActionPressed,
            icon: Icon(Icons.add, size: 16, color: actionColor),
            label: Text(
              actionLabel!,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: actionColor,
              ),
            ),
          ),
      ],
    );
  }
}
