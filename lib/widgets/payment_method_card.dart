import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Reusable Payment Method Display Card
class PaymentMethodCard extends StatelessWidget {
  final String type; // 'Visa' or 'Mastercard'
  final String number; // Masked number
  final String expiry;
  final VoidCallback? onDelete;

  const PaymentMethodCard({
    super.key,
    required this.type,
    required this.number,
    required this.expiry,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        )
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF1B4332), // Dark green bg for card icon
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              type == 'Visa' ? 'VISA' : 'MC',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Expires $expiry',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline_rounded, color: Colors.grey.shade400, size: 20),
            ),
        ],
      ),
    );
  }
}
