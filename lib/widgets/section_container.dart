import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class SectionContainer extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;

  const SectionContainer({
    super.key,
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600, height: 1.5),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: child,
        ),
      ],
    );
  }
}
