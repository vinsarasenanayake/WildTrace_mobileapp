// ============================================================================
// IMPORTS
// ============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================================
// SECTION TITLE WIDGET
// ============================================================================
class SectionTitle extends StatelessWidget {
  final String title;
  final Color? color;
  final bool showLine;
  final double fontSize;
  final double letterSpacing;
  final MainAxisAlignment mainAxisAlignment;

  const SectionTitle({
    super.key,
    required this.title,
    this.color = const Color(0xFF2ECC71),
    this.showLine = true,
    this.fontSize = 11,
    this.letterSpacing = 3.0,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        if (showLine) ...[
          Container(width: 24, height: 2, color: color),
          const SizedBox(width: 12),
        ],
        Text(
          title.toUpperCase(),
          style: GoogleFonts.inter(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
          ),
        ),
      ],
    );
  }
}
