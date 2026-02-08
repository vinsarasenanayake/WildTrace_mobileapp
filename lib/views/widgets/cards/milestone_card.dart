import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// milestone card
class MilestoneCard extends StatelessWidget {
  // milestone data
  final String year;
  final String title;
  final String description;

  const MilestoneCard({
    super.key,
    required this.year,
    required this.title,
    required this.description,
  });

  // builds card
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // year
          Text(
            year,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF27AE60),
            ),
          ),
          const SizedBox(height: 8),
          // title
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF1B4332),
            ),
          ),
          const SizedBox(height: 12),
          // description
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isDarkMode
                  ? Colors.white.withAlpha((0.7 * 255).round())
                  : Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
